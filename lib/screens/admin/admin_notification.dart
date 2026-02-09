// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'orders_page.dart';
import 'support_page.dart';

class AdminNotificationsPage extends StatelessWidget {
  const AdminNotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        title: const Text("Admin Notifications"),
        centerTitle: true,
        backgroundColor: Colors.indigo,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('orders').snapshots(),
        builder: (context, orderSnapshot) {
          if (!orderSnapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('tickets')
                .where('sentTo', isEqualTo: 'admin') // 🔥 admin-only tickets
                .snapshots(),
            builder: (context, ticketSnapshot) {
              if (!ticketSnapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final List<_NotificationItem> items = [];

              // ================= ORDERS =================
              for (var doc in orderSnapshot.data!.docs) {
                final data = doc.data() as Map<String, dynamic>;

                items.add(
                  _NotificationItem(
                    icon: Icons.shopping_cart,
                    title: "New Order Received",
                    message: "Order #${data['orderId'] ?? doc.id}",
                    color: Colors.green,
                    createdAt: data['createdAt'],
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => OrdersPage()),
                      );
                    },
                  ),
                );
              }

              // ================= TICKETS =================
              for (var doc in ticketSnapshot.data!.docs) {
                final data = doc.data() as Map<String, dynamic>;

                items.add(
                  _NotificationItem(
                    icon: Icons.support_agent,
                    title: "New Support Ticket",
                    message: data['subject'] ?? "Support request",
                    color: Colors.orange,
                    createdAt: data['createdAt'],
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => AdminSupportPage()),
                      );
                    },
                  ),
                );
              }

              // ================= SORT (SAFE) =================
              items.sort((a, b) {
                final aTime = a.createdAt?.toDate();
                final bTime = b.createdAt?.toDate();
                if (aTime == null || bTime == null) return 0;
                return bTime.compareTo(aTime);
              });

              if (items.isEmpty) {
                return const Center(child: Text("No notifications"));
              }

              return ListView(
                padding: const EdgeInsets.all(12),
                children: items
                    .map(
                      (n) => _NotificationTile(
                        icon: n.icon,
                        title: n.title,
                        message: n.message,
                        time: _formatTime(n.createdAt),
                        color: n.color,
                        onTap: n.onTap,
                      ),
                    )
                    .toList(),
              );
            },
          );
        },
      ),
    );
  }

  String _formatTime(Timestamp? t) {
    if (t == null) return "-";
    final d = t.toDate();
    return "${d.day}/${d.month}/${d.year}";
  }
}

// ================= DATA HOLDER =================
class _NotificationItem {
  final IconData icon;
  final String title;
  final String message;
  final Color color;
  final Timestamp? createdAt;
  final VoidCallback onTap;

  _NotificationItem({
    required this.icon,
    required this.title,
    required this.message,
    required this.color,
    required this.createdAt,
    required this.onTap,
  });
}

// ================= UI TILE =================
class _NotificationTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String time;
  final Color color;
  final VoidCallback onTap;

  const _NotificationTile({
    required this.icon,
    required this.title,
    required this.message,
    required this.time,
    required this.color,
    required this.onTap,
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
        onTap: onTap,
      ),
    );
  }
}
