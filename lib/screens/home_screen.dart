import 'package:byteback2/services/firebase_service.dart';
import 'package:flutter/material.dart';
import 'package:byteback2/widgets/device_button.dart';
import 'package:byteback2/widgets/custom_bot_nav.dart';
import 'package:byteback2/screens/main_navigation_screen.dart';
import 'package:get_it/get_it.dart';

class HomeScreen extends StatefulWidget {
  final bool showBottomNav;

  const HomeScreen({super.key, this.showBottomNav = true});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  FirebaseService fbService = GetIt.instance<FirebaseService>();

  void _navigateToFeedWithFilter(BuildContext context, String device) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder:
            (context) => MainNavigationScreen(
              initialIndex: 1, // Navigate to feed tab
              initialDevice: device,
            ),
      ),
    );
  }

  // Refresh function for pull-to-refresh
  Future<void> _refreshPage() async {
    // Reload user data and refresh the UI
    await fbService.reloadUser();
    await Future.delayed(
      const Duration(milliseconds: 500),
    ); // Small delay for UX
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF233C23),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refreshPage,
          color: const Color(0xFF233C23),
          backgroundColor: const Color(0xFFF8F5E3),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Container(
              height:
                  MediaQuery.of(context).size.height -
                  MediaQuery.of(context).padding.top -
                  MediaQuery.of(context).padding.bottom,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
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
                          children: [
                            Image.asset('images/logo.png', width: 100),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 24, top: 10),
                        child: GestureDetector(
                          onTap:
                              () => Navigator.of(context).pushNamed('/profile'),
                          child: CircleAvatar(
                            backgroundColor: const Color(0xFFF8F5E3),
                            radius: 30,
                            backgroundImage: AssetImage('images/pfp.jpeg'),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Welcome,',
                          style: TextStyle(
                            fontFamily: 'CenturyGo',
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        (() {
                          final user = fbService.getCurrentUser();
                          if (user == null) {
                            return const Text("Hello Friend!");
                          }

                          return FutureBuilder<Map<String, dynamic>?>(
                            future: fbService.getCurrentUserDocument(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Text(
                                  "Loading...",
                                  style: TextStyle(
                                    fontFamily: 'CenturyGo',
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                );
                              }

                              final userData = snapshot.data;
                              final fullName =
                                  userData?['displayName'] ??
                                  userData?['fullName'] ??
                                  user.email ??
                                  "User";

                              return FittedBox(
                                child: Text(
                                  "Hello $fullName!",
                                  style: const TextStyle(
                                    fontFamily: 'CenturyGo',
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              );
                            },
                          );
                        })(),

                        const SizedBox(height: 24),
                        const Text(
                          'What device would you like to find for?',
                          style: TextStyle(
                            fontFamily: 'CenturyGo',
                            fontSize: 18,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 150),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            DeviceButton(
                              icon: Icons.desktop_windows_outlined,
                              label: 'Desktop',
                              onTap:
                                  () => _navigateToFeedWithFilter(
                                    context,
                                    'Desktop',
                                  ),
                            ),
                            const SizedBox(width: 60),
                            DeviceButton(
                              icon: Icons.laptop_chromebook_outlined,
                              label: 'Laptop',
                              onTap:
                                  () => _navigateToFeedWithFilter(
                                    context,
                                    'Laptop',
                                  ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const Expanded(child: SizedBox()),
                  if (widget.showBottomNav) CustomBottomNav(currentIndex: 0),
                ],
              ),
            ),
          ),
        ),
      ),
      floatingActionButton:
          widget.showBottomNav
              ? Padding(
                padding: const EdgeInsets.only(bottom: 80, right: 10),
                child: FloatingActionButton(
                  backgroundColor: const Color(0xFFF8F5E3),
                  onPressed: () {
                    Navigator.of(context).pushNamed('/create');
                  },
                  child: Icon(Icons.add, color: Color.fromARGB(255, 0, 0, 0)),
                ),
              )
              : null,
    );
  }
}
