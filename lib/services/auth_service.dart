import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // LOGIN
  Future<User?> login(String email, String password) async {
    UserCredential credential =
        await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    return credential.user;
  }

  // SIGN UP
  Future<User?> register(
    String name,
    String email,
    String password,
  ) async {
    UserCredential credential =
        await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    await credential.user?.updateDisplayName(name.trim());

    return credential.user;
  }

  // FORGOT PASSWORD
  Future<void> resetPassword(String email) async {
    await _auth.sendPasswordResetEmail(
      email: email.trim(),
    );
  }

  // LOGOUT
  Future<void> logout() async {
    await _auth.signOut();
  }

  // CURRENT USER
  User? get currentUser => _auth.currentUser;

  // USER NAME
  String get userName {
    return _auth.currentUser?.displayName ?? 'Student';
  }
}