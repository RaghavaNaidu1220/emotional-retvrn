import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/config/theme_config.dart';
// import 'user_guide_screen.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

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
                          'Help & Support',
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        Text(
                          'Get help and support',
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
                    // FAQ Section
                    _buildHelpCard(
                      context,
                      'Frequently Asked Questions',
                      'Find answers to common questions',
                      Icons.quiz,
                      ThemeConfig.primaryGradient,
                      () => _showFAQ(context),
                      isDark,
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Contact Support
                    _buildHelpCard(
                      context,
                      'Contact Support',
                      'Get in touch with our support team',
                      Icons.support_agent,
                      [ThemeConfig.primaryBlue, ThemeConfig.primaryPurple],
                      () => _contactSupport(context),
                      isDark,
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // User Guide
                    _buildHelpCard(
                      context,
                      'User Guide',
                      'Learn how to use the app effectively',
                      Icons.book,
                      ThemeConfig.successGradient,
                      () => _showUserGuide(context),
                      isDark,
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Report Bug
                    _buildHelpCard(
                      context,
                      'Report a Bug',
                      'Help us improve by reporting issues',
                      Icons.bug_report,
                      [ThemeConfig.primaryOrange, ThemeConfig.primaryRed],
                      () => _reportBug(context),
                      isDark,
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Feature Request
                    _buildHelpCard(
                      context,
                      'Feature Request',
                      'Suggest new features for the app',
                      Icons.lightbulb,
                      [ThemeConfig.primaryPink, ThemeConfig.primaryPurple],
                      () => _featureRequest(context),
                      isDark,
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Live Chat
                    _buildHelpCard(
                      context,
                      'Live Chat',
                      'Chat with our support team',
                      Icons.chat,
                      [ThemeConfig.primaryGreen, ThemeConfig.primaryBlue],
                      () => _openLiveChat(context),
                      isDark,
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Community Forum
                    _buildHelpCard(
                      context,
                      'Community Forum',
                      'Connect with other users',
                      Icons.forum,
                      [ThemeConfig.primaryPurple, ThemeConfig.primaryPink],
                      () => _openCommunityForum(context),
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

  Widget _buildHelpCard(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    List<Color> gradientColors,
    VoidCallback onTap,
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: gradientColors),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: gradientColors.first.withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(
                    icon,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.grey[400],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showFAQ(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.8,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Frequently Asked Questions',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: [
                    _buildFAQItem(
                      context,
                      'How does the AI analysis work?',
                      'Our AI analyzes your journal entries using advanced natural language processing to identify emotions and suggest growth opportunities based on Spiral Dynamics psychology.',
                    ),
                    _buildFAQItem(
                      context,
                      'Is my data secure?',
                      'Yes, all your data is encrypted and stored securely. We never share your personal information or journal entries with third parties.',
                    ),
                    _buildFAQItem(
                      context,
                      'What is Spiral Dynamics?',
                      'Spiral Dynamics is a model of human development that describes different stages of consciousness and values systems that individuals and societies evolve through.',
                    ),
                    _buildFAQItem(
                      context,
                      'Can I export my journal entries?',
                      'Yes, you can export your journal entries in various formats from the settings menu.',
                    ),
                    _buildFAQItem(
                      context,
                      'How accurate is the emotion detection?',
                      'Our AI has been trained on extensive datasets and provides insights with confidence scores. However, it\'s meant to supplement, not replace, your own self-reflection.',
                    ),
                    _buildFAQItem(
                      context,
                      'Can I use the app offline?',
                      'Basic journaling works offline, but AI analysis and cloud sync require an internet connection.',
                    ),
                    _buildFAQItem(
                      context,
                      'How do I delete my account?',
                      'You can delete your account from the Settings page. This will permanently remove all your data.',
                    ),
                    _buildFAQItem(
                      context,
                      'Is there a premium version?',
                      'Currently, all features are free. We may introduce premium features in the future with advanced AI capabilities.',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFAQItem(BuildContext context, String question, String answer) {
    return ExpansionTile(
      title: Text(
        question,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Text(
            answer,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              height: 1.5,
              color: Colors.grey[600],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _contactSupport(BuildContext context) async {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text('Please email us at: support@emotionalspiral.com'),
      backgroundColor: ThemeConfig.primaryBlue,
      duration: Duration(seconds: 4),
    ),
  );
}

void _showUserGuide(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 600, maxHeight: 700),
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark 
            ? const Color(0xFF1E293B) 
            : Colors.white,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [ThemeConfig.primaryGreen, ThemeConfig.primaryBlue],
                ),
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.book, color: Colors.white, size: 28),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'User Guide',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close, color: Colors.white),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildGuideSection(
                      context,
                      'Getting Started',
                      '1. Create your account\n2. Complete your profile\n3. Take the Spiral Dynamics assessment\n4. Start journaling!',
                    ),
                    _buildGuideSection(
                      context,
                      'Journaling',
                      '• Tap the "+" button to create a new entry\n• Write your thoughts and feelings\n• Use voice recording for hands-free journaling\n• Review AI insights after each entry',
                    ),
                    _buildGuideSection(
                      context,
                      'AI Insights',
                      '• Get emotional analysis of your entries\n• Receive personalized growth suggestions\n• Track your emotional patterns over time\n• Use insights for self-reflection',
                    ),
                    _buildGuideSection(
                      context,
                      'Spiral Dynamics',
                      '• Take regular assessments to track growth\n• View your current stage and progress\n• Understand different consciousness levels\n• Set goals for personal development',
                    ),
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

Widget _buildGuideSection(BuildContext context, String title, String content) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 24),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: ThemeConfig.primaryBlue,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          content,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            height: 1.6,
          ),
        ),
      ],
    ),
  );
}

  void _reportBug(BuildContext context) {
  _showFeedbackDialog(context, 'bug', 'Report a Bug');
}

void _featureRequest(BuildContext context) {
  _showFeedbackDialog(context, 'feature', 'Feature Request');
}

void _showFeedbackDialog(BuildContext context, String type, String title) {
  showDialog(
    context: context,
    builder: (context) => Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark 
            ? const Color(0xFF1E293B) 
            : Colors.white,
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
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: type == 'bug' 
                    ? [ThemeConfig.primaryOrange, ThemeConfig.primaryRed]
                    : [ThemeConfig.primaryBlue, ThemeConfig.primaryPurple],
                ),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Row(
                children: [
                  Icon(
                    type == 'bug' ? Icons.bug_report : Icons.lightbulb,
                    color: Colors.white,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close, color: Colors.white),
                  ),
                ],
              ),
            ),
            
            // Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    TextField(
                      decoration: InputDecoration(
                        labelText: 'Title',
                        hintText: type == 'bug' 
                          ? 'Brief description of the issue'
                          : 'Feature name or summary',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      maxLines: 4,
                      decoration: InputDecoration(
                        labelText: 'Description',
                        hintText: type == 'bug'
                          ? 'Detailed description of the bug'
                          : 'Detailed description of the feature',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.of(context).pop(),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text('Cancel'),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('${type == 'bug' ? 'Bug report' : 'Feature request'} submitted successfully!'),
                                  backgroundColor: ThemeConfig.primaryGreen,
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              backgroundColor: type == 'bug' 
                                ? ThemeConfig.primaryOrange 
                                : ThemeConfig.primaryBlue,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'Submit',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
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

  Future<void> _openLiveChat(BuildContext context) async {
    // In a real app, this would open a chat widget or navigate to a chat screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Live chat coming soon! For now, please use email support.'),
        backgroundColor: ThemeConfig.primaryGreen,
      ),
    );
  }

  Future<void> _openCommunityForum(BuildContext context) async {
    const url = 'https://community.emotionalspiral.com';
    try {
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
      } else {
        throw Exception('Could not launch $url');
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Community forum coming soon!'),
            backgroundColor: ThemeConfig.primaryPurple,
          ),
        );
      }
    }
  }
}
