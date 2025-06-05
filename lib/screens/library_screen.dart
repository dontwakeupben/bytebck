import 'package:byteback2/models/Guide.dart';
import 'package:byteback2/widgets/custom_bot_nav.dart';
import 'package:byteback2/widgets/guide_card.dart';
import 'package:byteback2/data/guide_data.dart';
import 'package:flutter/material.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  // State class for LibraryScreen
  String? selectedPlatform;
  List<String> selectedDifficulties = [];
  String? selectedSort;

  List<Guide> get filteredGuides {
    // Filters guides based on selected criteria
    return GuideData.guides.where((guide) {
      bool matchesPlatform =
          selectedPlatform == null || guide.device == selectedPlatform;
      bool matchesDifficulty =
          selectedDifficulties.isEmpty ||
          selectedDifficulties.contains(guide.difficulty);
      return matchesPlatform && matchesDifficulty;
    }).toList();
  }

  void _showFilterMenu() {
    showModalBottomSheet(
      // Show filter options in a bottom sheet
      context: context,
      backgroundColor: const Color(0xFF233C23),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        // Builder for the bottom sheet
        return StatefulBuilder(
          // Use StatefulBuilder to manage state within the modal
          builder: (BuildContext context, StateSetter setModalState) {
            // SetModalState allows us to update the modal's state
            // Build the filter options UI
            return Container(
              padding: const EdgeInsets.all(24),
              child: Column(
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
    // Builds a filter button with visual feedback for selection
    // Returns a button with a label, visual feedback for selection, and an onTap callback
    return InkWell(
      // Use InkWell for tap feedback
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF233C23),
      body: SafeArea(
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment
                  .start, // Align children to the start of the column
          children: [
            Row(
              mainAxisAlignment:
                  MainAxisAlignment
                      .spaceBetween, // Space between logo and profile picture
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
                    // GestureDetector to handle tap on filter icon
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
            const SizedBox(height: 12),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                children: [
                  const Text(
                    'Your Guides',
                    style: TextStyle(
                      fontFamily: 'CenturyGo',
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...filteredGuides // Display guides based on the selected filters
                      .where(
                        (guide) => guide.isMine,
                      ) // Show only guides created by the user
                      .map(
                        // Map each guide to a GuideCard widget
                        (guide) => GuideCard(
                          title: guide.title,
                          subtitle: guide.subtitle,
                          image: guide.image,
                          difficulty: guide.difficulty,
                          device: guide.device,
                          createdBy: guide.createdBy,
                          isMine: guide.isMine,
                        ),
                      ),
                  const SizedBox(height: 24),
                  const Text(
                    'Liked Guides',
                    style: TextStyle(
                      fontFamily: 'CenturyGo',
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...filteredGuides //
                      .where((guide) => guide.isLiked)
                      .map(
                        (guide) => GuideCard(
                          title: guide.title,
                          subtitle: guide.subtitle,
                          image: guide.image,
                          difficulty: guide.difficulty,
                          device: guide.device,
                          createdBy: guide.createdBy,
                          isMine: guide.isMine,
                        ),
                      ),
                  const SizedBox(height: 24),
                  const Text(
                    'Downloaded Guides',
                    style: TextStyle(
                      fontFamily: 'CenturyGo',
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...filteredGuides // Show guides that are downloaded
                      .where((guide) => guide.isDownloaded)
                      .map(
                        (guide) => GuideCard(
                          title: guide.title,
                          subtitle: guide.subtitle,
                          image: guide.image,
                          difficulty: guide.difficulty,
                          device: guide.device,
                          createdBy: guide.createdBy,
                          isMine: guide.isMine,
                        ),
                      ),
                ],
              ),
            ),
            CustomBottomNav(currentIndex: 2),
          ],
        ),
      ),
    );
  }
}
