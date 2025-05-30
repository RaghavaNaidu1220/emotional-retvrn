import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/supabase_service.dart';
import '../../services/openai_service.dart';
import '../../services/whisper_service.dart';
import '../../services/web_audio_recorder.dart';
import '../../core/config/theme_config.dart';

class VoiceJournalScreen extends StatefulWidget {
  const VoiceJournalScreen({super.key});

  @override
  State<VoiceJournalScreen> createState() => _VoiceJournalScreenState();
}

class _VoiceJournalScreenState extends State<VoiceJournalScreen> {
  final SupabaseService _supabaseService = SupabaseService();
  final OpenAIService _openAIService = OpenAIService();
  final WhisperService _whisperService = WhisperService();
  final WebAudioRecorder _audioRecorder = WebAudioRecorder();
  final TextEditingController _textController = TextEditingController();
  
  bool _isRecording = false;
  bool _isTranscribing = false;
  bool _isAnalyzing = false;
  bool _isSaving = false;
  String _status = 'Tap the microphone to start recording or type your thoughts below';
  Map<String, dynamic>? _analysis;
  String? _errorMessage;
  
  @override
  void initState() {
    super.initState();
    _initializeServices();
  }

  void _initializeServices() {
    _whisperService.initialize();
    _audioRecorder.initialize();
  }

  Future<void> _toggleRecording() async {
    if (_isRecording) {
      await _stopRecording();
    } else {
      await _startRecording();
    }
  }

  Future<void> _startRecording() async {
    try {
      setState(() {
        _isRecording = true;
        _status = 'Recording... Speak now';
        _errorMessage = null;
        _analysis = null;
      });

      await _audioRecorder.startRecording();
      debugPrint('Recording started');
    } catch (e) {
      debugPrint('Error starting recording: $e');
      setState(() {
        _isRecording = false;
        _errorMessage = 'Failed to start recording: ${e.toString()}';
        _status = 'Recording failed';
      });
    }
  }

  Future<void> _stopRecording() async {
    try {
      setState(() {
        _isRecording = false;
        _isTranscribing = true;
        _status = 'Processing audio...';
      });

      final audioData = await _audioRecorder.stopRecording();
      if (audioData != null) {
        await _transcribeAudio(audioData);
      } else {
        throw Exception('No audio data recorded');
      }
    } catch (e) {
      debugPrint('Error stopping recording: $e');
      setState(() {
        _isTranscribing = false;
        _errorMessage = 'Failed to process recording: ${e.toString()}';
        _status = 'Processing failed';
      });
    }
  }

  Future<void> _transcribeAudio(Uint8List audioData) async {
    try {
      setState(() {
        _status = 'Transcribing speech...';
      });

      final transcript = await _whisperService.transcribeAudio(audioData);
      
      setState(() {
        _textController.text = transcript;
        _isTranscribing = false;
        _status = 'Transcription complete! Review and analyze your thoughts.';
      });

      // Auto-analyze after transcription
      await _analyzeText();
    } catch (e) {
      debugPrint('Transcription error: $e');
      setState(() {
        _isTranscribing = false;
        _errorMessage = 'Transcription failed: ${e.toString()}';
        _status = 'You can type your thoughts manually instead';
      });
    }
  }

  Future<void> _analyzeText() async {
    final text = _textController.text.trim();
    if (text.isEmpty) {
      setState(() {
        _errorMessage = 'Please record audio or enter text to analyze';
      });
      return;
    }

    setState(() {
      _isAnalyzing = true;
      _status = 'Analyzing your emotional state...';
      _errorMessage = null;
    });

    try {
      // Use voice journal specific analysis (different from AI journal)
      final analysis = await _getVoiceJournalAnalysis(text);
      
      setState(() {
        _analysis = analysis;
        _status = 'Analysis complete! Review your emotional insights.';
      });
    } catch (e) {
      debugPrint('Analysis error: $e');
      // Provide simple analysis to avoid blocking
      setState(() {
        _analysis = _getDefaultVoiceAnalysis(text);
        _status = 'Using simplified analysis';
      });
    } finally {
      setState(() {
        _isAnalyzing = false;
      });
    }
  }

