// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'order_details_page.dart';

class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  String _search = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Orders"),
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
      ),
      body: Column(
        children: [
          // 🔍 SEARCH BAR
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              decoration: InputDecoration(
                hintText: "Search by Order ID / Customer email",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.grey.shade200,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (v) {
                setState(() {
                  _search = v.toLowerCase();
                });
              },
            ),
          ),

          // 📋 ORDERS LIST
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('orders')
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final docs = snapshot.data!.docs;

                if (docs.isEmpty) {
                  return const Center(child: Text("No orders found"));
                }

                // 🔍 SEARCH FILTER (DART)
                final filtered = docs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final orderId = (data['orderId'] ?? '')
                      .toString()
                      .toLowerCase();
                  final customer = (data['orderBy'] ?? '')
                      .toString()
                      .toLowerCase();

                  return orderId.contains(_search) ||
                      customer.contains(_search);
                }).toList();

                if (filtered.isEmpty) {
                  return const Center(child: Text("No matching orders"));
                }

                return ListView.builder(
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final doc = filtered[index];
                    final data = doc.data() as Map<String, dynamic>;

                    return _orderCard(
                      context,
                      orderDocId: doc.id,
                      orderId: data['orderId'] ?? "-",
                      customer: data['orderBy'] ?? "-",
                      amount: "₹${data['grandTotal'] ?? 0}",
                      status: data['status'] ?? "-",
                      products: data['products'] ?? [],
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

  // ================= ORDER CARD =================
  Widget _orderCard(
    BuildContext context, {
    required String orderDocId,
    required String orderId,
    required String customer,
    required String amount,
    required String status,
    required List products,
  }) {
    Color statusColor;
    switch (status) {
      case "approved":
        statusColor = Colors.green;
        break;
      case "delivered":
        statusColor = Colors.blue;
        break;
      default:
        statusColor = Colors.orange;
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.deepPurple.shade100,
          child: const Icon(Icons.receipt_long, color: Colors.deepPurple),
        ),
        title: Text(
          orderId,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Customer: $customer"),
            _farmerNames(products),
            Text("Amount: $amount"),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              status.toUpperCase(),
              style: TextStyle(color: statusColor, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            const Icon(Icons.arrow_forward_ios, size: 14),
          ],
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => OrderDetailsPage(orderId: orderDocId),
            ),
          );
        },
      ),
    );
  }

  // ================= FARMER NAMES =================
  Widget _farmerNames(List products) {
    // collect unique farmer emails
    final emails = <String>{};
    for (var p in products) {
      if (p['addedBy'] != null) {
        emails.add(p['addedBy']);
      }
    }

    if (emails.isEmpty) {
      return const Text("Farmer: -");
    }

    return FutureBuilder<QuerySnapshot>(
      future: FirebaseFirestore.instance
          .collection('farmers')
          .where('email', whereIn: emails.toList())
          .get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Text("Farmer: loading...");
        }

        final names = snapshot.data!.docs
            .map((d) => d['name'].toString())
            .toList();

        return Text(
          "Farmer: ${names.join(', ')}",
          style: const TextStyle(fontSize: 13),
        );
      },
    );
  }
}
