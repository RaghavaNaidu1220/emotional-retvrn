import 'package:flutter/material.dart';
import '../../models/spiral_dynamics_model.dart';
import '../spiral_assessment/spiral_assessment_screen.dart';

class SpiralExplorerScreen extends StatefulWidget {
  const SpiralExplorerScreen({super.key});

  @override
  State<SpiralExplorerScreen> createState() => _SpiralExplorerScreenState();
}

class _SpiralExplorerScreenState extends State<SpiralExplorerScreen>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentIndex = 0;
  final List<SpiralDynamicsModel> _stages = SpiralDynamicsModel.getAllStages();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
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
                  const Expanded(
                    child: Text(
                      'Spiral Dynamics Explorer',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const SpiralAssessmentScreen(),
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
                      child: const Icon(Icons.quiz, size: 20),
                    ),
                  ),
                ],
              ),
            ),
            
            // Stage Indicator
            Container(
              height: 100,
              margin: const EdgeInsets.symmetric(horizontal: 20),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: List.generate(_stages.length, (index) {
                    final stage = _stages[index];
                    final isSelected = index == _currentIndex;
                    
                    return GestureDetector(
                      onTap: () {
                        _pageController.animateToPage(
                          index,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: isSelected ? 60 : 50,
                              height: isSelected ? 60 : 50,
                              decoration: BoxDecoration(
                                color: Color(stage.colorValue),
                                borderRadius: BorderRadius.circular(30),
                                border: isSelected 
                                    ? Border.all(color: Colors.white, width: 4)
                                    : null,
                                boxShadow: [
                                  BoxShadow(
                                    color: Color(stage.colorValue).withOpacity(0.3),
                                    blurRadius: isSelected ? 20 : 10,
                                    spreadRadius: isSelected ? 5 : 0,
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Text(
                                  stage.stage.substring(0, 1).toUpperCase(),
                                  style: TextStyle(
                                    color: _getTextColor(Color(stage.colorValue)),
                                    fontSize: isSelected ? 24 : 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              stage.stage.toUpperCase(),
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                color: isSelected 
                                    ? Theme.of(context).colorScheme.primary 
                                    : Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ),
            
            // Stage Content
            Expanded(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _currentIndex = index;
                    });
                    _animationController.reset();
                    _animationController.forward();
                  },
                  itemCount: _stages.length,
                  itemBuilder: (context, index) {
                    return _buildStageContent(_stages[index]);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStageContent(SpiralDynamicsModel stage) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(stage.colorValue),
                  Color(stage.colorValue).withOpacity(0.8),
                ],
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Color(stage.colorValue).withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Stage ${_currentIndex + 1} of ${_stages.length}',
                    style: TextStyle(
                      color: _getTextColor(Color(stage.colorValue)),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  stage.name,
                  style: TextStyle(
                    color: _getTextColor(Color(stage.colorValue)),
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  stage.description,
                  style: TextStyle(
                    color: _getTextColor(Color(stage.colorValue)).withOpacity(0.9),
                    fontSize: 18,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 32),
          
          // Characteristics Section
          _buildSection(
            'Key Characteristics',
            stage.characteristics,
            Icons.psychology,
            Color(stage.colorValue),
            isDark,
          ),
          
          const SizedBox(height: 24),
          
          // Growth Tips Section
          _buildSection(
            'Growth Tips',
            stage.growthTips,
            Icons.lightbulb,
            Color(stage.colorValue),
            isDark,
          ),
          
          const SizedBox(height: 32),
          
          // Navigation Buttons
          Row(
            children: [
              if (_currentIndex > 0)
                Expanded(
                  child: _buildNavButton(
                    'Previous Stage',
                    Icons.arrow_back,
                    false,
                    () {
                      _pageController.previousPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                    isDark,
                  ),
                ),
              if (_currentIndex > 0 && _currentIndex < _stages.length - 1)
                const SizedBox(width: 16),
              if (_currentIndex < _stages.length - 1)
                Expanded(
                  child: _buildNavButton(
                    'Next Stage',
                    Icons.arrow_forward,
                    true,
                    () {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                    isDark,
                  ),
                ),
            ],
          ),
          
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildSection(
    String title,
    List<String> items,
    IconData icon,
    Color color,
    bool isDark,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: color,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        ...items.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: color.withOpacity(0.2),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    item,
                    style: const TextStyle(
                      fontSize: 16,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildNavButton(
    String text,
    IconData icon,
    bool isPrimary,
    VoidCallback onPressed,
    bool isDark,
  ) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        gradient: isPrimary
            ? LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.primary,
                  Theme.of(context).colorScheme.primary.withOpacity(0.8),
                ],
              )
            : null,
        color: isPrimary ? null : (isDark ? const Color(0xFF1E293B) : Colors.white),
        borderRadius: BorderRadius.circular(16),
        border: isPrimary ? null : Border.all(
          color: Colors.grey.withOpacity(0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (!isPrimary) ...[
                Icon(
                  icon,
                  size: 20,
                  color: isDark ? Colors.white : Colors.black87,
                ),
                const SizedBox(width: 8),
              ],
              Text(
                text,
                style: TextStyle(
                  color: isPrimary ? Colors.white : (isDark ? Colors.white : Colors.black87),
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              if (isPrimary) ...[
                const SizedBox(width: 8),
                Icon(
                  icon,
                  size: 20,
                  color: Colors.white,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Color _getTextColor(Color backgroundColor) {
    final luminance = backgroundColor.computeLuminance();
    return luminance > 0.5 ? Colors.black87 : Colors.white;
  }
}
