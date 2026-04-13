import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import'orders.dart';

class Profile extends StatelessWidget {
  const Profile({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        centerTitle: true,
      ),
      body: user == null
          ? const Center(child: Text("Please login"))
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [

                  const SizedBox(height: 20),

                  // 👤 Avatar
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.deepOrange,
                    child: Text(
                      user.email![0].toUpperCase(),
                      style: const TextStyle(
                        fontSize: 40,
                        color: Colors.white,
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // 📧 Email
                  Text(
                    user.email ?? "No email",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  // 🆔 User ID
                  Text(
                    "UID: ${user.uid}",
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),

                  const SizedBox(height: 30),

                  const Divider(),

                  // 📋 Menu Items
                  ListTile(
                    leading: const Icon(Icons.shopping_bag_outlined,
                        color: Colors.deepOrange),
                    title: const Text("My Orders"),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                    onTap: () {
                      // Navigate to orders page
                    },
                  ),

                  const Divider(),

                  ListTile(
                    leading: const Icon(Icons.lock_outline,
                        color: Colors.deepOrange),
                    title: const Text("Change Password"),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                    onTap: () {
                      // Navigate to change password page
                    },
                  ),

                  const Divider(),

                  const Spacer(),

                  // 🚪 Logout
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(Icons.logout),
                      label: const Text("Logout"),
                      onPressed: () async {
                        await FirebaseAuth.instance.signOut();
                      },
                    ),
                  ),

                  const SizedBox(height: 20),
                  ListTile(
                    leading: const Icon(Icons.shopping_bag_outlined, color: Colors.deepOrange),
                    title: const Text("My Orders"),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const Orders()),
    );
  },
),
                ],
              ),
            ),
    );
  }
}