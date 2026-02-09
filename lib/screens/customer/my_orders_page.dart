// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'customer_dashboard_page.dart';
import 'order_details_page.dart';

class MyOrdersPage extends StatelessWidget {
  MyOrdersPage({super.key});

  final user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text("My Orders"),
        backgroundColor: Colors.blue,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CustomerDashboardPage()),
            );
          },
        ),
      ),
      body: user == null
          ? const Center(child: Text("Please login"))
          : StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('orders')
                  .where('orderBy', isEqualTo: user!.email)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final docs = snapshot.data!.docs;

                if (docs.isEmpty) {
                  return const Center(child: Text("No orders found"));
                }

                // 🔽 SORT IN DART (LATEST FIRST)
                docs.sort((a, b) {
                  final aData = a.data() as Map<String, dynamic>;
                  final bData = b.data() as Map<String, dynamic>;

                  final aTime =
                      (aData['createdAt'] as Timestamp?) ?? Timestamp.now();
                  final bTime =
                      (bData['createdAt'] as Timestamp?) ?? Timestamp.now();

                  return bTime.toDate().compareTo(aTime.toDate());
                });

                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final doc = docs[index];
                    final data = doc.data() as Map<String, dynamic>;
                    return _orderCard(context, data, doc.id);
                  },
                );
              },
            ),
    );
  }

  // 🧾 ORDER CARD (UI UNCHANGED)
  Widget _orderCard(
    BuildContext context,
    Map<String, dynamic> order,
    String orderId,
  ) {
    Color statusColor;
    switch (order['status']) {
      case "delivered":
        statusColor = Colors.green;
        break;
      case "cancelled":
        statusColor = Colors.red;
        break;
      default:
        statusColor = Colors.orange;
    }

    IconData paymentIcon;
    switch (order['paymentMethod']) {
      case "UPI":
        paymentIcon = Icons.qr_code;
        break;
      case "Card":
        paymentIcon = Icons.credit_card;
        break;
      default:
        paymentIcon = Icons.money;
    }

    final DateTime createdAt =
        (order['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now();

    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue.withOpacity(0.15),
          child: const Icon(Icons.receipt_long, color: Colors.blue),
        ),
        title: Text(
          "#${orderId.toUpperCase()}",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Date: ${createdAt.day}/${createdAt.month}/${createdAt.year}"),
            Text("Amount: ₹${order['grandTotal']}"),
            Row(
              children: [
                Icon(paymentIcon, size: 16, color: Colors.grey),
                const SizedBox(width: 6),
                Text("Payment: ${order['paymentMethod']}"),
              ],
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              order['status'].toString().toUpperCase(),
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
              builder: (_) => OrderDetailsPage(orderId: orderId),
            ),
          );
        },
      ),
    );
  }
}
