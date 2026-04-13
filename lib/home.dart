import 'package:flutter/material.dart';
import 'category.dart';
import 'offers.dart';
import 'product.dart';
import 'cart.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String? selectedCategory;
  String searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        centerTitle: true,
        backgroundColor: Colors.deepOrange,
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const Cart()),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // 🔍 Search Bar
            SizedBox(
              height: 45,
              child: TextField(
                controller: _searchController,
                onChanged: (value) {
                  setState(() {
                    searchQuery = value.trim().toLowerCase();
                  });
                },
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search),
                  hintText: 'Search',
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  // 👇 Clear button
                  suffixIcon: searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {
                              searchQuery = '';
                            });
                          },
                        )
                      : null,
                ),
              ),
            ),

            const SizedBox(height: 20),

            // 👇 Hide categories and offers when searching
            if (searchQuery.isEmpty) ...[
              const Text(
                "Categories",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 10),

              Category(
                onCategorySelected: (category) {
                  setState(() {
                    selectedCategory = category;
                  });
                },
              ),

              const Divider(thickness: 2, indent: 8, endIndent: 8),

              const SizedBox(height: 10),

              const Offers(),

              const SizedBox(height: 10),
            ],

            // 👇 Pass both search and category to Product
            Product(
              selectedCategory: searchQuery.isEmpty ? selectedCategory : null,
              searchQuery: searchQuery,
            ),
          ],
        ),
      ),
    );
  }
}