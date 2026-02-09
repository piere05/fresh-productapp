// ignore_for_file: prefer_const_constructors_in_immutables, use_build_context_synchronously

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProductDetailsPage extends StatefulWidget {
  final String productId;
  final Map<String, dynamic> productData;

  ProductDetailsPage({
    super.key,
    required this.productId,
    required this.productData,
  });

  @override
  State<ProductDetailsPage> createState() => _ProductDetailsPageState();
}

class _ProductDetailsPageState extends State<ProductDetailsPage> {
  int qty = 1;
  bool _inWishlist = false;
  String? _wishlistDocId;

  @override
  void initState() {
    super.initState();
    _checkWishlist();
  }

  // ❤️ CHECK IF IN WISHLIST
  Future<void> _checkWishlist() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final snap = await FirebaseFirestore.instance
        .collection('wishlist')
        .where('userEmail', isEqualTo: user.email)
        .where('productId', isEqualTo: widget.productId)
        .limit(1)
        .get();

    if (snap.docs.isNotEmpty) {
      setState(() {
        _inWishlist = true;
        _wishlistDocId = snap.docs.first.id;
      });
    }
  }

  // ❤️ TOGGLE WISHLIST
  Future<void> _toggleWishlist() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    if (_inWishlist) {
      await FirebaseFirestore.instance
          .collection('wishlist')
          .doc(_wishlistDocId)
          .delete();

      setState(() {
        _inWishlist = false;
        _wishlistDocId = null;
      });

      _showSnack("Removed from wishlist");
    } else {
      final doc = await FirebaseFirestore.instance.collection('wishlist').add({
        'userEmail': user.email,
        'productId': widget.productId,
        'productName': widget.productData['name'],
        'price': widget.productData['price'],
        'addedBy': widget.productData['addedBy'],
        'category': widget.productData['category'],
        'createdAt': FieldValue.serverTimestamp(),
      });

      setState(() {
        _inWishlist = true;
        _wishlistDocId = doc.id;
      });

      _showSnack("Added to wishlist");
    }
  }

  // 🛒 ADD TO CART
  // 🛒 ADD TO CART (UPDATE IF EXISTS)
  Future<void> _addToCart() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final price = widget.productData['price'];

    final cartQuery = await FirebaseFirestore.instance
        .collection('cart')
        .where('userEmail', isEqualTo: user.email)
        .where('productId', isEqualTo: widget.productId)
        .limit(1)
        .get();

    if (cartQuery.docs.isNotEmpty) {
      // ✅ UPDATE EXISTING CART ITEM
      final doc = cartQuery.docs.first;
      final existingQty = doc['qty'] as int;

      final newQty = existingQty + qty;

      await FirebaseFirestore.instance.collection('cart').doc(doc.id).update({
        'qty': newQty,
        'totalPrice': newQty * price,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      _showSnack("Cart updated");
    } else {
      // ✅ ADD NEW CART ITEM
      await FirebaseFirestore.instance.collection('cart').add({
        'userEmail': user.email,
        'productId': widget.productId,
        'addedBy': widget.productData['addedBy'],
        'productName': widget.productData['name'],
        'qty': qty,
        'price': price,
        'totalPrice': qty * price,
        'createdAt': FieldValue.serverTimestamp(),
      });

      _showSnack("Added to cart");
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.productData;

    final int currentStock = (p['currentStock'] as num?)?.toInt() ?? 0;
    return Scaffold(
      backgroundColor: const Color(0xFFE3F2FD),
      appBar: AppBar(
        title: const Text("Product Details"),
        backgroundColor: Colors.blue,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Card(
          color: Colors.white,
          elevation: 5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 🖼 IMAGE WITH HEART OVERLAY
                Stack(
                  children: [
                    Container(
                      height: 200,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.blue.shade100,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: p['imageBase64'] != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: Image.memory(
                                base64Decode(p['imageBase64']),
                                fit: BoxFit.cover,
                              ),
                            )
                          : const Icon(
                              Icons.shopping_bag,
                              size: 100,
                              color: Colors.blue,
                            ),
                    ),

                    // ❤️ HEART ICON
                    Positioned(
                      top: 10,
                      right: 10,
                      child: InkWell(
                        onTap: _toggleWishlist,
                        child: CircleAvatar(
                          backgroundColor: Colors.white,
                          radius: 20,
                          child: Icon(
                            _inWishlist
                                ? Icons.favorite
                                : Icons.favorite_border,
                            color: Colors.pink,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                Text(
                  p['name'],
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 6),

                Chip(
                  label: Text(p['category']),
                  backgroundColor: const Color(0xFFD6EAF8),
                  labelStyle: const TextStyle(color: Colors.blue),
                ),

                const SizedBox(height: 12),

                Text(
                  "₹${p['price']} / ${p['unit']}",
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),

                const SizedBox(height: 20),

                const Text(
                  "Description",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 6),

                Text(p['description'] ?? "No description available"),

                const SizedBox(height: 25),

                // ➕➖ QTY
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove),
                      onPressed: qty > 1 ? () => setState(() => qty--) : null,
                    ),
                    Text(qty.toString(), style: const TextStyle(fontSize: 18)),
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: qty < currentStock
                          ? () => setState(() => qty++)
                          : () => _showSnack("Only $currentStock in stock"),
                    ),
                  ],
                ),

                const SizedBox(height: 25),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.shopping_cart, color: Colors.white),
                    label: const Text(
                      "Add to Cart",
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: _addToCart,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }
}
