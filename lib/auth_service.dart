import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthService {

  /// Auto redirect if user logged in
  static Widget authGate({
    required Widget loggedInPage,
    required Widget loginPage,
  }) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasData) {
          return loggedInPage;
        }

        return loginPage;
      },
    );
  }

  /// Logout
  static Future logout() async {
    await FirebaseAuth.instance.signOut();
  }

  /// Send email verification
  static Future sendVerification() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null && !user.emailVerified) {
      await user.sendEmailVerification();
    }
  }
}