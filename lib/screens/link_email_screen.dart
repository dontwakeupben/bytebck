import 'package:byteback2/services/firebase_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LinkEmailScreen extends StatefulWidget {
  @override
  _LinkEmailScreenState createState() => _LinkEmailScreenState();
}

class _LinkEmailScreenState extends State<LinkEmailScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final FirebaseService _firebaseService = FirebaseService();
  final _passwordController = TextEditingController();

  bool _confirmPasswordVisible = false;
  bool _passwordVisible = false;

  final _confirmPasswordController = TextEditingController();
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

      await _firebaseService.reloadUser();

      // Get the current user after linking
      User? currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser != null) {
        // Create a comprehensive user document in Firestore
        await _firebaseService.createUserDocument(
          uid: currentUser.uid,
          email: currentUser.email ?? _emailController.text.trim(),
          displayName: _nameController.text.trim(),
          photoURL: 'images/pfp.jpeg', // Default profile picture
        );

        // Also update the Firebase Auth user's display name
        if (_nameController.text.trim().isNotEmpty) {
          await _firebaseService.updateUserDisplayName(
            _nameController.text.trim(),
          );
        }
      }

      await Future.delayed(Duration(seconds: 1));
      User? updatedUser = FirebaseAuth.instance.currentUser;

      if (updatedUser?.email != null) {
        Navigator.pushReplacementNamed(context, '/main');
      } else {
        setState(() {
          _error = "Something went wrong. Please try again.";
        });
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        if (e.code == 'email-already-in-use') {
          _error =
              'This email is already registered. Please use a different email or log in with this email instead.';
        } else {
          _error = e.message;
        }
      });
    } catch (e) {
      setState(() {
        _error = "Error creating user profile: $e";
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF233C23),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
      ), // 👈 Hides the back button,
      body: Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 40),
          padding: const EdgeInsets.all(24),
          height: 700, // Increased height to accommodate the name field
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
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.black87),
                      onPressed: () {
                        _firebaseService.logOut();
                        Navigator.pushReplacementNamed(context, '/login');
                      },
                    ),
                  ),

                  const SizedBox(height: 20),
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
                    'Please provide your name, email and password to create your account.',
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
                    controller: _nameController,
                    keyboardType: TextInputType.name,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                        RegExp(r"[a-zA-Z\s\-']"),
                      ), // Only allow letters, spaces, hyphens, and apostrophes
                      LengthLimitingTextInputFormatter(
                        50,
                      ), // Limit to 50 characters
                    ],
                    decoration: const InputDecoration(
                      errorBorder: UnderlineInputBorder(),
                      border: UnderlineInputBorder(),
                      hintText: 'Full Name',
                      hintStyle: TextStyle(
                        fontFamily: 'CenturyGo',
                        color: Colors.grey,
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Name is required';
                      }

                      // Remove extra whitespace and validate
                      final trimmedValue = value.trim();

                      // Check for minimum length
                      if (trimmedValue.length < 2) {
                        return 'Name must be at least 2 characters long';
                      }

                      // Check for maximum length
                      if (trimmedValue.length > 50) {
                        return 'Name must be less than 50 characters';
                      }

                      // Allow only letters, spaces, hyphens, and apostrophes
                      final validNameRegex = RegExp(r"^[a-zA-Z\s\-']+$");
                      if (!validNameRegex.hasMatch(trimmedValue)) {
                        return 'Name can only contain letters, spaces, hyphens, and apostrophes';
                      }

                      // Check for consecutive spaces
                      if (trimmedValue.contains(RegExp(r'\s{2,}'))) {
                        return 'Name cannot contain consecutive spaces';
                      }

                      // Check for leading/trailing special characters
                      if (RegExp(r"^[\-']").hasMatch(trimmedValue) ||
                          RegExp(r"[\-']$").hasMatch(trimmedValue)) {
                        return 'Name cannot start or end with special characters';
                      }

                      return null;
                    },
                    style: const TextStyle(
                      fontFamily: 'CenturyGo',
                      fontSize: 20,
                    ),
                  ),
                  const SizedBox(height: 32),
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      errorBorder: UnderlineInputBorder(),
                      border: UnderlineInputBorder(),
                      hintText: 'Email',
                      hintStyle: TextStyle(
                        fontFamily: 'CenturyGo',
                        color: Colors.grey,
                      ),
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
                  const SizedBox(height: 32),
                  TextFormField(
                    controller: _passwordController,
                    keyboardType: TextInputType.visiblePassword,
                    decoration: InputDecoration(
                      errorBorder: UnderlineInputBorder(),
                      border: UnderlineInputBorder(),
                      hintText: 'Password',
                      hintStyle: TextStyle(
                        fontFamily: 'CenturyGo',
                        color: Colors.grey,
                      ),
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
                    obscureText: !_passwordVisible,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a password';
                      }
                      if (value.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                    style: const TextStyle(
                      fontFamily: 'CenturyGo',
                      fontSize: 20,
                    ),
                  ),
                  const SizedBox(height: 32),
                  TextFormField(
                    controller: _confirmPasswordController,
                    keyboardType: TextInputType.visiblePassword,
                    decoration: InputDecoration(
                      errorBorder: UnderlineInputBorder(),
                      border: UnderlineInputBorder(),
                      hintText: 'Confirm Password',
                      hintStyle: TextStyle(
                        fontFamily: 'CenturyGo',
                        color: Colors.grey,
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _confirmPasswordVisible
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          color: Colors.grey[600],
                        ),
                        onPressed: () {
                          setState(() {
                            _confirmPasswordVisible = !_confirmPasswordVisible;
                          });
                        },
                      ),
                    ),
                    obscureText: !_confirmPasswordVisible,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please confirm your password';
                      }
                      if (value != _passwordController.text) {
                        return 'Passwords do not match';
                      }
                      return null;
                    },
                    style: const TextStyle(
                      fontFamily: 'CenturyGo',
                      fontSize: 20,
                    ),
                  ),
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
                                  'Create Account',
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
