// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'order_details_page.dart';

class NotificationsPage extends StatelessWidget {
  NotificationsPage({super.key});

  final user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text("Notifications"),
        backgroundColor: Colors.blue,
        centerTitle: true,
      ),
      body: user == null
          ? const Center(child: Text("Please login"))
          : StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('notifications')
                  .where('userEmail', isEqualTo: user!.email)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final docs = snapshot.data!.docs;

                if (docs.isEmpty) {
                  return const Center(child: Text("No notifications"));
                }

                // ✅ SORT IN DART (NEWEST FIRST)
                docs.sort((a, b) {
                  final aTime =
                      (a['createdAt'] as Timestamp?)?.toDate() ??
                      DateTime(2000);
                  final bTime =
                      (b['createdAt'] as Timestamp?)?.toDate() ??
                      DateTime(2000);
                  return bTime.compareTo(aTime);
                });

                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index].data() as Map<String, dynamic>;
                    return _notificationCard(context, data);
                  },
                );
              },
            ),
    );
  }

  // ================= NOTIFICATION CARD =================
  Widget _notificationCard(
    BuildContext context,
    Map<String, dynamic> notification,
  ) {
    Color iconColor;
    IconData icon;

    switch (notification['type']) {
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

    final createdAt = notification['createdAt'] != null
        ? (notification['createdAt'] as Timestamp).toDate()
        : DateTime.now();

    final date =
        "${createdAt.day.toString().padLeft(2, '0')}/"
        "${createdAt.month.toString().padLeft(2, '0')}/"
        "${createdAt.year}";

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
          notification['title'] ?? '',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(notification['message'] ?? ''),
        trailing: Text(
          date,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  OrderDetailsPage(orderId: notification['orderId']),
            ),
          );
        },
      ),
    );
  }
}
