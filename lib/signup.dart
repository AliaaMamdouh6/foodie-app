import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {

  final emailController = TextEditingController();
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  bool isPasswordHidden = true;
  bool isConfirmHidden = true;
  bool isLoading = false;

  String selectedCountryCode = "+20";

  /// Message Helper
  void showMessage(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  /// ===============================
  /// Signup Function (FIXED)
  /// ===============================
  Future<void> signUp() async {

    if (isLoading) return;

    if (emailController.text.isEmpty ||
        nameController.text.isEmpty ||
        phoneController.text.isEmpty ||
        passwordController.text.isEmpty ||
        confirmPasswordController.text.isEmpty) {
      showMessage("Please fill all fields");
      return;
    }

    if (passwordController.text != confirmPasswordController.text) {
      showMessage("Passwords do not match");
      return;
    }

    try {

      setState(() => isLoading = true);

      /// Create Firebase User
      UserCredential user =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      /// Send verification email
       user.user!.sendEmailVerification();

      /// Save user data background
       FirebaseFirestore.instance
          .collection("users")
          .doc(user.user!.uid)
          .set({
        "email": emailController.text.trim(),
        "name": nameController.text.trim(),
        "phone": selectedCountryCode + phoneController.text.trim(),
      });

      if (!mounted) return;

      Navigator.pushReplacementNamed(context, "/home");

    } on FirebaseAuthException catch (e) {

      if (e.code == "email-already-in-use") {
        showMessage("Email already in use");
      } else if (e.code == "weak-password") {
        showMessage("Password is too weak");
      } else if (e.code == "invalid-email") {
        showMessage("Invalid email format");
      } else {
        showMessage(e.message ?? "Signup failed");
      }

    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  /// ===============================
  /// UI
  /// ===============================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('signup'.tr())),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            Image.asset('assets/logo.png', height: 100),
            const SizedBox(height: 30),

            TextField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: 'email'.tr(),
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.email),
              ),
            ),

            const SizedBox(height: 15),

            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: 'name'.tr(),
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.person),
              ),
            ),

            const SizedBox(height: 15),

            Row(
              children: [

                DropdownButton<String>(
                  value: selectedCountryCode,
                  items: const [
                    DropdownMenuItem(value: "+20", child: Text("+20 🇪🇬")),
                    DropdownMenuItem(value: "+1", child: Text("+1 🇺🇸")),
                    DropdownMenuItem(value: "+966", child: Text("+966 🇸🇦")),
                  ],
                  onChanged: (value) {
                    setState(() {
                      selectedCountryCode = value!;
                    });
                  },
                ),

                const SizedBox(width: 10),

                Expanded(
                  child: TextField(
                    controller: phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      labelText: 'phone'.tr(),
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.phone),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 15),

            TextField(
              controller: passwordController,
              obscureText: isPasswordHidden,
              decoration: InputDecoration(
                labelText: 'password'.tr(),
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.lock),
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

            const SizedBox(height: 10),

            TextField(
              controller: confirmPasswordController,
              obscureText: isConfirmHidden,
              decoration: InputDecoration(
                labelText: 'confirm_password'.tr(),
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  icon: Icon(
                    isConfirmHidden
                        ? Icons.visibility
                        : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      isConfirmHidden = !isConfirmHidden;
                    });
                  },
                ),
              ),
            ),

            const SizedBox(height: 25),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isLoading ? null : signUp,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
                child: isLoading
                    ? const CircularProgressIndicator()
                    : Text('signup'.tr()),
              ),
            ),

            const SizedBox(height: 10),

            TextButton(
              onPressed: () =>
                  Navigator.pushReplacementNamed(context, '/signin'),
              child: Text('have_account'.tr()),
            ),
          ],
        ),
      ),
    );
  }
}