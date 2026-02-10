// ignore_for_file: use_null_aware_elements

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FarmerDetailsPage extends StatefulWidget {
  final String farmerId;

  const FarmerDetailsPage({super.key, required this.farmerId});

  @override
  State<FarmerDetailsPage> createState() => _FarmerDetailsPageState();
}

class _FarmerDetailsPageState extends State<FarmerDetailsPage> {
  late DocumentReference farmerRef;

  @override
  void initState() {
    super.initState();
    farmerRef = FirebaseFirestore.instance
        .collection('farmers')
        .doc(widget.farmerId);
  }

  Future<void> _updateStatus({bool? isApproved, bool? isBlocked}) async {
    await farmerRef.update({
      if (isApproved != null) 'isApproved': isApproved,
      if (isBlocked != null) 'isBlocked': isBlocked,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8F5E9),
      appBar: AppBar(
        title: const Text("Farmer Details"),
        backgroundColor: Colors.green,
        centerTitle: true,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: farmerRef.snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;

          final isApproved = data['isApproved'] == true;
          final isBlocked = data['isBlocked'] == true;

          String status = isBlocked
              ? "Blocked"
              : isApproved
              ? "Approved"
              : "Pending";

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Card(
                  elevation: 6,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
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
                        const SizedBox(height: 15),
                        Text(
                          data['name'],
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          data['email'],
                          style: const TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(height: 10),
                        Chip(
                          label: Text(
                            status,
                            style: const TextStyle(color: Colors.white),
                          ),
                          backgroundColor: status == "Approved"
                              ? Colors.green
                              : status == "Blocked"
                              ? Colors.red
                              : Colors.orange,
                        ),
                        const SizedBox(height: 15),
                        _infoRow(Icons.phone, "Phone", data['phone']),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                if (status == "Pending")
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () =>
                              _updateStatus(isApproved: true, isBlocked: false),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                          ),
                          child: const Text("Approve"),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () =>
                              _updateStatus(isApproved: false, isBlocked: true),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                          ),
                          child: const Text("Reject"),
                        ),
                      ),
                    ],
                  ),

                const SizedBox(height: 10),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _updateStatus(
                      isBlocked: !isBlocked,
                      isApproved: isBlocked ? true : false,
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isBlocked ? Colors.green : Colors.red,
                    ),
                    child: Text(isBlocked ? "Unblock Farmer" : "Block Farmer"),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.green),
          const SizedBox(width: 10),
          Text("$label: ", style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
