import 'package:byteback2/services/firebase_service.dart';
import 'package:flutter/material.dart';
import 'package:byteback2/widgets/device_button.dart';
import 'package:byteback2/widgets/custom_bot_nav.dart';
import 'package:byteback2/screens/feed_screen.dart';
import 'package:get_it/get_it.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  FirebaseService fbService = GetIt.instance<FirebaseService>();

  void _navigateToFeedWithFilter(BuildContext context, String device) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => FeedScreen(initialDevice: device),
      ),
    );
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
                    final email = user.email;
                    return FittedBox(
                      child: Text(
                        "Hello " + (email ?? "User") + "!",
                        style: const TextStyle(
                          fontFamily: 'CenturyGo',
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
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
                            () => _navigateToFeedWithFilter(context, 'Desktop'),
                      ),
                      const SizedBox(width: 60),
                      DeviceButton(
                        icon: Icons.laptop_chromebook_outlined,
                        label: 'Laptop',
                        onTap:
                            () => _navigateToFeedWithFilter(context, 'Laptop'),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const Spacer(),
            CustomBottomNav(currentIndex: 0),
          ],
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 80, right: 10),
        child: FloatingActionButton(
          backgroundColor: const Color(0xFFF8F5E3),
          onPressed: () {
            Navigator.of(context).pushNamed('/create');
          },
          child: Icon(Icons.add, color: Color.fromARGB(255, 0, 0, 0)),
        ),
      ),
    );
  }
}
