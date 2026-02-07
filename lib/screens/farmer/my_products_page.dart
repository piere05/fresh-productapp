// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

class MyProductsPage extends StatelessWidget {
  const MyProductsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F8E9),
      appBar: AppBar(
        title: const Text("My Products"),
        backgroundColor: Colors.green,
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          _productCard(
            context,
            name: "Tomatoes",
            price: "₹40 / kg",
            stock: "In Stock",
            stockColor: Colors.green,
          ),
          _productCard(
            context,
            name: "Onions",
            price: "₹30 / kg",
            stock: "Low Stock",
            stockColor: Colors.orange,
          ),
          _productCard(
            context,
            name: "Apples",
            price: "₹120 / kg",
            stock: "Out of Stock",
            stockColor: Colors.red,
          ),
        ],
      ),
    );
  }

  // 📦 PRODUCT CARD
  Widget _productCard(
    BuildContext context, {
    required String name,
    required String price,
    required String stock,
    required Color stockColor,
  }) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.green.withOpacity(0.15),
          child: const Icon(Icons.shopping_bag, color: Colors.green),
        ),
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(price),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              stock,
              style: TextStyle(color: stockColor, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, size: 18, color: Colors.blue),
                  onPressed: () {
                    _showSnack(context, "Edit $name (Demo)");
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete, size: 18, color: Colors.red),
                  onPressed: () {
                    _confirmDelete(context, name);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // 🔔 SNACKBAR
  void _showSnack(BuildContext context, String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  // 🗑 DELETE CONFIRMATION
  void _confirmDelete(BuildContext context, String name) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete Product"),
        content: Text("Are you sure you want to delete $name?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _showSnack(context, "$name deleted (Demo)");
            },
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }
}
