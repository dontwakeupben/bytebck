import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class FirebaseService {
  // Verify OTP code and sign in

  String? _verificationId;
  String? get verificationId => _verificationId;
  // Delete the current user account
  Future<String?> deleteCurrentUser() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await user.delete();
        return null; // Success
      } else {
        return 'No user is currently signed in.';
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        return 'Please re-authenticate and try again.';
      } else {
        return 'Error: ${e.message}';
      }
    } catch (e) {
      return 'Error: $e';
    }
  }

  // Send email verification to the current user
  Future<void> sendEmailVerification() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null && !user.emailVerified) {
      await user.sendEmailVerification();
    }
  }

  Future<dynamic> signInWithGoogle() async {
    try {
      GoogleSignInAccount? googleUser =
          await GoogleSignIn(
            clientId:
                '546845317104-tgf7ssojnq3b82h1lk4hf2isq67teabv.apps.googleusercontent.com',
          ).signIn();
      GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;
      OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );
      return await FirebaseAuth.instance.signInWithCredential(credential);
    } catch (e) {
      debugPrint('Google Sign-In failed: $e');
      return null;
    }
  }

  Future<UserCredential> register(email, password) {
    return FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<UserCredential> login(email, password) {
    return FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Stream<User?> getAuthUser() {
    return FirebaseAuth.instance.authStateChanges();
  }

  User? getCurrentUser() {
    return FirebaseAuth.instance.currentUser;
  }

  Future<void> logOut() {
    return FirebaseAuth.instance.signOut();
  }

  Future<void> forgotPassword(email) {
    return FirebaseAuth.instance.sendPasswordResetEmail(email: email);
  }

  Future<void> sendOTP(String phoneNumber) async {
    try {
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          // Auto-verification (for Android)
          try {
            await FirebaseAuth.instance.signInWithCredential(credential);
          } catch (e) {
            print('Auto-verification failed: $e');
          }
        },
        verificationFailed: (FirebaseAuthException e) {
          print('Verification failed: ${e.message}');
          throw Exception(e.message ?? 'Phone verification failed');
        },
        codeSent: (String verificationId, int? resendToken) {
          print('Code sent. Verification ID: $verificationId');
          _verificationId = verificationId;
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          print('Auto-retrieval timeout. Verification ID: $verificationId');
          _verificationId = verificationId;
        },
        timeout: const Duration(seconds: 60),
      );
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message ?? 'Failed to send OTP');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  Future<String?> verifyOTP({required String smsCode}) async {
    try {
      // Check if verification ID exists
      if (_verificationId == null || _verificationId!.isEmpty) {
        return 'No verification ID found. Please request OTP again.';
      }

      // Validate SMS code
      if (smsCode.isEmpty || smsCode.length != 6) {
        return 'Please enter a valid 6-digit code.';
      }

      // Create credential
      final credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: smsCode,
      );

      // Sign in with credential
      final userCredential = await FirebaseAuth.instance.signInWithCredential(
        credential,
      );

      // Verify sign in was successful
      if (userCredential.user == null) {
        return 'Sign in failed. Please try again.';
      }

      // Clear verification ID after successful verification
      _verificationId = null;

      return null; // Success
    } on FirebaseAuthException catch (e) {
      // Clear verification ID on certain errors
      if (e.code == 'session-expired' || e.code == 'invalid-verification-id') {
        _verificationId = null;
      }

      // Return specific error messages
      switch (e.code) {
        case 'invalid-verification-code':
          return 'Invalid verification code. Please check and try again.';
        case 'invalid-verification-id':
          return 'Verification session expired. Please request a new OTP.';
        case 'session-expired':
          return 'Verification session expired. Please request a new OTP.';
        case 'too-many-requests':
          return 'Too many attempts. Please try again later.';
        case 'quota-exceeded':
          return 'SMS quota exceeded. Please try again later.';
        default:
          return e.message ?? 'Verification failed: ${e.code}';
      }
    } catch (e) {
      return 'Unexpected error occurred: $e';
    }
  }

  // Method to reset verification state
  void resetVerification() {
    _verificationId = null;
  }

  Future<void> linkEmail(email, password) async {
    final user = FirebaseAuth.instance.currentUser;
    final credential = EmailAuthProvider.credential(
      email: email,
      password: password,
    );
    user?.linkWithCredential(credential);
  }

  // Future<void> setPassword(String password) async {
  //   final user = FirebaseAuth.instance.currentUser;
  //   final hasPassword =
  //       user?.providerData.any((info) => info.providerId == 'password') ??
  //       false;
  //   if (hasPassword) {
  //     await user?.updatePassword(password);
  //   } else {
  //     throw Exception('No user is currently signed in.');
  //   }
  // }
  Future<void> setPassword(String password) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('No user is currently signed in.');
    }
    await user.updatePassword(password);
  }

  Future<void> reloadUser() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await user.reload();
    } else {
      throw Exception('No user is currently signed in.');
    }
  }

  Future<bool> matchPassword(String password) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;

    final hasPassword = user.providerData.any(
      (info) => info.providerId == 'password',
    );
    if (!hasPassword) return false;

    try {
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: password,
      );
      await user.reauthenticateWithCredential(credential);
      return true; // Password matched
    } catch (_) {
      return false; // Password incorrect or failed
    }
  }

  Future<String?> emailUpdate(String newEmail) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return "No user signed in.";

    try {
      await user.verifyBeforeUpdateEmail(newEmail);
      return null; // Success
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }

  Future<String?> confirmUpdateOTP({required String smsCode}) async {
    try {
      // Check if verification ID exists
      if (_verificationId == null || _verificationId!.isEmpty) {
        return 'No verification ID found. Please request OTP again.';
      }

      // Validate SMS code
      if (smsCode.isEmpty || smsCode.length != 6) {
        return 'Please enter a valid 6-digit code.';
      }

      // Create credential
      final credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: smsCode,
      );

      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await user.updatePhoneNumber(credential);
      } else {
        throw FirebaseAuthException(
          code: 'user-not-signed-in',
          message: 'No signed-in user found.',
        );
      }

      // Clear verification ID after successful verification
      _verificationId = null;

      return null; // Success
    } on FirebaseAuthException catch (e) {
      // Clear verification ID on certain errors
      if (e.code == 'session-expired' || e.code == 'invalid-verification-id') {
        _verificationId = null;
      }

      // Return specific error messages
      switch (e.code) {
        case 'invalid-verification-code':
          return 'Invalid verification code. Please check and try again.';
        case 'invalid-verification-id':
          return 'Verification session expired. Please request a new OTP.';
        case 'session-expired':
          return 'Verification session expired. Please request a new OTP.';
        case 'too-many-requests':
          return 'Too many attempts. Please try again later.';
        case 'quota-exceeded':
          return 'SMS quota exceeded. Please try again later.';
        default:
          return e.message ?? 'Verification failed: ${e.code}';
      }
    } catch (e) {
      return 'Unexpected error occurred: $e';
    }
  }
}
