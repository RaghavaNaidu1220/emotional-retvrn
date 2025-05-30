import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/spiral_dynamics_model.dart';
import '../../core/config/app_config.dart';
import '../dashboard/home_screen.dart';

class SpiralAssessmentScreen extends StatefulWidget {
  const SpiralAssessmentScreen({super.key});

  @override
  State<SpiralAssessmentScreen> createState() => _SpiralAssessmentScreenState();
}

class _SpiralAssessmentScreenState extends State<SpiralAssessmentScreen> {
  int _currentQuestionIndex = 0;
  Map<int, String> _answers = {};
  bool _isCompleted = false;
  String? _resultStage;

  final List<AssessmentQuestion> _questions = [
    AssessmentQuestion(
      question: "What motivates you most in life?",
      options: {
        'beige': "Meeting basic survival needs (food, shelter, safety)",
        'purple': "Belonging to a group and following traditions",
        'red': "Gaining power and control over my environment",
        'blue': "Following rules and finding meaning through order",
        'orange': "Achieving success and personal advancement",
        'green': "Creating harmony and helping others",
        'yellow': "Understanding complex systems and integration",
        'turquoise': "Contributing to global consciousness and unity",
      },
    ),
    AssessmentQuestion(
      question: "How do you prefer to make decisions?",
      options: {
        'beige': "Based on immediate needs and instincts",
        'purple': "Following what the group or elders decide",
        'red': "Quickly and decisively, trusting my gut",
        'blue': "Following established rules and procedures",
        'orange': "Analyzing data and choosing the most effective option",
        'green': "Consulting with others and seeking consensus",
        'yellow': "Considering multiple perspectives and contexts",
        'turquoise': "Integrating all viewpoints for the greater good",
      },
    ),
    AssessmentQuestion(
      question: "What is your view on authority?",
      options: {
        'beige': "Authority should provide safety and resources",
        'purple': "Authority comes from tradition and spiritual wisdom",
        'red': "I prefer to be the authority or challenge it",
        'blue': "Authority maintains order and should be respected",
        'orange': "Authority should be earned through competence",
        'green': "Authority should be shared and democratic",
        'yellow': "Authority is contextual and situational",
        'turquoise': "Authority emerges naturally from wisdom and service",
      },
    ),
    AssessmentQuestion(
      question: "How do you handle conflict?",
      options: {
        'beige': "Avoid it or seek protection from others",
        'purple': "Look to group leaders or rituals for resolution",
        'red': "Confront it directly and assert dominance",
        'blue': "Follow proper procedures and rules",
        'orange': "Find win-win solutions through negotiation",
        'green': "Seek understanding and emotional healing",
        'yellow': "Analyze the systemic causes and adapt",
        'turquoise': "Transform it into an opportunity for growth",
      },
    ),
    AssessmentQuestion(
      question: "What gives your life meaning?",
      options: {
        'beige': "Surviving and meeting basic needs",
        'purple': "Connection to family, tribe, and traditions",
        'red': "Personal power and freedom of expression",
        'blue': "Serving a higher purpose and moral order",
        'orange': "Achievement, progress, and success",
        'green': "Love, relationships, and community harmony",
        'yellow': "Understanding life's complexity and flow",
        'turquoise': "Contributing to the evolution of consciousness",
      },
    ),
    AssessmentQuestion(
      question: "How do you view change?",
      options: {
        'beige': "Change is threatening and should be avoided",
        'purple': "Change should honor traditions and ancestors",
        'red': "Change is an opportunity to gain advantage",
        'blue': "Change should be orderly and purposeful",
        'orange': "Change drives progress and innovation",
        'green': "Change should benefit everyone involved",
        'yellow': "Change is natural and requires adaptation",
        'turquoise': "Change is part of the cosmic evolution",
      },
    ),
  ];

  void _selectAnswer(String stage) {
    setState(() {
      _answers[_currentQuestionIndex] = stage;
    });
  }