  Future<Map<String, dynamic>> _getVoiceJournalAnalysis(String text) async {
    try {
      // Voice journal specific prompt - different from AI journal
      final prompt = '''
Analyze this voice journal entry for emotional content. Provide a brief, supportive analysis:

Text: "$text"

Respond with JSON format:
{
  "primary_emotion": "main emotion detected",
  "intensity": "low/medium/high",
  "themes": ["theme1", "theme2"],
  "insights": "brief supportive insight",
  "suggestions": ["suggestion1", "suggestion2"],
  "mood_score": 0.5
}''';

      final response = await _openAIService.generateResponse(prompt);
      
      // Try to parse JSON response
      try {
        final jsonStart = response.indexOf('{');
        final jsonEnd = response.lastIndexOf('}') + 1;
        if (jsonStart >= 0 && jsonEnd > jsonStart) {
          final jsonStr = response.substring(jsonStart, jsonEnd);
          return Map<String, dynamic>.from(
            Map<String, dynamic>.from(
              Map<String, dynamic>.from(
                Map<String, dynamic>.from(jsonStr as Map)
              )
            )
          );
        }
      } catch (e) {
        debugPrint('JSON parsing failed: $e');
      }
      
      return _getDefaultVoiceAnalysis(text);
    } catch (e) {
      debugPrint('Voice analysis error: $e');
      return _getDefaultVoiceAnalysis(text);
    }
  }

  Map<String, dynamic> _getDefaultVoiceAnalysis(String text) {
    // Simple keyword-based analysis for voice journals
    final lowerText = text.toLowerCase();
    String primaryEmotion = 'neutral';
    String intensity = 'medium';
    List<String> themes = ['self-reflection'];
    String insights = 'Thank you for sharing your thoughts through voice journaling.';
    List<String> suggestions = ['Continue regular voice journaling'];
    double moodScore = 0.5;

    // Basic emotion detection
    if (lowerText.contains(RegExp(r'\b(happy|joy|excited|great|wonderful|amazing)\b'))) {
      primaryEmotion = 'happy';
      moodScore = 0.8;
      insights = 'Your voice journal reflects positive emotions and experiences.';
      suggestions = ['Celebrate these positive moments', 'Share your joy with others'];
    } else if (lowerText.contains(RegExp(r'\b(sad|depressed|down|upset|hurt)\b'))) {
      primaryEmotion = 'sad';
      moodScore = 0.2;
      insights = 'It sounds like you\'re going through a difficult time.';
      suggestions = ['Practice self-compassion', 'Consider reaching out for support'];
    } else if (lowerText.contains(RegExp(r'\b(angry|mad|frustrated|annoyed)\b'))) {
      primaryEmotion = 'angry';
      moodScore = 0.3;
      insights = 'Your voice journal shows some frustration or anger.';
      suggestions = ['Try deep breathing exercises', 'Consider what triggered these feelings'];
    } else if (lowerText.contains(RegExp(r'\b(anxious|worried|nervous|stressed)\b'))) {
      primaryEmotion = 'anxious';
      moodScore = 0.4;
      insights = 'You seem to be experiencing some anxiety or stress.';
      suggestions = ['Practice mindfulness', 'Break down overwhelming tasks'];
    }

    // Detect themes
    if (lowerText.contains(RegExp(r'\b(work|job|career|boss|colleague)\b'))) {
      themes.add('work');
    }
    if (lowerText.contains(RegExp(r'\b(family|parent|child|sibling)\b'))) {
      themes.add('family');
    }
    if (lowerText.contains(RegExp(r'\b(friend|relationship|partner)\b'))) {
      themes.add('relationships');
    }

    return {
      'primary_emotion': primaryEmotion,
      'intensity': intensity,
      'themes': themes,
      'insights': insights,
      'suggestions': suggestions,
      'mood_score': moodScore,
      'analysis_type': 'voice_journal',
      'offline_mode': true,
    };
  }

