// ignore_for_file: prefer_const_constructors_in_immutables, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'product_details_page.dart';

class WishlistPage extends StatelessWidget {
  WishlistPage({super.key});

  final user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF3E0),
      appBar: AppBar(
        title: const Text("My Wishlist"),
        backgroundColor: Colors.pink,
        centerTitle: true,
      ),
      body: user == null
          ? const Center(child: Text("Please login"))
          : StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('wishlist')
                  .where('userEmail', isEqualTo: user!.email)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final docs = snapshot.data!.docs;

                if (docs.isEmpty) {
                  return const Center(child: Text("Your wishlist is empty"));
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final doc = docs[index];
                    final data = doc.data() as Map<String, dynamic>;

                    return _wishlistCard(
                      context,
                      wishlistId: doc.id,
                      data: data,
                    );
                  },
                );
              },
            ),
    );
  }

  // ❤️ WISHLIST CARD (FIXED UI)
  Widget _wishlistCard(
    BuildContext context, {
    required String wishlistId,
    required Map<String, dynamic> data,
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
        title: Text(
          data['productName'],
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          "Category: ${data['category'] ?? '-'}\nPrice: ₹${data['price']}",
        ),
        isThreeLine: true,

        // ✅ FIXED: ROW instead of COLUMN
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.shopping_cart, color: Colors.green),
              tooltip: "View Product",
              onPressed: () async {
                final productSnap = await FirebaseFirestore.instance
                    .collection('products')
                    .doc(data['productId'])
                    .get();

                if (!productSnap.exists) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Product not available")),
                  );
                  return;
                }

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ProductDetailsPage(
                      productId: productSnap.id,
                      productData: productSnap.data() as Map<String, dynamic>,
                    ),
                  ),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              tooltip: "Remove",
              onPressed: () async {
                await FirebaseFirestore.instance
                    .collection('wishlist')
                    .doc(wishlistId)
                    .delete();

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Removed from wishlist")),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
