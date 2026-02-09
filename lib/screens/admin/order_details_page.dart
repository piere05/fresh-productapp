// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class OrderDetailsPage extends StatelessWidget {
  final String orderId; // Firestore document id

  const OrderDetailsPage({super.key, required this.orderId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3E5F5),
      appBar: AppBar(
        title: const Text("Order Details"),
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('orders')
            .doc(orderId)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;
          final products = List<Map<String, dynamic>>.from(
            data['products'] ?? [],
          );
          final deliveryAddress =
              data['deliveryAddress'] as Map<String, dynamic>?;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // ORDER SUMMARY
                _sectionCard(
                  title: "Order Summary",
                  child: Column(
                    children: [
                      _InfoText("Order ID", data['orderId'] ?? "-"),
                      _InfoText("Order Date", _formatDate(data['createdAt'])),
                      _InfoText(
                        "Status",
                        data['status']?.toString().toUpperCase() ?? "-",
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 15),

                // CUSTOMER DETAILS (FROM deliveryAddress)
                _sectionCard(
                  title: "Customer Details",
                  child: Column(
                    children: [
                      _InfoText("Name", deliveryAddress?['name'] ?? "-"),
                      _InfoText("Email", data['orderBy'] ?? "-"),
                      _InfoText("Phone", deliveryAddress?['phone'] ?? "-"),
                      _InfoText("Address", _formatAddress(deliveryAddress)),
                    ],
                  ),
                ),

                const SizedBox(height: 15),

                // FARMER DETAILS
                _farmerSection(products),

                const SizedBox(height: 15),

                // PRODUCTS
                _sectionCard(
                  title: "Products",
                  child: Column(
                    children: [
                      for (final p in products)
                        _ProductRow(
                          p['productName'] ?? "-",
                          "Qty: ${p['qty']}",
                          "₹${p['total']}",
                        ),
                      const Divider(),
                      _InfoText("Items Total", "₹${data['itemsTotal']}"),
                      _InfoText("Delivery Fee", "₹${data['deliveryFee']}"),
                      _InfoText("Grand Total", "₹${data['grandTotal']}"),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ================= FARMERS =================
  Widget _farmerSection(List<Map<String, dynamic>> products) {
    final farmerEmails = <String>{};

    for (final p in products) {
      if (p['addedBy'] != null) {
        farmerEmails.add(p['addedBy']);
      }
    }

    if (farmerEmails.isEmpty) {
      return _sectionCard(
        title: "Farmer Details",
        child: const Text("No farmer info"),
      );
    }

    return FutureBuilder<QuerySnapshot>(
      future: FirebaseFirestore.instance
          .collection('farmers')
          .where('email', whereIn: farmerEmails.toList())
          .get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return _sectionCard(
            title: "Farmer Details",
            child: const Text("Loading..."),
          );
        }

        final names = snapshot.data!.docs
            .map((d) => d['name'].toString())
            .toList();

        return _sectionCard(
          title: "Farmer Details",
          child: _InfoText("Name(s)", names.join(", ")),
        );
      },
    );
  }

  // ================= HELPERS =================
  Widget _sectionCard({required String title, required Widget child}) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            child,
          ],
        ),
      ),
    );
  }

  static String _formatDate(dynamic ts) {
    if (ts == null) return "-";
    final d = (ts as Timestamp).toDate();
    return "${d.day}-${d.month}-${d.year}";
  }

  static String _formatAddress(Map<String, dynamic>? addr) {
    if (addr == null) return "-";
    return "${addr['address']}, ${addr['city']} - ${addr['pincode']}";
  }
}

// ================= UI WIDGETS =================
class _InfoText extends StatelessWidget {
  final String label;
  final String value;

  const _InfoText(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              "$label:",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}

class _ProductRow extends StatelessWidget {
  final String name;
  final String qty;
  final String price;

  const _ProductRow(this.name, this.qty, this.price);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [Text(name), Text(qty), Text(price)],
      ),
    );
  }
}
