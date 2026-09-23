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
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw Exception('User not logged in');
    }

    final String? imageUrl = await CloudinaryService.uploadImage(imageFile);

    if (imageUrl == null || imageUrl.isEmpty) {
      throw Exception('Cloudinary upload failed');
    }

    await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
      'profileImageUrl': imageUrl,
    }, SetOptions(merge: true));

    return imageUrl;
  }

  // ============================================================
  // SET PROFILE IMAGE URL (used for asset selections or direct URLs)
  // ============================================================

  Future<void> setProfileImageUrl(String imageUrl) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw Exception('User not logged in');
    }

    await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
      'profileImageUrl': imageUrl,
    }, SetOptions(merge: true));
  }
}
