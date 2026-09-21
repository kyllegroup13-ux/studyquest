import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // LOGIN
  Future<User?> login(String email, String password) async {
    UserCredential credential = await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    return credential.user;
  }

  // SIGN UP
  Future<User?> register(String username, String email, String password) async {
    UserCredential credential = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    User? user = credential.user;

    if (user != null) {
      // Save username to Firebase Authentication
      await user.updateDisplayName(username.trim());

      // Save user information to Firestore
      await _firestore.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'username': username.trim(),
        'email': email.trim(),
        'role': 'student',
        'createdAt': FieldValue.serverTimestamp(),
      });
    }

    return user;
  }

  // FORGOT PASSWORD
  Future<void> resetPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email.trim());
  }

  // LOGOUT
  Future<void> logout() async {
    await _auth.signOut();
  }

  // CURRENT USER
  User? get currentUser => _auth.currentUser;

  // USERNAME
  String get userName {
    return _auth.currentUser?.displayName ?? 'Student';
  }
}
