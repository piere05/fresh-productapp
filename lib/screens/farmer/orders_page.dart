import 'package:flutter/material.dart';
import 'order_details_page.dart';

class OrdersPage extends StatelessWidget {
  const OrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3E5F5),
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

          // 📋 ORDER LIST
          Expanded(
            child: ListView(
              children: [
                _orderTile(
                  context,
                  orderId: "#ORD101",
                  customer: "Ravi Kumar",
                  amount: "₹1,200",
                  status: "Pending",
                ),
                _orderTile(
                  context,
                  orderId: "#ORD102",
                  customer: "Suresh",
                  amount: "₹850",
                  status: "Approved",
                ),
                _orderTile(
                  context,
                  orderId: "#ORD103",
                  customer: "Anitha",
                  amount: "₹640",
                  status: "Delivered",
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 🧾 ORDER TILE
  Widget _orderTile(
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
