import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/journal_provider.dart';
import '../../models/journal_model.dart';
import '../../services/audio_service.dart';
import '../../services/ai_chat_service.dart';
import '../../core/config/theme_config.dart';
import '../reflection/reflection_screen.dart';

class EnhancedJournalScreen extends StatefulWidget {
  final bool isVoiceMode;

  const EnhancedJournalScreen({
    super.key,
    this.isVoiceMode = false,
  });

  @override
  State<EnhancedJournalScreen> createState() => _EnhancedJournalScreenState();
}

class _EnhancedJournalScreenState extends State<EnhancedJournalScreen>
    with TickerProviderStateMixin {
  final TextEditingController _textController = TextEditingController();
  final AudioService _audioService = AudioService();
  final AIChatService _aiChatService = AIChatService();
  late AnimationController _pulseController;
  late AnimationController _fadeController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _fadeAnimation;

  bool _isRecording = false;
  bool _isProcessing = false;
  bool _isLoadingAI = false;
  String? _transcribedText;
  String? _aiQuestion;
  String? _aiInsight;
  String? _followUpQuestion;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );
    
    _loadAIQuestion();
    _fadeController.forward();
  }

  @override
  void dispose() {
    _textController.dispose();
    _audioService.dispose();
    _pulseController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _loadAIQuestion() async {
    setState(() {
      _isLoadingAI = true;
    });
    
    try {
      final journalProvider = Provider.of<JournalProvider>(context, listen: false);
      final recentEntries = journalProvider.journals.take(3).map((j) => j.content ?? '').toList();
      
      if (recentEntries.isNotEmpty) {
        _aiInsight = await _aiChatService.getEmotionalInsight(recentEntries);
      }
      
      _aiQuestion = await _aiChatService.getReflectiveQuestion(
        recentEntries.isNotEmpty ? recentEntries.first : null
      );
    } catch (e) {
      debugPrint('Error loading AI question: $e');
    } finally {
      setState(() {
        _isLoadingAI = false;
      });
    }
  }

  Future<void> _getFollowUpQuestion() async {
    if (_textController.text.trim().isEmpty) return;
    
    setState(() {
      _isLoadingAI = true;
    });
    
    try {
      _followUpQuestion = await _aiChatService.getFollowUpQuestion(_textController.text);
    } catch (e) {
      debugPrint('Error getting follow-up question: $e');
    } finally {
      setState(() {
        _isLoadingAI = false;
      });
    }
  }

  Future<void> _startRecording() async {
    try {
      await _audioService.startRecording();
      setState(() {
        _isRecording = true;
      });
      _pulseController.repeat(reverse: true);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.mic, color: Colors.white),
              SizedBox(width: 8),
              Text('Recording... Speak your thoughts'),
            ],
          ),
          backgroundColor: ThemeConfig.primaryGreen,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to start recording: $e'),
          backgroundColor: ThemeConfig.primaryRed,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
        _getFollowUpQuestion();
      }
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 8),
            Text('Recording completed'),
          ],
        ),
        backgroundColor: ThemeConfig.primaryBlue,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Future<void> _saveJournal() async {
    final content = _textController.text.trim();
    if (content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please add some content to your journal'),
          backgroundColor: ThemeConfig.primaryOrange,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final journalProvider = Provider.of<JournalProvider>(context, listen: false);
    
    if (!authProvider.isAuthenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please sign in to save your journal'),
          backgroundColor: ThemeConfig.primaryRed,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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

      final savedJournal = await journalProvider.createJournal(journal);
      final success = savedJournal != null;
      
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text('Journal saved successfully!'),
              ],
            ),
            backgroundColor: ThemeConfig.primaryGreen,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
        
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
            backgroundColor: ThemeConfig.primaryRed,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving journal: $e'),
          backgroundColor: ThemeConfig.primaryRed,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
    backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFFAFBFC),
    body: SafeArea(
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [
            // Enhanced App Bar
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : Colors.white,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(32),
                  bottomRight: Radius.circular(32),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF374151) : const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.arrow_back_ios_new, size: 20),
                    ),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        Text(
                          widget.isVoiceMode ? '🎙️ Voice Journal' : '✍️ Text Journal',
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        Text(
                          'Express your thoughts and feelings',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: widget.isVoiceMode 
                            ? [ThemeConfig.primaryRed, ThemeConfig.primaryPink]
                            : [ThemeConfig.primaryBlue, ThemeConfig.primaryPurple],
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: IconButton(
                      onPressed: () {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (_) => EnhancedJournalScreen(isVoiceMode: !widget.isVoiceMode),
                          ),
                        );
                      },
                      icon: Icon(
                        widget.isVoiceMode ? Icons.edit : Icons.mic,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (widget.isVoiceMode) ...[
                      // Voice Recording Section
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF1E293B) : Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            AnimatedBuilder(
                              animation: _pulseAnimation,
                              builder: (context, child) {
                                return Transform.scale(
                                  scale: _isRecording ? _pulseAnimation.value : 1.0,
                                  child: GestureDetector(
                                    onTap: _isRecording ? _stopRecording : _startRecording,
                                    child: Container(
                                      width: 120,
                                      height: 120,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: _isRecording 
                                              ? [ThemeConfig.primaryRed, ThemeConfig.primaryPink]
                                              : [ThemeConfig.primaryBlue, ThemeConfig.primaryPurple],
                                        ),
                                        borderRadius: BorderRadius.circular(60),
                                        boxShadow: [
                                          BoxShadow(
                                            color: (_isRecording ? ThemeConfig.primaryRed : ThemeConfig.primaryBlue)
                                                .withOpacity(0.4),
                                            blurRadius: _isRecording ? 30 : 20,
                                            spreadRadius: _isRecording ? 5 : 0,
                                          ),
                                        ],
                                      ),
                                      child: Icon(
                                        _isRecording ? Icons.stop : Icons.mic,
                                        size: 48,
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
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _isRecording ? 'Speak your thoughts freely...' : 'Share what\'s on your mind',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Colors.grey[600],
                              ),
                            ),
                            if (_isProcessing) ...[
                              const SizedBox(height: 24),
                              const CircularProgressIndicator(),
                              const SizedBox(height: 12),
                              Text(
                                'Processing audio...',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                    
                    // Text Input Section
                    Container(
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E293B) : Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: _textController,
                        maxLines: widget.isVoiceMode ? 8 : 12,
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
                        style: Theme.of(context).textTheme.bodyLarge,
                        onChanged: (text) {
                          if (text.length > 50 && _followUpQuestion == null && !_isLoadingAI) {
                            _getFollowUpQuestion();
                          }
                        },
                      ),
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Save Button
                    Container(
                      width: double.infinity,
                      height: 56,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: ThemeConfig.primaryGradient,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: ThemeConfig.primaryPurple.withOpacity(0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
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
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(
                                        Icons.auto_awesome,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Save & Analyze',
                                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
}
