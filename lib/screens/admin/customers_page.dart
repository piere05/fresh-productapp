import 'package:flutter/material.dart';
import 'customer_details_page.dart';

class CustomersPage extends StatelessWidget {
  const CustomersPage({super.key}); // ✅ const fixed

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE3F2FD),
      appBar: AppBar(
        title: const Text("Customers"),
        backgroundColor: Colors.blue,
        centerTitle: true,
      ),
      body: Column(
        children: [
          // 🔍 SEARCH BAR
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              decoration: InputDecoration(
                hintText: "Search customers...",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.grey.shade200,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // 📋 CUSTOMER LIST
          Expanded(
            child: ListView(
              children: [
                _customerTile(
                  context,
                  name: "Ravi Kumar",
                  email: "ravi@gmail.com",
                  status: "Active",
                ),
                _customerTile(
                  context,
                  name: "Suresh Kumar",
                  email: "suresh@gmail.com",
                  status: "Inactive",
                ),
                _customerTile(
                  context,
                  name: "Anitha",
                  email: "anitha@gmail.com",
                  status: "Active",
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 👤 CUSTOMER TILE
  Widget _customerTile(
    BuildContext context, {
    required String name,
    required String email,
    required String status,
  }) {
    final Color statusColor = status == "Active" ? Colors.green : Colors.red;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue.shade100,
          child: const Icon(Icons.person, color: Colors.blue),
        ),
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(email),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              status,
              style: TextStyle(color: statusColor, fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.arrow_forward_ios, size: 16),
          ],
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => CustomerDetailsPage()),
          );
        },
      ),
    );
  }
}
