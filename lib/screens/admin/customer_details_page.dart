// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CustomerDetailsPage extends StatelessWidget {
  final String customerId; // uid

  const CustomerDetailsPage({super.key, required this.customerId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE3F2FD),
      appBar: AppBar(
        title: const Text("Customer Details"),
        backgroundColor: Colors.blue,
        centerTitle: true,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('customers')
            .doc(customerId)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.data!.exists) {
            return const Center(child: Text("Customer not found"));
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;
          final bool isBlocked = data['isBlocked'] ?? false;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // 👤 PROFILE CARD
                Card(
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        _profileImage(data['imageBase64']),
                        const SizedBox(height: 15),
                        Text(
                          data['name'] ?? "-",
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          data['email'] ?? "-",
                          style: const TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(height: 15),
                        _infoRow(Icons.phone, "Phone", data['phone'] ?? "-"),
                        _infoRow(
                          Icons.verified_user,
                          "Status",
                          isBlocked ? "Blocked" : "Active",
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // 📍 ADDRESS CARD (ANY ONE)
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Address",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 10),

                        StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection('customers')
                              .doc(customerId)
                              .collection('addresses')
                              .limit(1)
                              .snapshots(),
                          builder: (context, addrSnap) {
                            if (!addrSnap.hasData) {
                              return const Text("Loading address...");
                            }

                            if (addrSnap.data!.docs.isEmpty) {
                              return const Text("No address found");
                            }

                            final a =
                                addrSnap.data!.docs.first.data()
                                    as Map<String, dynamic>;

                            return Text(
                              "${a['address'] ?? ''}, "
                              "${a['city'] ?? ''} - "
                              "${a['pincode'] ?? ''}",
                              style: const TextStyle(fontSize: 14),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 25),

                // 🔒 BLOCK / UNBLOCK
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: Icon(isBlocked ? Icons.lock_open : Icons.block),
                    label: Text(isBlocked ? "Unblock" : "Block"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isBlocked ? Colors.green : Colors.orange,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () => _toggleBlock(isBlocked),
                  ),
                ),

                const SizedBox(height: 10),

                // 🗑 DELETE CUSTOMER
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.delete),
                    label: const Text("Delete Customer"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () => _confirmDelete(context),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ================= PROFILE IMAGE =================
  Widget _profileImage(String? base64) {
    if (base64 == null || base64.isEmpty) {
      return const CircleAvatar(
        radius: 45,
        backgroundColor: Colors.blue,
        child: Icon(Icons.person, size: 45, color: Colors.white),
      );
    }

    return CircleAvatar(
      radius: 45,
      backgroundImage: MemoryImage(base64Decode(base64)),
    );
  }

  // ================= BLOCK / UNBLOCK =================
  Future<void> _toggleBlock(bool isBlocked) async {
    await FirebaseFirestore.instance
        .collection('customers')
        .doc(customerId)
        .update({
          'isBlocked': !isBlocked,
          'updatedAt': FieldValue.serverTimestamp(),
        });
  }

  // ================= DELETE CUSTOMER DOC =================
  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete Customer"),
        content: const Text(
          "This will permanently delete the customer record. Continue?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);

              await FirebaseFirestore.instance
                  .collection('customers')
                  .doc(customerId)
                  .delete();

              Navigator.pop(context);
            },
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }

  // ================= INFO ROW =================
  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.blue),
          const SizedBox(width: 10),
          Text("$label: ", style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
