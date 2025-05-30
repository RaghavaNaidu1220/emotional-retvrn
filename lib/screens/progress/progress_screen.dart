import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/supabase_service.dart';
import '../../core/config/app_config.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  final SupabaseService _supabaseService = SupabaseService();
  int _selectedTabIndex = 0;
  Map<String, dynamic> _progressData = {};
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadProgressData();
  }

  Future<void> _loadProgressData() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userId = authProvider.currentUser?.id;
    
    if (userId == null) {
      setState(() {
        _errorMessage = 'User not authenticated';
        _isLoading = false;
      });
      return;
    }

    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final progressData = await _supabaseService.getUserProgress(userId);
      
      setState(() {
        _progressData = progressData;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading progress data: $e');
      setState(() {
        _errorMessage = 'Failed to load progress data: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Progress Tracker'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadProgressData,
            tooltip: 'Refresh data',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? _buildErrorWidget()
              : Column(
                  children: [
                    // Tab Bar
                    Container(
                      margin: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () => setState(() => _selectedTabIndex = 0),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                decoration: BoxDecoration(
                                  color: _selectedTabIndex == 0 
                                      ? Theme.of(context).colorScheme.primary 
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  'Overview',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: _selectedTabIndex == 0 
                                        ? Colors.white 
                                        : Colors.grey[600],
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () => setState(() => _selectedTabIndex = 1),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                decoration: BoxDecoration(
                                  color: _selectedTabIndex == 1 
                                      ? Theme.of(context).colorScheme.primary 
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  'Emotions',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: _selectedTabIndex == 1 
                                        ? Colors.white 
                                        : Colors.grey[600],
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Content
                    Expanded(
                      child: _selectedTabIndex == 0 
                          ? _buildOverviewTab()
                          : _buildEmotionChart(),
                    ),
                  ],
                ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Error Loading Progress',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadProgressData,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewTab() {
    if (_progressData.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.analytics, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No progress data yet',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            SizedBox(height: 8),
            Text(
              'Start journaling to see your progress',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your Journey Overview',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          // Stats cards
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Total Journals',
                  '${_progressData['total_journals'] ?? 0}',
                  Icons.book,
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Voice Entries',
                  '${_progressData['voice_journals'] ?? 0}',
                  Icons.mic,
                  Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'AI Conversations',
                  '${_progressData['ai_journals'] ?? 0}',
                  Icons.psychology,
                  Colors.purple,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Analyses',
                  '${(_progressData['emotion_analyses'] as List?)?.length ?? 0}',
                  Icons.analytics,
                  Colors.orange,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Recent activity
          Text(
            'Recent Activity',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          if ((_progressData['emotion_analyses'] as List?)?.isNotEmpty == true)
            ..._buildRecentAnalyses()
          else
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.grey[600]),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text('No recent emotional analyses available'),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildRecentAnalyses() {
    final analyses = _progressData['emotion_analyses'] as List;
    return analyses.take(5).map((analysis) {
      final emotion = analysis['primary_emotion'] ?? 'Unknown';
      final insights = analysis['insights'] ?? 'No insights available';
      final createdAt = DateTime.tryParse(analysis['created_at'] ?? '');
      
      return Card(
        margin: const EdgeInsets.only(bottom: 8),
        child: ListTile(
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _getEmotionColor(emotion).withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              _getEmotionIcon(emotion),
              color: _getEmotionColor(emotion),
            ),
          ),
          title: Text(emotion.toUpperCase()),
          subtitle: Text(
            insights.length > 100 ? '${insights.substring(0, 100)}...' : insights,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: createdAt != null
              ? Text(
                  '${createdAt.day}/${createdAt.month}',
                  style: Theme.of(context).textTheme.bodySmall,
                )
              : null,
        ),
      );
    }).toList();
  }

  Widget _buildEmotionChart() {
    final analyses = _progressData['emotion_analyses'] as List? ?? [];
    
    if (analyses.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.sentiment_neutral, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No emotion data yet',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            SizedBox(height: 8),
            Text(
              'Start journaling to see your emotional patterns',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    // Aggregate emotion data
    final Map<String, double> emotionTotals = {};
    for (final analysis in analyses) {
      final emotion = analysis['primary_emotion'] ?? 'unknown';
      emotionTotals[emotion] = (emotionTotals[emotion] ?? 0) + 1;
    }

    final sortedEmotions = emotionTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Emotion Distribution',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          // Pie Chart
          if (sortedEmotions.isNotEmpty)
            SizedBox(
              height: 300,
              child: PieChart(
                PieChartData(
                  sections: sortedEmotions.take(6).map((entry) {
                    final percentage = (entry.value / emotionTotals.values.reduce((a, b) => a + b) * 100);
                    return PieChartSectionData(
                      value: entry.value,
                      title: '${entry.key}\n${percentage.round()}%',
                      color: _getEmotionColor(entry.key),
                      radius: 100,
                      titleStyle: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    );
                  }).toList(),
                  centerSpaceRadius: 40,
                  sectionsSpace: 2,
                ),
              ),
            ),
          
          const SizedBox(height: 24),
          
          // Emotion List
          Text(
            'Detailed Breakdown',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          ...sortedEmotions.map((entry) {
            final percentage = (entry.value / emotionTotals.values.reduce((a, b) => a + b) * 100).round();
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: _getEmotionColor(entry.key),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                title: Text(entry.key.toUpperCase()),
                trailing: Text(
                  '$percentage%',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Color _getEmotionColor(String emotion) {
    switch (emotion.toLowerCase()) {
      case 'joy':
      case 'happiness':
      case 'excited':
        return Colors.yellow[700]!;
      case 'sad':
      case 'sadness':
      case 'grief':
        return Colors.blue[700]!;
      case 'angry':
      case 'anger':
      case 'frustrated':
        return Colors.red[700]!;
      case 'fear':
      case 'anxious':
      case 'anxiety':
        return Colors.purple[700]!;
      case 'love':
      case 'grateful':
      case 'gratitude':
        return Colors.pink[700]!;
      case 'calm':
      case 'peaceful':
      case 'relaxed':
        return Colors.green[700]!;
      case 'reflective':
      case 'thoughtful':
        return Colors.indigo[700]!;
      default:
        return Colors.grey[700]!;
    }
  }

  IconData _getEmotionIcon(String emotion) {
    switch (emotion.toLowerCase()) {
      case 'joy':
      case 'happiness':
      case 'excited':
        return Icons.sentiment_very_satisfied;
      case 'sad':
      case 'sadness':
      case 'grief':
        return Icons.sentiment_very_dissatisfied;
      case 'angry':
      case 'anger':
      case 'frustrated':
        return Icons.sentiment_dissatisfied;
      case 'fear':
      case 'anxious':
      case 'anxiety':
        return Icons.psychology;
      case 'love':
      case 'grateful':
      case 'gratitude':
        return Icons.favorite;
      case 'calm':
      case 'peaceful':
      case 'relaxed':
        return Icons.self_improvement;
      case 'reflective':
      case 'thoughtful':
        return Icons.lightbulb;
      default:
        return Icons.sentiment_neutral;
    }
  }
}
