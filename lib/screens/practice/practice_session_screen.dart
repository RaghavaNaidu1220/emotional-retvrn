import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/practice_model.dart';
import '../../core/config/theme_config.dart';
import '../../services/audio_service.dart';
import '../../services/ai_chat_service.dart';
import '../../providers/auth_provider.dart';
import '../../providers/journal_provider.dart';
import '../../models/journal_model.dart';

class PracticeSessionScreen extends StatefulWidget {
  final PracticeModel practice;

  const PracticeSessionScreen({
    super.key,
    required this.practice,
  });

  @override
  State<PracticeSessionScreen> createState() => _PracticeSessionScreenState();
}

class _PracticeSessionScreenState extends State<PracticeSessionScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  
  final TextEditingController _textController = TextEditingController();
  final AudioService _audioService = AudioService();
  final AIChatService _aiChatService = AIChatService();
  
  bool _isVoiceMode = false;
  bool _isRecording = false;
  bool _isProcessing = false;
  bool _showQuestions = false;
  
  String? _userInput;
  List<String> _aiQuestions = [];
  List<String> _userResponses = [];
  int _currentQuestionIndex = 0;
  
  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _textController.dispose();
    _audioService.dispose();
    super.dispose();
  }

  Future<void> _startSession() async {
    final input = _textController.text.trim();
    if (input.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please share your thoughts first')),
      );
      return;
    }

    setState(() {
      _isProcessing = true;
      _userInput = input;
    });

    try {
      // Generate AI questions based on user input and practice type
      final questions = await _generateRelevantQuestions(input);
      setState(() {
        _aiQuestions = questions;
        _showQuestions = true;
        _currentQuestionIndex = 0;
        _userResponses = List.filled(questions.length, '');
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error generating questions: $e')),
      );
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  Future<List<String>> _generateRelevantQuestions(String userInput) async {
    // Generate questions based on practice category and user input
    final prompt = '''Based on this ${widget.practice.category.toLowerCase()} practice session and the user's input: "$userInput", 
    generate 3-4 thoughtful follow-up questions that help explore their experience deeper. 
    Make the questions specific to ${widget.practice.title} practice.
    
    Return only the questions, one per line.''';
    
    try {
      final response = await _aiChatService.getFollowUpQuestion(prompt);
      return response.split('\n').where((q) => q.trim().isNotEmpty).take(4).toList();
    } catch (e) {
      // Fallback questions based on practice category
      return _getFallbackQuestions();
    }
  }

  List<String> _getFallbackQuestions() {
    switch (widget.practice.category) {
      case 'Meditation':
        return [
          'What thoughts or feelings came up during your meditation?',
          'How did your body feel throughout the practice?',
          'What was the most challenging part of staying present?',
          'What insights or realizations did you have?'
        ];
      case 'Breathing':
        return [
          'How did your breathing pattern change during the exercise?',
          'What sensations did you notice in your body?',
          'Did you feel any emotional shifts while breathing?',
          'How do you feel now compared to when you started?'
        ];
      case 'Mindfulness':
        return [
          'What did you become more aware of during this practice?',
          'Which thoughts or emotions were most prominent?',
          'How did practicing mindfulness affect your perspective?',
          'What would you like to be more mindful of going forward?'
        ];
      default:
        return [
          'How are you feeling right now?',
          'What was most meaningful about this experience?',
          'What would you like to explore further?',
          'How might this practice help you in daily life?'
        ];
    }
  }

  Future<void> _saveSession() async {
    setState(() {
      _isProcessing = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final journalProvider = Provider.of<JournalProvider>(context, listen: false);
      
      if (!authProvider.isAuthenticated) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please sign in to save your session')),
        );
        return;
      }

      // Compile session data
      final sessionContent = _compileSessionContent();
      
      final userId = authProvider.currentUser?.id ?? 'demo_user_123';
      final journal = JournalModel(
        userId: userId,
        content: sessionContent,
        createdAt: DateTime.now(),
      );

      final success = await journalProvider.createJournal(journal);
      
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Session saved and analyzed successfully!'),
            backgroundColor: ThemeConfig.primaryGreen,
          ),
        );
        
        Navigator.of(context).pop();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving session: $e')),
      );
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  String _compileSessionContent() {
    final buffer = StringBuffer();
    buffer.writeln('Practice Session: ${widget.practice.title}');
    buffer.writeln('Category: ${widget.practice.category}');
    buffer.writeln('Duration: ${widget.practice.duration} minutes');
    buffer.writeln('\nInitial Thoughts:');
    buffer.writeln(_userInput);
    buffer.writeln('\nReflection Questions & Responses:');
    
    for (int i = 0; i < _aiQuestions.length; i++) {
      buffer.writeln('\nQ${i + 1}: ${_aiQuestions[i]}');
      buffer.writeln('A${i + 1}: ${_userResponses[i]}');
    }
    
    return buffer.toString();
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
              // Header
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : Colors.white,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(24),
                    bottomRight: Radius.circular(24),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 15,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF374151) : const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(12),
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
                            widget.practice.title,
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${widget.practice.category} • ${widget.practice.duration}m',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: ThemeConfig.primaryGradient,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: IconButton(
                        onPressed: () {
                          setState(() {
                            _isVoiceMode = !_isVoiceMode;
                          });
                        },
                        icon: Icon(
                          _isVoiceMode ? Icons.keyboard : Icons.mic,
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
                      if (!_showQuestions) ...[
                        // Initial Input Section
                        _buildInitialInputSection(isDark),
                      ] else ...[
                        // Questions Section
                        _buildQuestionsSection(isDark),
                      ],
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

  Widget _buildInitialInputSection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                ThemeConfig.primaryBlue.withOpacity(0.1),
                ThemeConfig.primaryPurple.withOpacity(0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.lightbulb_outline,
                    color: ThemeConfig.primaryBlue,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Start Your Session',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: ThemeConfig.primaryBlue,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'Share your current thoughts, feelings, or what brought you to this ${widget.practice.category.toLowerCase()} practice today.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 24),
        
        // Input Section
        Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 15,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: TextField(
            controller: _textController,
            maxLines: 8,
            decoration: InputDecoration(
              hintText: _isVoiceMode 
                  ? 'Tap the mic to record your thoughts...'
                  : 'Type your thoughts and feelings here...',
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(20),
            ),
          ),
        ),
        
        const SizedBox(height: 24),
        
        // Action Button
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: _isProcessing ? null : _startSession,
            style: ElevatedButton.styleFrom(
              backgroundColor: ThemeConfig.primaryBlue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: _isProcessing
                ? const CircularProgressIndicator(color: Colors.white)
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.psychology, color: Colors.white),
                      const SizedBox(width: 8),
                      Text(
                        'Generate Reflection Questions',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuestionsSection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Progress Indicator
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Text(
                'Question ${_currentQuestionIndex + 1} of ${_aiQuestions.length}',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Text(
                '${((_currentQuestionIndex + 1) / _aiQuestions.length * 100).round()}%',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: ThemeConfig.primaryBlue,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Linear Progress
        LinearProgressIndicator(
          value: (_currentQuestionIndex + 1) / _aiQuestions.length,
          backgroundColor: Colors.grey[300],
          valueColor: AlwaysStoppedAnimation<Color>(ThemeConfig.primaryBlue),
        ),
        
        const SizedBox(height: 24),
        
        // Current Question
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                ThemeConfig.primaryPurple.withOpacity(0.1),
                ThemeConfig.primaryBlue.withOpacity(0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.help_outline,
                    color: ThemeConfig.primaryPurple,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Reflection Question',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: ThemeConfig.primaryPurple,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                _aiQuestions[_currentQuestionIndex],
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 24),
        
        // Answer Input
        Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 15,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: TextField(
            maxLines: 6,
            decoration: const InputDecoration(
              hintText: 'Share your thoughts on this question...',
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(20),
            ),
            onChanged: (value) {
              _userResponses[_currentQuestionIndex] = value;
            },
          ),
        ),
        
        const SizedBox(height: 24),
        
        // Navigation Buttons
        Row(
          children: [
            if (_currentQuestionIndex > 0)
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _currentQuestionIndex--;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[300],
                    foregroundColor: Colors.black,
                  ),
                  child: const Text('Previous'),
                ),
              ),
            if (_currentQuestionIndex > 0) const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                onPressed: _currentQuestionIndex < _aiQuestions.length - 1
                    ? () {
                        setState(() {
                          _currentQuestionIndex++;
                        });
                      }
                    : _saveSession,
                style: ElevatedButton.styleFrom(
                  backgroundColor: ThemeConfig.primaryBlue,
                ),
                child: _isProcessing
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                        _currentQuestionIndex < _aiQuestions.length - 1
                            ? 'Next Question'
                            : 'Complete Session',
                        style: const TextStyle(color: Colors.white),
                      ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
