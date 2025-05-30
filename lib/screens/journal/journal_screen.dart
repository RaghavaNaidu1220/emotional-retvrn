import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/journal_provider.dart';
import '../../models/journal_model.dart';
import '../../services/audio_service.dart';
import '../reflection/reflection_screen.dart';

class JournalScreen extends StatefulWidget {
  final bool isVoiceMode;
  
  const JournalScreen({
    super.key,
    this.isVoiceMode = false,
  });

  @override
  State<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends State<JournalScreen>
    with TickerProviderStateMixin {
  final TextEditingController _textController = TextEditingController();
  final AudioService _audioService = AudioService();
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  
  bool _isRecording = false;
  bool _isProcessing = false;
  String? _transcribedText;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    _audioService.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _startRecording() async {
    try {
      await _audioService.startRecording();
      setState(() {
        _isRecording = true;
      });
      _pulseController.repeat(reverse: true);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Recording started. Speak now...'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to start recording: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _stopRecording() async {
    await _audioService.stopRecording();
    _pulseController.stop();
    setState(() {
      _isRecording = false;
      _transcribedText = _audioService.transcribedText;
      if (_transcribedText != null && _transcribedText!.isNotEmpty) {
        _textController.text = _transcribedText!;
      }
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Recording stopped'),
        backgroundColor: Colors.blue,
        duration: Duration(seconds: 1),
      ),
    );
  }

  Future<void> _saveJournal() async {
    final content = _textController.text.trim();
    if (content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add some content to your journal'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final journalProvider = Provider.of<JournalProvider>(context, listen: false);
    
    if (!authProvider.isAuthenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please sign in to save your journal'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      final userId = authProvider.currentUser?.id ?? 'demo_user_123';
      final journal = JournalModel(
        userId: userId,
        content: content,
        transcript: _transcribedText,
        createdAt: DateTime.now(),
      );

      final success = await journalProvider.createJournal(journal);
      
      if (success && mounted) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Journal saved successfully!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
        
        // Navigate to reflection screen after a short delay
        await Future.delayed(const Duration(milliseconds: 500));
        
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (_) => ReflectionScreen(
                journalContent: content,
              ),
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(journalProvider.errorMessage ?? 'Failed to save journal'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving journal: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          children: [
            // Custom App Bar
            Container(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E293B) : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(Icons.arrow_back, size: 20),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      widget.isVoiceMode ? 'Voice Journal' : 'Text Journal',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (_) => JournalScreen(isVoiceMode: !widget.isVoiceMode),
                        ),
                      );
                    },
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E293B) : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        widget.isVoiceMode ? Icons.edit : Icons.mic,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Text
                    Text(
                      widget.isVoiceMode 
                          ? 'Record your thoughts and feelings'
                          : 'Write about your emotions and experiences',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey[600],
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 32),
                    
                    if (widget.isVoiceMode) ...[
                      // Voice Recording Section
                      Expanded(
                        flex: 2,
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              AnimatedBuilder(
                                animation: _pulseAnimation,
                                builder: (context, child) {
                                  return Transform.scale(
                                    scale: _isRecording ? _pulseAnimation.value : 1.0,
                                    child: GestureDetector(
                                      onTap: _isRecording ? _stopRecording : _startRecording,
                                      child: Container(
                                        width: 140,
                                        height: 140,
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: _isRecording 
                                                ? [Colors.red, Colors.red.withOpacity(0.8)]
                                                : [const Color(0xFF3B82F6), const Color(0xFF3B82F6).withOpacity(0.8)],
                                          ),
                                          borderRadius: BorderRadius.circular(70),
                                          boxShadow: [
                                            BoxShadow(
                                              color: (_isRecording ? Colors.red : const Color(0xFF3B82F6))
                                                  .withOpacity(0.3),
                                              blurRadius: 30,
                                              spreadRadius: _isRecording ? 10 : 0,
                                            ),
                                          ],
                                        ),
                                        child: Icon(
                                          _isRecording ? Icons.stop : Icons.mic,
                                          size: 60,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(height: 24),
                              Text(
                                _isRecording ? 'Tap to stop recording' : 'Tap to start recording',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              if (_isProcessing) ...[
                                const SizedBox(height: 24),
                                const CircularProgressIndicator(),
                                const SizedBox(height: 12),
                                const Text(
                                  'Processing audio...',
                                  style: TextStyle(fontSize: 16),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                    ],
                    
                    // Text Input Section
                    Expanded(
                      flex: widget.isVoiceMode ? 3 : 5,
                      child: Container(
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF1E293B) : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: TextField(
                          controller: _textController,
                          maxLines: null,
                          expands: true,
                          decoration: InputDecoration(
                            hintText: widget.isVoiceMode 
                                ? 'Transcribed text will appear here...'
                                : 'Start writing your thoughts...',
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.all(24),
                            hintStyle: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 16,
                            ),
                          ),
                          style: const TextStyle(
                            fontSize: 16,
                            height: 1.6,
                          ),
                          textAlignVertical: TextAlignVertical.top,
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Save Button
                    Container(
                      width: double.infinity,
                      height: 56,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF6366F1).withOpacity(0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: _isProcessing ? null : _saveJournal,
                          borderRadius: BorderRadius.circular(16),
                          child: Center(
                            child: _isProcessing
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text(
                                    'Save & Analyze',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
