// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'order_details_page.dart';

class MyOrdersPage extends StatelessWidget {
  MyOrdersPage({super.key});

  final List<Map<String, String>> orders = [
    {
      "id": "#ORD101",
      "date": "20 Aug 2026",
      "amount": "₹120",
      "status": "Pending",
      "payment": "Cash on Delivery",
    },
    {
      "id": "#ORD102",
      "date": "18 Aug 2026",
      "amount": "₹340",
      "status": "Delivered",
      "payment": "UPI",
    },
    {
      "id": "#ORD103",
      "date": "15 Aug 2026",
      "amount": "₹220",
      "status": "Cancelled",
      "payment": "Card",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text("My Orders"),
        backgroundColor: Colors.blue,
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: orders.length,
        itemBuilder: (context, index) {
          final order = orders[index];
          return _orderCard(context, order);
        },
      ),
    );
  }

  // 🧾 ORDER CARD
  Widget _orderCard(BuildContext context, Map<String, String> order) {
    Color statusColor;
    switch (order["status"]) {
      case "Delivered":
        statusColor = Colors.green;
        break;
      case "Cancelled":
        statusColor = Colors.red;
        break;
      default:
        statusColor = Colors.orange;
    }

    IconData paymentIcon;
    switch (order["payment"]) {
      case "UPI":
        paymentIcon = Icons.qr_code;
        break;
      case "Card":
        paymentIcon = Icons.credit_card;
        break;
      default:
        paymentIcon = Icons.money;
    }

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
          order["id"]!,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Date: ${order["date"]}"),
            Text("Amount: ${order["amount"]}"),
            Row(
              children: [
                Icon(paymentIcon, size: 16, color: Colors.grey),
                const SizedBox(width: 6),
                Text("Payment: ${order["payment"]}"),
              ],
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              order["status"]!,
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
