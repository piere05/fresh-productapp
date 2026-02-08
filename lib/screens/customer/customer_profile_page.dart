// ignore_for_file: use_build_context_synchronously

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'edit_profile_page.dart';

class CustomerProfilePage extends StatelessWidget {
  const CustomerProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text("My Profile"),
        backgroundColor: Colors.blue,
        centerTitle: true,
      ),
      body: user == null
          ? const Center(child: Text("Please login"))
          : StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('customers')
                  .doc(user.uid)
                  .snapshots(),
              builder: (context, snap) {
                if (!snap.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final data = snap.data!.data() as Map<String, dynamic>? ?? {};

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // ================= PROFILE CARD =================
                      Card(
                        elevation: 5,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            children: [
                              CircleAvatar(
                                radius: 45,
                                backgroundColor: Colors.blue,
                                backgroundImage: data['imageBase64'] != null
                                    ? MemoryImage(
                                        base64Decode(data['imageBase64']),
                                      )
                                    : null,
                                child: data['imageBase64'] == null
                                    ? const Icon(
                                        Icons.person,
                                        size: 45,
                                        color: Colors.white,
                                      )
                                    : null,
                              ),
                              const SizedBox(height: 15),
                              Text(
                                data['name'] ?? 'Customer',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                user.email ?? '',
                                style: const TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 25),

                      // ================= INFO =================
                      _infoTile(
                        Icons.phone,
                        "Phone",
                        data['phone'] ?? 'Not set',
                      ),

                      _addressTile(user.uid),

                      _infoTile(Icons.verified_user, "Status", "Active"),

                      const SizedBox(height: 25),

                      // ================= EDIT PROFILE =================
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.edit),
                          label: const Text("Edit Profile"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const EditProfilePage(),
                              ),
                            );
                          },
                        ),
                      ),

                      const SizedBox(height: 12),

                      // ================= CHANGE PASSWORD =================
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.lock),
                          label: const Text("Change Password"),
                          onPressed: () => _changePassword(context),
                        ),
                      ),

                      const SizedBox(height: 12),

                      // ================= LOGOUT =================
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.logout),
                          label: const Text("Logout"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          onPressed: () => _logout(context),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }

  // ================= ADDRESS (SUB COLLECTION) =================
  Widget _addressTile(String uid) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('customers')
          .doc(uid)
          .collection('addresses')
          .limit(1)
          .snapshots(),
      builder: (context, snap) {
        if (!snap.hasData || snap.data!.docs.isEmpty) {
          return _infoTile(Icons.location_on, "Address", "Not added");
        }

        final d = snap.data!.docs.first.data() as Map<String, dynamic>;

        return _infoTile(
          Icons.location_on,
          "Address",
          "${d['address']}, ${d['city']} - ${d['pincode']}",
        );
      },
    );
  }

  // ================= INFO TILE =================
  Widget _infoTile(IconData icon, String label, String value) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        leading: Icon(icon, color: Colors.blue),
        title: Text(label),
        subtitle: Text(value),
      ),
    );
  }

  // ================= CHANGE PASSWORD =================
  void _changePassword(BuildContext context) {
    final oldPass = TextEditingController();
    final newPass = TextEditingController();
    final confirmPass = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Change Password"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: oldPass,
              obscureText: true,
              decoration: const InputDecoration(labelText: "Old Password"),
            ),
            TextField(
              controller: newPass,
              obscureText: true,
              decoration: const InputDecoration(labelText: "New Password"),
            ),
            TextField(
              controller: confirmPass,
              obscureText: true,
              decoration: const InputDecoration(labelText: "Confirm Password"),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              if (newPass.text.length < 8 || newPass.text != confirmPass.text) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Password invalid")),
                );
                return;
              }

              final user = FirebaseAuth.instance.currentUser!;
              final cred = EmailAuthProvider.credential(
                email: user.email!,
                password: oldPass.text,
              );

              await user.reauthenticateWithCredential(cred);
              await user.updatePassword(newPass.text);

              Navigator.pop(context);
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text("Password updated")));
            },
            child: const Text("Update"),
          ),
        ],
      ),
    );
  }

  // ================= LOGOUT =================
  void _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.pop(context);
  }
}
