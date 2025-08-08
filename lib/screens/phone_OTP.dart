import 'package:byteback2/services/firebase_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:byteback2/screens/link_email_screen.dart';

class PhoneOtp extends StatefulWidget {
  const PhoneOtp({super.key});

  @override
  State<PhoneOtp> createState() => _PhoneOtpState();
}

class _PhoneOtpState extends State<PhoneOtp> {
  final FirebaseService _firebaseService = FirebaseService();
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();

  bool _codeSent = false;
  bool _loading = false;

  void sendOTP(context) async {
    setState(() => _loading = true);
    try {
      // Format phone number for Singapore
      String phoneNumber = _phoneController.text.trim();
      if (!phoneNumber.startsWith('+')) {
        phoneNumber = '+65$phoneNumber';
      }

      await _firebaseService.sendOTP(phoneNumber);
      setState(() {
        _codeSent = true;
        _loading = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('OTP sent!')));
    } catch (e) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to send OTP: $e')));
    }
  }

  void verifyOTP(context) async {
    setState(() => _loading = true);
    final result = await _firebaseService.verifyOTP(
      smsCode: _otpController.text.trim(),
    );
    setState(() => _loading = false);
    if (result == null) {
      if (FirebaseAuth.instance.currentUser?.email == null) {
        Navigator.pushReplacementNamed(context, '/link_email');
      } else {
        Navigator.pushReplacementNamed(context, '/main');
      }
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(result)));
    }
  }

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
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      icon: const Icon(
                        Icons.arrow_back,
                        color: Color.fromARGB(255, 8, 8, 8),
                      ),
                      onPressed: () {
                        if (_codeSent) {
                          setState(() {
                            _codeSent = false;
                            _otpController.clear();
                          });
                        } else {
                          Navigator.pop(context);
                        }
                      },
                    ),
                  ),
                  const SizedBox(height: 50),
                  Text(
                    _codeSent ? 'Verify OTP' : 'Phone Number Login',
                    style: const TextStyle(
                      fontFamily: 'CenturyGo',
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    _codeSent
                        ? 'Enter the 6-digit code sent to\n+65${_phoneController.text}'
                        : 'Enter your phone number to receive\na verification code',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: 'CenturyGo',
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 80),
                  Row(
                    children: [
                      Icon(_codeSent ? Icons.lock : Icons.phone, size: 28),
                      const SizedBox(width: 8),
                      Expanded(
                        child:
                            _codeSent
                                ? TextFormField(
                                  controller: _otpController,
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                    LengthLimitingTextInputFormatter(6),
                                  ],
                                  decoration: const InputDecoration(
                                    errorBorder: UnderlineInputBorder(),
                                    border: UnderlineInputBorder(),
                                    hintText: 'Enter 6-digit code',
                                    hintStyle: TextStyle(
                                      fontFamily: 'CenturyGo',
                                      color: Colors.grey,
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter the OTP code';
                                    }
                                    if (value.length != 6) {
                                      return 'Please enter a valid 6-digit code';
                                    }
                                    return null;
                                  },
                                  style: const TextStyle(
                                    fontFamily: 'CenturyGo',
                                    fontSize: 24,
                                    letterSpacing: 4,
                                  ),
                                  textAlign: TextAlign.center,
                                )
                                : TextFormField(
                                  controller: _phoneController,
                                  keyboardType: TextInputType.phone,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                    LengthLimitingTextInputFormatter(8),
                                  ],
                                  decoration: const InputDecoration(
                                    errorBorder: UnderlineInputBorder(),
                                    border: UnderlineInputBorder(),
                                    hintText: 'Phone Number (e.g., 12345678)',
                                    hintStyle: TextStyle(
                                      fontFamily: 'CenturyGo',
                                      color: Colors.grey,
                                    ),
                                    prefixText: '+65 ',
                                    prefixStyle: TextStyle(
                                      fontFamily: 'CenturyGo',
                                      color: Colors.black,
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter your phone number';
                                    }
                                    if (value.length < 8) {
                                      return 'Please enter a valid Singapore phone number';
                                    }
                                    return null;
                                  },
                                  style: const TextStyle(
                                    fontFamily: 'CenturyGo',
                                  ),
                                ),
                      ),
                    ],
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
                                    if (_codeSent) {
                                      verifyOTP(context);
                                    } else {
                                      sendOTP(context);
                                    }
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
                                : Text(
                                  _codeSent ? 'Verify Code' : 'Send OTP',
                                  style: const TextStyle(
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

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }
}
