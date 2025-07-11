import 'package:byteback2/services/firebase_service.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LinkEmailScreen extends StatefulWidget {
  @override
  _LinkEmailScreenState createState() => _LinkEmailScreenState();
}

class _LinkEmailScreenState extends State<LinkEmailScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final FirebaseService _firebaseService = FirebaseService();
  final _passwordController = TextEditingController();
  bool _loading = false;
  String? _error;

  void _linkEmail() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await _firebaseService.linkEmail(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );
      Navigator.pushReplacementNamed(context, '/home'); // Success, go back
    } on FirebaseAuthException catch (e) {
      setState(() {
        if (e.code == 'email-already-in-use') {
          _error =
              'This email is already registered. Please use a different email or log in with this email instead.';
        } else {
          _error = e.message;
        }
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF233C23),
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
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
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 50),
                  const Text(
                    'Link Email & Password',
                    style: TextStyle(
                      fontFamily: 'CenturyGo',
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Please provide an email and password to link to your account.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'CenturyGo',
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 80),
                  if (_error != null) ...[
                    Text(
                      _error!,
                      style: const TextStyle(
                        color: Colors.red,
                        fontFamily: 'CenturyGo',
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      hintText: 'Email',
                      hintStyle: TextStyle(
                        fontFamily: 'CenturyGo',
                        color: Colors.grey,
                      ),
                      border: InputBorder.none,
                    ),
                    validator:
                        (v) =>
                            v != null && v.contains('@')
                                ? null
                                : 'Enter a valid email',
                    style: const TextStyle(
                      fontFamily: 'CenturyGo',
                      fontSize: 20,
                    ),
                  ),
                  const Divider(),
                  TextFormField(
                    controller: _passwordController,
                    decoration: const InputDecoration(
                      hintText: 'Password',
                      hintStyle: TextStyle(
                        fontFamily: 'CenturyGo',
                        color: Colors.grey,
                      ),
                      border: InputBorder.none,
                    ),
                    obscureText: true,
                    validator:
                        (v) =>
                            v != null && v.length >= 6
                                ? null
                                : 'Password too short',
                    style: const TextStyle(
                      fontFamily: 'CenturyGo',
                      fontSize: 20,
                    ),
                  ),
                  const Divider(),
                  const SizedBox(height: 100),
                  Center(
                    child: SizedBox(
                      width: 200,
                      child: ElevatedButton(
                        onPressed:
                            _loading
                                ? null
                                : () {
                                  if (_formKey.currentState!.validate()) {
                                    _linkEmail();
                                  }
                                },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(28),
                          ),
                          minimumSize: const Size.fromHeight(48),
                        ),
                        child:
                            _loading
                                ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                                : const Text(
                                  'Link Email',
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
      ),
    );
  }
}
