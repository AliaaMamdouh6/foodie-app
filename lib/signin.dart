import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'home.dart';

class SignIn extends StatefulWidget {
  const SignIn({super.key});

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool isPasswordHidden = true;
  bool isConfirmHidden = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('signin'.tr())),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Image.asset('assets/logo.png', height: 100),
            const SizedBox(height: 30),

            /// EMAIL
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: 'email'.tr(),
                prefixIcon: const Icon(Icons.email),
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 15),

            /// PASSWORD
            TextField(
              controller: passwordController,
              obscureText: isPasswordHidden,
              decoration: InputDecoration(
                labelText: 'password'.tr(),
                prefixIcon: const Icon(Icons.lock),
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(
                    isPasswordHidden
                        ? Icons.visibility
                        : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      isPasswordHidden = !isPasswordHidden;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height:30, width:10),

            /// SIGN IN BUTTON
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  if (emailController.text.isEmpty ||
                      passwordController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content:
                            Text("Please enter email and password"),
                      ),
                    );
                    return;
                  }

                  try {
                    await FirebaseAuth.instance
                        .signInWithEmailAndPassword(
                      email: emailController.text.trim(),
                      password: passwordController.text.trim(),
                    );

                    Navigator.pushReplacementNamed(
                        context, '/home');
                  } on FirebaseAuthException catch (e) {
                    String message = "Login failed";

                    if (e.code == 'user-not-found') {
                      message =
                          "No user found with this email";
                    } else if (e.code == 'wrong-password') {
                      message = "Wrong password";
                    } else if (e.code == 'invalid-email') {
                      message =
                          "Invalid email format";
                    }

                    ScaffoldMessenger.of(context)
                        .showSnackBar(
                      SnackBar(content: Text(message)),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                      vertical: 15),
                ),
                child: Text('signin'.tr()),
              ),
            ),
            
            const SizedBox(height: 10),

            TextButton(
              onPressed: () =>
                  Navigator.pushReplacementNamed(context, '/forget'),
              child: Text('forget_password'.tr()),
            ),
          ],
        ),
      ),
    );
  }
}