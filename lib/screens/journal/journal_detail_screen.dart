import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/journal_provider.dart';
import '../../core/config/theme_config.dart';
import '../../core/config/app_config.dart';

class JournalDetailScreen extends StatelessWidget {
  final dynamic journal;
  
  const JournalDetailScreen({
    super.key,
    required this.journal,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Consumer<JournalProvider>(
      builder: (context, journalProvider, child) {
        // Find the analysis for this journal
        final analysis = journalProvider.analyses
            .where((a) => a.journalId == journal.id)
            .isNotEmpty
            ? journalProvider.analyses
                .where((a) => a.journalId == journal.id)
                .first
            : null;
        
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
                              'Journal Entry',
                              style: Theme.of(context).textTheme.headlineMedium,
                            ),
                            Text(
                              _formatDate(journal.createdAt),
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      PopupMenuButton<String>(
                        onSelected: (value) {
                          switch (value) {
                            case 'edit':
                              _editJournal(context);
                              break;
                            case 'delete':
                              _deleteJournal(context);
                              break;
                            case 'share':
                              _shareJournal(context);
                              break;
                          }
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'edit',
                            child: Row(
                              children: [
                                Icon(Icons.edit),
                                SizedBox(width: 8),
                                Text('Edit'),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'share',
                            child: Row(
                              children: [
                                Icon(Icons.share),
                                SizedBox(width: 8),
                                Text('Share'),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(Icons.delete, color: Colors.red),
                                SizedBox(width: 8),
                                Text('Delete', style: TextStyle(color: Colors.red)),
                              ],
                            ),
                          ),
                        ],
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF374151) : const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.more_vert, size: 20),
                        ),
                      ),
                    ],
                  ),
                ),
                
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Journal Content
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(24),
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
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: ThemeConfig.primaryGradient,
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(
                                      journal.transcript != null ? Icons.mic : Icons.edit_note,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    journal.transcript != null ? 'Voice Journal' : 'Text Journal',
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              if (journal.content != null && journal.content.isNotEmpty)
                                Text(
                                  journal.content,
                                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    height: 1.6,
                                  ),
                                )
                              else if (journal.transcript != null)
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Transcript:',
                                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      journal.transcript,
                                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                        height: 1.6,
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        ),
                        
                        if (analysis != null) ...[
                          const SizedBox(height: 24),
                          
                          // Emotion Analysis
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(24),
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
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: ThemeConfig.primaryGreen.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Icon(
                                        Icons.psychology,
                                        color: ThemeConfig.primaryGreen,
                                        size: 20,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      'AI Analysis',
                                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20),
                                
                                // Spiral Stage
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Color(AppConfig.spiralColors[analysis.spiralColor]?['color'] ?? 0xFF6750A4)
                                        .withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: Color(AppConfig.spiralColors[analysis.spiralColor]?['color'] ?? 0xFF6750A4),
                                      width: 1,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 24,
                                        height: 24,
                                        decoration: BoxDecoration(
                                          color: Color(AppConfig.spiralColors[analysis.spiralColor]?['color'] ?? 0xFF6750A4),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              AppConfig.spiralColors[analysis.spiralColor]?['name'] ?? 'Unknown',
                                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Text(
                                              AppConfig.spiralColors[analysis.spiralColor]?['description'] ?? '',
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
                                
                                const SizedBox(height: 16),
                                
                                // Emotions
                                Text(
                                  'Detected Emotions',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: analysis.emotions.entries.map((entry) {
                                    final intensity = (entry.value * 100).round();
                                    return Chip(
                                      label: Text('${entry.key} ($intensity%)'),
                                      backgroundColor: _getEmotionColor(entry.key).withOpacity(0.2),
                                      side: BorderSide(color: _getEmotionColor(entry.key)),
                                    );
                                  }).toList(),
                                ),
                                
                                const SizedBox(height: 16),
                                
                                // Suggestions
                                Text(
                                  'Growth Suggestions',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                ...analysis.suggestions.map((suggestion) => Padding(
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
                        ],
                        
                        const SizedBox(height: 32),
                        
                        // Action Buttons
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: isDark ? const Color(0xFF374151) : Colors.grey[100],
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: ElevatedButton.icon(
                                  onPressed: () => _editJournal(context),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    shadowColor: Colors.transparent,
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                  ),
                                  icon: const Icon(Icons.edit),
                                  label: const Text('Edit'),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: ThemeConfig.primaryGradient,
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: ElevatedButton.icon(
                                  onPressed: () => _shareJournal(context),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    shadowColor: Colors.transparent,
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                  ),
                                  icon: const Icon(Icons.share, color: Colors.white),
                                  label: const Text(
                                    'Share',
                                    style: TextStyle(color: Colors.white),
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
              ],
            ),
          ),
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays == 0) {
      return 'Today at ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays == 1) {
      return 'Yesterday at ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays < 7) {
      final weekdays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
      return '${weekdays[date.weekday - 1]} at ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } else {
      return '${date.day}/${date.month}/${date.year} at ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    }
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

  void _editJournal(BuildContext context) {
    // TODO: Navigate to edit screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Edit functionality coming soon!'),
        backgroundColor: ThemeConfig.primaryBlue,
      ),
    );
  }

  void _deleteJournal(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Journal'),
        content: const Text('Are you sure you want to delete this journal entry? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              // TODO: Implement delete functionality
              Navigator.pop(context);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Journal deleted successfully'),
                  backgroundColor: ThemeConfig.primaryRed,
                ),
              );
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _shareJournal(BuildContext context) {
    // TODO: Implement share functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Share functionality coming soon!'),
        backgroundColor: ThemeConfig.primaryGreen,
      ),
    );
  }
}
