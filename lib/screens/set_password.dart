import 'package:byteback2/services/firebase_service.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';

class SetPasswordScreen extends StatefulWidget {
  @override
  _SetPasswordScreenState createState() => _SetPasswordScreenState();
}

class _SetPasswordScreenState extends State<SetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  FirebaseService fbService = GetIt.instance<FirebaseService>();
  final _passwordController = TextEditingController();
  final FirebaseService _firebaseService = FirebaseService();
  bool _loading = false;
  bool _passwordVisible = false;
  bool _confirmPasswordVisible = false;
  String? _error;

  void _setPassword() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      fbService.setPassword(_passwordController.text.trim());
      Navigator.pushReplacementNamed(context, '/home'); // Success, go back
    } on FirebaseAuthException catch (e) {
      setState(() {
        _error = e.message;
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = fbService.getCurrentUser();

    return Scaffold(
      backgroundColor: const Color(0xFF233C23),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false, // 👈 Hides the back button
      ),
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
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.black87),
                      onPressed: () {
                        _firebaseService.logOut();
                        Navigator.pop(context, '/login');
                      },
                    ),
                  ),
                  const SizedBox(height: 50),
                  const Text(
                    'Set Password',
                    style: TextStyle(
                      fontFamily: 'CenturyGo',
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),

                  const SizedBox(height: 20),

                  Text(
                    'Please set up a password for ${user?.email ?? "your account"}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
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
                    controller: _passwordController,
                    decoration: const InputDecoration(
                      errorBorder: UnderlineInputBorder(),
                      border: UnderlineInputBorder(),
                      hintText: 'Password',
                      hintStyle: TextStyle(
                        fontFamily: 'CenturyGo',
                        color: Colors.grey,
                      ),
                    ),
                    obscureText: _passwordVisible,

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
                                    _setPassword();
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
                                  'Set Password',
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
