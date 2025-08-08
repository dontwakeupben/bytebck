import 'package:byteback2/models/firestore_user.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
    try {
      final user = FirebaseAuth.instance.currentUser;
      final credential = EmailAuthProvider.credential(
        email: email,
        password: password,
      );
      user?.linkWithCredential(credential);
    } catch (e) {
      throw Exception('Unexpected Error $e');
    }
  }

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

  // Firestore CRUD operations for guide cards

  // Create a new guide card
  Future<String?> createGuideCard({
    required String title,
    required String description,
    required String imageUrl,
    required String device, // "desktop" or "laptop"
    required String difficulty, // "easy", "medium", or "hard"
    String? customId, // Optional custom ID, otherwise uses auto-generated ID
  }) async {
    try {
      final user = getCurrentUser();
      if (user == null) {
        return 'No user is currently signed in.';
      }

      final guideData = {
        'title': title,
        'description': description,
        'imageUrl': imageUrl,
        'device': device,
        'difficulty': difficulty,
        'createdAt': FieldValue.serverTimestamp(),
        'likes': 0,
        'createdBy': user.uid,
        'createdByName': user.displayName ?? user.email ?? 'Anonymous',
      };

      if (customId != null) {
        await FirebaseFirestore.instance
            .collection('guides')
            .doc(customId)
            .set(guideData);
        return null; // Success
      } else {
        await FirebaseFirestore.instance.collection('guides').add(guideData);
        return null; // Success
      }
    } on FirebaseException catch (e) {
      return 'Firestore error: ${e.message}';
    } catch (e) {
      return 'Unexpected error: $e';
    }
  }

  // Get a single guide card by ID
  Future<Map<String, dynamic>?> getGuideCard(String guideId) async {
    try {
      final doc =
          await FirebaseFirestore.instance
              .collection('guides')
              .doc(guideId)
              .get();

      if (doc.exists) {
        final data = doc.data()!;
        data['id'] = doc.id; // Add document ID to the data
        return data;
      } else {
        return null; // Guide doesn't exist
      }
    } on FirebaseException catch (e) {
      debugPrint('Firestore error: ${e.message}');
      return null;
    } catch (e) {
      debugPrint('Unexpected error: $e');
      return null;
    }
  }

  // Get all guide cards
  Future<List<Map<String, dynamic>>> getAllGuideCards() async {
    try {
      final querySnapshot =
          await FirebaseFirestore.instance
              .collection('guides')
              .orderBy('createdAt', descending: true)
              .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id; // Add document ID to the data
        return data;
      }).toList();
    } on FirebaseException catch (e) {
      debugPrint('Firestore error: ${e.message}');
      return [];
    } catch (e) {
      debugPrint('Unexpected error: $e');
      return [];
    }
  }

  // Get guide cards with filters
  Future<List<Map<String, dynamic>>> getFilteredGuideCards({
    String? device,
    String? difficulty,
    String? createdBy,
    int? limit,
  }) async {
    try {
      Query query = FirebaseFirestore.instance.collection('guides');

      if (device != null) {
        query = query.where('device', isEqualTo: device);
      }
      if (difficulty != null) {
        query = query.where('difficulty', isEqualTo: difficulty);
      }
      if (createdBy != null) {
        query = query.where('createdBy', isEqualTo: createdBy);
      }

      query = query.orderBy('createdAt', descending: true);

      if (limit != null) {
        query = query.limit(limit);
      }

      final querySnapshot = await query.get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id; // Add document ID to the data
        return data;
      }).toList();
    } on FirebaseException catch (e) {
      debugPrint('Firestore error: ${e.message}');
      return [];
    } catch (e) {
      debugPrint('Unexpected error: $e');
      return [];
    }
  }

  // Update a guide card
  Future<String?> updateGuideCard({
    required String guideId,
    String? title,
    String? description,
    String? imageUrl,
    String? device,
    String? difficulty,
  }) async {
    try {
      final user = getCurrentUser();
      if (user == null) {
        return 'No user is currently signed in.';
      }

      // Check if user owns this guide
      final guideDoc =
          await FirebaseFirestore.instance
              .collection('guides')
              .doc(guideId)
              .get();

      if (!guideDoc.exists) {
        return 'Guide not found.';
      }

      final guideData = guideDoc.data()!;
      if (guideData['createdBy'] != user.uid) {
        return 'You can only edit your own guides.';
      }

      final updateData = <String, dynamic>{};

      if (title != null) updateData['title'] = title;
      if (description != null) updateData['description'] = description;
      if (imageUrl != null) updateData['imageUrl'] = imageUrl;
      if (device != null) updateData['device'] = device;
      if (difficulty != null) updateData['difficulty'] = difficulty;

      if (updateData.isNotEmpty) {
        await FirebaseFirestore.instance
            .collection('guides')
            .doc(guideId)
            .update(updateData);
      }

      return null; // Success
    } on FirebaseException catch (e) {
      return 'Firestore error: ${e.message}';
    } catch (e) {
      return 'Unexpected error: $e';
    }
  }

  // Delete a guide card
  Future<String?> deleteGuideCard(String guideId) async {
    try {
      final user = getCurrentUser();
      if (user == null) {
        return 'No user is currently signed in.';
      }

      // Check if user owns this guide
      final guideDoc =
          await FirebaseFirestore.instance
              .collection('guides')
              .doc(guideId)
              .get();

      if (!guideDoc.exists) {
        return 'Guide not found.';
      }

      final guideData = guideDoc.data()!;
      if (guideData['createdBy'] != user.uid) {
        return 'You can only delete your own guides.';
      }

      await FirebaseFirestore.instance
          .collection('guides')
          .doc(guideId)
          .delete();

      return null; // Success
    } on FirebaseException catch (e) {
      return 'Firestore error: ${e.message}';
    } catch (e) {
      return 'Unexpected error: $e';
    }
  }

  // Like/Unlike a guide card
  Future<String?> toggleLikeGuideCard(String guideId) async {
    try {
      final user = getCurrentUser();
      if (user == null) {
        return 'No user is currently signed in.';
      }

      final guideRef = FirebaseFirestore.instance
          .collection('guides')
          .doc(guideId);

      return await FirebaseFirestore.instance.runTransaction((
        transaction,
      ) async {
        final guideDoc = await transaction.get(guideRef);

        if (!guideDoc.exists) {
          throw Exception('Guide not found.');
        }

        final guideData = guideDoc.data()!;
        final currentLikes = guideData['likes'] ?? 0;

        // Simply increment the likes count
        transaction.update(guideRef, {'likes': currentLikes + 1});

        return null; // Success
      });
    } on FirebaseException catch (e) {
      return 'Firestore error: ${e.message}';
    } catch (e) {
      return 'Unexpected error: $e';
    }
  }

  // Get guide cards created by current user
  Future<List<Map<String, dynamic>>> getCurrentUserGuideCards() async {
    final user = getCurrentUser();
    if (user == null) {
      return [];
    }

    return await getFilteredGuideCards(createdBy: user.uid);
  }

  // Search guide cards by title or description
  Future<List<Map<String, dynamic>>> searchGuideCards(String searchTerm) async {
    try {
      // Note: Firestore doesn't support full-text search natively
      // This is a basic implementation that gets all guides and filters client-side
      // For production, consider using Algolia or similar service

      final allGuides = await getAllGuideCards();
      final searchTermLower = searchTerm.toLowerCase();

      return allGuides.where((guide) {
        final title = (guide['title'] as String).toLowerCase();
        final description = (guide['description'] as String).toLowerCase();
        return title.contains(searchTermLower) ||
            description.contains(searchTermLower);
      }).toList();
    } catch (e) {
      debugPrint('Search error: $e');
      return [];
    }
  }

  Future<void> addUserInfo(String email, String fullName) {
    return FirebaseFirestore.instance.collection('users').doc(email).set({
      'fullName': fullName,
    });
  }

  Future<FirestoreUser?> getUserInfo() async {
    DocumentSnapshot snapshot =
        await FirebaseFirestore.instance
            .collection('users')
            .doc(getCurrentUser()?.email)
            .get();
    if (snapshot.exists) {
      final data = snapshot.data() as Map<String, dynamic>;
      return FirestoreUser(id: snapshot.id, fullName: data['fullName'] ?? '');
    } else {
      return FirestoreUser(id: '', fullName: '');
    }
  }

  // Get current user's document from Firestore
  Future<Map<String, dynamic>?> getCurrentUserDocument() async {
    try {
      final user = getCurrentUser();
      if (user == null) {
        return null;
      }

      // Try with UID first (new structure)
      DocumentSnapshot snapshot =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get();

      if (snapshot.exists) {
        final data = snapshot.data() as Map<String, dynamic>;
        data['id'] = snapshot.id;
        return data;
      }

      // Fallback to email-based lookup (old structure)
      snapshot =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.email)
              .get();

      if (snapshot.exists) {
        final data = snapshot.data() as Map<String, dynamic>;
        data['id'] = snapshot.id;
        return data;
      }

      return null;
    } catch (e) {
      debugPrint('Error getting user document: $e');
      return null;
    }
  }

  // Update current user's document
  Future<String?> updateCurrentUserDocument({
    String? displayName,
    String? phoneNumber,
    String? photoURL,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      final user = getCurrentUser();
      if (user == null) {
        return 'No user is currently signed in.';
      }

      final updateData = <String, dynamic>{
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (displayName != null) updateData['displayName'] = displayName;
      if (phoneNumber != null) updateData['phoneNumber'] = phoneNumber;
      if (photoURL != null) updateData['photoURL'] = photoURL;
      if (additionalData != null) updateData.addAll(additionalData);

      // Try with UID first (new structure)
      DocumentSnapshot snapshot =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get();

      if (snapshot.exists) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update(updateData);
      } else {
        // Fallback to email-based (old structure)
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.email)
            .update(updateData);
      }

      return null; // Success
    } on FirebaseException catch (e) {
      return 'Firestore error: ${e.message}';
    } catch (e) {
      return 'Unexpected error: $e';
    }
  }
}
