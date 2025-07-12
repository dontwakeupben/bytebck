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
  String? _error;

  @override
  Widget build(BuildContext context) {
    final user = fbService.getCurrentUser();

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
                      enabledBorder: UnderlineInputBorder(),
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

                  const SizedBox(height: 100),
                  Center(
                    child: SizedBox(
                      width: 200,
                      child: ElevatedButton(
                        onPressed:
                            _loading
                                ? null
                                : () {
                                  if (_formKey.currentState!.validate()) {}
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
