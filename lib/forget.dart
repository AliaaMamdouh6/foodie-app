import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:easy_localization/easy_localization.dart';
import 'signin.dart';
class Forget extends StatefulWidget {
  const Forget({super.key});

  @override
  State<Forget> createState() => _ForgetState();
}

class _ForgetState extends State<Forget> {

  final TextEditingController emailController = TextEditingController();

  bool isLoading = false;

  /// Message Helper
  void showMessage(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  /// Reset Password Function
  Future<void> resetPassword() async {

    if (emailController.text.isEmpty) {
      showMessage("Enter your email");
      return;
    }

    try {
      setState(() => isLoading = true);

      await FirebaseAuth.instance
          .sendPasswordResetEmail(
        email: emailController.text.trim(),
      );

      showMessage("Password reset email sent");

      Navigator.pop(context);

    } on FirebaseAuthException catch (e) {

      if (e.code == "user-not-found") {
        showMessage("No user found with this email");
      } else if (e.code == "invalid-email") {
        showMessage("Invalid email format");
      } else {
        showMessage("Error sending reset email");
      }

    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: (){
         Navigator.pushReplacementNamed(context, '/signin');
          },
        ),
        title: Text("forget_password".tr()),
      
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [

            const SizedBox(height: 40),

            /// Email Field
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: "Enter your email",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email),
              ),
            ),

            const SizedBox(height: 25),

            /// Reset Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isLoading ? null : resetPassword,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
                child: isLoading
                    ? const CircularProgressIndicator()
                    : const Text("Reset Password"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}