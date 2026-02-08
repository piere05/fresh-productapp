import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'order_details_page.dart';

class OrdersPage extends StatelessWidget {
  const OrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    final farmerEmail = FirebaseAuth.instance.currentUser!.email;

    return Scaffold(
      backgroundColor: const Color(0xFFF3E5F5),
      appBar: AppBar(
        title: const Text("Orders"),
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              decoration: InputDecoration(
                hintText: "Search orders...",
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

          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('orders')
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final orders = snapshot.data!.docs.where((doc) {
                  final products = (doc['products'] as List);
                  return products.any((p) => p['addedBy'] == farmerEmail);
                }).toList();

                if (orders.isEmpty) {
                  return const Center(child: Text("No Orders Found"));
                }

                return ListView(
                  children: orders.map((doc) {
                    final data = doc.data() as Map<String, dynamic>;

                    return _orderTile(
                      context,
                      orderId: doc.id,
                      customer: data['orderBy'],
                      amount: "₹${data['grandTotal']}",
                      status: data['status'],
                      orderData: data,
                    );
                  }).toList(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _orderTile(
    BuildContext context, {
    required String orderId,
    required String customer,
    required String amount,
    required String status,
    required Map<String, dynamic> orderData,
  }) {
    Color statusColor;
    switch (status) {
      case "approved":
        statusColor = Colors.green;
        break;
      case "delivered":
        statusColor = Colors.blue;
        break;
      default:
        statusColor = Colors.orange;
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.deepPurple.shade100,
          child: const Icon(Icons.receipt_long, color: Colors.deepPurple),
        ),
        title: Text(
          orderId,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text("Customer: $customer\nAmount: $amount"),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              status,
              style: TextStyle(color: statusColor, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            const Icon(Icons.arrow_forward_ios, size: 14),
          ],
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  OrderDetailsPage(orderId: orderId, orderData: orderData),
            ),
          );
        },
      ),
    );
  }
}
