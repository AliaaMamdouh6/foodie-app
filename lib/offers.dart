import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Offers extends StatelessWidget {
  const Offers({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        // 🔹 Title
        const Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            "Offers",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),

        // 🔹 Slider
        SizedBox(
          height: 170,
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('products')
                .where('isOffer', isEqualTo: true)
                .snapshots(),
            builder: (context, snapshot) {

              // 🔄 Loading
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              // ❌ Error
              if (snapshot.hasError) {
                return const Center(child: Text("Error loading offers"));
              }

              final products = snapshot.data!.docs;

              // ❌ No offers
              if (products.isEmpty) {
                return const Center(child: Text("No offers available"));
              }

              return PageView.builder(
                itemCount: products.length,
                itemBuilder: (context, index) {

                  final data =
                      products[index].data() as Map<String, dynamic>;

                  final name = data['name'] ?? "No name";
                  final image = data['image'] ??
                      "https://via.placeholder.com/300";
                  final discount = data['discount'] ?? 0;

                  return offerCard(name, image, discount);
                  
                },
              );
            },
          ),
        ),
      ],
    );
  }

  // 🔥 Offer Card
  Widget offerCard(String name, String image, int discount) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Stack(
          fit: StackFit.expand,
          children: [

            // 🖼️ Image
            Image.network(
              image,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return const Center(child: Icon(Icons.error));
              },
            ),

            // 🌑 Dark overlay
            Container(
              color: Colors.black.withOpacity(0.4),
            ),

            // 🏷️ Text
            Center(
              child: Text(
                "$discount% OFF\n$name",
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}