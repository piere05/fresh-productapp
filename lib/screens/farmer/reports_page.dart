// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ReportsPage extends StatelessWidget {
  const ReportsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final farmerEmail = FirebaseAuth.instance.currentUser!.email!;

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        title: const Text("Reports"),
        backgroundColor: Colors.indigo,
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('orders').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;

          double farmerSales = 0;
          int farmerOrdersCount = 0;

          final List<QueryDocumentSnapshot> farmerOrders = [];

          for (var doc in docs) {
            final products = doc['products'] as List;

            final farmerProducts = products
                .where((p) => p['addedBy'] == farmerEmail)
                .toList();

            if (farmerProducts.isNotEmpty) {
              farmerOrders.add(doc);
              farmerOrdersCount++;

              for (var p in farmerProducts) {
                farmerSales += (p['total'] ?? 0).toDouble();
              }
            }
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 📊 SUMMARY
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 15,
                  mainAxisSpacing: 15,
                  children: [
                    _ReportCard(
                      title: "Total Sales",
                      value: "₹${farmerSales.toStringAsFixed(0)}",
                      icon: Icons.currency_rupee,
                      color: Colors.green,
                    ),
                    _ReportCard(
                      title: "Total Orders",
                      value: farmerOrdersCount.toString(),
                      icon: Icons.receipt_long,
                      color: Colors.blue,
                    ),
                  ],
                ),

                const SizedBox(height: 25),

                const Text(
                  "Analytics",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),

                _reportTile(
                  context,
                  icon: Icons.show_chart,
                  title: "Sales Overview",
                  subtitle: "Your revenue summary",
                  onTap: () =>
                      _salesOverview(context, farmerSales, farmerOrdersCount),
                ),
                _reportTile(
                  context,
                  icon: Icons.trending_up,
                  title: "Order Trends",
                  subtitle: "Delivered vs Pending",
                  onTap: () => _orderTrends(context, farmerOrders),
                ),
                _reportTile(
                  context,
                  icon: Icons.inventory,
                  title: "Product Performance",
                  subtitle: "Your top products",
                  onTap: () =>
                      _productPerformance(context, farmerOrders, farmerEmail),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ---------------- MODALS ----------------

  void _salesOverview(BuildContext context, double sales, int orders) {
    _openModal(context, "Sales Overview", [
      _modalRow("Total Orders", orders.toString()),
      _modalRow("Total Revenue", "₹${sales.toStringAsFixed(0)}"),
    ]);
  }

  void _orderTrends(BuildContext context, List<QueryDocumentSnapshot> orders) {
    final delivered = orders.where((o) => o['status'] == 'delivered').length;
    final pending = orders.length - delivered;

    _openModal(context, "Order Trends", [
      _modalRow("Delivered Orders", delivered.toString()),
      _modalRow("Pending Orders", pending.toString()),
    ]);
  }

  void _productPerformance(
    BuildContext context,
    List<QueryDocumentSnapshot> orders,
    String farmerEmail,
  ) {
    final Map<String, int> productCount = {};

    for (var o in orders) {
      for (var p in o['products']) {
        if (p['addedBy'] == farmerEmail) {
          productCount[p['productName']] =
              (productCount[p['productName']] ?? 0) + (p['qty'] as int);
        }
      }
    }

    _openModal(
      context,
      "Product Performance",
      productCount.entries
          .map((e) => _modalRow(e.key, "${e.value} sold"))
          .toList(),
    );
  }

  // ---------------- UI HELPERS ----------------

  Widget _reportTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.indigo.withOpacity(0.15),
          child: Icon(icon, color: Colors.indigo),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }

  void _openModal(BuildContext context, String title, List<Widget> children) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _modalRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [Text(label), Text(value)],
      ),
    );
  }
}

// ---------------- SUMMARY CARD ----------------

class _ReportCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _ReportCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              backgroundColor: color.withOpacity(0.15),
              child: Icon(icon, color: color),
            ),
            const SizedBox(height: 10),
            Text(
              value,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            Text(title),
          ],
        ),
      ),
    );
  }
}
