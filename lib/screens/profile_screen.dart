import 'package:byteback2/services/firebase_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _loading = false;

  // Helper to check if email is verified

  bool get isEmailVerified {
    final user = FirebaseAuth.instance.currentUser;
    return user?.emailVerified ?? false;
  }

  // Send verification email and show feedback
  void sendVerificationEmail() async {
    try {
      await fbService.sendEmailVerification();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Verification email sent!')));
      setState(() {}); // Refresh UI in case user verifies
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error sending verification: $e')));
    }
  }

  void sendOTP(context, phone) async {
    setState(() => _loading = true);
    try {
      // Format phone number for Singapore
      if (!phone.startsWith('+')) {
        phone = '+65$phone';
      }

      await fbService.sendOTP(phone);
      setState(() {
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

  void confirmOTP(context, otpCode) async {
    await fbService.confirmUpdateOTP(smsCode: otpCode).catchError((e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    });
  }

  bool _passwordVisible = false;
  bool _isDarkMode = false;
  bool oldPasswordVisible = false;

  // Function to show a confirmation dialog when saving changes
  void _showSaveConfirmation(name, email, password, phone) async {
    final dialogFormKey = GlobalKey<FormState>();
    final oldPasswordController = TextEditingController();
    final otpController = TextEditingController();
    final user = fbService.getCurrentUser();
    final currentPhoneNumber = user?.phoneNumber ?? '';
    final currentEmail = user?.email ?? '';
    bool phoneChanged = (phone.isNotEmpty && phone != currentPhoneNumber);
    bool emailChanged = (email.isNotEmpty && email != currentEmail);

    if (_formKey.currentState?.validate() ?? false) {
      if (phoneChanged) {
        sendOTP(context, phone);
      }
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(
            builder: (context, setState) {
              return AlertDialog(
                backgroundColor: const Color(0xFFF8F5E3),
                title: const Text(
                  'Confirm Changes',
                  style: TextStyle(
                    fontFamily: 'CenturyGo',
                    color: Color(0xFF233C23),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                content: Form(
                  key: dialogFormKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        phoneChanged
                            ? 'Please enter the OTP code to the new number and current password to save changes.'
                            : 'Please enter your current password to save changes.',
                        style: const TextStyle(
                          fontFamily: 'CenturyGo',
                          color: Color(0xFF233C23),
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (phoneChanged)
                        TextFormField(
                          controller: otpController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            hintText: '6 Digit OTP Code',
                            hintStyle: TextStyle(
                              fontFamily: 'CenturyGo',
                              color: Colors.grey,
                            ),
                            border: UnderlineInputBorder(),
                            errorBorder: UnderlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter the OTP code';
                            }
                            if (value.length != 6) {
                              return 'OTP code must be 6 digits';
                            }
                            return null;
                          },
                          style: const TextStyle(
                            fontFamily: 'CenturyGo',
                            fontSize: 18,
                          ),
                        ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: oldPasswordController,
                        obscureText: !oldPasswordVisible,
                        keyboardType: TextInputType.visiblePassword,
                        decoration: InputDecoration(
                          hintText: 'Password',
                          hintStyle: const TextStyle(
                            fontFamily: 'CenturyGo',
                            color: Colors.grey,
                          ),
                          border: const UnderlineInputBorder(),
                          errorBorder: const UnderlineInputBorder(),
                          suffixIcon: IconButton(
                            icon: Icon(
                              oldPasswordVisible
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              color: Colors.grey[600],
                            ),
                            onPressed: () {
                              setState(() {
                                oldPasswordVisible = !oldPasswordVisible;
                              });
                            },
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please confirm your password';
                          }
                          return null;
                        },
                        style: const TextStyle(
                          fontFamily: 'CenturyGo',
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () async {
                      if (dialogFormKey.currentState!.validate()) {
                        bool passwordMatches = await fbService.matchPassword(
                          oldPasswordController.text,
                        );
                        if (!passwordMatches) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Incorrect password. Changes not saved.',
                              ),
                            ),
                          );
                          return;
                        }

                        // Update name in Firestore if changed
                        final userData =
                            await fbService.getCurrentUserDocument();
                        final currentName =
                            userData?['displayName'] ??
                            userData?['fullName'] ??
                            '';
                        if (name.isNotEmpty && name != currentName) {
                          try {
                            await fbService.updateCurrentUserDocument(
                              displayName: name,
                              additionalData: {'fullName': name},
                            );
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Error updating name: $e'),
                              ),
                            );
                          }
                        }

                        // Update password if provided
                        if (password.isNotEmpty) {
                          try {
                            await fbService.setPassword(password);
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Error updating password: $e'),
                              ),
                            );
                          }
                        }

                        // Update email if changed
                        if (emailChanged) {
                          try {
                            await fbService.emailUpdate(email);
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Error updating email: $e'),
                              ),
                            );
                          }
                        }

                        // Update phone number if changed
                        if (phoneChanged) {
                          confirmOTP(context, otpController.text);
                        }

                        await fbService.reloadUser();
                        await Future.delayed(const Duration(seconds: 1));

                        Navigator.of(context).pop(); // Close dialog

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Changes saved successfully'),
                          ),
                        );

                        // Refresh the UI
                        setState(() {});
                      }
                    },
                    child: const Text(
                      'Save',
                      style: TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
      );
    }
  }

  FirebaseService fbService = GetIt.instance<FirebaseService>();
  void logout(context) async {
    try {
      await fbService.logOut();
      Navigator.of(context).pushReplacementNamed("/");
      FocusScope.of(context).unfocus();
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User logged out successfully!')),
      );
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/',
        (route) => false, // Remove all previous routes
      );
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.code)));
    }
  }

  void deleteAccount(context) async {
    final result = await fbService.deleteCurrentUser();
    if (result == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Account deleted successfully.')),
      );
      Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(result)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = fbService.getCurrentUser();
    final email = user?.email;
    final phone = user?.phoneNumber;

    return Scaffold(
      backgroundColor: const Color(0xFF233C23),
      body: SafeArea(
        child: SingleChildScrollView(
          child: FutureBuilder<Map<String, dynamic>?>(
            future: fbService.getCurrentUserDocument(),
            builder: (context, snapshot) {
              final userData = snapshot.data;
              final currentName =
                  userData?['displayName'] ?? userData?['fullName'] ?? '';

              final _nameController = TextEditingController(text: currentName);
              final _emailController = TextEditingController(
                text: email ?? "User",
              );
              final _passwordController = TextEditingController();
              final _phoneController = TextEditingController(text: phone);

              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Back button at the top left
                  Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 8, top: 8),
                        child: Align(
                          alignment: Alignment.topLeft,
                          child: IconButton(
                            icon: const Icon(
                              Icons.arrow_back,
                              color: Colors.white,
                            ),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 8, top: 8),
                        child: Align(
                          alignment: Alignment.topRight,
                          child: IconButton(
                            icon: const Icon(
                              Icons.refresh,
                              color: Colors.white,
                              size: 27,
                            ),
                            onPressed: () {
                              fbService.reloadUser();
                              setState(
                                () {},
                              ); // Refresh the UI after reloading user data
                            },
                            tooltip: 'Refresh',
                          ),
                        ),
                      ),
                    ],
                  ),
                  const FittedBox(
                    fit: BoxFit.scaleDown,
                    child: CircleAvatar(
                      radius: 60,
                      backgroundImage: AssetImage('images/pfp.jpeg'),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Center(
                    child: Text(
                      'Edit picture',
                      style: TextStyle(
                        fontFamily: 'CenturyGo',
                        fontSize: 14,
                        color: Color.fromARGB(255, 255, 255, 255),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Center(
                    child: Container(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8F5E3),
                        borderRadius: BorderRadius.circular(28),
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Email verification button (only if not verified)
                            if (!isEmailVerified)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 16.0),
                                child: ElevatedButton.icon(
                                  onPressed: sendVerificationEmail,
                                  icon: const Icon(
                                    Icons.verified,
                                    color: const Color(0xFF233C23),
                                  ),
                                  label: const Text(
                                    'Verify Email',
                                    style: TextStyle(
                                      fontFamily: 'CenturyGo',
                                      color: const Color(0xFF233C23),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                  ),
                                ),
                              ),
                            const SizedBox(height: 25),
                            Center(
                              child: Text(
                                'Change Profile Information',
                                style: TextStyle(
                                  fontFamily: 'CenturyGo',
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                            Align(
                              alignment: Alignment(-0.97, -0.94),
                              child: Text(
                                'Name',
                                style: TextStyle(
                                  fontFamily: 'CenturyGo',
                                  fontSize: 16,
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),

                            TextFormField(
                              controller: _nameController,
                              keyboardType: TextInputType.name,

                              decoration: InputDecoration(
                                hintText: 'Enter your name',
                                filled: true,
                                fillColor: Colors.brown[200],
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                                contentPadding: const EdgeInsets.fromLTRB(
                                  12,
                                  28,
                                  12,
                                  12,
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Name is required';
                                }
                                return null;
                              },
                              style: const TextStyle(fontFamily: 'CenturyGo'),
                            ),
                            const SizedBox(height: 24),

                            Align(
                              alignment: Alignment(-0.97, 1),
                              child: Text(
                                'Email',
                                style: TextStyle(
                                  fontFamily: 'CenturyGo',
                                  fontSize: 16,
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),

                            TextFormField(
                              keyboardType: TextInputType.emailAddress,

                              controller: _emailController,
                              decoration: InputDecoration(
                                hintText: 'Enter your email',
                                filled: true,
                                fillColor: Colors.brown[200],
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                                contentPadding: const EdgeInsets.fromLTRB(
                                  12,
                                  28,
                                  12,
                                  12,
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Email is required';
                                }
                                if (!RegExp(
                                  r'^[\w-\.]+@([\w-]+\.)+[\w]{2,4}$',
                                ).hasMatch(value)) {
                                  return 'Enter a valid email';
                                }
                                return null;
                              },
                              style: const TextStyle(fontFamily: 'CenturyGo'),
                            ),

                            const SizedBox(height: 24),
                            Align(
                              alignment: Alignment(-0.97, 1),
                              child: Text(
                                'Password',
                                style: TextStyle(
                                  fontFamily: 'CenturyGo',
                                  fontSize: 16,
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),

                            TextFormField(
                              controller: _passwordController,
                              keyboardType: TextInputType.visiblePassword,

                              obscureText: !_passwordVisible,
                              decoration: InputDecoration(
                                hintText: 'Enter your new password',
                                filled: true,
                                fillColor: Colors.brown[200],
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                                contentPadding: const EdgeInsets.fromLTRB(
                                  12,
                                  28,
                                  12,
                                  12,
                                ),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _passwordVisible
                                        ? Icons.visibility
                                        : Icons.visibility_off,
                                    color: Colors.black54,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _passwordVisible = !_passwordVisible;
                                    });
                                  },
                                ),
                              ),
                              validator: (value) {
                                if (value!.isNotEmpty && value.length < 6) {
                                  return 'Password must be at least 6 characters';
                                }
                                return null;
                              },
                              style: const TextStyle(fontFamily: 'CenturyGo'),
                            ),
                            const SizedBox(height: 24),
                            Align(
                              alignment: Alignment(-0.97, 1),
                              child: Text(
                                'Phone Number (Optional)',
                                style: TextStyle(
                                  fontFamily: 'CenturyGo',
                                  fontSize: 16,
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),

                            TextFormField(
                              controller: _phoneController,
                              keyboardType: TextInputType.phone,
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                  RegExp(r'^\+?\d*'),
                                ), // Allows '+' at the beginning and digits
                              ],
                              decoration: InputDecoration(
                                hintText:
                                    'Enter your phone number (optional, e.g. +6591234567)',
                                filled: true,
                                fillColor: Colors.brown[200],
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                                contentPadding: const EdgeInsets.fromLTRB(
                                  12,
                                  28,
                                  12,
                                  12,
                                ),
                              ),
                              validator: (value) {
                                // Make phone number optional
                                if (value == null || value.isEmpty) {
                                  return null; // Allow empty phone number
                                }

                                final sgPhoneRegex = RegExp(r'^\+65[89]\d{7}$');
                                if (!sgPhoneRegex.hasMatch(value)) {
                                  return 'Phone number must start with +65 and be\n8 digits (e.g. +6591234567) and is valid.';
                                }
                                return null;
                              },
                              style: const TextStyle(fontFamily: 'CenturyGo'),
                            ),

                            const SizedBox(height: 32),
                            ElevatedButton(
                              onPressed: () async {
                                _showSaveConfirmation(
                                  _nameController.text,
                                  _emailController.text,
                                  _passwordController.text,
                                  _phoneController.text,
                                );
                                setState(() {
                                  final user = fbService.getCurrentUser();
                                  _emailController.text = user?.email ?? '';
                                  _phoneController.text =
                                      user?.phoneNumber ?? '';
                                  // similarly update other controllers
                                });
                              },

                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green[600],
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: const Text(
                                'Save Changes',
                                style: TextStyle(
                                  fontFamily: 'CenturyGo',
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                            ElevatedButton.icon(
                              onPressed: () {
                                Navigator.pushNamed(context, '/premium');
                              },
                              icon: const Icon(Icons.star, color: Colors.black),
                              label: const Text(
                                'Upgrade to Premium',
                                style: TextStyle(
                                  fontFamily: 'CenturyGo',
                                  color: Colors.black,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFD1B3E0),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                            ElevatedButton(
                              onPressed: () {
                                logout(context);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.brown[200],
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),

                              child: const Text(
                                'Log Out',
                                style: TextStyle(
                                  fontFamily: 'CenturyGo',
                                  color: Colors.black,
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                            ElevatedButton(
                              onPressed: () {
                                // Show confirmation dialog before deleting account
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      backgroundColor: const Color(0xFFF8F5E3),
                                      title: const Text(
                                        'Delete Account',
                                        style: TextStyle(
                                          fontFamily: 'CenturyGo',
                                          color: Color(0xFF233C23),
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      content: const Column(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Are you sure you want to delete your account?',
                                            style: TextStyle(
                                              fontFamily: 'CenturyGo',
                                              color: Color(0xFF233C23),
                                            ),
                                          ),
                                          SizedBox(height: 12),
                                          Text(
                                            'This action cannot be undone.',
                                            style: TextStyle(
                                              fontFamily: 'CenturyGo',
                                              color: Colors.red,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                          child: const Text(
                                            'Cancel',
                                            style: TextStyle(
                                              fontFamily: 'CenturyGo',
                                              color: Color(0xFF233C23),
                                            ),
                                          ),
                                        ),
                                        TextButton(
                                          onPressed: () async {
                                            deleteAccount(context);
                                          },
                                          child: const Text(
                                            'Delete Account',
                                            style: TextStyle(
                                              fontFamily: 'CenturyGo',
                                              color: Colors.red,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red[900],
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),

                              child: const Text(
                                'Delete Account',
                                style: TextStyle(
                                  fontFamily: 'CenturyGo',
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Align(
                              alignment: Alignment.bottomRight,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                mainAxisSize: MainAxisSize.min,
                                children: const [
                                  Text(
                                    'Joined',
                                    style: TextStyle(
                                      fontFamily: 'CenturyGo',
                                      fontSize: 12,
                                      color: Colors.black,
                                    ),
                                  ),
                                  Text(
                                    '27 / 7 / 2024',
                                    style: TextStyle(
                                      fontFamily: 'CenturyGo',
                                      fontSize: 12,
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Settings section as a Column
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 0,
                      vertical: 8,
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Color(0xFF233C23),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          const _SettingsTile(
                            icon: Icons.notifications,
                            label: 'Notifications',
                          ),
                          Divider(
                            color: Color.fromARGB(255, 0, 0, 0),
                            height: 1,
                            indent: 0,
                            endIndent: 0,
                          ),
                          const _SettingsTile(
                            icon: Icons.lock,
                            label: 'Privacy',
                          ),
                          Divider(
                            color: Color.fromARGB(255, 0, 0, 0),
                            height: 1,
                            indent: 0,
                            endIndent: 0,
                          ),
                          _SettingsTile(
                            icon: Icons.help_outline,
                            label: 'Help',
                          ),
                          Divider(
                            color: Color.fromARGB(255, 0, 0, 0),
                            height: 1,
                            indent: 0,
                            endIndent: 0,
                          ),
                          _SettingsTile(
                            icon: Icons.info_outline,
                            label: 'About',
                          ),
                          Divider(
                            color: Color.fromARGB(255, 0, 0, 0),
                            height: 1,
                            indent: 0,
                            endIndent: 0,
                          ),
                          ListTile(
                            leading: Icon(
                              Icons.dark_mode,
                              color: const Color.fromARGB(255, 255, 255, 255),
                            ),
                            title: Text(
                              'Dark Mode',
                              style: const TextStyle(
                                fontFamily: 'CenturyGo',
                                color: Color.fromARGB(255, 255, 255, 255),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            // This switch toggles dark mode
                            trailing: Switch(
                              value: _isDarkMode,
                              onChanged: (value) {
                                setState(() {
                                  _isDarkMode = value;
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        backgroundColor: const Color(
                                          0xFFF8F5E3,
                                        ),
                                        title: Text(
                                          value
                                              ? 'Dark Mode Enabled'
                                              : 'Dark Mode Disabled',
                                          style: const TextStyle(
                                            fontFamily: 'CenturyGo',
                                            color: Color(0xFF233C23),
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        content: Text(
                                          value
                                              ? 'Dark mode has been enabled.'
                                              : 'Dark mode has been disabled.',
                                          style: const TextStyle(
                                            fontFamily: 'CenturyGo',
                                            color: Color(0xFF233C23),
                                          ),
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                            child: const Text(
                                              'OK',
                                              style: TextStyle(
                                                fontFamily: 'CenturyGo',
                                                color: Color(0xFF233C23),
                                              ),
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                });
                              },
                              activeColor: const Color(0xFFD1B3E0),
                              activeTrackColor: const Color(0xFFF8F5E3),
                              inactiveThumbColor: Colors.grey,
                              inactiveTrackColor: Colors.grey[300],
                            ),
                            dense: true,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 0,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ], // Close children of FutureBuilder Column
              );
            }, // Close FutureBuilder builder
          ), // Close FutureBuilder
        ), // Close SingleChildScrollView
      ), // Close SafeArea
    ); // Close Scaffold
  }
}

// Widget for individual settings tiles
class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String label;
  const _SettingsTile({required this.icon, required this.label});
  // Constructor for the settings tile widget
  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: const Color.fromARGB(255, 255, 255, 255)),
      title: Text(
        label,
        style: const TextStyle(
          fontFamily: 'CenturyGo',
          color: Color.fromARGB(255, 255, 255, 255),
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        color: Color.fromARGB(255, 0, 0, 0),
        size: 16,
      ),
      onTap: () {},
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
    );
  }
}
