import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'product_details.dart';

class Product extends StatelessWidget {
  final String? selectedCategory;
  final String searchQuery;

  const Product({
    super.key,
    this.selectedCategory,
    this.searchQuery = '',
  });

  @override
  Widget build(BuildContext context) {
    final stream = (selectedCategory == null)
        ? FirebaseFirestore.instance.collection('products').snapshots()
        : FirebaseFirestore.instance
            .collection('products')
            .where('categoryId', isEqualTo: selectedCategory)
            .snapshots();

    return StreamBuilder<QuerySnapshot>(
      stream: stream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return const Center(child: Text("Error loading products"));
        }

        var products = snapshot.data!.docs;

        // 👇 Filter by search query locally
        if (searchQuery.isNotEmpty) {
          products = products.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final name = (data['name'] ?? '').toString().toLowerCase();
            return name.contains(searchQuery);
          }).toList();
        }

        if (products.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                const Icon(Icons.search_off, size: 60, color: Colors.grey),
                const SizedBox(height: 10),
                Text(
                  searchQuery.isNotEmpty
                      ? 'No results for "$searchQuery"'
                      : "No products found",
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: products.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.62,
          ),
          itemBuilder: (context, index) {
            final data = products[index].data() as Map<String, dynamic>;
            return ProductCard(
              data: data,
              productId: products[index].id,
            );
          },
        );
      },
    );
  }
}

class ProductCard extends StatefulWidget {
  final Map<String, dynamic> data;
  final String productId;

  const ProductCard({super.key, required this.data, required this.productId});

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  int cartQuantity = 0;
  String? cartDocId;

  @override
  void initState() {
    super.initState();
    _listenToCart();
  }

  void _listenToCart() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('cart')
        .where('name', isEqualTo: widget.data['name'])
        .snapshots()
        .listen((snapshot) {
      if (mounted) {
        setState(() {
          if (snapshot.docs.isNotEmpty) {
            cartQuantity = snapshot.docs.first['quantity'] ?? 1;
            cartDocId = snapshot.docs.first.id;
          } else {
            cartQuantity = 0;
            cartDocId = null;
          }
        });
      }
    });
  }

  Future<void> _addToCart() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please login first")),
      );
      return;
    }

    final isOffer = widget.data['isOffer'] ?? false;
    final discount = isOffer ? (widget.data['discount'] ?? 0) : 0;
    final originalPrice = (widget.data['price'] ?? 0).toDouble();
    final discountedPrice = isOffer
        ? originalPrice - (originalPrice * discount / 100)
        : originalPrice;

    final cartRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('cart');

    if (cartDocId != null) {
      await cartRef.doc(cartDocId).update({'quantity': cartQuantity + 1});
    } else {
      await cartRef.add({
        'name': widget.data['name'],
        'image': widget.data['image'],
        'originalPrice': originalPrice,
        'price': discountedPrice,
        'discount': discount,
        'hasOffer': isOffer,
        'quantity': 1,
      });
    }
  }

  Future<void> _decrementCart() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final cartRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('cart');

    if (cartQuantity > 1) {
      await cartRef.doc(cartDocId).update({'quantity': cartQuantity - 1});
    } else {
      await cartRef.doc(cartDocId).delete();
    }
  }

  @override
  Widget build(BuildContext context) {
    final name = widget.data['name'] ?? "No name";
    final image = widget.data['image'] ?? "https://via.placeholder.com/150";
    final price = widget.data['price'] ?? 0;
    final isOffer = widget.data['isOffer'] ?? false;
    final discount = widget.data['discount'] ?? 0;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProductDetails(productId: widget.productId),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.all(8),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // 🖼️ Image + badge
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    image,
                    height: 120,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        const Icon(Icons.broken_image),
                  ),
                ),
                if (isOffer)
                  Positioned(
                    top: 6,
                    left: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        "$discount% OFF",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 6),

            // 🏷️ Name
            Text(
              name,
              style: const TextStyle(fontWeight: FontWeight.bold),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),

            // 💰 Price
            if (isOffer) ...[
              Text(
                "$price EGP",
                style: const TextStyle(
                  decoration: TextDecoration.lineThrough,
                  color: Colors.grey,
                  fontSize: 12,
                ),
              ),
              Text(
                "${(price - (price * discount / 100)).toStringAsFixed(0)} EGP",
                style: const TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ] else
              Text("$price EGP"),

            const SizedBox(height: 6),

            // 🛒 Add to Cart or Quantity controls
            cartQuantity == 0
                ? SizedBox(
                    width: double.infinity,
                    height: 32,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: _addToCart,
                      child: const Text(
                        "Add to Cart",
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      InkWell(
                        onTap: _decrementCart,
                        child: const Icon(Icons.remove_circle_outline,
                            color: Colors.deepOrange),
                      ),
                      Text(
                        "$cartQuantity",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      InkWell(
                        onTap: _addToCart,
                        child: const Icon(Icons.add_circle_outline,
                            color: Colors.deepOrange),
                      ),
                    ],
                  ),
          ],
        ),
      ),
    );
  }
}