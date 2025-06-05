import 'package:flutter/material.dart';

class PremiumScreen extends StatelessWidget {
  const PremiumScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD1B3E0), // light purple
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 8, top: 8),
              child: Align(
                alignment: Alignment.topLeft,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
            Center(
              child: Container(
                margin: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 40,
                ),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F5E3),
                  borderRadius: BorderRadius.circular(28),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset('images/logo.png', width: 100),
                    const SizedBox(height: 16),
                    const Icon(Icons.star, size: 48, color: Colors.black87),
                    const SizedBox(height: 16),
                    const Text(
                      'Experience the difference',
                      style: TextStyle(
                        fontFamily: 'CenturyGo',
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Go Premium and enjoy full control over your user experience. 50% goes to e-waste charity organisations, cancel anytime.',
                      style: TextStyle(
                        fontFamily: 'CenturyGo',
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Go Premium, Give Back!',
                      style: TextStyle(
                        fontFamily: 'CenturyGo',
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Unlock the full experience with our Premium Plan—get access to in-depth video guides, advanced repair tutorials, and expert-level tips to fix your computer faster and smarter.\n\nBut here\'s the best part: 50% of all Premium earnings go directly to e-waste charities in Singapore.\n\nSo every time you learn and level up with Premium, you\'re also helping reduce tech waste and support a cleaner, greener future. Learn more. Waste less. Make an impact.',
                      style: TextStyle(
                        fontFamily: 'CenturyGo',
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () {},
                      icon: Image.asset('images/nets.png', width: 30),
                      label: const Text(
                        'Continue to Payment >',
                        style: TextStyle(
                          fontFamily: 'CenturyGo',
                          fontSize: 18,
                          color: Colors.black,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD1B3E0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        minimumSize: const Size.fromHeight(48),
                      ),
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
}
