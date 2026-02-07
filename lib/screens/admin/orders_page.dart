// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'order_details_page.dart';

class OrdersPage extends StatelessWidget {
  const OrdersPage({super.key}); // NOT const

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Orders"),
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
      ),
      body: Column(
        children: [
          // 🔍 SEARCH BAR
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

          // 🏷 STATUS FILTER (UI ONLY)
          SizedBox(
            height: 45,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: const [
                _StatusChip("All", Colors.grey),
                _StatusChip("Pending", Colors.orange),
                _StatusChip("Approved", Colors.green),
                _StatusChip("Delivered", Colors.blue),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // 📋 ORDERS LIST
          Expanded(
            child: ListView(
              children: [
                _orderCard(
                  context,
                  orderId: "#ORD1001",
                  customer: "Ravi Kumar",
                  amount: "₹120",
                  status: "Pending",
                ),
                _orderCard(
                  context,
                  orderId: "#ORD1002",
                  customer: "Suresh",
                  amount: "₹340",
                  status: "Approved",
                ),
                _orderCard(
                  context,
                  orderId: "#ORD1003",
                  customer: "Anitha",
                  amount: "₹220",
                  status: "Delivered",
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ORDER CARD
  Widget _orderCard(
    BuildContext context, {
    required String orderId,
    required String customer,
    required String amount,
    required String status,
  }) {
    Color statusColor;
    switch (status) {
      case "Approved":
        statusColor = Colors.green;
        break;
      case "Delivered":
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
            MaterialPageRoute(builder: (_) => OrderDetailsPage()),
          );
        },
      ),
    );
  }
}

// STATUS CHIP (UI ONLY)
class _StatusChip extends StatelessWidget {
  final String label;
  final Color color;

  const _StatusChip(this.label, this.color);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Chip(
        label: Text(label),
        backgroundColor: color.withOpacity(0.15),
        labelStyle: TextStyle(color: color),
      ),
    );
  }
}
