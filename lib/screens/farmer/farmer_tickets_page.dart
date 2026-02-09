// ignore_for_file: deprecated_member_use, use_build_context_synchronously, unused_local_variable

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FarmerTicketsPage extends StatelessWidget {
  FarmerTicketsPage({super.key});

  final farmerEmail = FirebaseAuth.instance.currentUser!.email;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text("Customer Support Tickets"),
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('tickets')
            .where('addedBy', isEqualTo: farmerEmail)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final tickets = snapshot.data!.docs;

          if (tickets.isEmpty) {
            return const Center(child: Text("No tickets found"));
          }

          // 🔽 SORT IN DART (LATEST FIRST)
          tickets.sort((a, b) {
            final aTime = (a['createdAt'] as Timestamp?) ?? Timestamp.now();
            final bTime = (b['createdAt'] as Timestamp?) ?? Timestamp.now();
            return bTime.toDate().compareTo(aTime.toDate());
          });

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: tickets.length,
            itemBuilder: (context, index) {
              final doc = tickets[index];
              final data = doc.data() as Map<String, dynamic>;
              return _ticketCard(context, doc.id, data);
            },
          );
        },
      ),
    );
  }

  // ===================== TICKET CARD =====================
  Widget _ticketCard(
    BuildContext context,
    String ticketId,
    Map<String, dynamic> t,
  ) {
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
        subtitle: Text("Order ID: ${t['orderId']}\nStatus: ${t['status']}"),
        isThreeLine: true,
        trailing: TextButton(
          child: const Text("View"),
          onPressed: () => _openTicketModal(context, ticketId, t),
        ),
      ),
    );
  }

  // ===================== MODAL =====================
  void _openTicketModal(
    BuildContext context,
    String ticketId,
    Map<String, dynamic> t,
  ) {
    String selectedStatus = t['status'] ?? "Pending";
    final replyController = TextEditingController(text: t['reply'] ?? "");

    final bool isResolved = selectedStatus == "Resolved";

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
          child: StatefulBuilder(
            builder: (context, setModalState) {
              return SingleChildScrollView(
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

                    const SizedBox(height: 10),

                    const Text(
                      "Status",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String>(
                      value: selectedStatus,
                      items: const [
                        DropdownMenuItem(
                          value: "Pending",
                          child: Text("Pending"),
                        ),
                        DropdownMenuItem(
                          value: "Resolved",
                          child: Text("Resolved"),
                        ),
                        DropdownMenuItem(
                          value: "Not Resolved",
                          child: Text("Not Resolved"),
                        ),
                      ],
                      onChanged: (v) {
                        setModalState(() {
                          selectedStatus = v!;
                        });
                      },
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                      ),
                    ),

                    const SizedBox(height: 14),

                    const Text(
                      "Reply",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: replyController,
                      maxLines: 4,
                      enabled: selectedStatus != "Resolved",
                      decoration: InputDecoration(
                        hintText: selectedStatus == "Resolved"
                            ? "Ticket resolved. Reply disabled."
                            : "Type your reply...",
                        border: const OutlineInputBorder(),
                      ),
                    ),

                    const SizedBox(height: 20),

                    SizedBox(
                      width: double.infinity,
                      height: 45,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple,
                        ),
                        onPressed: () async {
                          await FirebaseFirestore.instance
                              .collection('tickets')
                              .doc(ticketId)
                              .update({
                                'status': selectedStatus,
                                'reply': replyController.text.trim(),
                                'repliedAt': Timestamp.now(),
                              });

                          Navigator.pop(context);
                        },
                        child: const Text(
                          "Update Ticket",
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
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
}
