// ignore_for_file: deprecated_member_use

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminProductsPage extends StatefulWidget {
  const AdminProductsPage({super.key});

  @override
  State<AdminProductsPage> createState() => _AdminProductsPageState();
}

class _AdminProductsPageState extends State<AdminProductsPage> {
  String _search = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Products"),
        backgroundColor: Colors.orange,
        centerTitle: true,
      ),
      body: Column(
        children: [
          // 🔍 SEARCH
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              onChanged: (v) => setState(() => _search = v),
              decoration: InputDecoration(
                hintText: "Search products...",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.grey.shade200,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // 📦 PRODUCTS LIST
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('products')
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final docs = snapshot.data!.docs.where((doc) {
                  final name = (doc['name'] ?? "").toString().toLowerCase();
                  return name.contains(_search.toLowerCase());
                }).toList();

                if (docs.isEmpty) {
                  return const Center(child: Text("No products found"));
                }

                return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index].data() as Map<String, dynamic>;
                    return _productCard(data);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ================= PRODUCT CARD =================
  Widget _productCard(Map<String, dynamic> p) {
    final bool inStock = p['inStock'] == true;
    final String farmerId = p['farmerId'] ?? "";

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: _productImage(p['imageBase64']),
        title: Text(
          p['name'] ?? "-",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Category: ${p['category'] ?? '-'}"),
            Text("Price: ₹${p['price']} / ${p['unit']}"),
            Text("Stock: ${p['currentStock']}"),
            const SizedBox(height: 4),
            _farmerInfo(farmerId),
          ],
        ),
        trailing: Text(
          inStock ? "In Stock" : "Out of Stock",
          style: TextStyle(
            color: inStock ? Colors.green : Colors.red,
            fontWeight: FontWeight.bold,
          ),
        ),
        isThreeLine: true,
      ),
    );
  }

  // ================= IMAGE =================
  Widget _productImage(String? base64) {
    if (base64 == null || base64.isEmpty) {
      return const CircleAvatar(
        backgroundColor: Colors.orange,
        child: Icon(Icons.shopping_bag, color: Colors.white),
      );
    }

    try {
      return CircleAvatar(backgroundImage: MemoryImage(base64Decode(base64)));
    } catch (_) {
      return const CircleAvatar(
        backgroundColor: Colors.orange,
        child: Icon(Icons.shopping_bag, color: Colors.white),
      );
    }
  }

  // ================= FARMER INFO =================
  Widget _farmerInfo(String farmerId) {
    if (farmerId.isEmpty) {
      return const Text("Farmer: -");
    }

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('farmers')
          .doc(farmerId)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Text("Farmer: Loading...");
        }

        final f = snapshot.data!.data() as Map<String, dynamic>?;

        if (f == null) {
          return const Text("Farmer: -");
        }

        return Text(
          "Farmer: ${f['name']} (${f['email']})",
          style: const TextStyle(fontSize: 12),
        );
      },
    );
  }
}
