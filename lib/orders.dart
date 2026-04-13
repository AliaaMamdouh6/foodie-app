import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Orders extends StatelessWidget {
  const Orders({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text("Please login")),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Orders"),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('orders')
            .where('userId', isEqualTo: user.uid)
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text("Error loading orders"));
          }

          final orders = snapshot.data!.docs;

          if (orders.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.receipt_long_outlined,
                      size: 80, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    "No orders yet",
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final data = orders[index].data() as Map<String, dynamic>;
              final orderId = orders[index].id;
              final status = data['status'] ?? 'pending';
              final total = data['total'] ?? 0;
              final createdAt = data['createdAt'] != null
                  ? (data['createdAt'] as dynamic).toDate()
                  : DateTime.now();
              final items = List<Map<String, dynamic>>.from(data['items'] ?? []);

              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: ExpansionTile(
                  tilePadding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 8),
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Order #${orderId.substring(0, 6).toUpperCase()}",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      _statusBadge(status),
                    ],
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "${createdAt.day}/${createdAt.month}/${createdAt.year}",
                          style: const TextStyle(color: Colors.grey),
                        ),
                        Text(
                          "$total EGP",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.deepOrange,
                          ),
                        ),
                      ],
                    ),
                  ),
                  children: [
                    const Divider(height: 1),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: items.length,
                      itemBuilder: (context, i) {
                        final item = items[i];
                        return ListTile(
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              item['image'] ?? '',
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) =>
                                  const Icon(Icons.broken_image),
                            ),
                          ),
                          title: Text(item['name'] ?? ''),
                          subtitle: Text(
                              "${item['price']} EGP x ${item['quantity']}"),
                          trailing: Text(
                            "${(item['price'] * item['quantity']).toStringAsFixed(0)} EGP",
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _statusBadge(String status) {
    Color color;
    IconData icon;

    switch (status) {
      case 'confirmed':
        color = Colors.blue;
        icon = Icons.check_circle_outline;
        break;
      case 'preparing':
        color = Colors.orange;
        icon = Icons.restaurant;
        break;
      case 'delivered':
        color = Colors.green;
        icon = Icons.done_all;
        break;
      case 'cancelled':
        color = Colors.red;
        icon = Icons.cancel_outlined;
        break;
      default:
        color = Colors.grey;
        icon = Icons.hourglass_empty;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            status.toUpperCase(),
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}