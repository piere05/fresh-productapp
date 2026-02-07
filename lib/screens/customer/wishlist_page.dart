// ignore_for_file: prefer_const_constructors_in_immutables

import 'package:flutter/material.dart';

class WishlistPage extends StatelessWidget {
  WishlistPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF3E0),
      appBar: AppBar(
        title: const Text("My Wishlist"),
        backgroundColor: Colors.pink,
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          _wishlistCard(
            context,
            name: "Apples",
            price: "₹120 / kg",
            category: "Fruits",
          ),
          _wishlistCard(
            context,
            name: "Tomatoes",
            price: "₹40 / kg",
            category: "Vegetables",
          ),
          _wishlistCard(
            context,
            name: "Onions",
            price: "₹30 / kg",
            category: "Vegetables",
          ),
        ],
      ),
    );
  }

  // ❤️ WISHLIST CARD
  Widget _wishlistCard(
    BuildContext context, {
    required String name,
    required String price,
    required String category,
  }) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.pink.shade100,
          child: const Icon(Icons.favorite, color: Colors.pink),
        ),
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text("Category: $category\nPrice: $price"),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.shopping_cart, color: Colors.green),
              tooltip: "Add to Cart",
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("$name added to cart (Demo)")),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              tooltip: "Remove",
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("$name removed from wishlist (Demo)")),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
