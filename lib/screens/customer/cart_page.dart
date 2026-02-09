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
        centerTitle: true,
        backgroundColor: Colors.blue,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('cart')
            .where('userEmail', isEqualTo: user!.email)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text(snapshot.error.toString()));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("Your cart is empty"));
          }

          final docs = snapshot.data!.docs;

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final cartDoc = docs[index];
                    final cartItem = cartDoc.data() as Map<String, dynamic>;

                    return _cartItemWithProductStock(cartDoc.id, cartItem);
                  },
                ),
              ),

              _totalSection(docs),
            ],
          );
        },
      ),
    );
  }

  // 🔁 CART ITEM WITH PRODUCT STOCK
  Widget _cartItemWithProductStock(
    String cartDocId,
    Map<String, dynamic> cartItem,
  ) {
    final productId = cartItem['productId'];
    final price = (cartItem['price'] as num?)?.toInt() ?? 0;
    final qty = (cartItem['qty'] as num?)?.toInt() ?? 0;

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('products')
          .doc(productId)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox();
        }

        final product = snapshot.data!.data() as Map<String, dynamic>?;

        final stock = (product?['currentStock'] as num?)?.toInt() ?? 0;
        final bool canIncrease = qty < stock;

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            leading: const Icon(Icons.shopping_bag, color: Colors.blue),
            title: Text(
              cartItem['productName'] ?? "Unknown",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("₹$price x $qty = ₹${price * qty}"),
                Text(
                  "Stock: $stock",
                  style: TextStyle(
                    color: stock == 0 ? Colors.red : Colors.grey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ➖
                IconButton(
                  icon: const Icon(Icons.remove),
                  onPressed: qty > 1
                      ? () => _updateQty(cartDocId, price, qty - 1)
                      : () => _deleteItem(cartDocId),
                ),

                Text("$qty"),

                // ➕ BLOCK IF EXCEEDS STOCK
                IconButton(
                  icon: const Icon(Icons.add),
                  color: canIncrease ? Colors.black : Colors.grey,
                  onPressed: canIncrease
                      ? () => _updateQty(cartDocId, price, qty + 1)
                      : () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Stock limit reached"),
                            ),
                          );
                        },
                ),

                // 🗑 DELETE
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _deleteItem(cartDocId),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // 💰 TOTAL SECTION
  Widget _totalSection(List<QueryDocumentSnapshot> docs) {
    final totalAmount = docs.fold<int>(0, (sum, d) {
      final data = d.data() as Map<String, dynamic>;
      final price = (data['price'] as num?)?.toInt() ?? 0;
      final qty = (data['qty'] as num?)?.toInt() ?? 0;
      return sum + (price * qty);
    });

    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Total Amount",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
              onPressed: totalAmount == 0
                  ? null
                  : () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const CheckoutPage()),
                      );
                    },
              child: const Text("Proceed to Checkout"),
            ),
          ),
        ],
      ),
    );
  }

  // 🔁 UPDATE QTY
  Future<void> _updateQty(String docId, int price, int qty) async {
    await FirebaseFirestore.instance.collection('cart').doc(docId).update({
      'qty': qty,
      'totalPrice': qty * price,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // 🗑 DELETE
  Future<void> _deleteItem(String docId) async {
    await FirebaseFirestore.instance.collection('cart').doc(docId).delete();
  }
}
