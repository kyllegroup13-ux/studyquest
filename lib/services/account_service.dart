import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'cloudinary_service.dart';

class AccountService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ============================================================
  // CURRENT USER
  // ============================================================

  User? get currentUser => _auth.currentUser;

  // ============================================================
  // GET USER DATA
  // ============================================================

  Future<Map<String, dynamic>?> getUserData() async {
    final user = _auth.currentUser;

    if (user == null) {
      return null;
    }

    final document = await _firestore.collection('users').doc(user.uid).get();

    final data = document.data() ?? {};

    // Date Joined
    DateTime? joinedDate;

    final timestamp = data['dateJoined'];

    if (timestamp is Timestamp) {
      joinedDate = timestamp.toDate();
    } else {
      // Fallback for old accounts
      joinedDate = user.metadata.creationTime;
    }

    return {
      'username': (data['username'] ?? '').toString(),
      'email': (data['email'] ?? user.email ?? '').toString(),
      'profileImageUrl': (data['profileImageUrl'] ?? '').toString(),
      'dateJoined': joinedDate,
    };
  }

  // ============================================================
  // UPDATE USERNAME
  // ============================================================

  Future<void> updateUsername(String username) async {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('No user is currently logged in.');
    }

    await _firestore.collection('users').doc(user.uid).update({
      'username': username.trim(),
    });
  }

  // ============================================================
  // UPDATE PROFILE IMAGE
  // ============================================================

  Future<String> updateProfileImage(File imageFile) async {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('No user is currently logged in.');
    }

    final imageUrl = await CloudinaryService.uploadProfileImage(imageFile);

    if (imageUrl == null || imageUrl.isEmpty) {
      throw Exception('Failed to upload profile image.');
    }

    await _firestore.collection('users').doc(user.uid).update({
      'profileImageUrl': imageUrl,
    });

    return imageUrl;
  }
}
