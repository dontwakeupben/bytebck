import 'package:byteback2/models/Guide.dart';
import 'package:byteback2/widgets/custom_bot_nav.dart';
import 'package:byteback2/widgets/guide_card.dart';
import 'package:byteback2/services/guide_service.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class FeedScreen extends StatefulWidget {
  final String? initialDevice;
  final bool showBottomNav;

  const FeedScreen({super.key, this.initialDevice, this.showBottomNav = true});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  final GuideService _guideService = GetIt.instance<GuideService>();
  String? selectedPlatform;
  List<String> selectedDifficulties = [];
  String? selectedSort;
  List<Guide> _guides = [];
  bool _isLoading = true;

  @override
  void initState() {
    // Initialize the selected platform with the initial device if provided from the home screen
    super.initState();
    selectedPlatform = widget.initialDevice;
    _loadGuides();
  }

  Future<void> _loadGuides() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final guides = await _guideService.getAllGuides();
      setState(() {
        _guides = guides;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('Error loading guides: $e');
    }
  }

  // Refresh function for pull-to-refresh
  Future<void> _refreshPage() async {
    // Refresh the guide data from Firestore
    await _loadGuides();
  }

  void _showFilterMenu() {
    // Show the filter modal bottom sheet
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF233C23),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return StatefulBuilder(
          // Use StatefulBuilder to manage state within the modal
          builder: (BuildContext context, StateSetter setModalState) {
            // Allows us to update the modal state independently
            return Container(
              padding: const EdgeInsets.all(24),
              child: Column(
                // Main content of the filter modal
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Filters',
                    style: TextStyle(
                      fontFamily: 'CenturyGo',
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Platform',
                    style: TextStyle(
                      fontFamily: 'CenturyGo',
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _buildFilterButton(
                          'Laptop',
                          selectedPlatform == 'Laptop',
                          () =>
                              setModalState(() => selectedPlatform = 'Laptop'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildFilterButton(
                          'Desktop',
                          selectedPlatform == 'Desktop',
                          () =>
                              setModalState(() => selectedPlatform = 'Desktop'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Difficulty',
                    style: TextStyle(
                      fontFamily: 'CenturyGo',
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _buildFilterButton(
                          'Easy',
                          selectedDifficulties.contains('Easy'),
                          () {
                            setModalState(() {
                              if (selectedDifficulties.contains('Easy')) {
                                selectedDifficulties.remove('Easy');
                              } else {
                                selectedDifficulties.add('Easy');
                              }
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildFilterButton(
                          'Medium',
                          selectedDifficulties.contains('Medium'),
                          () {
                            setModalState(() {
                              if (selectedDifficulties.contains('Medium')) {
                                selectedDifficulties.remove('Medium');
                              } else {
                                selectedDifficulties.add('Medium');
                              }
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildFilterButton(
                          'Hard',
                          selectedDifficulties.contains('Hard'),
                          () {
                            setModalState(() {
                              if (selectedDifficulties.contains('Hard')) {
                                selectedDifficulties.remove('Hard');
                              } else {
                                selectedDifficulties.add('Hard');
                              }
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Sort By',
                    style: TextStyle(
                      fontFamily: 'CenturyGo',
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _buildFilterButton(
                          'Most Popular',
                          selectedSort == 'Most Popular',
                          () => setModalState(
                            () => selectedSort = 'Most Popular',
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildFilterButton(
                          'Newest',
                          selectedSort == 'Newest',
                          () => setModalState(() => selectedSort = 'Newest'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () {
                            setModalState(() {
                              selectedPlatform = null;
                              selectedDifficulties = [];
                              selectedSort = null;
                            });
                          },
                          child: const Text(
                            'Reset',
                            style: TextStyle(
                              color: Colors.white70,
                              fontFamily: 'CenturyGo',
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {});
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFF8F5E3),
                            foregroundColor: const Color(0xFF233C23),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'Apply',
                            style: TextStyle(
                              fontFamily: 'CenturyGo',
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildFilterButton(String label, bool isSelected, VoidCallback onTap) {
    // Helper method to build filter buttons
    // Builds a filter button with the given label, selection state, and tap handler
    // The button's appearance changes based on whether it is selected
    // Returns an InkWell widget that responds to taps
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFF8F5E3) : Colors.white24,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? const Color(0xFF233C23) : Colors.white,
              fontFamily: 'CenturyGo',
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  List<Guide> get filteredGuides {
    // Filters the list of guides based on selected criteria
    // Returns a list of guides that match the selected platform and difficulties
    return _guides.where((guide) {
      bool matchesPlatform =
          selectedPlatform == null || guide.device == selectedPlatform;
      bool matchesDifficulty =
          selectedDifficulties.isEmpty ||
          selectedDifficulties.contains(guide.difficulty);
      return matchesPlatform && matchesDifficulty;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF233C23),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 150, top: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [Image.asset('images/logo.png', width: 100)],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 24, top: 10),
                  child: GestureDetector(
                    onTap: () => Navigator.of(context).pushNamed('/profile'),
                    child: CircleAvatar(
                      backgroundColor: const Color(0xFFF8F5E3),
                      radius: 30,
                      backgroundImage: AssetImage('images/pfp.jpeg'),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8F5E3),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Row(
                        children: [
                          const SizedBox(width: 12),
                          const Icon(Icons.search, color: Colors.black54),
                          const SizedBox(width: 2),
                          Expanded(
                            child: TextField(
                              decoration: InputDecoration(
                                hintText: 'Search parts, guides, fixes',
                                hintStyle: TextStyle(
                                  fontFamily: 'CenturyGo',
                                  color: Colors.black54,
                                ),
                                border: InputBorder.none,
                              ),
                              style: const TextStyle(fontFamily: 'CenturyGo'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: () => Navigator.of(context).pushNamed('/search'),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8F5E3),
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: const Icon(
                        Icons.search_outlined,
                        color: Color(0xFF233C23),
                        size: 24,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: _showFilterMenu,
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8F5E3),
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: const Icon(Icons.tune, color: Colors.black54),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                'New Today',
                style: TextStyle(
                  fontFamily: 'CenturyGo',
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _refreshPage,
                color: const Color(0xFF233C23),
                backgroundColor: const Color(0xFFF8F5E3),
                child:
                    _isLoading
                        ? const Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFFF8F5E3),
                          ),
                        )
                        : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          itemCount: filteredGuides.length,
                          itemBuilder: (context, index) {
                            final guide = filteredGuides[index];
                            return GuideCard(
                              guide: guide,
                              onUpdate: _loadGuides,
                            );
                          },
                        ),
              ),
            ),
            if (widget.showBottomNav) CustomBottomNav(currentIndex: 1),
          ],
        ),
      ),
    );
  }
}
