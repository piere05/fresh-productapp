// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'add_address_page.dart';

class DeliveryAddressPage extends StatelessWidget {
  const DeliveryAddressPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(body: Center(child: Text("Please login")));
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text("Delivery Address"),
        backgroundColor: Colors.indigo,
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('customers')
            .doc(user.uid)
            .collection('addresses')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // 📍 SAVED ADDRESSES
                Expanded(
                  child: docs.isEmpty
                      ? const Center(child: Text("No address found"))
                      : ListView.builder(
                          itemCount: docs.length,
                          itemBuilder: (context, index) {
                            final doc = docs[index];
                            final data = doc.data() as Map<String, dynamic>;

                            return _addressCard(
                              context: context,
                              title: data['name'],
                              address:
                                  "${data['address']}, ${data['city']} - ${data['pincode']}\n📞 ${data['phone']}",
                              isDefault: data['isDefault'] == true,
                              onEdit: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => AddAddressPage(
                                      addressId: doc.id,
                                      addressData: data,
                                    ),
                                  ),
                                );
                              },
                              onDelete: () async {
                                await FirebaseFirestore.instance
                                    .collection('customers')
                                    .doc(user.uid)
                                    .collection('addresses')
                                    .doc(doc.id)
                                    .delete();
                              },
                            );
                          },
                        ),
                ),

                const SizedBox(height: 10),

                // ➕ ADD ADDRESS BUTTON
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    icon: const Icon(
                      Icons.add_location_alt,
                      color: Colors.white,
                    ),
                    label: const Text(
                      "Add New Address",
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.indigo,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AddAddressPage(),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // 📦 ADDRESS CARD (SAME UI)
  Widget _addressCard({
    required BuildContext context,
    required String title,
    required String address,
    required bool isDefault,
    required VoidCallback onEdit,
    required VoidCallback onDelete,
  }) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        leading: Icon(
          Icons.location_on,
          color: isDefault ? Colors.green : Colors.indigo,
        ),
        title: Row(
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            if (isDefault) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  "Default",
                  style: TextStyle(color: Colors.green, fontSize: 12),
                ),
              ),
            ],
          ],
        ),
        subtitle: Text(address),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            if (value == "edit") {
              onEdit();
            } else if (value == "delete") {
              onDelete();
            }
          },
          itemBuilder: (_) => const [
            PopupMenuItem(value: "edit", child: Text("Edit")),
            PopupMenuItem(value: "delete", child: Text("Delete")),
          ],
        ),
      ),
    );
  }
}
