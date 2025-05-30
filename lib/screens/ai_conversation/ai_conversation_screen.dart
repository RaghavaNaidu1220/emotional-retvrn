import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/config/theme_config.dart';
import '../../services/ai_conversation_service.dart';
import '../../services/audio_service.dart';
import '../../providers/journal_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/conversation_model.dart';
import '../../models/journal_model.dart';
import '../analysis/conversation_analysis_screen.dart';

class AIConversationScreen extends StatefulWidget {
  final bool isVoiceMode;
  
  const AIConversationScreen({
    Key? key,
    this.isVoiceMode = false,
  }) : super(key: key);

  @override
  State<AIConversationScreen> createState() => _AIConversationScreenState();
}

class _AIConversationScreenState extends State<AIConversationScreen> with TickerProviderStateMixin {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final AIConversationService _aiService = AIConversationService();
  final AudioService _audioService = AudioService();
  
  List<ConversationMessage> _messages = [];
  bool _isRecording = false;
  bool _isProcessing = false;
  bool _isSaving = false;
  String _transcribedText = '';
  late AnimationController _typingController;
  bool _hasPermission = false;
  Timer? _transcriptUpdateTimer;
  bool _ttsEnabled = true;
  
  @override
  void initState() {
    super.initState();
    _typingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
    
    // Start with AI greeting
    _addAIMessage("Hello! I'm here to listen and understand. How are you feeling right now?");
    
    // Request microphone permission
    _requestMicrophonePermission();
    
    // Auto-start voice mode if selected
    if (widget.isVoiceMode) {
      Future.delayed(const Duration(milliseconds: 1000), () {
        if (_hasPermission) {
          _startVoiceRecording();
        }
      });
    }
  }
  
