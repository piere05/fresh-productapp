// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'user_details_page.dart';

class UsersPage extends StatelessWidget {
  const UsersPage({super.key}); // NOT const

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text("Users Management"),
        backgroundColor: Colors.blueGrey,
        centerTitle: true,
      ),
      body: Column(
        children: [
          // 🔍 SEARCH BAR
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 6),
            child: TextField(
              decoration: InputDecoration(
                hintText: "Search users by name or email",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.grey.shade200,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // 🏷 FILTER CHIPS (UI ONLY)
          SizedBox(
            height: 42,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: const [
                _FilterChip("All"),
                _FilterChip("Admin"),
                _FilterChip("Farmer"),
                _FilterChip("Customer"),
                _FilterChip("Active"),
                _FilterChip("Blocked"),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // 👥 USERS LIST
          Expanded(
            child: ListView(
              children: [
                _userCard(
                  context,
                  name: "Ravi Kumar",
                  email: "ravi@gmail.com",
                  role: "Customer",
                  status: "Active",
                ),
                _userCard(
                  context,
                  name: "Ramesh",
                  email: "ramesh@farmer.com",
                  role: "Farmer",
                  status: "Pending",
                ),
                _userCard(
                  context,
                  name: "Admin User",
                  email: "admin@system.com",
                  role: "Admin",
                  status: "Active",
                ),
                _userCard(
                  context,
                  name: "Suresh",
                  email: "suresh@gmail.com",
                  role: "Customer",
                  status: "Blocked",
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 👤 USER CARD
  Widget _userCard(
    BuildContext context, {
    required String name,
    required String email,
    required String role,
    required String status,
  }) {
    final roleColor = _roleColor(role);
    final statusColor = _statusColor(status);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: roleColor.withOpacity(0.15),
          child: Icon(Icons.person, color: roleColor),
        ),
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(email),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            _badge(role, roleColor),
            const SizedBox(height: 4),
            _badge(status, statusColor, small: true),
          ],
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => UserDetailsPage()),
          );
        },
      ),
    );
  }

  // 🏷 BADGE
  Widget _badge(String text, Color color, {bool small = false}) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: small ? 8 : 10,
        vertical: small ? 2 : 4,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: small ? 11 : 12,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  // 🎨 ROLE COLOR
  Color _roleColor(String role) {
    switch (role) {
      case "Admin":
        return Colors.red;
      case "Farmer":
        return Colors.green;
      default:
        return Colors.blue;
    }
  }

  // 🎨 STATUS COLOR
  Color _statusColor(String status) {
    switch (status) {
      case "Active":
        return Colors.green;
      case "Pending":
        return Colors.orange;
      default:
        return Colors.red;
    }
  }
}

// 🏷 FILTER CHIP (UI ONLY)
class _FilterChip extends StatelessWidget {
  final String label;

  const _FilterChip(this.label);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Chip(
        label: Text(label),
        backgroundColor: Colors.blueGrey.withOpacity(0.15),
        labelStyle: const TextStyle(color: Colors.blueGrey),
      ),
    );
  }
}
