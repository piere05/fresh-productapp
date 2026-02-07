import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'farmer_details_page.dart';

class FarmersPage extends StatefulWidget {
  const FarmersPage({super.key});

  @override
  State<FarmersPage> createState() => _FarmersPageState();
}

class _FarmersPageState extends State<FarmersPage> {
  String _search = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8F5E9),
      appBar: AppBar(
        title: const Text("Farmers"),
        backgroundColor: Colors.green,
        centerTitle: true,
      ),
      body: Column(
        children: [
          // 🔍 SEARCH
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              onChanged: (v) => setState(() => _search = v),
              decoration: InputDecoration(
                hintText: "Search farmers...",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // 👨‍🌾 FARMERS LIST
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('farmers')
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text("No farmers found"));
                }

                final farmers = snapshot.data!.docs.where((doc) {
                  final name = doc['name'].toString().toLowerCase();
                  return name.contains(_search.toLowerCase());
                }).toList();

                if (farmers.isEmpty) {
                  return const Center(child: Text("No farmers found"));
                }

                return ListView.builder(
                  itemCount: farmers.length,
                  itemBuilder: (context, index) {
                    final doc = farmers[index];
                    final data = doc.data() as Map<String, dynamic>;

                    String status = "Pending";
                    if (data['isBlocked'] == true) {
                      status = "Blocked";
                    } else if (data['isApproved'] == true) {
                      status = "Approved";
                    }

                    return _farmerCard(
                      context,
                      uid: doc.id,
                      name: data['name'],
                      phone: data['phone'],
                      status: status,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _farmerCard(
    BuildContext context, {
    required String uid,
    required String name,
    required String phone,
    required String status,
  }) {
    Color statusColor = status == "Approved"
        ? Colors.green
        : status == "Blocked"
        ? Colors.red
        : Colors.orange;

    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.green.shade100,
          child: const Icon(Icons.agriculture, color: Colors.green),
        ),
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(phone),
        trailing: Chip(
          label: Text(status, style: const TextStyle(color: Colors.white)),
          backgroundColor: statusColor,
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => FarmerDetailsPage(farmerId: uid)),
          );
        },
      ),
    );
  }
}