  Future<void> _requestMicrophonePermission() async {
    try {
      final hasPermission = await _audioService.requestPermissions();
      setState(() {
        _hasPermission = hasPermission;
      });
      
      if (!hasPermission) {
        _showErrorSnackBar('Microphone permission is required for voice input. Please allow microphone access and refresh the page.');
      } else {
        debugPrint('Microphone permission granted successfully');
      }
    } catch (e) {
      debugPrint('Error requesting microphone permission: $e');
      _showErrorSnackBar('Could not access microphone. Please check your browser settings.');
    }
  }
  
  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    _typingController.dispose();
    _transcriptUpdateTimer?.cancel();
    _audioService.stopSpeaking(); // Stop any ongoing speech
    _audioService.dispose();
    super.dispose();
  }
  
  void _addUserMessage(String text) {
    if (text.trim().isEmpty) return;
    
    setState(() {
      _messages.add(ConversationMessage(
        text: text,
        isUser: true,
        timestamp: DateTime.now(),
      ));
      _isProcessing = true;
    });
    
    _scrollToBottom();
    _getAIResponse(text);
  }
  
  void _addAIMessage(String text) {
    setState(() {
      _messages.add(ConversationMessage(
        text: text,
        isUser: false,
        timestamp: DateTime.now(),
      ));
      _isProcessing = false;
    });
    
    _scrollToBottom();
    
    // Speak the AI response if TTS is enabled
    if (_ttsEnabled && text.isNotEmpty) {
      _audioService.speak(text);
    }
  }
  
  Future<void> _getAIResponse(String userMessage) async {
    try {
      final response = await _aiService.getResponse(userMessage, _messages);
      _addAIMessage(response);
    } catch (e) {
      _addAIMessage("I'm having trouble connecting. Could you try again?");
      debugPrint('Error getting AI response: $e');
    }
  }
  
  Future<void> _startVoiceRecording() async {
    if (_isRecording || !_hasPermission) {
      if (!_hasPermission) {
        _showErrorSnackBar('Please allow microphone access to use voice input');
        await _requestMicrophonePermission();
      }
      return;
    }
    
    // Check if speech recognition is supported
    if (!_audioService.isSpeechRecognitionSupported()) {
      _showErrorSnackBar('Speech recognition is not supported in this browser. Please use Chrome or Edge.');
      return;
    }
    
    // Stop any ongoing TTS when user starts speaking
    await _audioService.stopSpeaking();
    
    setState(() {
      _isRecording = true;
      _transcribedText = '';
    });
    
    try {
      await _audioService.startRecording();
      
      // Start timer to update transcript in real-time
      _transcriptUpdateTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
        if (_isRecording) {
          final currentTranscript = _audioService.getCurrentTranscript();
          if (currentTranscript != _transcribedText) {
            setState(() {
              _transcribedText = currentTranscript;
            });
          }
        } else {
          timer.cancel();
        }
      });
      
    } catch (e) {
      setState(() {
        _isRecording = false;
      });
      _showErrorSnackBar('Could not start recording: $e');
    }
  }
  
  Future<void> _stopVoiceRecording() async {
    if (!_isRecording) return;
    
    _transcriptUpdateTimer?.cancel();
    
    setState(() {
      _isRecording = false;
      _isProcessing = true;
    });
    
    try {
      await _audioService.stopRecording();
      
      // Wait for transcription to complete
      await Future.delayed(const Duration(milliseconds: 1000));
      
      final transcribed = _audioService.transcribedText ?? '';
      _transcribedText = transcribed.trim();
      
      debugPrint('Final transcribed text: "$_transcribedText"');
      
      if (_transcribedText.isNotEmpty) {
        _addUserMessage(_transcribedText);
      } else {
        setState(() {
          _isProcessing = false;
        });
        
        // Show debug information
        final debugInfo = _audioService.debugInfo;
        _showDebugDialog(debugInfo);
      }
    } catch (e) {
      setState(() {
        _isProcessing = false;
      });
      _showErrorSnackBar('Error processing audio: $e');
    }
  }

  void _showDebugDialog(String debugInfo) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Speech Recognition Debug'),
        content: SingleChildScrollView(
          child: Text(
            debugInfo.isEmpty ? 'No debug information available' : debugInfo,
            style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _startVoiceRecording(); // Try again
            },
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }
  
  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }
  
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: ThemeConfig.primaryRed,
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'Dismiss',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }
  
  Future<void> _saveConversation() async {
    if (_messages.length <= 1) {
      _showErrorSnackBar('No conversation to save');
      return;
    }
    
    setState(() {
      _isSaving = true;
    });
    
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final journalProvider = Provider.of<JournalProvider>(context, listen: false);
      
      if (authProvider.currentUser == null) {
        throw Exception('User not logged in');
      }
      
      // Combine all messages into a single journal entry
      final userMessages = _messages.where((m) => m.isUser).map((m) => m.text).join('\n\n');
      final aiMessages = _messages.where((m) => !m.isUser).map((m) => m.text).join('\n\n');
      
      final content = 'My thoughts:\n$userMessages\n\nAI responses:\n$aiMessages';
      
      final journal = JournalModel(
        userId: authProvider.currentUser!.id,
        content: content,
        createdAt: DateTime.now(),
      );
      
      await journalProvider.createJournal(journal);
      
      // Get conversation analysis
      final analysis = await _aiService.analyzeEmotions(userMessages);
      
      setState(() {
        _isSaving = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Conversation saved to journal'),
          backgroundColor: ThemeConfig.primaryGreen,
        ),
      );
      
      // Show analysis screen
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => ConversationAnalysisScreen(
            messages: _messages,
            analysis: analysis,
            journal: journal,
          ),
        ),
      );
      
    } catch (e) {
      setState(() {
        _isSaving = false;
      });
      _showErrorSnackBar('Error saving conversation: $e');
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          widget.isVoiceMode ? 'Voice Journal' : 'AI Journal',
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                _messages = [_messages.first]; // Keep only the greeting
                _aiService.resetConversation(); // Reset AI context
              });
            },
            icon: const Icon(Icons.refresh, color: Colors.black87),
            tooltip: 'Reset conversation',
          ),
          if (_messages.length > 1)
            IconButton(
              onPressed: _isSaving ? null : _saveConversation,
              icon: _isSaving 
                ? const SizedBox(
                    width: 20, 
                    height: 20, 
                    child: CircularProgressIndicator(strokeWidth: 2)
                  )
                : const Icon(Icons.save_outlined, color: Colors.black87),
              tooltip: 'Save conversation',
            ),
          IconButton(
            onPressed: () {
              setState(() {
                _ttsEnabled = !_ttsEnabled;
                _audioService.setTTSEnabled(_ttsEnabled);
              });
            },
            icon: Icon(
              _ttsEnabled ? Icons.volume_up : Icons.volume_off,
              color: _ttsEnabled ? ThemeConfig.primaryBlue : Colors.grey,
            ),
            tooltip: _ttsEnabled ? 'Disable text-to-speech' : 'Enable text-to-speech',
          ),
        ],
      ),
      body: Column(
        children: [
          // Permission warning
          if (!_hasPermission)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: ThemeConfig.primaryRed.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: ThemeConfig.primaryRed.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.mic_off, color: ThemeConfig.primaryRed),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Microphone access required for voice input. Please allow microphone access in your browser.',
                      style: TextStyle(color: ThemeConfig.primaryRed),
                    ),
                  ),
                  TextButton(
                    onPressed: _requestMicrophonePermission,
                    child: Text(
                      'Enable',
                      style: TextStyle(color: ThemeConfig.primaryRed),
                    ),
                  ),
                ],
              ),
            ),
          
          // Messages area
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ListView.builder(
                controller: _scrollController,
                itemCount: _messages.length + (_isProcessing ? 1 : 0),
                itemBuilder: (context, index) {
                  // Show typing indicator
                  if (_isProcessing && index == _messages.length) {
                    return _buildTypingIndicator();
                  }
                  
                  final message = _messages[index];
                  return _buildMessageBubble(message);
                },
              ),
            ),
          ),
          
          // Input area
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  // Mute/unmute button
                  IconButton(
                    onPressed: () {
                      setState(() {
                        _ttsEnabled = !_ttsEnabled;
                        _audioService.setTTSEnabled(_ttsEnabled);
                      });
                    },
                    icon: Icon(
                      _ttsEnabled ? Icons.volume_up : Icons.volume_off,
                      color: _ttsEnabled ? ThemeConfig.primaryBlue : Colors.grey,
                      size: 24,
                    ),
                  ),
                  
                  // Text input
                  Expanded(
                    child: TextField(
                      controller: _textController,
                      enabled: !_isRecording && !_isProcessing,
                      decoration: InputDecoration(
                        hintText: _isRecording 
                          ? 'Listening to your voice...' 
                          : (_isProcessing ? 'Processing...' : 'Type your message...'),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.grey[100],
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      onSubmitted: (text) {
                        if (text.trim().isNotEmpty) {
                          _addUserMessage(text);
                          _textController.clear();
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  
                  // Voice/send button
                  GestureDetector(
                    onTap: _isProcessing 
                      ? null 
                      : (_isRecording 
                          ? _stopVoiceRecording 
                          : (_textController.text.trim().isNotEmpty 
                              ? () {
                                  _addUserMessage(_textController.text);
                                  _textController.clear();
                                }
                              : _startVoiceRecording)),
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: _isRecording 
                          ? Colors.red 
                          : (_textController.text.trim().isNotEmpty 
                              ? ThemeConfig.primaryBlue 
                              : ThemeConfig.primaryBlue),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _isRecording 
                          ? Icons.stop 
                          : (_textController.text.trim().isNotEmpty 
                              ? Icons.send 
                              : Icons.mic),
                        color: Colors.white,
                        size: 24,
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
  
  Widget _buildMessageBubble(ConversationMessage message) {
    final isUser = message.isUser;
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) _buildAvatar(),
          const SizedBox(width: 12),
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isUser 
                  ? ThemeConfig.primaryBlue
                  : Colors.grey[100],
                borderRadius: BorderRadius.circular(18),
              ),
              child: Text(
                message.text,
                style: TextStyle(
                  color: isUser ? Colors.white : Colors.black87,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          if (isUser) const SizedBox(width: 36), // Space for avatar alignment
        ],
      ),
    );
  }
  
  Widget _buildAvatar() {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: ThemeConfig.primaryBlue,
        shape: BoxShape.circle,
      ),
      child: const Icon(
        Icons.psychology,
        color: Colors.white,
        size: 20,
      ),
    );
  }
  
  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAvatar(),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDot(0),
                const SizedBox(width: 4),
                _buildDot(100),
                const SizedBox(width: 4),
                _buildDot(200),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildDot(int delay) {
    return AnimatedBuilder(
      animation: _typingController,
      builder: (context, child) {
        final begin = 0.0;
        final end = 1.0;
        
        final animation = Tween(begin: begin, end: end).animate(
          CurvedAnimation(
            parent: _typingController,
            curve: Interval(
              delay / 1000,
              (delay + 500) / 1000,
              curve: Curves.easeInOut,
            ),
          ),
        );
        
        return Transform.translate(
          offset: Offset(0, -3 * animation.value),
          child: Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: ThemeConfig.primaryBlue,
              shape: BoxShape.circle,
            ),
          ),
        );
      },
    );
  }
}
