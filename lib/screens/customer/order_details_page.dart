// ignore_for_file: prefer_const_constructors_in_immutables

import 'package:flutter/material.dart';

class OrderDetailsPage extends StatelessWidget {
  OrderDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        title: const Text("Order Details"),
        backgroundColor: Colors.blue,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 📦 ORDER STATUS
            _sectionCard(
              title: "Order Status",
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text(
                    "Delivered",
                    style: TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Chip(
                    label: Text("Paid"),
                    backgroundColor: Color(0xFFDFF5E3),
                    labelStyle: TextStyle(color: Colors.green),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 15),

            // 🧾 ORDER INFO
            _sectionCard(
              title: "Order Information",
              child: Column(
                children: const [
                  _InfoRow("Order ID", "#ORD101"),
                  _InfoRow("Order Date", "15 Aug 2026"),
                  _InfoRow("Payment", "UPI"),
                ],
              ),
            ),

            const SizedBox(height: 15),

            // 🛒 PRODUCT DETAILS
            _sectionCard(
              title: "Products",
              child: Column(
                children: const [
                  _ProductRow("Tomatoes", "2 kg", "₹80"),
                  _ProductRow("Onions", "1 kg", "₹40"),
                  Divider(),
                  _InfoRow("Total Amount", "₹120"),
                ],
              ),
            ),

            const SizedBox(height: 15),

            // 🚚 DELIVERY ADDRESS
            _sectionCard(
              title: "Delivery Address",
              child: const Text(
                "Ravi Kumar\nChennai, Tamil Nadu\n+91 98765 43210",
                style: TextStyle(height: 1.5),
              ),
            ),

            const SizedBox(height: 25),

            // 🔄 ACTION BUTTONS
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.receipt),
                label: const Text("Download Invoice"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  _showSnack(context, "Invoice download (Demo)");
                },
              ),
            ),

            const SizedBox(height: 10),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.support_agent),
                label: const Text("Need Help"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  _showSnack(context, "Support page (Demo)");
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 📌 SECTION CARD
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

  // 🔔 SNACKBAR
  void _showSnack(BuildContext context, String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}

// 🧾 INFO ROW
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

// 🛒 PRODUCT ROW
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
