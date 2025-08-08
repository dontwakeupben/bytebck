import 'package:byteback2/models/Guide.dart';
import 'package:byteback2/services/guide_service.dart';
import 'package:byteback2/widgets/guide_card.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

/// Advanced search screen demonstrating comprehensive Firestore query capabilities
/// Implements all required database operations: filtering, sorting, aggregation, and CRUD
class AdvancedSearchScreen extends StatefulWidget {
  const AdvancedSearchScreen({super.key});

  @override
  State<AdvancedSearchScreen> createState() => _AdvancedSearchScreenState();
}

class _AdvancedSearchScreenState extends State<AdvancedSearchScreen> {
  final GuideService _guideService = GetIt.instance<GuideService>();
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _creatorController = TextEditingController();

  List<Guide> _searchResults = [];
  bool _isLoading = false;
  String _selectedSearchType = 'basic';
  String _selectedSortOrder = 'newest';
  List<String> _selectedDevices = [];
  List<String> _selectedDifficulties = [];

  @override
  void initState() {
    super.initState();
  }

  Future<void> _performSearch() async {
    setState(() => _isLoading = true);

    try {
      List<Guide> results = [];

      switch (_selectedSearchType) {
        case 'basic':
          if (_searchController.text.isNotEmpty) {
            results = await _guideService.searchGuides(_searchController.text);
          } else {
            results = await _guideService.getAllGuides();
          }
          break;

        case 'advanced':
          results = await _guideService.searchGuidesAdvanced(
            titleContains:
                _titleController.text.isNotEmpty ? _titleController.text : null,
            descriptionContains:
                _descriptionController.text.isNotEmpty
                    ? _descriptionController.text
                    : null,
            createdByContains:
                _creatorController.text.isNotEmpty
                    ? _creatorController.text
                    : null,
          );
          break;

        case 'filter':
          // Unified filter that handles single and multiple selections intelligently
          if (_selectedDevices.isEmpty && _selectedDifficulties.isEmpty) {
            // No filters selected, show all guides
            results = await _guideService.getAllGuides();
          } else {
            // Apply selected filters
            results = await _guideService.getGuidesWithAdvancedFilters(
              devices: _selectedDevices.isNotEmpty ? _selectedDevices : null,
              difficulties:
                  _selectedDifficulties.isNotEmpty
                      ? _selectedDifficulties
                      : null,
            );
          }
          break;

        case 'trending':
          results = await _guideService.getTrendingGuides(limit: 20);
          break;

        case 'recommended':
          results = await _guideService.getRecommendedGuides(limit: 20);
          break;
      }

      // Apply sorting
      switch (_selectedSortOrder) {
        case 'newest':
          results = await _guideService.getGuidesSortedByNewest();
          break;
        case 'popular':
          results = await _guideService.getGuidesSortedByPopularity();
          break;
        case 'title_asc':
          results = await _guideService.getGuidesSortedByTitle(ascending: true);
          break;
        case 'title_desc':
          results = await _guideService.getGuidesSortedByTitle(
            ascending: false,
          );
          break;
      }

      setState(() {
        _searchResults = results;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Search error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF233C23),
      appBar: AppBar(
        title: const Text(
          'Advanced Search',
          style: TextStyle(fontFamily: 'CenturyGo', color: Colors.white),
        ),
        backgroundColor: const Color(0xFF233C23),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 20),
        child: Column(
          children: [
            // Search Controls Section
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Color(0xFF2A4A2A),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Search Type Selector
                  const Text(
                    'Search Type:',
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'CenturyGo',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 10,
                    runSpacing: 8,
                    children: [
                      _buildSearchTypeChip('basic', 'Basic Search'),
                      _buildSearchTypeChip('advanced', 'Advanced Search'),
                      _buildSearchTypeChip('filter', 'Filter by Criteria'),
                      _buildSearchTypeChip('trending', 'Trending'),
                      _buildSearchTypeChip('recommended', 'Recommended'),
                    ],
                  ),
                  const SizedBox(height: 20), // Search Input Fields
                  if (_selectedSearchType == 'basic') ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF233C23),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white24),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Basic Search',
                            style: TextStyle(
                              color: Color(0xFFF8F5E3),
                              fontFamily: 'CenturyGo',
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _searchController,
                            style: const TextStyle(color: Colors.white),
                            decoration: const InputDecoration(
                              hintText: 'Search guides...',
                              hintStyle: TextStyle(color: Colors.white70),
                              border: OutlineInputBorder(),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.white70),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Color(0xFFF8F5E3),
                                ),
                              ),
                              prefixIcon: Icon(
                                Icons.search,
                                color: Colors.white70,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  if (_selectedSearchType == 'advanced') ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF233C23),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white24),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Advanced Search Fields',
                            style: TextStyle(
                              color: Color(0xFFF8F5E3),
                              fontFamily: 'CenturyGo',
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _titleController,
                            style: const TextStyle(color: Colors.white),
                            decoration: const InputDecoration(
                              hintText: 'Title contains...',
                              hintStyle: TextStyle(color: Colors.white70),
                              border: OutlineInputBorder(),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.white70),
                              ),
                              prefixIcon: Icon(
                                Icons.title,
                                color: Colors.white70,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _descriptionController,
                            style: const TextStyle(color: Colors.white),
                            decoration: const InputDecoration(
                              hintText: 'Description contains...',
                              hintStyle: TextStyle(color: Colors.white70),
                              border: OutlineInputBorder(),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.white70),
                              ),
                              prefixIcon: Icon(
                                Icons.description,
                                color: Colors.white70,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _creatorController,
                            style: const TextStyle(color: Colors.white),
                            decoration: const InputDecoration(
                              hintText: 'Creator contains...',
                              hintStyle: TextStyle(color: Colors.white70),
                              border: OutlineInputBorder(),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.white70),
                              ),
                              prefixIcon: Icon(
                                Icons.person,
                                color: Colors.white70,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  if (_selectedSearchType == 'filter') ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF233C23),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white24),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Filter Options',
                            style: TextStyle(
                              color: Color(0xFFF8F5E3),
                              fontFamily: 'CenturyGo',
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Select one or multiple criteria to filter guides',
                            style: TextStyle(
                              color: Colors.white70,
                              fontFamily: 'CenturyGo',
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Device Types:',
                            style: TextStyle(
                              color: Colors.white,
                              fontFamily: 'CenturyGo',
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 10,
                            runSpacing: 8,
                            children: [
                              _buildFilterChip(
                                'Desktop',
                                _selectedDevices,
                                true,
                              ),
                              _buildFilterChip(
                                'Laptop',
                                _selectedDevices,
                                true,
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            'Difficulties:',
                            style: TextStyle(
                              color: Colors.white,
                              fontFamily: 'CenturyGo',
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 10,
                            runSpacing: 8,
                            children: [
                              _buildFilterChip(
                                'Easy',
                                _selectedDifficulties,
                                false,
                              ),
                              _buildFilterChip(
                                'Medium',
                                _selectedDifficulties,
                                false,
                              ),
                              _buildFilterChip(
                                'Hard',
                                _selectedDifficulties,
                                false,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 20),

                  // Sort Order Selector
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF233C23),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white24),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Sort Order:',
                          style: TextStyle(
                            color: Color(0xFFF8F5E3),
                            fontFamily: 'CenturyGo',
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 10,
                          runSpacing: 8,
                          children: [
                            _buildSortChip('newest', 'Newest First'),
                            _buildSortChip('popular', 'Most Popular'),
                            _buildSortChip('title_asc', 'A-Z'),
                            _buildSortChip('title_desc', 'Z-A'),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Search Button
                  Container(
                    width: double.infinity,
                    height: 52,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFF8F5E3), Color(0xFFE8E0C3)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: _performSearch,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(
                            Icons.search,
                            color: Color(0xFF233C23),
                            size: 20,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Search Guides',
                            style: TextStyle(
                              color: Color(0xFF233C23),
                              fontFamily: 'CenturyGo',
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Search Results
            Container(
              margin: const EdgeInsets.only(top: 16),
              child:
                  _isLoading
                      ? Container(
                        height: 300,
                        child: const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircularProgressIndicator(
                                color: Color(0xFFF8F5E3),
                                strokeWidth: 3,
                              ),
                              SizedBox(height: 16),
                              Text(
                                'Searching guides...',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontFamily: 'CenturyGo',
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                      : _searchResults.isEmpty
                      ? Container(
                        height: 300,
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.search_off,
                                size: 64,
                                color: Colors.white.withOpacity(0.3),
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'No results found',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'CenturyGo',
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Try adjusting your search criteria\nor select a different search type.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontFamily: 'CenturyGo',
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                      : Column(
                        children: [
                          // Results Header
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.list_alt,
                                  color: const Color(0xFFF8F5E3),
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '${_searchResults.length} result${_searchResults.length == 1 ? '' : 's'} found',
                                  style: const TextStyle(
                                    color: Color(0xFFF8F5E3),
                                    fontFamily: 'CenturyGo',
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Results List
                          ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            itemCount: _searchResults.length,
                            separatorBuilder:
                                (context, index) => const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final guide = _searchResults[index];
                              return GuideCard(
                                guide: guide,
                                onUpdate: () {
                                  // Optionally refresh search results
                                  // _performSearch(); // Uncomment if you want to refresh on update
                                },
                              );
                            },
                          ),
                        ],
                      ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchTypeChip(String value, String label) {
    final isSelected = _selectedSearchType == value;
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow:
            isSelected
                ? [
                  BoxShadow(
                    color: const Color(0xFFF8F5E3).withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
                : null,
      ),
      child: FilterChip(
        label: Text(
          label,
          style: TextStyle(
            color: isSelected ? const Color(0xFF233C23) : Colors.white,
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            _selectedSearchType = value;
            _searchResults.clear();
          });
        },
        selectedColor: const Color(0xFFF8F5E3),
        backgroundColor: const Color(0xFF1A2E1A),
        side: BorderSide(
          color: isSelected ? const Color(0xFFF8F5E3) : Colors.white54,
          width: isSelected ? 2 : 1,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
    );
  }

  Widget _buildSortChip(String value, String label) {
    final isSelected = _selectedSortOrder == value;
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow:
            isSelected
                ? [
                  BoxShadow(
                    color: const Color(0xFFF8F5E3).withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
                : null,
      ),
      child: FilterChip(
        label: Text(
          label,
          style: TextStyle(
            color: isSelected ? const Color(0xFF233C23) : Colors.white,
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            _selectedSortOrder = value;
          });
        },
        selectedColor: const Color(0xFFF8F5E3),
        backgroundColor: const Color(0xFF1A2E1A),
        side: BorderSide(
          color: isSelected ? const Color(0xFFF8F5E3) : Colors.white54,
          width: isSelected ? 2 : 1,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
    );
  }

  Widget _buildFilterChip(
    String value,
    List<String> selectedList,
    bool isDevice,
  ) {
    final isSelected = selectedList.contains(value);
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow:
            isSelected
                ? [
                  BoxShadow(
                    color: const Color(0xFFF8F5E3).withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
                : null,
      ),
      child: FilterChip(
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isDevice
                  ? (value == 'Desktop' ? Icons.computer : Icons.laptop)
                  : (value == 'Easy'
                      ? Icons.star_outline
                      : value == 'Medium'
                      ? Icons.star_half
                      : Icons.star),
              size: 16,
              color: isSelected ? const Color(0xFF233C23) : Colors.white70,
            ),
            const SizedBox(width: 6),
            Text(
              value,
              style: TextStyle(
                color: isSelected ? const Color(0xFF233C23) : Colors.white,
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            if (selected) {
              selectedList.add(value);
            } else {
              selectedList.remove(value);
            }
          });
        },
        selectedColor: const Color(0xFFF8F5E3),
        backgroundColor: const Color(0xFF1A2E1A),
        side: BorderSide(
          color: isSelected ? const Color(0xFFF8F5E3) : Colors.white54,
          width: isSelected ? 2 : 1,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    _creatorController.dispose();
    super.dispose();
  }
}
