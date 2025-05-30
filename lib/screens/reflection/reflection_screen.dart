import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/journal_provider.dart';
import '../../core/config/app_config.dart';
import '../dashboard/home_screen.dart';

class ReflectionScreen extends StatefulWidget {
  final String journalContent;
  
  const ReflectionScreen({
    super.key,
    required this.journalContent,
  });

  @override
  State<ReflectionScreen> createState() => _ReflectionScreenState();
}

class _ReflectionScreenState extends State<ReflectionScreen> {
  @override
  Widget build(BuildContext context) {
    return Consumer<JournalProvider>(
      builder: (context, journalProvider, child) {
        final latestAnalysis = journalProvider.analyses.isNotEmpty 
            ? journalProvider.analyses.first 
            : null;
            
        return Scaffold(
          appBar: AppBar(
            title: const Text('Reflection & Insights'),
            automaticallyImplyLeading: false,
            actions: [
              IconButton(
                icon: const Icon(Icons.home),
                onPressed: () {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const HomeScreen()),
                    (route) => false,
                  );
                },
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Journal Content
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Your Journal Entry',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          widget.journalContent,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                if (latestAnalysis != null) ...[
                  // Spiral Dynamics Stage
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Spiral Dynamics Stage',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Color(AppConfig.spiralColors[latestAnalysis.spiralColor]?['color'] ?? 0xFF6750A4)
                                  .withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Color(AppConfig.spiralColors[latestAnalysis.spiralColor]?['color'] ?? 0xFF6750A4),
                                width: 2,
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 24,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    color: Color(AppConfig.spiralColors[latestAnalysis.spiralColor]?['color'] ?? 0xFF6750A4),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        AppConfig.spiralColors[latestAnalysis.spiralColor]?['name'] ?? 'Unknown',
                                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        AppConfig.spiralColors[latestAnalysis.spiralColor]?['description'] ?? '',
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
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Detected Emotions
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Detected Emotions',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: latestAnalysis.emotions.entries.map((entry) {
                              final intensity = (entry.value * 100).round();
                              return Chip(
                                label: Text('${entry.key} ($intensity%)'),
                                backgroundColor: _getEmotionColor(entry.key).withOpacity(0.2),
                                side: BorderSide(color: _getEmotionColor(entry.key)),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Primary Emotion: ${latestAnalysis.primaryEmotion}',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: _getEmotionColor(latestAnalysis.primaryEmotion),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Growth Suggestions
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Growth Suggestions',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          ...latestAnalysis.suggestions.map((suggestion) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  margin: const EdgeInsets.only(top: 6),
                                  width: 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).colorScheme.primary,
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    suggestion,
                                    style: Theme.of(context).textTheme.bodyLarge,
                                  ),
                                ),
                              ],
                            ),
                          )).toList(),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Confidence Score
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Icon(
                            Icons.analytics,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Analysis Confidence: ${(latestAnalysis.confidenceScore * 100).round()}%',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ] else ...[
                  // Loading or Error State
                  const Card(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: Column(
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 16),
                          Text('Analyzing your journal entry...'),
                        ],
                      ),
                    ),
                  ),
                ],
                
                const SizedBox(height: 32),
                
                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text('Write Another'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(builder: (_) => const HomeScreen()),
                            (route) => false,
                          );
                        },
                        child: const Text('Go Home'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Color _getEmotionColor(String emotion) {
    switch (emotion.toLowerCase()) {
      case 'joy':
      case 'happiness':
      case 'excitement':
        return Colors.yellow[700]!;
      case 'sadness':
      case 'grief':
        return Colors.blue[700]!;
      case 'anger':
      case 'frustration':
        return Colors.red[700]!;
      case 'fear':
      case 'anxiety':
        return Colors.purple[700]!;
      case 'love':
      case 'gratitude':
        return Colors.pink[700]!;
      case 'calm':
      case 'peace':
        return Colors.green[700]!;
      default:
        return Colors.grey[700]!;
    }
  }
}
