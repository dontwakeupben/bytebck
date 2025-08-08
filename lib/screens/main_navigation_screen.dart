import 'package:flutter/material.dart';
import 'package:byteback2/screens/home_screen.dart';
import 'package:byteback2/screens/feed_screen.dart';
import 'package:byteback2/screens/library_screen.dart';
import 'package:byteback2/widgets/nav_icon.dart';

/// Main navigation screen that handles smooth tab switching
/// Eliminates jumpy animations by maintaining screen state
class MainNavigationScreen extends StatefulWidget {
  final int initialIndex;
  final String? initialDevice; // For feed screen filtering

  const MainNavigationScreen({
    super.key,
    this.initialIndex = 0,
    this.initialDevice,
  });

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen>
    with TickerProviderStateMixin {
  late PageController _pageController;
  int _currentIndex = 0;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: _currentIndex);

    // Setup smooth fade animation for tab transitions
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 1.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _onTabTapped(int index) {
    if (_currentIndex != index) {
      setState(() {
        _currentIndex = index;
      });

      // Smooth page transition
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: _fadeAnimation,
        builder: (context, child) {
          return FadeTransition(
            opacity: _fadeAnimation,
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(), // Disable swipe
              onPageChanged: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              children: [
                const HomeScreenContent(),
                FeedScreenContent(initialDevice: widget.initialDevice),
                const LibraryScreenContent(),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: Container(
        color: const Color(0xFFF8F5E3),
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            NavIcon(
              icon: Icons.home,
              selected: _currentIndex == 0,
              onTap: () => _onTabTapped(0),
            ),
            NavIcon(
              icon: Icons.search,
              selected: _currentIndex == 1,
              onTap: () => _onTabTapped(1),
            ),
            NavIcon(
              icon: Icons.menu,
              selected: _currentIndex == 2,
              onTap: () => _onTabTapped(2),
            ),
          ],
        ),
      ),
      floatingActionButton:
          _currentIndex == 0
              ? Padding(
                padding: const EdgeInsets.only(bottom: 16, right: 10),
                child: FloatingActionButton(
                  backgroundColor: const Color(0xFFF8F5E3),
                  onPressed: () {
                    Navigator.of(context).pushNamed('/create');
                  },
                  child: const Icon(
                    Icons.add,
                    color: Color.fromARGB(255, 0, 0, 0),
                  ),
                ),
              )
              : null,
    );
  }
}

/// Content-only version of HomeScreen for tab navigation
class HomeScreenContent extends StatefulWidget {
  const HomeScreenContent({super.key});

  @override
  State<HomeScreenContent> createState() => _HomeScreenContentState();
}

class _HomeScreenContentState extends State<HomeScreenContent>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true; // Keep state when switching tabs

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin

    // Return the HomeScreen content without the bottom navigation
    return const HomeScreen(showBottomNav: false);
  }
}

/// Content-only version of LibraryScreen for tab navigation
class LibraryScreenContent extends StatefulWidget {
  const LibraryScreenContent({super.key});

  @override
  State<LibraryScreenContent> createState() => _LibraryScreenContentState();
}

class _LibraryScreenContentState extends State<LibraryScreenContent>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true; // Keep state when switching tabs

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin

    // Return the LibraryScreen content without the bottom navigation
    return const LibraryScreen(showBottomNav: false);
  }
}

/// Content-only version of FeedScreen for tab navigation
class FeedScreenContent extends StatefulWidget {
  final String? initialDevice;

  const FeedScreenContent({super.key, this.initialDevice});

  @override
  State<FeedScreenContent> createState() => _FeedScreenContentState();
}

class _FeedScreenContentState extends State<FeedScreenContent>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true; // Keep state when switching tabs

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin

    // Return the FeedScreen content without the bottom navigation
    return FeedScreen(
      initialDevice: widget.initialDevice,
      showBottomNav: false,
    );
  }
}
