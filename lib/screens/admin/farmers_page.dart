import 'package:flutter/material.dart';
import 'farmer_details_page.dart';

class FarmersPage extends StatefulWidget {
  const FarmersPage({super.key}); // NOT const

  @override
  State<FarmersPage> createState() => _FarmersPageState();
}

class _FarmersPageState extends State<FarmersPage> {
  String _search = "";

  // 🔹 DEMO FARMER DATA (Frontend only)
  final List<Map<String, String>> _farmers = [
    {"name": "Ramesh Kumar", "location": "Coimbatore", "status": "Pending"},
    {"name": "Suresh", "location": "Salem", "status": "Approved"},
    {"name": "Manoj", "location": "Madurai", "status": "Blocked"},
    {"name": "Karthik", "location": "Erode", "status": "Approved"},
  ];

  @override
  Widget build(BuildContext context) {
    // 🔍 SEARCH FILTER
    final filteredFarmers = _farmers.where((farmer) {
      return farmer["name"]!.toLowerCase().contains(_search.toLowerCase());
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFE8F5E9),
      appBar: AppBar(
        title: const Text("Farmers"),
        backgroundColor: Colors.green,
        centerTitle: true,
      ),
      body: Column(
        children: [
          // 🔍 SEARCH BAR
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  _search = value;
                });
              },
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
            child: filteredFarmers.isEmpty
                ? const Center(
                    child: Text(
                      "No farmers found",
                      style: TextStyle(fontSize: 16),
                    ),
                  )
                : ListView.builder(
                    itemCount: filteredFarmers.length,
                    itemBuilder: (context, index) {
                      final farmer = filteredFarmers[index];
                      return _farmerCard(
                        context,
                        name: farmer["name"]!,
                        location: farmer["location"]!,
                        status: farmer["status"]!,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  // 👨‍🌾 FARMER CARD
  Widget _farmerCard(
    BuildContext context, {
    required String name,
    required String location,
    required String status,
  }) {
    Color statusColor;
    switch (status) {
      case "Approved":
        statusColor = Colors.green;
        break;
      case "Pending":
        statusColor = Colors.orange;
        break;
      default:
        statusColor = Colors.red;
    }

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
        subtitle: Text("Location: $location"),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Chip(
              label: Text(
                status,
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
              backgroundColor: statusColor,
            ),
          ],
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => FarmerDetailsPage()),
          );
        },
      ),
    );
  }
}
