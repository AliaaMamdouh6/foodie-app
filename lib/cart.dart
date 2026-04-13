import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'orders.dart';

class Cart extends StatelessWidget {
  const Cart({super.key});

  Future<void> placeOrder(BuildContext context, List<QueryDocumentSnapshot> items, double total) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    // 👇 Build items list for the order
    final orderItems = items.map((item) {
      final data = item.data() as Map<String, dynamic>;
      return {
        'name': data['name'],
        'image': data['image'],
        'price': data['price'],
        'quantity': data['quantity'],
      };
    }).toList();

    // 👇 Create order in Firestore
    await FirebaseFirestore.instance.collection('orders').add({
      'userId': user.uid,
      'items': orderItems,
      'total': total,
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
    });

    // 👇 Clear cart after order placed
    final cartRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('cart');

    for (var item in items) {
      await cartRef.doc(item.id).delete();
    }

    // 👇 Navigate to orders page
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const Orders()),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Order placed successfully ✅")),
    );
  }

  void removeItem(String uid, String itemId) {
    FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('cart')
        .doc(itemId)
        .delete();
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text("Please login")),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Cart"), centerTitle: true),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('cart')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text("Error loading cart"));
          }

          final items = snapshot.data!.docs;

          if (items.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_cart_outlined,
                      size: 80, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    "Cart is empty",
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          double total = 0;
          for (var item in items) {
            final data = item.data() as Map<String, dynamic>;
            total += (data['price'] ?? 0) * (data['quantity'] ?? 1);
          }

          return Column(
            children: [

              // 🛒 Cart Items
              Expanded(
                child: ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final data = items[index].data() as Map<String, dynamic>;
                    final name = data['name'];
                    final image = data['image'];
                    final price = data['price'];
                    final quantity = data['quantity'];
                    final hasOffer = data['hasOffer'] ?? false;
                    final discount = data['discount'] ?? 0;
                    final originalPrice = data['originalPrice'] ?? price;

                    return ListTile(
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          image,
                          width: 55,
                          height: 55,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              const Icon(Icons.broken_image),
                        ),
                      ),
                      title: Text(
                        name,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (hasOffer) ...[
                            Text(
                              "$originalPrice EGP",
                              style: const TextStyle(
                                decoration: TextDecoration.lineThrough,
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                            Text(
                              "$price EGP  (-$discount%)",
                              style: const TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ] else
                            Text("$price EGP"),
                          Text("Quantity: $quantity"),
                        ],
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => removeItem(user.uid, items[index].id),
                      ),
                    );
                  },
                ),
              ),

              // 💰 Total + Checkout
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border(
                      top: BorderSide(color: Colors.grey.shade300)),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Total",
                          style: TextStyle(fontSize: 18),
                        ),
                        Text(
                          "${total.toStringAsFixed(0)} EGP",
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.deepOrange,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepOrange,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: const Icon(Icons.check_circle_outline),
                        label: const Text(
                          "Place Order",
                          style: TextStyle(fontSize: 16),
                        ),
                        // 👇 Place order on tap
                        onPressed: () => placeOrder(context, items, total),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}