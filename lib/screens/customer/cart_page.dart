// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'checkout_page.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  // 🛒 DEMO CART ITEMS (Frontend only)
  final List<Map<String, dynamic>> _cartItems = [
    {"name": "Tomatoes", "price": 40, "qty": 2},
    {"name": "Onions", "price": 30, "qty": 1},
  ];

  int get _totalAmount {
    return _cartItems.fold(
      0,
      (sum, item) => sum + (item["price"] * item["qty"]) as int,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE3F2FD),
      appBar: AppBar(
        title: const Text("My Cart"),
        backgroundColor: Colors.blue,
        centerTitle: true,
      ),
      body: _cartItems.isEmpty
          ? const Center(
              child: Text("Your cart is empty", style: TextStyle(fontSize: 16)),
            )
          : Column(
              children: [
                // 🛒 CART LIST
                Expanded(
                  child: ListView.builder(
                    itemCount: _cartItems.length,
                    itemBuilder: (context, index) {
                      final item = _cartItems[index];
                      return _cartItemCard(item, index);
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
                            "₹$_totalAmount",
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
                              MaterialPageRoute(builder: (_) => CheckoutPage()),
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
            ),
    );
  }

  // 🧾 CART ITEM CARD
  Widget _cartItemCard(Map<String, dynamic> item, int index) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue.shade100,
          child: const Icon(Icons.shopping_bag, color: Colors.blue),
        ),
        title: Text(
          item["name"],
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          "₹${item["price"]} x ${item["qty"]} = ₹${item["price"] * item["qty"]}",
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ➖
            IconButton(
              icon: const Icon(Icons.remove),
              onPressed: () {
                setState(() {
                  if (item["qty"] > 1) {
                    item["qty"]--;
                  }
                });
              },
            ),

            Text("${item["qty"]}"),

            // ➕
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                setState(() {
                  item["qty"]++;
                });
              },
            ),

            // 🗑 REMOVE
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () {
                setState(() {
                  _cartItems.removeAt(index);
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}
