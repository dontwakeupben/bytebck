import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _passwordVisible = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF233C23),
      body: Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 40),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFFF8F5E3),
            borderRadius: BorderRadius.circular(28),
          ),

          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 24),
              Text(
                'Login',
                style: TextStyle(
                  fontFamily: 'CenturyGo',
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  const Icon(Icons.person_outline, size: 28),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Username',
                        hintStyle: TextStyle(
                          fontFamily: 'CenturyGo',
                          color: Colors.grey[500],
                        ),
                        border: InputBorder.none,
                      ),
                      style: const TextStyle(fontFamily: 'CenturyGo'),
                    ),
                  ),
                ],
              ),
              const Divider(),
              Row(
                children: [
                  const Icon(Icons.lock_outline, size: 28),
                  const SizedBox(width: 8),

                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(top: 10),
                      child: TextField(
                        obscureText: !_passwordVisible,
                        decoration: InputDecoration(
                          hintText: 'Password',
                          hintStyle: TextStyle(
                            fontFamily: 'CenturyGo',
                            color: Colors.grey[500],
                          ),
                          border: InputBorder.none,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _passwordVisible
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              color: Colors.grey[600],
                            ),
                            onPressed: () {
                              setState(() {
                                _passwordVisible = !_passwordVisible;
                              });
                            },
                          ),
                        ),
                        style: const TextStyle(fontFamily: 'CenturyGo'),
                      ),
                    ),
                  ),
                ],
              ),
              const Divider(),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton(
                  onPressed: () => Navigator.pushNamed(context, '/register'),
                  child: const Text(
                    "Don't have an account?",
                    style: TextStyle(fontFamily: 'CenturyGo', fontSize: 12),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/home');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                  minimumSize: const Size.fromHeight(48),
                ),
                child: const Text(
                  'Sign In',
                  style: TextStyle(
                    fontFamily: 'CenturyGo',
                    fontSize: 20,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/home');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                  minimumSize: const Size.fromHeight(48),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Sign in with ',
                      style: TextStyle(
                        fontFamily: 'CenturyGo',
                        fontSize: 20,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(width: 8),
                    Image.asset('images/google.png', width: 28, height: 28),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => Navigator.pushNamed(context, '/forgot'),
                child: const Text(
                  'Forget Password?',
                  style: TextStyle(fontFamily: 'CenturyGo', fontSize: 12),
                ),
              ),
              const SizedBox(height: 16),
              Image.asset('images/logo.png', width: 100),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}
