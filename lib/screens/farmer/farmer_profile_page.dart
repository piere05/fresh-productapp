// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:project/screens/role_selection/role_selection_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FarmerProfilePage extends StatefulWidget {
  const FarmerProfilePage({super.key});

  @override
  State<FarmerProfilePage> createState() => _FarmerProfilePageState();
}

class _FarmerProfilePageState extends State<FarmerProfilePage> {
  final user = FirebaseAuth.instance.currentUser!;
  final uid = FirebaseAuth.instance.currentUser!.uid;

  // 🚪 Logout
  void _confirmLogout() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Logout"),
        content: const Text("Are you sure you want to logout?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context); // close dialog

              // 🔥 Firebase sign out
              await FirebaseAuth.instance.signOut();

              // 🧹 Clear SharedPreferences
              final prefs = await SharedPreferences.getInstance();
              await prefs.clear();

              // 🔁 Go to role selection (clear stack)
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const RoleSelectionPage()),
                (_) => false,
              );
            },
            child: const Text("Logout"),
          ),
        ],
      ),
    );
  }

  // ✏️ Edit Profile (ONLY name & phone)
  void _editProfile(Map<String, dynamic> data) {
    final nameCtrl = TextEditingController(text: data['name']);
    final phoneCtrl = TextEditingController(text: data['phone']);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: EdgeInsets.fromLTRB(
          16,
          20,
          16,
          MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _field("Name", nameCtrl),
            _field("Phone", phoneCtrl),
            const SizedBox(height: 15),
            SizedBox(
              width: double.infinity,
              height: 45,
              child: ElevatedButton(
                onPressed: () async {
                  await FirebaseFirestore.instance
                      .collection('farmers')
                      .doc(uid)
                      .update({
                        'name': nameCtrl.text.trim(),
                        'phone': phoneCtrl.text.trim(),
                      });
                  Navigator.pop(context);
                },
                child: const Text("Update Profile"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 🔐 Change Password (OLD + NEW + CONFIRM)
  void _changePassword() {
    final oldCtrl = TextEditingController();
    final newCtrl = TextEditingController();
    final confirmCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: EdgeInsets.fromLTRB(
          16,
          20,
          16,
          MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _passwordField("Old Password", oldCtrl),
            _passwordField("New Password", newCtrl),
            _passwordField("Confirm Password", confirmCtrl),
            const SizedBox(height: 15),
            SizedBox(
              width: double.infinity,
              height: 45,
              child: ElevatedButton(
                onPressed: () async {
                  if (newCtrl.text.length < 8) {
                    _toast("Password must be at least 8 characters");
                    return;
                  }
                  if (newCtrl.text != confirmCtrl.text) {
                    _toast("Passwords do not match");
                    return;
                  }

                  try {
                    final cred = EmailAuthProvider.credential(
                      email: user.email!,
                      password: oldCtrl.text,
                    );

                    await user.reauthenticateWithCredential(cred);
                    await user.updatePassword(newCtrl.text);

                    Navigator.pop(context);
                    _toast("Password updated successfully");
                  } catch (e) {
                    _toast("Old password is incorrect");
                  }
                },
                child: const Text("Change Password"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8F5E9),
      appBar: AppBar(
        title: const Text("My Profile"),
        backgroundColor: Colors.green,
        centerTitle: true,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('farmers')
            .doc(uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final raw = snapshot.data!.data() as Map<String, dynamic>;

          final name = raw['name'] ?? '';
          final phone = raw['phone'] ?? '';
          final email = raw['email'] ?? user.email ?? '';
          final isApproved = raw['isApproved'] ?? false;
          final isBlocked = raw['isBlocked'] ?? false;

          return ScrollConfiguration(
            behavior: const ScrollBehavior().copyWith(scrollbars: false),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          const CircleAvatar(
                            radius: 45,
                            backgroundColor: Colors.green,
                            child: Icon(
                              Icons.agriculture,
                              size: 45,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            name,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            email,
                            style: const TextStyle(color: Colors.grey),
                          ),
                          const SizedBox(height: 15),

                          _infoRow(Icons.phone, "Phone", phone),

                          const SizedBox(height: 10),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _statusChip(
                                isApproved ? "Approved" : "Pending",
                                isApproved ? Colors.green : Colors.orange,
                              ),
                              const SizedBox(width: 10),
                              if (isBlocked) _statusChip("Blocked", Colors.red),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 25),

                  _optionTile(
                    icon: Icons.edit,
                    title: "Edit Profile",
                    onTap: () => _editProfile({'name': name, 'phone': phone}),
                  ),
                  _optionTile(
                    icon: Icons.lock,
                    title: "Change Password",
                    onTap: _changePassword,
                  ),

                  const SizedBox(height: 30),

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.logout),
                      label: const Text("Logout"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      onPressed: _confirmLogout,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _field(String label, TextEditingController c) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: c,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  Widget _passwordField(String label, TextEditingController c) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: c,
        obscureText: true,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.green),
        const SizedBox(width: 10),
        Text("$label: ", style: const TextStyle(fontWeight: FontWeight.bold)),
        Expanded(child: Text(value)),
      ],
    );
  }

  Widget _optionTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, color: Colors.green),
        title: Text(title),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }

  Widget _statusChip(String text, Color color) {
    return Chip(
      label: Text(text, style: const TextStyle(color: Colors.white)),
      backgroundColor: color,
    );
  }

  void _toast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }
}
