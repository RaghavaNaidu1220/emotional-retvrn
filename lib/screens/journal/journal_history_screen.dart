import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/journal_provider.dart';
import '../../core/config/theme_config.dart';
import 'journal_detail_screen.dart';

class JournalHistoryScreen extends StatefulWidget {
  const JournalHistoryScreen({super.key});

  @override
  State<JournalHistoryScreen> createState() => _JournalHistoryScreenState();
}

class _JournalHistoryScreenState extends State<JournalHistoryScreen> {
  String _searchQuery = '';
  String _selectedFilter = 'All';
  final List<String> _filters = ['All', 'Text', 'Voice', 'This Week', 'This Month'];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Consumer<JournalProvider>(
      builder: (context, journalProvider, child) {
        final filteredJournals = _getFilteredJournals(journalProvider.journals);
        
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
                  child: Column(
                    children: [
                      Row(
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
                                  'Journal History',
                                  style: Theme.of(context).textTheme.headlineMedium,
                                ),
                                Text(
                                  '${filteredJournals.length} entries',
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: ThemeConfig.primaryGradient,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: IconButton(
                              onPressed: () {
                                // Show search/filter options
                                _showFilterBottomSheet(context);
                              },
                              icon: const Icon(Icons.tune, color: Colors.white, size: 20),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      
                      // Search Bar
                      Container(
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF374151) : const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: TextField(
                          onChanged: (value) {
                            setState(() {
                              _searchQuery = value;
                            });
                          },
                          decoration: InputDecoration(
                            hintText: 'Search your journals...',
                            prefixIcon: Icon(Icons.search, color: Colors.grey[500]),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.all(16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Filter Chips
                Container(
                  height: 60,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: _filters.length,
                    itemBuilder: (context, index) {
                      final filter = _filters[index];
                      final isSelected = _selectedFilter == filter;
                      
                      return Container(
                        margin: const EdgeInsets.only(right: 12),
                        child: FilterChip(
                          label: Text(filter),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              _selectedFilter = filter;
                            });
                          },
                          backgroundColor: isDark ? const Color(0xFF374151) : Colors.grey[100],
                          selectedColor: ThemeConfig.primaryPurple.withOpacity(0.2),
                          checkmarkColor: ThemeConfig.primaryPurple,
                          labelStyle: TextStyle(
                            color: isSelected ? ThemeConfig.primaryPurple : Colors.grey[600],
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                
                // Journal List
                Expanded(
                  child: filteredJournals.isEmpty
                      ? _buildEmptyState(isDark)
                      : ListView.builder(
                          padding: const EdgeInsets.all(20),
                          itemCount: filteredJournals.length,
                          itemBuilder: (context, index) {
                            final journal = filteredJournals[index];
                            return _buildJournalCard(journal, isDark);
                          },
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  List<dynamic> _getFilteredJournals(List<dynamic> journals) {
    var filtered = journals.where((journal) {
      // Search filter
      if (_searchQuery.isNotEmpty) {
        final content = journal.content?.toLowerCase() ?? '';
        if (!content.contains(_searchQuery.toLowerCase())) {
          return false;
        }
      }
      
      // Type filter
      switch (_selectedFilter) {
        case 'Text':
          return journal.content != null && journal.content.isNotEmpty;
        case 'Voice':
          return journal.transcript != null && journal.transcript.isNotEmpty;
        case 'This Week':
          final weekAgo = DateTime.now().subtract(const Duration(days: 7));
          return journal.createdAt.isAfter(weekAgo);
        case 'This Month':
          final monthAgo = DateTime.now().subtract(const Duration(days: 30));
          return journal.createdAt.isAfter(monthAgo);
        default:
          return true;
      }
    }).toList();
    
    return filtered;
  }

  Widget _buildJournalCard(dynamic journal, bool isDark) {
    String contentPreview = 'Voice Journal';
    if (journal.content != null && journal.content.isNotEmpty) {
      contentPreview = journal.content.length > 100 
          ? journal.content.substring(0, 100) + '...'
          : journal.content;
    }
    
    final now = DateTime.now();
    final journalDate = journal.createdAt;
    final difference = now.difference(journalDate);
    
    String timeAgo;
    if (difference.inDays > 0) {
      timeAgo = '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      timeAgo = '${difference.inHours}h ago';
    } else {
      timeAgo = '${difference.inMinutes}m ago';
    }
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => JournalDetailScreen(journal: journal),
              ),
            );
          },
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(20),
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
                    Expanded(
                      child: Text(
                        timeAgo,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 14,
                      color: Colors.grey[400],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  contentPreview,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    height: 1.5,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  ThemeConfig.primaryPurple.withOpacity(0.1),
                  ThemeConfig.primaryBlue.withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              Icons.search_off,
              size: 40,
              color: ThemeConfig.primaryPurple,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'No journals found',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your search or filters',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  void _showFilterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Filter Options',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: _filters.map((filter) {
                final isSelected = _selectedFilter == filter;
                return FilterChip(
                  label: Text(filter),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      _selectedFilter = filter;
                    });
                    Navigator.pop(context);
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
