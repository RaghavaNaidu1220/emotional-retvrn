import 'package:flutter/material.dart';
import '../auth/auth_screen.dart';
import 'widgets/onboarding_page.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingPageData> _pages = [
    OnboardingPageData(
      title: 'Welcome to Emotional Spiral',
      description: 'Discover your emotional patterns and growth journey through the lens of Spiral Dynamics psychology.',
      icon: Icons.psychology,
      color: const Color(0xFF6750A4),
    ),
    OnboardingPageData(
      title: 'Journal Your Emotions',
      description: 'Express yourself through text or voice. Our AI will help you understand your emotional landscape.',
      icon: Icons.edit_note,
      color: const Color(0xFF2196F3),
    ),
    OnboardingPageData(
      title: 'Track Your Growth',
      description: 'See your progress through different stages of consciousness and emotional development.',
      icon: Icons.trending_up,
      color: const Color(0xFF4CAF50),
    ),
    OnboardingPageData(
      title: 'Get Personalized Insights',
      description: 'Receive AI-powered suggestions for your emotional growth and spiritual development.',
      icon: Icons.lightbulb,
      color: const Color(0xFFFF9800),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  return OnboardingPage(data: _pages[index]);
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _pages.length,
                      (index) => Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: _currentPage == index ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _currentPage == index
                              ? Theme.of(context).colorScheme.primary
                              : Colors.grey[300],
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      if (_currentPage > 0)
                        TextButton(
                          onPressed: () {
                            _pageController.previousPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          },
                          child: const Text('Back'),
                        ),
                      const Spacer(),
                      ElevatedButton(
                        onPressed: () {
                          if (_currentPage == _pages.length - 1) {
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                builder: (_) => const AuthScreen(),
                              ),
                            );
                          } else {
                            _pageController.nextPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          }
                        },
                        child: Text(
                          _currentPage == _pages.length - 1 
                              ? 'Get Started' 
                              : 'Next',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class OnboardingPageData {
  final String title;
  final String description;
  final IconData icon;
  final Color color;

  OnboardingPageData({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });
}