  void _nextQuestion() {
    if (_currentQuestionIndex < _questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
      });
    } else {
      _completeAssessment();
    }
  }

  void _previousQuestion() {
    if (_currentQuestionIndex > 0) {
      setState(() {
        _currentQuestionIndex--;
      });
    }
  }

  void _completeAssessment() {
    // Calculate the most frequent stage
    Map<String, int> stageCount = {};
    for (String stage in _answers.values) {
      stageCount[stage] = (stageCount[stage] ?? 0) + 1;
    }
    
    String mostFrequentStage = stageCount.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
    
    setState(() {
      _resultStage = mostFrequentStage;
      _isCompleted = true;
    });
  }

  Future<void> _saveResult() async {
    if (_resultStage == null) return;
    
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.userProfile;
    
    if (user != null) {
      final updatedUser = user.copyWith(spiralStage: _resultStage);
      await authProvider.updateProfile(updatedUser);
    }
    
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
        (route) => false,
      );
    }
  }

  Color _getStageColor(String stage) {
    final stageInfo = AppConfig.spiralColors[stage];
    if (stageInfo != null && stageInfo['color'] != null) {
      final colorValue = stageInfo['color'] as int;
      return Color(colorValue);
    }
    return const Color(0xFF6366F1); // Default color
  }

  Color _getTextColor(Color backgroundColor) {
    final luminance = backgroundColor.computeLuminance();
    return luminance > 0.5 ? Colors.black87 : Colors.white;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    if (_isCompleted) {
      return _buildResultScreen(isDark);
    }
    
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Header
              Row(
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
                  const Expanded(
                    child: Text(
                      'Spiral Dynamics Assessment',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
              
              const SizedBox(height: 32),
              
              // Progress Indicator
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Question ${_currentQuestionIndex + 1} of ${_questions.length}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '${((_currentQuestionIndex + 1) / _questions.length * 100).round()}%',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: (_currentQuestionIndex + 1) / _questions.length,
                        backgroundColor: Colors.grey[300],
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Theme.of(context).colorScheme.primary,
                        ),
                        minHeight: 8,
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Question
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _questions[_currentQuestionIndex].question,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          height: 1.3,
                        ),
                      ),
                      
                      const SizedBox(height: 32),
                      
                      // Options
                      ..._questions[_currentQuestionIndex].options.entries.map((entry) {
                        final isSelected = _answers[_currentQuestionIndex] == entry.key;
                        
                        return Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: isSelected 
                                ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                                : (isDark ? const Color(0xFF1E293B) : Colors.white),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isSelected 
                                  ? Theme.of(context).colorScheme.primary
                                  : Colors.grey.withOpacity(0.3),
                              width: isSelected ? 2 : 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () => _selectAnswer(entry.key),
                              borderRadius: BorderRadius.circular(16),
                              child: Padding(
                                padding: const EdgeInsets.all(20),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 24,
                                      height: 24,
                                      decoration: BoxDecoration(
                                        color: isSelected 
                                            ? Theme.of(context).colorScheme.primary
                                            : Colors.transparent,
                                        border: Border.all(
                                          color: isSelected 
                                              ? Theme.of(context).colorScheme.primary
                                              : Colors.grey,
                                          width: 2,
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: isSelected 
                                          ? const Icon(
                                              Icons.check,
                                              color: Colors.white,
                                              size: 16,
                                            )
                                          : null,
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Text(
                                        entry.value,
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                          height: 1.4,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                ),
              ),
              
              // Navigation Buttons
              Row(
                children: [
                  if (_currentQuestionIndex > 0)
                    Expanded(
                      child: Container(
                        height: 56,
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF1E293B) : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.grey.withOpacity(0.3),
                          ),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: _previousQuestion,
                            borderRadius: BorderRadius.circular(16),
                            child: const Center(
                              child: Text(
                                'Previous',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  if (_currentQuestionIndex > 0) const SizedBox(width: 16),
                  Expanded(
                    child: Container(
                      height: 56,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: _answers.containsKey(_currentQuestionIndex)
                              ? [const Color(0xFF6366F1), const Color(0xFF8B5CF6)]
                              : [Colors.grey, Colors.grey],
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: _answers.containsKey(_currentQuestionIndex) ? _nextQuestion : null,
                          borderRadius: BorderRadius.circular(16),
                          child: Center(
                            child: Text(
                              _currentQuestionIndex == _questions.length - 1 ? 'Complete' : 'Next',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultScreen(bool isDark) {
    final stage = SpiralDynamicsModel.getStageByName(_resultStage!);
    final stageColor = _getStageColor(_resultStage!);
    final stageInfo = AppConfig.spiralColors[_resultStage!];
    
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const SizedBox(height: 40),
              
              // Success Icon
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      stageColor,
                      stageColor.withOpacity(0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(50),
                  boxShadow: [
                    BoxShadow(
                      color: stageColor.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.psychology,
                  color: _getTextColor(stageColor),
                  size: 50,
                ),
              ),
              
              const SizedBox(height: 32),
              
              const Text(
                'Assessment Complete!',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              
              const SizedBox(height: 16),
              
              Text(
                'Your Spiral Dynamics stage has been identified',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
              
              const SizedBox(height: 40),
              
              // Result Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      stageColor,
                      stageColor.withOpacity(0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: stageColor.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      stageInfo?['name'] ?? stage?.name ?? 'Unknown',
                      style: TextStyle(
                        color: _getTextColor(stageColor),
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      stageInfo?['description'] ?? stage?.description ?? '',
                      style: TextStyle(
                        color: _getTextColor(stageColor),
                        fontSize: 16,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              
              const Spacer(),
              
              // Save Button
              Container(
                width: double.infinity,
                height: 56,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: _saveResult,
                    borderRadius: BorderRadius.circular(16),
                    child: const Center(
                      child: Text(
                        'Save & Continue',
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
    );
  }
}

class AssessmentQuestion {
  final String question;
  final Map<String, String> options;

  AssessmentQuestion({
    required this.question,
    required this.options,
  });
}
