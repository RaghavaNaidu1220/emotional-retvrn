import 'package:flutter/material.dart';
import 'dart:async';
import '../../core/config/theme_config.dart';
import '../../models/practice_model.dart';

class PracticeDetailScreen extends StatefulWidget {
  final PracticeModel practice;
  
  const PracticeDetailScreen({
    Key? key,
    required this.practice,
  }) : super(key: key);

  @override
  State<PracticeDetailScreen> createState() => _PracticeDetailScreenState();
}

class _PracticeDetailScreenState extends State<PracticeDetailScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  Timer? _timer;
  int _duration = 300; // 5 minutes in seconds
  int _timeRemaining = 300;
  bool _isRunning = false;
  bool _isCompleted = false;
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _animationController.repeat(reverse: true);
    
    // Parse duration from practice
    if (widget.practice.duration.contains('5 min')) {
      _duration = 300;
    } else if (widget.practice.duration.contains('10 min')) {
      _duration = 600;
    } else if (widget.practice.duration.contains('15 min')) {
      _duration = 900;
    } else if (widget.practice.duration.contains('20 min')) {
      _duration = 1200;
    }
    
    _timeRemaining = _duration;
  }
  
  @override
  void dispose() {
    _timer?.cancel();
    _animationController.dispose();
    super.dispose();
  }
  
  void _startTimer() {
    setState(() {
      _isRunning = true;
    });
    
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_timeRemaining > 0) {
          _timeRemaining--;
        } else {
          _timer?.cancel();
          _isRunning = false;
          _isCompleted = true;
          _showCompletionDialog();
        }
      });
    });
  }
  
  void _pauseTimer() {
    setState(() {
      _isRunning = false;
      _timer?.cancel();
    });
  }
  
  void _resetTimer() {
    setState(() {
      _timeRemaining = _duration;
      _isRunning = false;
      _isCompleted = false;
      _timer?.cancel();
    });
  }
  
  void _showCompletionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text('Practice Complete!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: ThemeConfig.primaryGreen.withOpacity(0.1),
                borderRadius: BorderRadius.circular(100),
              ),
              child: Icon(
                Icons.check_circle,
                color: ThemeConfig.primaryGreen,
                size: 60,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Congratulations on completing your ${widget.practice.title} practice!',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              'How do you feel now?',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _resetTimer();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: ThemeConfig.primaryGreen,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Start Again'),
          ),
        ],
      ),
    );
  }
  
  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }
  
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 800;
    final colors = _getCategoryColors(widget.practice.category);
    
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
      body: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            expandedHeight: 200,
            floating: false,
            pinned: true,
            backgroundColor: Colors.transparent,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: colors,
                  ),
                ),
                child: Stack(
                  children: [
                    // Background pattern
                    Positioned.fill(
                      child: Opacity(
                        opacity: 0.1,
                        child: CustomPaint(
                          painter: PatternPainter(),
                        ),
                      ),
                    ),
                    // Content
                    SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    _getCategoryIcon(widget.practice.category),
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    widget.practice.category,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              widget.practice.title,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                height: 1.2,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(
                                  Icons.timer,
                                  color: Colors.white70,
                                  size: 16,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  widget.practice.duration,
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                const Icon(
                                  Icons.bar_chart,
                                  color: Colors.white70,
                                  size: 16,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  widget.practice.difficulty,
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 14,
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
          ),
          
          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: isDesktop
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Left column - Timer
                        Expanded(
                          flex: 2,
                          child: _buildTimerSection(isDark, colors),
                        ),
                        const SizedBox(width: 24),
                        // Right column - Content
                        Expanded(
                          flex: 3,
                          child: _buildContentSection(isDark),
                        ),
                      ],
                    )
                  : Column(
                      children: [
                        _buildTimerSection(isDark, colors),
                        const SizedBox(height: 24),
                        _buildContentSection(isDark),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildTimerSection(bool isDark, List<Color> colors) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Practice Timer',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Follow along with the timer',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 30),
          // Timer display
          SizedBox(
            width: 200,
            height: 200,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Background circle
                Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    color: isDark 
                        ? const Color(0xFF0F172A) 
                        : const Color(0xFFF1F5F9),
                    shape: BoxShape.circle,
                  ),
                ),
                // Progress indicator
                SizedBox(
                  width: 200,
                  height: 200,
                  child: CircularProgressIndicator(
                    value: _timeRemaining / _duration,
                    strokeWidth: 12,
                    backgroundColor: isDark 
                        ? const Color(0xFF334155) 
                        : const Color(0xFFE2E8F0),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      _isCompleted 
                          ? ThemeConfig.primaryGreen
                          : colors.first,
                    ),
                  ),
                ),
                // Time display
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _formatTime(_timeRemaining),
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    Text(
                      'remaining',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
          // Timer controls
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Reset button
              IconButton(
                onPressed: _resetTimer,
                icon: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark 
                        ? const Color(0xFF334155) 
                        : const Color(0xFFE2E8F0),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.refresh,
                    color: isDark ? Colors.white70 : Colors.black54,
                  ),
                ),
                iconSize: 48,
                padding: EdgeInsets.zero,
              ),
              const SizedBox(width: 20),
              // Play/Pause button
              IconButton(
                onPressed: _isRunning ? _pauseTimer : _startTimer,
                icon: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: colors,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: colors.first.withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Icon(
                    _isRunning ? Icons.pause : Icons.play_arrow,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
                iconSize: 64,
                padding: EdgeInsets.zero,
              ),
              const SizedBox(width: 20),
              // Duration selector
              IconButton(
                onPressed: () {
                  _showDurationPicker();
                },
                icon: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark 
                        ? const Color(0xFF334155) 
                        : const Color(0xFFE2E8F0),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.timer,
                    color: isDark ? Colors.white70 : Colors.black54,
                  ),
                ),
                iconSize: 48,
                padding: EdgeInsets.zero,
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  void _showDurationPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Select Duration',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildDurationOption('5 min', 300),
                  _buildDurationOption('10 min', 600),
                  _buildDurationOption('15 min', 900),
                  _buildDurationOption('20 min', 1200),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }
  
  Widget _buildDurationOption(String label, int seconds) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isSelected = _duration == seconds;
    final colors = _getCategoryColors(widget.practice.category);
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _duration = seconds;
          _timeRemaining = seconds;
          _isRunning = false;
          _isCompleted = false;
          _timer?.cancel();
        });
        Navigator.pop(context);
      },
      child: Container(
        width: 70,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          gradient: isSelected 
              ? LinearGradient(colors: colors)
              : null,
          color: isSelected 
              ? null
              : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
          borderRadius: BorderRadius.circular(12),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: colors.first.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Column(
          children: [
            Text(
              label,
              style: TextStyle(
                color: isSelected 
                    ? Colors.white 
                    : (isDark ? Colors.white70 : Colors.black87),
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildContentSection(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Description
          Text(
            'Description',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            widget.practice.description,
            style: TextStyle(
              fontSize: 16,
              height: 1.6,
              color: isDark ? Colors.white70 : Colors.black87,
            ),
          ),
          const SizedBox(height: 24),
          
          // Instructions
          Text(
            'Instructions',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          ...widget.practice.instructions.asMap().entries.map((entry) {
            final index = entry.key;
            final instruction = entry.value;
            
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: ThemeConfig.primaryPurple.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: TextStyle(
                          color: ThemeConfig.primaryPurple,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      instruction,
                      style: TextStyle(
                        fontSize: 16,
                        height: 1.5,
                        color: isDark ? Colors.white70 : Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
          const SizedBox(height: 24),
          
          // Benefits
          Text(
            'Benefits',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          ...widget.practice.benefits.map((benefit) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.check_circle,
                    color: ThemeConfig.primaryGreen,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      benefit,
                      style: TextStyle(
                        fontSize: 16,
                        height: 1.5,
                        color: isDark ? Colors.white70 : Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
  
  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'meditation':
        return Icons.self_improvement;
      case 'breathing':
        return Icons.air;
      case 'mindfulness':
        return Icons.spa;
      case 'emotional':
      case 'emotional regulation':
        return Icons.favorite;
      case 'spiral':
      case 'spiral dynamics':
        return Icons.psychology;
      case 'journaling':
        return Icons.edit_note;
      default:
        return Icons.fitness_center;
    }
  }
  
  List<Color> _getCategoryColors(String category) {
    switch (category.toLowerCase()) {
      case 'meditation':
        return [ThemeConfig.primaryPurple, ThemeConfig.primaryBlue];
      case 'breathing':
        return [ThemeConfig.primaryBlue, ThemeConfig.primaryGreen];
      case 'mindfulness':
        return [ThemeConfig.primaryGreen, ThemeConfig.primaryYellow];
      case 'emotional':
      case 'emotional regulation':
        return [ThemeConfig.primaryPink, ThemeConfig.primaryRed];
      case 'spiral':
      case 'spiral dynamics':
        return [ThemeConfig.primaryOrange, ThemeConfig.primaryRed];
      case 'journaling':
        return [ThemeConfig.primaryPurple, ThemeConfig.primaryPink];
      default:
        return ThemeConfig.primaryGradient;
    }
  }
}

// Pattern painter for background
class PatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;
    
    final spacing = 20.0;
    
    for (double i = 0; i < size.width + size.height; i += spacing) {
      canvas.drawLine(
        Offset(0, i),
        Offset(i, 0),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
