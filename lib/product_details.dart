import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProductDetails extends StatefulWidget {
  final String productId;

  const ProductDetails({super.key, required this.productId});

  @override
  State<ProductDetails> createState() => _ProductDetailsState();
}

class _ProductDetailsState extends State<ProductDetails> {
  int quantity = 1;

  void increment() => setState(() => quantity++);
  void decrement() => setState(() { if (quantity > 1) quantity--; });

  Future<void> addToCart(BuildContext context, Map<String, dynamic> product) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please login first")),
      );
      return;
    }

    final isOffer = product['isOffer'] ?? false;
    final discount = isOffer ? (product['discount'] ?? 0) : 0;
    final originalPrice = (product['price'] ?? 0).toDouble();
    final discountedPrice = isOffer
        ? originalPrice - (originalPrice * discount / 100)
        : originalPrice;

    final cartRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('cart');

    final existing = await cartRef
        .where('name', isEqualTo: product['name'])
        .get();

    if (existing.docs.isNotEmpty) {
      final docId = existing.docs.first.id;
      final currentQuantity = existing.docs.first['quantity'] ?? 1;
      await cartRef.doc(docId).update({
        'quantity': currentQuantity + quantity,
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Quantity updated ✅")),
      );
    } else {
      await cartRef.add({
        'name': product['name'],
        'image': product['image'],
        'originalPrice': originalPrice,
        'price': discountedPrice,
        'discount': discount,
        'hasOffer': isOffer,
        'quantity': quantity,
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isOffer
              ? "Added with $discount% OFF ✅"
              : "Added to cart ✅"),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('products')
            .doc(widget.productId)
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError || !snapshot.hasData) {
            return const Center(child: Text("Error loading product"));
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;
          final name = data['name'] ?? "No name";
          final image = data['image'] ?? "https://via.placeholder.com/300";
          final price = (data['price'] ?? 0).toDouble();
          final description = data['description'] ?? "No description";
          final isOffer = data['isOffer'] ?? false;
          final discount = isOffer ? (data['discount'] ?? 0) : 0;
          final discountedPrice = isOffer
              ? price - (price * discount / 100)
              : price;

          return Column(
            children: [

              // 🖼️ Image
              Stack(
                children: [
                  SizedBox(
                    height: 250,
                    width: double.infinity,
                    child: Image.network(image, fit: BoxFit.cover),
                  ),

                  // 🏷️ Discount badge
                  if (isOffer)
                    Positioned(
                      top: 16,
                      left: 16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          "$discount% OFF",
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),

              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      // 🏷️ Name
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 10),

                      // 💰 Price
                      if (isOffer) ...[
                        Text(
                          "$price EGP",
                          style: const TextStyle(
                            decoration: TextDecoration.lineThrough,
                            color: Colors.grey,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          "${discountedPrice.toStringAsFixed(0)} EGP",
                          style: const TextStyle(
                            fontSize: 20,
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ] else
                        Text(
                          "$price EGP",
                          style: const TextStyle(
                            fontSize: 18,
                            color: Colors.green,
                          ),
                        ),

                      const SizedBox(height: 15),

                      // 📄 Description
                      Text(description),

                      const Spacer(),

                      // 🔢 Quantity Selector
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            onPressed: decrement,
                            icon: const Icon(Icons.remove_circle_outline),
                            color: Colors.deepOrange,
                            iconSize: 30,
                          ),
                          Text(
                            "$quantity",
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            onPressed: increment,
                            icon: const Icon(Icons.add_circle_outline),
                            color: Colors.deepOrange,
                            iconSize: 30,
                          ),
                        ],
                      ),

                      const SizedBox(height: 10),

                      // 🛒 Add to Cart
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => addToCart(context, data),
                          child: Text("Add $quantity to Cart"),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}