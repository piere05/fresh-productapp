// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SupportPage extends StatelessWidget {
  const SupportPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        title: const Text("Support & Help"),
        backgroundColor: Colors.teal,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: "Create Ticket",
            onPressed: () => _createTicketDialog(context),
          ),
        ],
      ),

      body: user == null
          ? const Center(child: Text("Please login"))
          : StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('tickets')
                  .where('userEmail', isEqualTo: user.email)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final tickets = snapshot.data!.docs;

                if (tickets.isEmpty) {
                  return const Center(
                    child: Text(
                      "No support tickets yet",
                      style: TextStyle(color: Colors.grey),
                    ),
                  );
                }

                // 🔽 SORT IN DART (LATEST FIRST)
                tickets.sort((a, b) {
                  final aTime =
                      (a['createdAt'] as Timestamp?) ?? Timestamp.now();
                  final bTime =
                      (b['createdAt'] as Timestamp?) ?? Timestamp.now();
                  return bTime.toDate().compareTo(aTime.toDate());
                });

                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: tickets.length,
                  itemBuilder: (context, index) {
                    final doc = tickets[index];
                    final data = doc.data() as Map<String, dynamic>;
                    return _ticketCard(context, data);
                  },
                );
              },
            ),
    );
  }

  // ===================== CREATE TICKET =====================
  void _createTicketDialog(BuildContext context) {
    final subjectController = TextEditingController();
    final descController = TextEditingController();
    final user = FirebaseAuth.instance.currentUser;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Create Support Ticket"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: subjectController,
                decoration: const InputDecoration(
                  labelText: "Subject",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descController,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: "Description",
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              if (subjectController.text.trim().isEmpty ||
                  descController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("All fields are required")),
                );
                return;
              }

              await FirebaseFirestore.instance.collection('tickets').add({
                'subject': subjectController.text.trim(),
                'description': descController.text.trim(),
                'status': 'Pending',
                'reply': '',
                'createdAt': Timestamp.now(),

                // routing
                'raisedBy': 'farmer',
                'sentTo': 'admin',

                // user
                'userEmail': user?.email,
                'userId': user?.uid,
              });

              Navigator.pop(context);

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Ticket submitted successfully")),
              );
            },
            child: const Text("Submit"),
          ),
        ],
      ),
    );
  }

  // ===================== TICKET CARD =====================
  Widget _ticketCard(BuildContext context, Map<String, dynamic> t) {
    Color statusColor;
    switch (t['status']) {
      case 'Resolved':
        statusColor = Colors.green;
        break;
      case 'Not Resolved':
        statusColor = Colors.red;
        break;
      default:
        statusColor = Colors.orange;
    }

    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: statusColor.withOpacity(0.15),
          child: Icon(Icons.support_agent, color: statusColor),
        ),
        title: Text(
          t['subject'],
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text("Status: ${t['status']}"),
        trailing: const Icon(Icons.arrow_forward_ios, size: 14),
        onTap: () => _openTicketModal(context, t),
      ),
    );
  }

  // ===================== VIEW MODAL =====================
  void _openTicketModal(BuildContext context, Map<String, dynamic> t) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
            16,
            20,
            16,
            MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 50,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade400,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                _section("Subject", t['subject']),
                _section("Description", t['description']),

                _section(
                  "Reply",
                  t['reply'] == null || t['reply'].toString().isEmpty
                      ? "No reply yet"
                      : t['reply'],
                ),

                const SizedBox(height: 12),

                Row(
                  children: [
                    const Text(
                      "Status:",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 10),
                    Chip(
                      label: Text(t['status'].toString().toUpperCase()),
                      backgroundColor: _statusBg(t['status']),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ===================== HELPERS =====================
  Widget _section(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          const SizedBox(height: 6),
          Text(value, style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }

  Color _statusBg(String status) {
    switch (status) {
      case 'Resolved':
        return Colors.green.shade100;
      case 'Not Resolved':
        return Colors.red.shade100;
      default:
        return Colors.orange.shade100;
    }
  }
}