  Future<void> _saveEntry() async {
    final text = _textController.text.trim();
    if (text.isEmpty) {
      setState(() {
        _errorMessage = 'Please record audio or enter text to save';
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
      _status = 'Saving your voice journal entry...';
    });

    try {
      // Save to voice journal specific table
      final analysisJson = {
        'primary_emotion': _analysis?['primary_emotion'] ?? 'neutral',
        'intensity': _analysis?['intensity'] ?? 'medium',
        'themes': _analysis?['themes'] ?? ['voice-journal'],
        'insights': _analysis?['insights'] ?? 'Voice journal entry saved',
        'suggestions': _analysis?['suggestions'] ?? ['Continue voice journaling'],
        'mood_score': _analysis?['mood_score'] ?? 0.5,
        'analysis_type': 'voice_journal',
        'offline_mode': _analysis?['offline_mode'] ?? true,
        'timestamp': DateTime.now().toIso8601String(),
      };

      await _supabaseService.saveVoiceJournalEntry(
        userId: userId,
        transcript: text,
        analysisJson: analysisJson,
      );

      setState(() {
        _status = 'Voice journal entry saved successfully!';
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Voice journal entry saved to your history!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 3),
        ),
      );

      // Clear form after successful save
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() {
            _textController.clear();
            _analysis = null;
            _status = 'Tap the microphone to start recording or type your thoughts below';
          });
        }
      });

    } catch (e) {
      debugPrint('Save error: $e');
      setState(() {
        _errorMessage = 'Failed to save: ${e.toString()}';
        _status = 'Save failed';
      });
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  void _clearForm() {
    setState(() {
      _textController.clear();
      _analysis = null;
      _errorMessage = null;
      _status = 'Tap the microphone to start recording or type your thoughts below';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Voice Journal'),
        backgroundColor: ThemeConfig.primaryBlue,
        foregroundColor: Colors.white,
        actions: [
          if (_textController.text.isNotEmpty || _analysis != null)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: _clearForm,
              tooltip: 'Clear',
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Voice Recording Section
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Text(
                      'Voice Recording',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: ThemeConfig.primaryBlue,
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    // Large Record Button
                    GestureDetector(
                      onTap: _isTranscribing ? null : _toggleRecording,
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _isRecording 
                              ? Colors.red 
                              : (_isTranscribing ? Colors.orange : ThemeConfig.primaryBlue),
                          boxShadow: [
                            BoxShadow(
                              color: (_isRecording ? Colors.red : ThemeConfig.primaryBlue)
                                  .withOpacity(0.3),
                              spreadRadius: _isRecording ? 8 : 4,
                              blurRadius: 15,
                            ),
                          ],
                        ),
                        child: _isTranscribing
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 3,
                              )
                            : Icon(
                                _isRecording ? Icons.stop : Icons.mic,
                                size: 50,
                                color: Colors.white,
                              ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    Text(
                      _isRecording 
                          ? 'Recording... Tap to stop'
                          : _isTranscribing
                              ? 'Processing audio...'
                              : 'Tap to start recording',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: _isRecording 
                            ? Colors.red 
                            : (_isTranscribing ? Colors.orange : ThemeConfig.primaryBlue),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Error message
            if (_errorMessage != null)
              Container(
                margin: const EdgeInsets.only(bottom: 16),
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

            // Text input section
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Your Thoughts (Voice or Text)',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _textController,
                      maxLines: 6,
                      decoration: InputDecoration(
                        hintText: 'Your voice recording will appear here, or you can type directly...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        filled: true,
                        fillColor: Colors.grey[50],
                      ),
                      onChanged: (value) {
                        setState(() {
                          _analysis = null; // Clear analysis when text changes
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Action buttons
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _isAnalyzing || _textController.text.trim().isEmpty 
                                ? null 
                                : _analyzeText,
                            icon: _isAnalyzing 
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : const Icon(Icons.psychology),
                            label: Text(_isAnalyzing ? 'Analyzing...' : 'Analyze Emotions'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: ThemeConfig.primaryBlue,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        if (_analysis != null)
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _isSaving ? null : _saveEntry,
                              icon: _isSaving 
                                  ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    )
                                  : const Icon(Icons.save),
                              label: Text(_isSaving ? 'Saving...' : 'Save to History'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Status
            if (_status.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _status,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[700],
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

            const SizedBox(height: 16),

            // Voice Journal Analysis results
            if (_analysis != null) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.record_voice_over,
                            color: Colors.purple,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Voice Journal Analysis',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.purple,
                            ),
                          ),
                          if (_analysis!['offline_mode'] == true) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.orange.shade100,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'Offline',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.orange.shade700,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 12),
                      
                      _buildAnalysisItem('Primary Emotion', _analysis!['primary_emotion'] ?? 'Unknown'),
                      _buildAnalysisItem('Intensity', _analysis!['intensity'] ?? 'Medium'),
                      _buildAnalysisItem('Insights', _analysis!['insights'] ?? 'No insights available'),
                      
                      if (_analysis!['themes'] != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          'Themes:',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Wrap(
                          spacing: 8,
                          children: (_analysis!['themes'] as List).map((theme) => 
                            Chip(
                              label: Text(theme),
                              backgroundColor: Colors.purple.shade50,
                              labelStyle: TextStyle(color: Colors.purple.shade700),
                            ),
                          ).toList(),
                        ),
                      ],
                      
                      if (_analysis!['suggestions'] != null) ...[
                        const SizedBox(height: 12),
                        Text(
                          'Suggestions:',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        ...(_analysis!['suggestions'] as List).map((suggestion) => 
                          Padding(
                            padding: const EdgeInsets.only(left: 8, top: 2),
                            child: Text('• $suggestion'),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAnalysisItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              color: Colors.grey[700],
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    _audioRecorder.dispose();
    super.dispose();
  }
}
