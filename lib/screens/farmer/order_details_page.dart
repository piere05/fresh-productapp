// ignore_for_file: unnecessary_to_list_in_spreads, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class OrderDetailsPage extends StatelessWidget {
  final String orderId;
  final Map<String, dynamic> orderData;

  const OrderDetailsPage({
    super.key,
    required this.orderId,
    required this.orderData,
  });

  @override
  Widget build(BuildContext context) {
    final status = orderData['status'];

    return Scaffold(
      backgroundColor: const Color(0xFFF3E5F5),
      appBar: AppBar(
        title: const Text("Order Details"),
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 🧾 ORDER SUMMARY
            _sectionCard(
              title: "Order Summary",
              child: Column(
                children: [
                  _InfoRow("Order ID", orderId),
                  _InfoRow("Status", status),
                  _InfoRow("Payment", orderData['paymentMethod']),
                ],
              ),
            ),

            const SizedBox(height: 15),

            // 👤 CUSTOMER DETAILS
            _sectionCard(
              title: "Customer Details",
              child: Column(
                children: [_InfoRow("Email", orderData['orderBy'])],
              ),
            ),

            const SizedBox(height: 15),

            // 📦 PRODUCT DETAILS
            _sectionCard(
              title: "Products",
              child: Column(
                children: [
                  ...(orderData['products'] as List).map((p) {
                    return _ProductRow(
                      p['productName'],
                      "${p['qty']}",
                      "₹${p['total']}",
                    );
                  }).toList(),
                  const Divider(),
                  _InfoRow("Total Amount", "₹${orderData['grandTotal']}"),
                ],
              ),
            ),

            const SizedBox(height: 25),

            // ✅ ACTION BUTTONS
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: status == "delivered"
                        ? null
                        : () => _updateStatus(context, "approved"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text("Approve"),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: status == "delivered"
                        ? null
                        : () => _updateStatus(context, "cancelled"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text("Reject"),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // 🚚 MARK AS DELIVERED
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: status == "delivered"
                    ? null
                    : () => _updateStatus(context, "delivered"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text("Mark as Delivered"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 🔲 SECTION CARD (UNCHANGED UI)
  Widget _sectionCard({required String title, required Widget child}) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            child,
          ],
        ),
      ),
    );
  }

  // 🔥 UPDATE STATUS + ADD NOTIFICATION
  Future<void> _updateStatus(BuildContext context, String newStatus) async {
    final orderRef = FirebaseFirestore.instance
        .collection('orders')
        .doc(orderId);

    final notificationRef = FirebaseFirestore.instance
        .collection('notifications')
        .doc();

    await FirebaseFirestore.instance.runTransaction((tx) async {
      tx.update(orderRef, {'status': newStatus});

      tx.set(notificationRef, {
        'userEmail': orderData['orderBy'],
        'orderId': orderId,
        'title': "Order Status Updated",
        'message': "Your order status changed to $newStatus",
        'createdAt': FieldValue.serverTimestamp(),
        'seen': false,
      });
    });

    Navigator.pop(context);
  }
}

// 🔹 INFO ROW (FIXED – SAME FILE)
class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              "$label:",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}

// 🔹 PRODUCT ROW (UNCHANGED UI)
class _ProductRow extends StatelessWidget {
  final String name;
  final String qty;
  final String price;

  const _ProductRow(this.name, this.qty, this.price);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [Text(name), Text(qty), Text(price)],
      ),
    );
  }
}
