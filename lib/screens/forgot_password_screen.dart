import 'package:flutter/material.dart';

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF233C23),
      body: Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 40),
          padding: const EdgeInsets.all(24),
          height: 650,
          decoration: BoxDecoration(
            color: const Color(0xFFF8F5E3),
            borderRadius: BorderRadius.circular(28),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 50),
                const Text(
                  'Forget Password',
                  style: TextStyle(
                    fontFamily: 'CenturyGo',
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 150),
                Row(
                  children: [
                    const Icon(Icons.person_outline, size: 28),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Username/Email',
                          hintStyle: TextStyle(
                            fontFamily: 'CenturyGo',
                            color: Colors.grey,
                          ),
                          border: InputBorder.none,
                        ),
                        style: const TextStyle(fontFamily: 'CenturyGo'),
                      ),
                    ),
                  ],
                ),
                const Divider(),
                const SizedBox(height: 150),
                Center(
                  child: SizedBox(
                    width: 200, // Fixed width for shorter button
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/email-sent');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                        minimumSize: const Size.fromHeight(48),
                      ),
                      child: const Text(
                        'Continue',
                        style: TextStyle(
                          fontFamily: 'CenturyGo',
                          fontSize: 18,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
