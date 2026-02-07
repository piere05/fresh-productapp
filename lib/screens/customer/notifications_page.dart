// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

class NotificationsPage extends StatelessWidget {
  NotificationsPage({super.key});

  final List<Map<String, String>> notifications = [
    {
      "title": "Order Confirmed",
      "message": "Your order #ORD101 has been confirmed",
      "time": "Just now",
      "type": "success",
    },
    {
      "title": "Order Shipped",
      "message": "Order #ORD102 is on the way",
      "time": "2 hours ago",
      "type": "info",
    },
    {
      "title": "Order Delivered",
      "message": "Order #ORD100 has been delivered successfully",
      "time": "Yesterday",
      "type": "success",
    },
    {
      "title": "Order Cancelled",
      "message": "Order #ORD099 was cancelled",
      "time": "2 days ago",
      "type": "error",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text("Notifications"),
        backgroundColor: Colors.blue,
        centerTitle: true,
      ),
      body: notifications.isEmpty
          ? const Center(
              child: Text("No notifications", style: TextStyle(fontSize: 16)),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final notification = notifications[index];
                return _notificationCard(notification);
              },
            ),
    );
  }

  // 🔔 NOTIFICATION CARD
  Widget _notificationCard(Map<String, String> notification) {
    Color iconColor;
    IconData icon;

    switch (notification["type"]) {
      case "success":
        iconColor = Colors.green;
        icon = Icons.check_circle;
        break;
      case "error":
        iconColor = Colors.red;
        icon = Icons.cancel;
        break;
      default:
        iconColor = Colors.blue;
        icon = Icons.info;
    }

    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: iconColor.withOpacity(0.15),
          child: Icon(icon, color: iconColor),
        ),
        title: Text(
          notification["title"]!,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(notification["message"]!),
        trailing: Text(
          notification["time"]!,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
        onTap: () {},
      ),
    );
  }
}
