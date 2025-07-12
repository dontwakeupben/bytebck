import 'package:byteback2/services/firebase_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Helper to check if email is verified

  bool get isEmailVerified {
    final user = FirebaseAuth.instance.currentUser;
    return user?.emailVerified ?? false;
  }

  // Send verification email and show feedback
  Future<void> sendVerificationEmail() async {
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

  bool _passwordVisible = false;
  bool _isDarkMode = false;
  // Function to show a confirmation dialog when saving changes
  void _showSaveConfirmation() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFFF8F5E3),
          title: const Text(
            'Save Changes',
            style: TextStyle(
              fontFamily: 'CenturyGo',
              color: Color(0xFF233C23),
              fontWeight: FontWeight.bold,
            ),
          ),
          content: const Text(
            'Are you sure you want to save these changes?',
            style: TextStyle(fontFamily: 'CenturyGo', color: Color(0xFF233C23)),
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
              onPressed: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Changes saved successfully'),
                    backgroundColor: Color(0xFF233C23),
                  ),
                );
              },
              child: const Text(
                'Save',
                style: TextStyle(
                  fontFamily: 'CenturyGo',
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
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
    return Scaffold(
      backgroundColor: const Color(0xFF233C23),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Back button at the top left
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
              FittedBox(
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
                              color: Colors.blue,
                            ),
                            label: const Text(
                              'Verify Email',
                              style: TextStyle(
                                fontFamily: 'CenturyGo',
                                color: Colors.blue,
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
                      const SizedBox(height: 16),
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

                      _ProfileField(value: 'ben angelo', isPassword: false),
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

                      _ProfileField(value: email ?? "User", isPassword: false),
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

                      _ProfileField(
                        value: 'ballslicker32',
                        isPassword: true,
                        passwordVisible: _passwordVisible,
                        onTogglePassword: () {
                          setState(() {
                            _passwordVisible = !_passwordVisible;
                          });
                        },
                      ),
                      const SizedBox(height: 32),
                      ElevatedButton(
                        onPressed: _showSaveConfirmation,
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
                                  crossAxisAlignment: CrossAxisAlignment.start,
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
              // Settings section as a Column
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
                child: Container(
                  decoration: BoxDecoration(
                    color: Color(0xFF233C23),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      const _SettingsTile(icon: Icons.person, label: 'Account'),
                      Divider(
                        color: Color.fromARGB(255, 0, 0, 0),
                        height: 1,
                        indent: 0,
                        endIndent: 0,
                      ),
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
                      const _SettingsTile(icon: Icons.lock, label: 'Privacy'),
                      Divider(
                        color: Color.fromARGB(255, 0, 0, 0),
                        height: 1,
                        indent: 0,
                        endIndent: 0,
                      ),
                      _SettingsTile(icon: Icons.help_outline, label: 'Help'),
                      Divider(
                        color: Color.fromARGB(255, 0, 0, 0),
                        height: 1,
                        indent: 0,
                        endIndent: 0,
                      ),
                      _SettingsTile(icon: Icons.info_outline, label: 'About'),
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
                                    backgroundColor: const Color(0xFFF8F5E3),
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
            ],
          ),
        ),
      ),
    );
  }
}

// Widget for profile fields with optional password visibility toggle
class _ProfileField extends StatelessWidget {
  final String value;
  final bool isPassword;
  final bool? passwordVisible;
  final VoidCallback? onTogglePassword;

  const _ProfileField({
    required this.value,
    this.isPassword = false,
    this.passwordVisible,
    this.onTogglePassword,
  });

  @override
  // Build method for the profile field widget
  Widget build(BuildContext context) {
    return TextField(
      obscureText: isPassword && !(passwordVisible ?? false),
      decoration: InputDecoration(
        floatingLabelBehavior: FloatingLabelBehavior.always,
        labelStyle: const TextStyle(
          fontFamily: 'CenturyGo',
          color: Colors.black,
          fontWeight: FontWeight.bold,
        ),
        filled: true,
        fillColor: Colors.brown[200],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.fromLTRB(12, 28, 12, 12),
        suffixIcon:
            isPassword
                ? IconButton(
                  icon: Icon(
                    passwordVisible ?? false
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    color: Colors.black54,
                  ),
                  onPressed: onTogglePassword,
                )
                : null,
      ),
      style: const TextStyle(fontFamily: 'CenturyGo'),
      controller: TextEditingController(text: value),
    );
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
