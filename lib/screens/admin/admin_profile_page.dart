// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../role_selection/role_selection_page.dart';

class AdminProfilePage extends StatelessWidget {
  const AdminProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFFFEBEE),
      appBar: AppBar(
        title: const Text("Admin Profile"),
        backgroundColor: Colors.redAccent,
        centerTitle: true,
      ),
      body: user == null
          ? const Center(child: Text("Please login"))
          : StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('admin')
                  .where('email', isEqualTo: user.email)
                  .limit(1)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text("Admin profile not found"));
                }

                final doc = snapshot.data!.docs.first;
                final data = doc.data() as Map<String, dynamic>;

                return Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      // 👤 PROFILE CARD
                      Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        elevation: 5,
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            children: [
                              const CircleAvatar(
                                radius: 45,
                                backgroundColor: Colors.redAccent,
                                child: Icon(
                                  Icons.admin_panel_settings,
                                  size: 45,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 15),
                              Text(
                                data['name'] ?? "Admin",
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                data['email'] ?? "",
                                style: const TextStyle(color: Colors.grey),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "📞 ${data['mobile'] ?? '-'}",
                                style: const TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 25),

                      // ✏️ EDIT PROFILE
                      _profileTile(
                        context,
                        Icons.edit,
                        "Edit Profile",
                        () => _editProfile(context, doc.reference, data),
                      ),

                      // 🔐 CHANGE PASSWORD
                      _profileTile(
                        context,
                        Icons.lock,
                        "Change Password",
                        () => _changePassword(context),
                      ),

                      const Spacer(),

                      // 🚪 LOGOUT
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.logout),
                          label: const Text("Logout"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          onPressed: () => _confirmLogout(context),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }

  // ================= EDIT PROFILE =================
  void _editProfile(
    BuildContext context,
    DocumentReference docRef,
    Map<String, dynamic> data,
  ) {
    final nameCtrl = TextEditingController(text: data['name']);
    final mobileCtrl = TextEditingController(text: data['mobile']);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Edit Profile"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(
                labelText: "Name",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: mobileCtrl,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: "Mobile",
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () async {
              await docRef.update({
                'name': nameCtrl.text.trim(),
                'mobile': mobileCtrl.text.trim(),
              });
              Navigator.pop(context);
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  // ================= CHANGE PASSWORD =================
  void _changePassword(BuildContext context) {
    final oldCtrl = TextEditingController();
    final newCtrl = TextEditingController();
    final confirmCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Change Password"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: oldCtrl,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: "Old Password",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: newCtrl,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: "New Password",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: confirmCtrl,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: "Confirm Password",
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () async {
              if (newCtrl.text != confirmCtrl.text || newCtrl.text.length < 8) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Password must be 8+ chars and match"),
                  ),
                );
                return;
              }

              final user = FirebaseAuth.instance.currentUser!;
              final cred = EmailAuthProvider.credential(
                email: user.email!,
                password: oldCtrl.text,
              );

              await user.reauthenticateWithCredential(cred);
              await user.updatePassword(newCtrl.text);

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
  void _confirmLogout(BuildContext context) {
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
              await FirebaseAuth.instance.signOut();
              Navigator.pop(context);
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

  // ================= TILE =================
  Widget _profileTile(
    BuildContext context,
    IconData icon,
    String title,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        leading: Icon(icon, color: Colors.redAccent),
        title: Text(title),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}
