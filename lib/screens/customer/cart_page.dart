// ignore_for_file: deprecated_member_use, use_build_context_synchronously, avoid_types_as_parameter_names

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'checkout_page.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      return const Scaffold(
        body: Center(child: Text("Please login to view cart")),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFE3F2FD),
      appBar: AppBar(
        title: const Text("My Cart"),
        backgroundColor: Colors.blue,
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('cart')
            .where('userEmail', isEqualTo: user!.email)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return const Center(
              child: Text("Your cart is empty", style: TextStyle(fontSize: 16)),
            );
          }

          final totalAmount = docs.fold<int>(
            0,
            (sum, d) => sum + (d['price'] as int) * (d['qty'] as int),
          );

          return Column(
            children: [
              // 🛒 CART LIST
              Expanded(
                child: ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final doc = docs[index];
                    final item = doc.data() as Map<String, dynamic>;

                    return _cartItemCard(doc.id, item);
                  },
                ),
              ),

              // 💰 TOTAL & CHECKOUT
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Total Amount",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "₹$totalAmount",
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const CheckoutPage(),
                            ),
                          );
                        },
                        child: const Text(
                          "Proceed to Checkout",
                          style: TextStyle(fontSize: 16),
                        ),
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

  // 🧾 CART ITEM CARD (SAME UI, FIREBASE)
  Widget _cartItemCard(String docId, Map<String, dynamic> item) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue.shade100,
          child: const Icon(Icons.shopping_bag, color: Colors.blue),
        ),
        title: Text(
          item['productName'],
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          "₹${item['price']} x ${item['qty']} = ₹${item['price'] * item['qty']}",
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ➖
            IconButton(
              icon: const Icon(Icons.remove),
              onPressed: item['qty'] > 1
                  ? () => _updateQty(docId, item, item['qty'] - 1)
                  : null,
            ),

            Text("${item['qty']}"),

            // ➕
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => _updateQty(docId, item, item['qty'] + 1),
            ),

            // 🗑 DELETE
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _deleteItem(docId),
            ),
          ],
        ),
      ),
    );
  }

  // 🔁 UPDATE QTY
  Future<void> _updateQty(
    String docId,
    Map<String, dynamic> item,
    int newQty,
  ) async {
    await FirebaseFirestore.instance.collection('cart').doc(docId).update({
      'qty': newQty,
      'totalPrice': newQty * item['price'],
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // 🗑 DELETE ITEM
  Future<void> _deleteItem(String docId) async {
    await FirebaseFirestore.instance.collection('cart').doc(docId).delete();
  }
}
