// ByteBack - A platform for sharing computer hardware guides
// Main application entry point that sets up the app theme and routing

import 'package:byteback2/firebase_options.dart';
import 'package:byteback2/screens/create_guide_screen.dart';
import 'package:byteback2/screens/link_email_screen.dart';
import 'package:byteback2/screens/phone_OTP.dart';
import 'package:byteback2/services/firebase_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/forgot_password_screen.dart';
import 'screens/email_sent_screen.dart';
import 'screens/home_screen.dart';
import 'screens/feed_screen.dart';
import 'screens/library_screen.dart';
import 'screens/premium_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/set_password.dart';
// import other screens as you create them

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  GetIt.instance.registerLazySingleton(() => FirebaseService());
  runApp(MyApp());
}

/// Root widget of the ByteBack application
/// Configures the app theme and routing system
class MyApp extends StatelessWidget {
  FirebaseService fbService = GetIt.instance<FirebaseService>();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: fbService.getAuthUser(),
      builder: (context, snapshot) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'ByteBack',
          // Configure app-wide theme settings
          theme: ThemeData(
            fontFamily: 'CenturyGo', // Custom font for consistent typography
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF233C23),
            ), // Primary brand color
            useMaterial3: true, // Enable Material 3 design system
          ),
          // Use home instead of initialRoute to react to auth state
          home:
              snapshot.connectionState == ConnectionState.waiting
                  ? const SplashScreen()
                  : (snapshot.hasData
                      ? const HomeScreen()
                      : const SplashScreen()),
          routes: {
            '/login': (context) => const LoginScreen(),
            '/register': (context) => const RegisterScreen(),
            '/forgot': (context) => const ForgotPasswordScreen(),
            '/email-sent': (context) => const EmailSentScreen(),
            '/home': (context) => const HomeScreen(),
            '/feed': (context) => const FeedScreen(),
            '/library': (context) => const LibraryScreen(),
            '/premium': (context) => const PremiumScreen(),
            '/profile': (context) => const ProfileScreen(),
            '/create': (context) => const CreateGuideScreen(),
            '/phone_otp': (context) => const PhoneOtp(),
            '/link_email': (context) => LinkEmailScreen(),
            '/set_password': (context) => SetPasswordScreen(),
            // Add other routes here as you implement them
          },
        );
      },
    );
  }
}
