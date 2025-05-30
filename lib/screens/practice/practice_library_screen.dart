import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/config/theme_config.dart';
import '../../providers/practice_provider.dart';
import '../../models/practice_model.dart';
import 'practice_detail_screen.dart';

class PracticeLibraryScreen extends StatefulWidget {
  const PracticeLibraryScreen({Key? key}) : super(key: key);

  @override
  State<PracticeLibraryScreen> createState() => _PracticeLibraryScreenState();
}

class _PracticeLibraryScreenState extends State<PracticeLibraryScreen> {
  String _selectedCategory = 'All';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<PracticeProvider>(context, listen: false).loadPractices();
    });
  }
  
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    
    // Responsive grid columns
    int crossAxisCount;
    if (screenWidth > 1200) {
      crossAxisCount = 6; // Desktop
    } else if (screenWidth > 800) {
      crossAxisCount = 4; // Tablet
    } else if (screenWidth > 600) {
      crossAxisCount = 3; // Large mobile
    } else {
      crossAxisCount = 2; // Mobile
    }
    
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
      body: CustomScrollView(
        slivers: [
          // Modern App Bar
          SliverAppBar(
            expandedHeight: 120,
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
                    colors: [
                      ThemeConfig.primaryPurple.withOpacity(0.1),
                      ThemeConfig.primaryBlue.withOpacity(0.1),
                    ],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: ThemeConfig.primaryGradient,
                                ),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Icon(
                                Icons.fitness_center,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Practice Library',
                                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: isDark ? Colors.white : Colors.black87,
                                    ),
                                  ),
                                  Text(
                                    'Discover mindfulness practices',
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: isDark ? const Color(0xFF1E293B) : Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: const Icon(Icons.refresh, size: 20),
                              ),
                              onPressed: () {
                                Provider.of<PracticeProvider>(context, listen: false).loadPractices();
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          
          // Search and Filters
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Search bar
                  Container(
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
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search practices...',
                        prefixIcon: Icon(
                          Icons.search,
                          color: ThemeConfig.primaryPurple,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 16,
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value;
                        });
                      },
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Category filter
                  SizedBox(
                    height: 40,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        _buildCategoryChip('All', isDark),
                        _buildCategoryChip('Meditation', isDark),
                        _buildCategoryChip('Breathing', isDark),
                        _buildCategoryChip('Mindfulness', isDark),
                        _buildCategoryChip('Emotional', isDark),
                        _buildCategoryChip('Spiral', isDark),
                        _buildCategoryChip('Journaling', isDark),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Practices Grid
          Consumer<PracticeProvider>(
            builder: (context, practiceProvider, child) {
              if (practiceProvider.isLoading) {
                return SliverToBoxAdapter(child: _buildLoadingState());
              }
              
              final allPractices = practiceProvider.practices.isEmpty 
                  ? PracticeModel.getSamplePractices()
                  : practiceProvider.practices;
              
              final filteredPractices = allPractices.where((practice) {
                final matchesCategory = _selectedCategory == 'All' || 
                    practice.category.toLowerCase().contains(_selectedCategory.toLowerCase());
                final matchesSearch = _searchQuery.isEmpty || 
                    practice.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                    practice.description.toLowerCase().contains(_searchQuery.toLowerCase());
                return matchesCategory && matchesSearch;
              }).toList();
              
              if (filteredPractices.isEmpty) {
                return SliverToBoxAdapter(child: _buildNoResultsState());
              }
              
              return SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverGrid(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    childAspectRatio: 0.85,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final practice = filteredPractices[index];
                      return _buildCompactPracticeCard(practice, isDark);
                    },
                    childCount: filteredPractices.length,
                  ),
                ),
              );
            },
          ),
          
          // Bottom padding
          const SliverToBoxAdapter(
            child: SizedBox(height: 100),
          ),
        ],
      ),
    );
  }
  
  Widget _buildCategoryChip(String category, bool isDark) {
    final isSelected = _selectedCategory == category;
    
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        child: FilterChip(
          label: Text(category),
          selected: isSelected,
          onSelected: (selected) {
            setState(() {
              _selectedCategory = category;
            });
          },
          backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
          selectedColor: ThemeConfig.primaryPurple.withOpacity(0.15),
          checkmarkColor: ThemeConfig.primaryPurple,
          side: BorderSide(
            color: isSelected 
                ? ThemeConfig.primaryPurple 
                : Colors.transparent,
            width: 1.5,
          ),
          labelStyle: TextStyle(
            color: isSelected 
                ? ThemeConfig.primaryPurple 
                : (isDark ? Colors.white70 : Colors.black87),
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            fontSize: 13,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          elevation: isSelected ? 2 : 0,
          shadowColor: ThemeConfig.primaryPurple.withOpacity(0.3),
        ),
      ),
    );
  }
  
  Widget _buildCompactPracticeCard(PracticeModel practice, bool isDark) {
    final colors = _getCategoryColors(practice.category);
    
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => PracticeDetailScreen(practice: practice),
          ),
        );
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Compact header with gradient
            Container(
              height: 50,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: colors,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Center(
                child: Icon(
                  _getCategoryIcon(practice.category),
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
            
            // Compact content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      practice.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Expanded(
                      child: Text(
                        practice.description,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 10,
                          height: 1.2,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.timer_outlined,
                          size: 10,
                          color: Colors.grey[500],
                        ),
                        const SizedBox(width: 2),
                        Text(
                          practice.duration,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 9,
                            fontWeight: FontWeight.w500,
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
  
  Widget _buildLoadingState() {
    return Container(
      height: 300,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: ThemeConfig.primaryGradient,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 3,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Loading practices...',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildNoResultsState() {
    return Container(
      height: 300,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: ThemeConfig.primaryBlue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                Icons.search_off,
                size: 48,
                color: ThemeConfig.primaryBlue,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'No matching practices',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try adjusting your filters',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _selectedCategory = 'All';
                  _searchQuery = '';
                  _searchController.clear();
                });
              },
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Reset filters'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
