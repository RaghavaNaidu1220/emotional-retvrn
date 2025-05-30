import 'package:flutter/material.dart';
import '../../core/config/theme_config.dart';
import '../../models/conversation_model.dart';
import '../../models/journal_model.dart';
import 'dart:math' as math;

class ConversationAnalysisScreen extends StatefulWidget {
  final List<ConversationMessage> messages;
  final Map<String, dynamic> analysis;
  final JournalModel journal;
  
  const ConversationAnalysisScreen({
    Key? key,
    required this.messages,
    required this.analysis,
    required this.journal,
  }) : super(key: key);

  @override
  State<ConversationAnalysisScreen> createState() => _ConversationAnalysisScreenState();
}

class _ConversationAnalysisScreenState extends State<ConversationAnalysisScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _animationController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animationController.forward();
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    _animationController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final emotions = widget.analysis['emotions'] as Map<String, dynamic>? ?? {};
    final dominantEmotion = widget.analysis['dominant_emotion'] as String? ?? 'neutral';
    final insights = widget.analysis['insights'] as List<dynamic>? ?? [];
    
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFFAFBFC),
      appBar: AppBar(
        title: const Text('Conversation Analysis'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            icon: const Icon(Icons.home),
            tooltip: 'Go to Home',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Emotions', icon: Icon(Icons.psychology)),
            Tab(text: 'Insights', icon: Icon(Icons.lightbulb)),
            Tab(text: 'Trends', icon: Icon(Icons.trending_up)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildEmotionsTab(emotions, dominantEmotion, isDark),
          _buildInsightsTab(insights, isDark),
          _buildTrendsTab(emotions, isDark),
        ],
      ),
    );
  }
  
  Widget _buildEmotionsTab(Map<String, dynamic> emotions, String dominantEmotion, bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Primary Emotion Card
          AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return Transform.scale(
                scale: _animationController.value,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: _getEmotionColors(dominantEmotion),
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: _getEmotionColors(dominantEmotion)[0].withOpacity(0.3),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Icon(
                        _getEmotionIcon(dominantEmotion),
                        size: 60,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Primary Emotion',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        dominantEmotion.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          
          const SizedBox(height: 24),
          
          // Emotional Spectrum
          Text(
            'Emotional Spectrum',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          
          ...emotions.entries.map((entry) {
            final emotion = entry.key;
            final intensity = (entry.value as num).toDouble();
            
            return AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                _getEmotionIcon(emotion),
                                size: 20,
                                color: _getEmotionColors(emotion)[0],
                              ),
                              const SizedBox(width: 8),
                              Text(
                                emotion.capitalize(),
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: isDark ? Colors.white : Colors.black87,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            '${(intensity * 100).round()}%',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: isDark ? Colors.white70 : Colors.black54,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Container(
                        height: 8,
                        decoration: BoxDecoration(
                          color: isDark ? Colors.grey[800] : Colors.grey[200],
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor: intensity * _animationController.value,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: _getEmotionColors(emotion),
                              ),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          }).toList(),
          
          const SizedBox(height: 24),
          
          // Sentiment Analysis
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : Colors.white,
              borderRadius: BorderRadius.circular(16),
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
                Text(
                  'Sentiment Analysis',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),
                _buildSentimentIndicator(emotions, isDark),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildInsightsTab(List<dynamic> insights, bool isDark) {
    final userMessages = widget.messages.where((m) => m.isUser).toList();
    final aiMessages = widget.messages.where((m) => !m.isUser).toList();
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Conversation Summary
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [ThemeConfig.primaryPurple, ThemeConfig.primaryBlue],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Conversation Summary',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'You shared ${userMessages.length} messages with thoughtful emotional expression. '
                  'The conversation lasted ${_getConversationDuration()} and covered ${_getTopics().length} main topics.',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Key Insights
          Text(
            'Key Insights',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          
          ...insights.asMap().entries.map((entry) {
            final index = entry.key;
            final insight = entry.value.toString();
            
            return AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, 50 * (1 - _animationController.value)),
                  child: Opacity(
                    opacity: _animationController.value,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E293B) : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: ThemeConfig.primaryGradient[index % ThemeConfig.primaryGradient.length].withOpacity(0.3),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  ThemeConfig.primaryGradient[index % ThemeConfig.primaryGradient.length],
                                  ThemeConfig.primaryGradient[(index + 1) % ThemeConfig.primaryGradient.length],
                                ],
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.lightbulb,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              insight,
                              style: TextStyle(
                                fontSize: 16,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          }).toList(),
          
          const SizedBox(height: 24),
          
          // Emotional Patterns
          Text(
            'Emotional Patterns',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : Colors.white,
              borderRadius: BorderRadius.circular(16),
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
                _buildPatternItem('Expression Style', _getExpressionStyle(), Icons.chat_bubble, isDark),
                const SizedBox(height: 12),
                _buildPatternItem('Emotional Depth', _getEmotionalDepth(), Icons.psychology, isDark),
                const SizedBox(height: 12),
                _buildPatternItem('Communication Flow', _getCommunicationFlow(), Icons.timeline, isDark),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Conversation Flow
          Text(
            'Conversation Flow',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          
          Container(
            height: 200,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: _buildConversationFlowChart(isDark),
          ),
        ],
      ),
    );
  }
  
  Widget _buildTrendsTab(Map<String, dynamic> emotions, bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Emotional Trends
          Text(
            'Emotional Trends',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          
          Container(
            height: 250,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: _buildEmotionalTrendsChart(emotions, isDark),
          ),
          
          const SizedBox(height: 24),
          
          // Sentiment Distribution
          Text(
            'Sentiment Distribution',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          
          Container(
            height: 200,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: _buildSentimentPieChart(emotions, isDark),
          ),
          
          const SizedBox(height: 24),
          
          // Emotional Growth
          Text(
            'Emotional Growth',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [ThemeConfig.primaryGreen, ThemeConfig.primaryBlue],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Growth Insights',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Your emotional awareness is developing beautifully. This conversation shows ${_getGrowthPercentage()}% emotional intelligence growth compared to typical patterns.',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Icon(Icons.trending_up, color: Colors.white, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Keep exploring your emotions!',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSentimentIndicator(Map<String, dynamic> emotions, bool isDark) {
    final positiveEmotions = ['joy', 'trust', 'anticipation'];
    final negativeEmotions = ['sadness', 'anger', 'fear', 'disgust'];
    
    double positiveScore = 0;
    double negativeScore = 0;
    
    for (String emotion in positiveEmotions) {
      positiveScore += (emotions[emotion] as num?)?.toDouble() ?? 0;
    }
    
    for (String emotion in negativeEmotions) {
      negativeScore += (emotions[emotion] as num?)?.toDouble() ?? 0;
    }
    
    final total = positiveScore + negativeScore;
    final positivePercentage = total > 0 ? positiveScore / total : 0.5;
    
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Negative',
              style: TextStyle(
                color: isDark ? Colors.white70 : Colors.black54,
                fontSize: 14,
              ),
            ),
            Text(
              'Positive',
              style: TextStyle(
                color: isDark ? Colors.white70 : Colors.black54,
                fontSize: 14,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          height: 12,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            gradient: LinearGradient(
              colors: [
                ThemeConfig.primaryRed,
                Colors.orange,
                ThemeConfig.primaryGreen,
              ],
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                left: (positivePercentage * MediaQuery.of(context).size.width * 0.7) - 6,
                top: -2,
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: ThemeConfig.primaryBlue, width: 2),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '${(positivePercentage * 100).round()}% Positive Sentiment',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
  
  Widget _buildPatternItem(String title, String description, IconData icon, bool isDark) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [ThemeConfig.primaryPurple, ThemeConfig.primaryBlue],
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Colors.white, size: 16),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              Text(
                description,
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? Colors.white70 : Colors.black54,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildConversationFlowChart(bool isDark) {
    return CustomPaint(
      size: const Size(double.infinity, 168),
      painter: ConversationFlowPainter(
        messages: widget.messages,
        isDark: isDark,
        animation: _animationController,
      ),
    );
  }
  
  Widget _buildEmotionalTrendsChart(Map<String, dynamic> emotions, bool isDark) {
    return CustomPaint(
      size: const Size(double.infinity, 218),
      painter: EmotionalTrendsPainter(
        emotions: emotions,
        isDark: isDark,
        animation: _animationController,
      ),
    );
  }
  
  Widget _buildSentimentPieChart(Map<String, dynamic> emotions, bool isDark) {
    return CustomPaint(
      size: const Size(double.infinity, 168),
      painter: SentimentPiePainter(
        emotions: emotions,
        isDark: isDark,
        animation: _animationController,
      ),
    );
  }
  
  List<Color> _getEmotionColors(String emotion) {
    switch (emotion.toLowerCase()) {
      case 'joy':
        return [Colors.amber, Colors.orange];
      case 'sadness':
        return [Colors.blue, Colors.indigo];
      case 'anger':
        return [Colors.red, Colors.deepOrange];
      case 'fear':
        return [Colors.purple, Colors.deepPurple];
      case 'surprise':
        return [Colors.pink, Colors.pinkAccent];
      case 'disgust':
        return [Colors.green, Colors.teal];
      case 'trust':
        return [Colors.lightBlue, Colors.cyan];
      case 'anticipation':
        return [Colors.lime, Colors.lightGreen];
      default:
        return [Colors.grey, Colors.blueGrey];
    }
  }
  
  IconData _getEmotionIcon(String emotion) {
    switch (emotion.toLowerCase()) {
      case 'joy':
        return Icons.sentiment_very_satisfied;
      case 'sadness':
        return Icons.sentiment_very_dissatisfied;
      case 'anger':
        return Icons.sentiment_dissatisfied;
      case 'fear':
        return Icons.psychology;
      case 'surprise':
        return Icons.sentiment_neutral;
      case 'disgust':
        return Icons.sentiment_dissatisfied;
      case 'trust':
        return Icons.favorite;
      case 'anticipation':
        return Icons.sentiment_satisfied;
      default:
        return Icons.sentiment_neutral;
    }
  }
  
  String _getConversationDuration() {
    if (widget.messages.isEmpty) return '0 minutes';
    
    final start = widget.messages.first.timestamp;
    final end = widget.messages.last.timestamp;
    final duration = end.difference(start);
    
    if (duration.inMinutes < 1) {
      return '${duration.inSeconds} seconds';
    } else {
      return '${duration.inMinutes} minutes';
    }
  }
  
  List<String> _getTopics() {
    final userMessages = widget.messages.where((m) => m.isUser).map((m) => m.text.toLowerCase()).join(' ');
    
    List<String> topics = [];
    if (userMessages.contains('work') || userMessages.contains('job')) topics.add('Work');
    if (userMessages.contains('family') || userMessages.contains('relationship')) topics.add('Relationships');
    if (userMessages.contains('stress') || userMessages.contains('anxious')) topics.add('Stress');
    if (userMessages.contains('happy') || userMessages.contains('joy')) topics.add('Happiness');
    if (userMessages.contains('future') || userMessages.contains('goal')) topics.add('Future Planning');
    
    return topics.isEmpty ? ['Personal Reflection'] : topics;
  }
  
  String _getExpressionStyle() {
    final userMessages = widget.messages.where((m) => m.isUser).toList();
    final avgLength = userMessages.fold(0, (sum, m) => sum + m.text.length) / userMessages.length;
    
    if (avgLength > 100) {
      return 'Detailed and expressive';
    } else if (avgLength > 50) {
      return 'Thoughtful and clear';
    } else {
      return 'Concise and direct';
    }
  }
  
  String _getEmotionalDepth() {
    final emotions = widget.analysis['emotions'] as Map<String, dynamic>? ?? {};
    final activeEmotions = emotions.values.where((v) => (v as num) > 0.3).length;
    
    if (activeEmotions >= 4) {
      return 'Rich emotional complexity';
    } else if (activeEmotions >= 2) {
      return 'Moderate emotional range';
    } else {
      return 'Focused emotional expression';
    }
  }
  
  String _getCommunicationFlow() {
    final userMessages = widget.messages.where((m) => m.isUser).length;
    final aiMessages = widget.messages.where((m) => !m.isUser).length;
    
    if (userMessages > aiMessages) {
      return 'User-driven conversation';
    } else if (aiMessages > userMessages) {
      return 'AI-guided exploration';
    } else {
      return 'Balanced dialogue';
    }
  }
  
  int _getGrowthPercentage() {
    final insights = widget.analysis['insights'] as List<dynamic>? ?? [];
    final emotions = widget.analysis['emotions'] as Map<String, dynamic>? ?? {};
    
    // Calculate growth based on emotional diversity and insight depth
    final emotionalDiversity = emotions.values.where((v) => (v as num) > 0.2).length;
    final insightDepth = insights.length;
    
    return math.min(95, 60 + (emotionalDiversity * 5) + (insightDepth * 3));
  }
}

// Custom Painters for Charts
class ConversationFlowPainter extends CustomPainter {
  final List<ConversationMessage> messages;
  final bool isDark;
  final Animation<double> animation;
  
  ConversationFlowPainter({
    required this.messages,
    required this.isDark,
    required this.animation,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    
    final userPaint = Paint()
      ..color = ThemeConfig.primaryPurple
      ..strokeWidth = 3;
    
    final aiPaint = Paint()
      ..color = ThemeConfig.primaryGreen
      ..strokeWidth = 3;
    
    final path = Path();
    final userPath = Path();
    final aiPath = Path();
    
    for (int i = 0; i < messages.length; i++) {
      final x = (i / (messages.length - 1)) * size.width;
      final y = messages[i].isUser ? size.height * 0.3 : size.height * 0.7;
      
      if (i == 0) {
        path.moveTo(x, y);
        if (messages[i].isUser) {
          userPath.moveTo(x, y);
        } else {
          aiPath.moveTo(x, y);
        }
      } else {
        path.lineTo(x, y);
        if (messages[i].isUser) {
          userPath.lineTo(x, y);
        } else {
          aiPath.lineTo(x, y);
        }
      }
      
      // Draw message points
      canvas.drawCircle(
        Offset(x, y),
        4 * animation.value,
        Paint()..color = messages[i].isUser ? ThemeConfig.primaryPurple : ThemeConfig.primaryGreen,
      );
    }
    
    // Draw flow lines
    paint.color = isDark ? Colors.white24 : Colors.black12;
    canvas.drawPath(path, paint);
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class EmotionalTrendsPainter extends CustomPainter {
  final Map<String, dynamic> emotions;
  final bool isDark;
  final Animation<double> animation;
  
  EmotionalTrendsPainter({
    required this.emotions,
    required this.isDark,
    required this.animation,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill;
    
    final emotionList = emotions.entries.toList();
    final barWidth = size.width / emotionList.length;
    
    for (int i = 0; i < emotionList.length; i++) {
      final emotion = emotionList[i];
      final intensity = (emotion.value as num).toDouble();
      final barHeight = size.height * intensity * animation.value;
      
      final rect = Rect.fromLTWH(
        i * barWidth + barWidth * 0.1,
        size.height - barHeight,
        barWidth * 0.8,
        barHeight,
      );
      
      paint.shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: _getEmotionColors(emotion.key),
      ).createShader(rect);
      
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(4)),
        paint,
      );
    }
  }
  
  List<Color> _getEmotionColors(String emotion) {
    switch (emotion.toLowerCase()) {
      case 'joy':
        return [Colors.amber, Colors.orange];
      case 'sadness':
        return [Colors.blue, Colors.indigo];
      case 'anger':
        return [Colors.red, Colors.deepOrange];
      case 'fear':
        return [Colors.purple, Colors.deepPurple];
      default:
        return [Colors.grey, Colors.blueGrey];
    }
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class SentimentPiePainter extends CustomPainter {
  final Map<String, dynamic> emotions;
  final bool isDark;
  final Animation<double> animation;
  
  SentimentPiePainter({
    required this.emotions,
    required this.isDark,
    required this.animation,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 3;
    
    final positiveEmotions = ['joy', 'trust', 'anticipation'];
    final negativeEmotions = ['sadness', 'anger', 'fear', 'disgust'];
    
    double positiveScore = 0;
    double negativeScore = 0;
    double neutralScore = 0;
    
    for (String emotion in positiveEmotions) {
      positiveScore += (emotions[emotion] as num?)?.toDouble() ?? 0;
    }
    
    for (String emotion in negativeEmotions) {
      negativeScore += (emotions[emotion] as num?)?.toDouble() ?? 0;
    }
    
    neutralScore = (emotions['surprise'] as num?)?.toDouble() ?? 0;
    
    final total = positiveScore + negativeScore + neutralScore;
    if (total == 0) return;
    
    double startAngle = -math.pi / 2;
    
    // Draw positive segment
    final positiveAngle = (positiveScore / total) * 2 * math.pi * animation.value;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      positiveAngle,
      true,
      Paint()..color = ThemeConfig.primaryGreen,
    );
    startAngle += positiveAngle;
    
    // Draw negative segment
    final negativeAngle = (negativeScore / total) * 2 * math.pi * animation.value;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      negativeAngle,
      true,
      Paint()..color = ThemeConfig.primaryRed,
    );
    startAngle += negativeAngle;
    
    // Draw neutral segment
    final neutralAngle = (neutralScore / total) * 2 * math.pi * animation.value;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      neutralAngle,
      true,
      Paint()..color = Colors.grey,
    );
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}
