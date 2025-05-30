import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/supabase_service.dart';
import '../../services/openai_service.dart';
import '../../services/whisper_service.dart';
import '../../services/web_audio_recorder.dart';
import '../../core/config/theme_config.dart';

class AIJournalScreen extends StatefulWidget {
  const AIJournalScreen({super.key});

  @override
  State<AIJournalScreen> createState() => _AIJournalScreenState();
}

class _AIJournalScreenState extends State<AIJournalScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final SupabaseService _supabaseService = SupabaseService();
  final OpenAIService _openAIService = OpenAIService();
  final WhisperService _whisperService = WhisperService();
  final WebAudioRecorder _audioRecorder = WebAudioRecorder();
  
  List<Map<String, String>> _conversation = [];
  bool _isRecording = false;
  bool _isTranscribing = false;
  bool _isGenerating = false;
  bool _isSaving = false;
  String _status = '';
  String? _errorMessage;
  int _questionCount = 0;
  final int _maxQuestions = 5;

  @override
  void initState() {
    super.initState();
    _whisperService.initialize();
    _initializeRecorder();
    _startConversation();
  }

  Future<void> _initializeRecorder() async {
    try {
      await _audioRecorder.requestPermissions();
    } catch (e) {
      debugPrint('Error initializing recorder: $e');
    }
  }

  void _startConversation() {
    setState(() {
      _conversation = [
        {
          'role': 'ai',
          'message': "Hello! I'm here to listen and understand. How are you feeling right now?"
        }
      ];
      _questionCount = 1;
    });
  }

  Future<void> _startRecording() async {
    try {
      setState(() {
        _isRecording = true;
        _status = 'Recording... Speak now';
        _errorMessage = null;
      });

      await _audioRecorder.startRecording();
    } catch (e) {
      debugPrint('Error starting recording: $e');
      setState(() {
        _isRecording = false;
        _status = 'Recording failed';
        _errorMessage = 'Could not start recording: $e';
      });
    }
  }

  Future<void> _stopRecording() async {
    if (!_isRecording) return;

    try {
      setState(() {
        _isRecording = false;
        _isTranscribing = true;
        _status = 'Processing audio...';
      });

      // Get the recorded audio data
      final audioData = await _audioRecorder.stopRecording();
      
      // Transcribe with Whisper
      if (_whisperService.isAvailable) {
        try {
          final transcript = await _whisperService.transcribeAudio(audioData);
          setState(() {
            _textController.text = transcript;
            _status = 'Transcription complete!';
          });
        } catch (e) {
          debugPrint('Whisper transcription error: $e');
          setState(() {
            _errorMessage = 'Transcription failed. Please try typing instead.';
          });
        }
      } else {
        // Fallback to simple text
        setState(() {
          _textController.text = "I'm feeling reflective today.";
          _status = 'Using sample text (Whisper unavailable)';
        });
      }
    } catch (e) {
      debugPrint('Error stopping recording: $e');
      setState(() {
        _status = 'Recording failed';
        _errorMessage = 'Failed to process recording: $e';
      });
    } finally {
      setState(() {
        _isTranscribing = false;
      });
    }
  }

  Future<void> _sendMessage() async {
    final message = _textController.text.trim();
    if (message.isEmpty) return;

    setState(() {
      _conversation.add({'role': 'user', 'message': message});
      _textController.clear();
      _isGenerating = true;
      _errorMessage = null;
    });

    _scrollToBottom();

    try {
      String aiResponse;
      
      if (_questionCount >= _maxQuestions) {
        // Final summary message
        aiResponse = "Thank you for sharing. What feels different for you now compared to when we started talking?";
      } else {
        // Generate response with timeout
        aiResponse = await _getResponseWithTimeout(message);
        _questionCount++;
      }

      setState(() {
        _conversation.add({'role': 'ai', 'message': aiResponse});
      });

    } catch (e) {
      debugPrint('Error generating AI response: $e');
      
      // Provide simple fallback response
      final fallbackResponse = "I appreciate you sharing that. Could you tell me more about how that makes you feel?";

      setState(() {
        _conversation.add({
          'role': 'ai', 
          'message': fallbackResponse
        });
        _questionCount++;
      });

    } finally {
      setState(() {
        _isGenerating = false;
      });
      _scrollToBottom();
    }
  }

  Future<String> _getResponseWithTimeout(String message) async {
    try {
      // Set a timeout to prevent hanging
      return await Future.any([
        _openAIService.generateReflectiveQuestion(
          message,
          conversationContext: _conversation
              .map((msg) => "${msg['role']}: ${msg['message']}")
              .join('\n'),
        ),
        Future.delayed(const Duration(seconds: 8), () {
          throw TimeoutException('Response generation took too long');
        }),
      ]);
    } catch (e) {
      debugPrint('Response generation error: $e');
      
      // Simple fallback responses based on conversation stage
      final fallbackResponses = [
        "That's interesting. How does that make you feel?",
        "I see. What thoughts come up when you reflect on that?",
        "Thank you for sharing. What do you think is behind those feelings?",
        "I understand. How might you approach this situation differently?",
        "That makes sense. What would be helpful for you right now?"
      ];
      
      return fallbackResponses[_questionCount % fallbackResponses.length];
    }
  }

  Future<void> _saveConversation() async {
    if (_conversation.length < 2) {
      setState(() {
        _errorMessage = 'No conversation to save';
      });
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userId = authProvider.currentUser?.id;
    
    if (userId == null) {
      setState(() {
        _errorMessage = 'User not authenticated';
      });
      return;
    }

    setState(() {
      _isSaving = true;
      _status = 'Saving...';
    });

    try {
      // Extract user inputs and AI questions
      final userInputs = _conversation
          .where((msg) => msg['role'] == 'user')
          .map((msg) => msg['message']!)
          .toList();
      
      final aiQuestions = _conversation
          .where((msg) => msg['role'] == 'ai')
          .map((msg) => msg['message']!)
          .toList();

      // Simplified conversation text
      final fullConversation = _conversation
          .map((msg) => "${msg['role'] == 'user' ? 'You' : 'AI'}: ${msg['message']}")
          .join('\n\n');

      await _supabaseService.saveAIJournalEntry(
        userId: userId,
        inputText: fullConversation,
        reflectiveQuestions: aiQuestions,
        offlineMode: false,
      );

      setState(() {
        _status = 'Saved successfully!';
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Conversation saved!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );

      // Reset conversation after save
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          _startConversation();
          setState(() {
            _status = '';
          });
        }
      });

    } catch (e) {
      debugPrint('Error saving conversation: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Save failed: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Journal'),
        backgroundColor: ThemeConfig.primaryPurple,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _startConversation,
            tooltip: 'Start new conversation',
          ),
        ],
      ),
      body: Column(
        children: [
          // Error message
          if (_errorMessage != null)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                border: Border.all(color: Colors.red.shade200),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.error_outline, color: Colors.red.shade600),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _errorMessage!,
                      style: TextStyle(color: Colors.red.shade700),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => setState(() => _errorMessage = null),
                    color: Colors.red.shade600,
                    iconSize: 18,
                  ),
                ],
              ),
            ),

          // Conversation
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _conversation.length + (_isGenerating ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _conversation.length && _isGenerating) {
                  return _buildTypingIndicator();
                }

                final message = _conversation[index];
                final isUser = message['role'] == 'user';

                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (!isUser) ...[
                        CircleAvatar(
                          backgroundColor: ThemeConfig.primaryPurple,
                          child: const Icon(Icons.psychology, color: Colors.white),
                        ),
                        const SizedBox(width: 12),
                      ],
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isUser 
                                ? ThemeConfig.primaryPurple
                                : Colors.grey[100],
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            message['message']!,
                            style: TextStyle(
                              color: isUser ? Colors.white : Colors.black87,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                      if (isUser) ...[
                        const SizedBox(width: 12),
                        CircleAvatar(
                          backgroundColor: Colors.grey[300],
                          child: const Icon(Icons.person, color: Colors.grey),
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
          ),

          // Status
          if (_status.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                _status,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),

          // Input area
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                // Voice input button
                IconButton(
                  onPressed: _isRecording ? _stopRecording : _startRecording,
                  icon: _isRecording || _isTranscribing
                      ? SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              _isRecording ? Colors.red : ThemeConfig.primaryPurple,
                            ),
                          ),
                        )
                      : Icon(
                          Icons.mic,
                          color: ThemeConfig.primaryPurple,
                        ),
                  tooltip: _isRecording ? 'Stop recording' : 'Voice input',
                ),
                
                // Text input
                Expanded(
                  child: TextField(
                    controller: _textController,
                    decoration: const InputDecoration(
                      hintText: 'Type your message...',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    maxLines: null,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                
                const SizedBox(width: 8),
                
                // Send button
                IconButton(
                  onPressed: _isGenerating ? null : _sendMessage,
                  icon: _isGenerating 
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.send),
                  color: ThemeConfig.primaryPurple,
                  tooltip: 'Send message',
                ),
                
                // Save button
                if (_conversation.length > 2)
                  IconButton(
                    onPressed: _isSaving ? null : _saveConversation,
                    icon: _isSaving 
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.save),
                    color: Colors.green,
                    tooltip: 'Save conversation',
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: ThemeConfig.primaryPurple,
            child: const Icon(Icons.psychology, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'AI is thinking',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        ThemeConfig.primaryPurple,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    _audioRecorder.dispose();
    super.dispose();
  }
}
