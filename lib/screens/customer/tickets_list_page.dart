// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TicketsListPage extends StatelessWidget {
  TicketsListPage({super.key});

  final user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text("My Support Tickets"),
        backgroundColor: Colors.orange,
        centerTitle: true,
      ),
      body: user == null
          ? const Center(child: Text("Please login"))
          : StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('tickets')
                  .where('userEmail', isEqualTo: user!.email)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final tickets = snapshot.data!.docs;

                if (tickets.isEmpty) {
                  return const Center(child: Text("No tickets found"));
                }

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

  // ===================== TICKET CARD =====================
  Widget _ticketCard(BuildContext context, Map<String, dynamic> t) {
    Color statusColor;
    switch (t['status']) {
      case 'closed':
        statusColor = Colors.green;
        break;
      case 'pending':
        statusColor = Colors.orange;
        break;
      default:
        statusColor = Colors.blue;
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
        subtitle: Text("Order ID: ${t['orderId']}\nStatus: ${t['status']}"),
        isThreeLine: true,
        trailing: TextButton(
          child: const Text("View"),
          onPressed: () => _openTicketModal(context, t),
        ),
      ),
    );
  }

  // ===================== MODAL VIEW =====================
  void _openTicketModal(BuildContext context, Map<String, dynamic> t) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 30),
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

                _row("Order ID", t['orderId']),
                const SizedBox(height: 12),

                _section("Subject", t['subject']),
                _section("Description", t['description']),

                _section(
                  "Reply",
                  t['reply'] == null || t['reply'].toString().isEmpty
                      ? "No reply yet"
                      : t['reply'],
                ),

                const SizedBox(height: 15),

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

  Widget _row(String l, String r) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(l, style: const TextStyle(fontWeight: FontWeight.bold)),
        Text(r),
      ],
    );
  }

  Color _statusBg(String status) {
    switch (status) {
      case 'closed':
        return Colors.green.shade100;
      case 'pending':
        return Colors.orange.shade100;
      default:
        return Colors.blue.shade100;
    }
  }
}
