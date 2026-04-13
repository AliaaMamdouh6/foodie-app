import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Category extends StatefulWidget {
  final Function(String?) onCategorySelected;

  const Category({super.key, required this.onCategorySelected});

  @override
  State<Category> createState() => _CategoryState();
}

class _CategoryState extends State<Category> {
  int selectedIndex = -1;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 45,
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('categories').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final categoryDocs = snapshot.data!.docs;

          return ListView.builder(
            scrollDirection: Axis.horizontal,
            // +1 for "All" button
            itemCount: categoryDocs.length + 1,
            itemBuilder: (context, index) {
              final isSelected = index == selectedIndex;

              // 👈 First item is always "All"
              if (index == 0) {
                return GestureDetector(
                  onTap: () {
                    setState(() => selectedIndex = 0);
                    widget.onCategorySelected(null); // null = show all
                  },
                  child: Container(
                    width: 120,
                    margin: const EdgeInsets.symmetric(horizontal: 6),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.deepOrange : Colors.transparent,
                      borderRadius: BorderRadius.circular(40),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Center(
                      child: Text(
                        "All",
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                );
              }

              final doc = categoryDocs[index - 1];
              final name = doc['name'];
              final categoryId = doc.id; // 👈 get doc ID e.g. "cat1"

              return GestureDetector(
                onTap: () {
                  setState(() => selectedIndex = index);
                  widget.onCategorySelected(categoryId); // 👈 send ID not name
                },
                child: Container(
                  width: 120,
                  margin: const EdgeInsets.symmetric(horizontal: 6),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.deepOrange : Colors.transparent,
                    borderRadius: BorderRadius.circular(40),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Center(
                    child: Text(
                      name,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}