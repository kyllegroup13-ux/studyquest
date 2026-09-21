import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:e_learning/interface/dashboard.dart';
import 'package:e_learning/interface/startup_one.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),

      builder: (context, snapshot) {
        // Firebase is still checking the login state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // User is logged in
        if (snapshot.hasData) {
          return const HomePage();
        }

        // User is not logged in
        return const StartUp();
      },
    );
  }
}