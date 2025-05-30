import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../core/config/theme_config.dart';
import '../auth/auth_screen.dart';
import '../dashboard/home_screen.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic));
    
    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark 
              ? [const Color(0xFF0F172A), const Color(0xFF1E293B), const Color(0xFF334155)]
              : [const Color(0xFFFAFBFC), const Color(0xFFF1F5F9), const Color(0xFFE2E8F0)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                children: [
                  const SizedBox(height: 60),
                  
                  // Hero Section
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: Column(
                        children: [
                          // App Icon with Gradient
                          Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: ThemeConfig.primaryGradient,
                              ),
                              borderRadius: BorderRadius.circular(30),
                              boxShadow: [
                                BoxShadow(
                                  color: ThemeConfig.primaryPurple.withOpacity(0.3),
                                  blurRadius: 30,
                                  offset: const Offset(0, 15),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.psychology,
                              size: 60,
                              color: Colors.white,
                            ),
                          ),
                          
                          const SizedBox(height: 32),
                          
                          // App Title
                          ShaderMask(
                            shaderCallback: (bounds) => const LinearGradient(
                              colors: ThemeConfig.primaryGradient,
                            ).createShader(bounds),
                            child: Text(
                              'Emotional Spiral',
                              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontSize: 42,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          
                          const SizedBox(height: 16),
                          
                          Text(
                            'Transform your emotional journey with AI-powered insights and voice journaling',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: isDark ? Colors.grey[300] : Colors.grey[600],
                              height: 1.5,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 60),
                  
                  // Features Section
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: Column(
                      children: [
                        Text(
                          'Powerful Features',
                          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 32),
                        
                        _buildFeatureCard(
                          context,
                          Icons.mic,
                          'Voice Journaling',
                          'Express yourself naturally with voice-to-text journaling and real-time emotional analysis',
                          [ThemeConfig.primaryRed, ThemeConfig.primaryPink],
                          isDark,
                        ),
                        
                        const SizedBox(height: 20),
                        
                        _buildFeatureCard(
                          context,
                          Icons.psychology,
                          'AI Conversations',
                          'Engage in meaningful conversations with AI that understands your emotional patterns',
                          [ThemeConfig.primaryBlue, ThemeConfig.primaryPurple],
                          isDark,
                        ),
                        
                        const SizedBox(height: 20),
                        
                        _buildFeatureCard(
                          context,
                          Icons.insights,
                          'Emotional Insights',
                          'Discover patterns in your emotions and receive personalized growth recommendations',
                          [ThemeConfig.primaryGreen, ThemeConfig.primaryBlue],
                          isDark,
                        ),
                        
                        const SizedBox(height: 20),
                        
                        _buildFeatureCard(
                          context,
                          Icons.auto_awesome,
                          'Spiral Dynamics',
                          'Track your consciousness evolution through the lens of Spiral Dynamics psychology',
                          [ThemeConfig.primaryOrange, ThemeConfig.primaryYellow],
                          isDark,
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 60),
                  
                  // CTA Section
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            ThemeConfig.primaryPurple.withOpacity(0.1),
                            ThemeConfig.primaryBlue.withOpacity(0.1),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: ThemeConfig.primaryPurple.withOpacity(0.2),
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            'Ready to begin your journey?',
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          
                          const SizedBox(height: 16),
                          
                          Text(
                            'Join thousands of users discovering their emotional patterns and growing through AI-powered insights',
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: isDark ? Colors.grey[300] : Colors.grey[600],
                              height: 1.6,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          
                          const SizedBox(height: 32),
                          
                          // Auth Buttons
                          Consumer<AuthProvider>(
                            builder: (context, authProvider, child) {
                              if (authProvider.user != null) {
                                return _buildGradientButton(
                                  context,
                                  'Continue to Dashboard',
                                  Icons.arrow_forward,
                                  () => Navigator.of(context).pushReplacement(
                                    MaterialPageRoute(builder: (_) => const HomeScreen()),
                                  ),
                                );
                              }
                              
                              return Column(
                                children: [
                                  _buildGradientButton(
                                    context,
                                    authProvider.isLoading ? 'Signing in...' : 'Continue with Google',
                                    Icons.login,
                                    authProvider.isLoading ? null : () => _signInWithGoogle(context),
                                  ),
                                  
                                  const SizedBox(height: 16),
                                  
                                  TextButton(
                                    onPressed: () => Navigator.of(context).push(
                                      MaterialPageRoute(builder: (_) => const AuthScreen()),
                                    ),
                                    child: Text(
                                      'Sign in with Email',
                                      style: TextStyle(
                                        color: ThemeConfig.primaryPurple,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // Footer
                  Text(
                    '© 2024 Emotional Spiral. Transform your emotional intelligence.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[500],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureCard(
    BuildContext context,
    IconData icon,
    String title,
    String description,
    List<Color> gradientColors,
    bool isDark,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: gradientColors),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: gradientColors.first.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 32,
            ),
          ),
          
          const SizedBox(width: 20),
          
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
                const SizedBox(height: 8),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: isDark ? Colors.grey[300] : Colors.grey[600],
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGradientButton(
    BuildContext context,
    String text,
    IconData icon,
    VoidCallback? onPressed,
  ) {
    return Container(
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
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ElevatedButton.icon(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        icon: Icon(icon, color: Colors.white),
        label: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Future<void> _signInWithGoogle(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    final success = await authProvider.signInWithGoogle();
    
    if (success && mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.errorMessage ?? 'Google sign in failed'),
          backgroundColor: ThemeConfig.primaryRed,
        ),
      );
    }
  }
}
