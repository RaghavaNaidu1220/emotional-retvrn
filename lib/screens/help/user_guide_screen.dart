import 'package:flutter/material.dart';
import '../../core/config/theme_config.dart';

class UserGuideScreen extends StatelessWidget {
  const UserGuideScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFFAFBFC),
      body: SafeArea(
        child: Column(
          children: [
            // Custom App Bar
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
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'User Guide',
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        Text(
                          'Learn how to use the app',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    _buildGuideSection(
                      context,
                      'Getting Started',
                      'Learn the basics of using Emotional Spiral',
                      Icons.play_circle_outline,
                      ThemeConfig.primaryGradient,
                      [
                        'Create your account with email and password',
                        'Complete your profile setup',
                        'Take the Spiral Dynamics assessment',
                        'Start your first journal entry',
                      ],
                      isDark,
                    ),
                    
                    const SizedBox(height: 20),
                    
                    _buildGuideSection(
                      context,
                      'Journaling',
                      'Master the art of reflective journaling',
                      Icons.edit_note,
                      [ThemeConfig.primaryBlue, ThemeConfig.primaryPurple],
                      [
                        'Tap the "+" button to create a new entry',
                        'Write your thoughts and feelings freely',
                        'Use voice recording for hands-free journaling',
                        'Review AI insights after each entry',
                        'Add emotion tags to track patterns',
                      ],
                      isDark,
                    ),
                    
                    const SizedBox(height: 20),
                    
                    _buildGuideSection(
                      context,
                      'Voice Reflection',
                      'Use voice notes for deeper reflection',
                      Icons.mic,
                      ThemeConfig.successGradient,
                      [
                        'Tap the microphone icon to start recording',
                        'Speak naturally about your thoughts',
                        'The AI will transcribe and analyze your voice',
                        'Review the transcription and insights',
                        'Edit the text if needed',
                      ],
                      isDark,
                    ),
                    
                    const SizedBox(height: 20),
                    
                    _buildGuideSection(
                      context,
                      'Spiral Dynamics',
                      'Understand your consciousness evolution',
                      Icons.psychology,
                      [ThemeConfig.primaryOrange, ThemeConfig.primaryRed],
                      [
                        'Take the assessment to find your current stage',
                        'Learn about each consciousness level',
                        'Track your growth over time',
                        'Understand how stages influence your thinking',
                        'Use insights for personal development',
                      ],
                      isDark,
                    ),
                    
                    const SizedBox(height: 20),
                    
                    _buildGuideSection(
                      context,
                      'AI Insights',
                      'Leverage AI for emotional intelligence',
                      Icons.auto_awesome,
                      [ThemeConfig.primaryPink, ThemeConfig.primaryPurple],
                      [
                        'AI analyzes your writing for emotional patterns',
                        'Get personalized reflection questions',
                        'Receive insights about your growth',
                        'Discover emotional trends over time',
                        'Use suggestions for deeper self-awareness',
                      ],
                      isDark,
                    ),
                    
                    const SizedBox(height: 20),
                    
                    _buildGuideSection(
                      context,
                      'Privacy & Security',
                      'Your data is safe and private',
                      Icons.security,
                      [ThemeConfig.primaryGreen, ThemeConfig.primaryBlue],
                      [
                        'All data is encrypted and secure',
                        'Your journal entries are private',
                        'AI analysis happens securely',
                        'You control your data',
                        'Export or delete data anytime',
                      ],
                      isDark,
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

  Widget _buildGuideSection(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    List<Color> gradientColors,
    List<String> steps,
    bool isDark,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: gradientColors),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Row(
              children: [
                Icon(icon, color: Colors.white, size: 28),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: steps.asMap().entries.map((entry) {
                final index = entry.key;
                final step = entry.value;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(colors: gradientColors),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            '${index + 1}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          step,
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
