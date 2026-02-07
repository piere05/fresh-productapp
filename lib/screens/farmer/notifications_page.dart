// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        title: const Text("Notifications"),
        centerTitle: true,
        backgroundColor: Colors.indigo,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            tooltip: "Clear all",
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("All notifications cleared (Demo)"),
                ),
              );
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: const [
          _NotificationTile(
            icon: Icons.shopping_cart,
            title: "New Order Received",
            message: "Order #ORD101 has been placed",
            time: "Just now",
            color: Colors.green,
          ),
          _NotificationTile(
            icon: Icons.check_circle,
            title: "Order Approved",
            message: "Order #ORD095 approved successfully",
            time: "10 mins ago",
            color: Colors.blue,
          ),
          _NotificationTile(
            icon: Icons.delivery_dining,
            title: "Order Delivered",
            message: "Order #ORD078 delivered",
            time: "1 hour ago",
            color: Colors.orange,
          ),
          _NotificationTile(
            icon: Icons.warning,
            title: "Low Stock Alert",
            message: "Tomatoes stock is running low",
            time: "Yesterday",
            color: Colors.red,
          ),
        ],
      ),
    );
  }
}

// 🔔 NOTIFICATION TILE
class _NotificationTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String time;
  final Color color;

  const _NotificationTile({
    required this.icon,
    required this.title,
    required this.message,
    required this.time,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.15),
          child: Icon(icon, color: color),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(message),
        trailing: Text(
          time,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
        onTap: () {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text("$title clicked (Demo)")));
        },
      ),
    );
  }
}
