// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

class ReportsPage extends StatelessWidget {
  const ReportsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        title: const Text("Reports"),
        backgroundColor: Colors.indigo,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 📊 SUMMARY CARDS
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 15,
              mainAxisSpacing: 15,
              children: const [
                _ReportCard(
                  title: "Total Sales",
                  value: "₹1,25,000",
                  icon: Icons.currency_rupee,
                  color: Colors.green,
                ),
                _ReportCard(
                  title: "Total Orders",
                  value: "980",
                  icon: Icons.receipt_long,
                  color: Colors.blue,
                ),
                _ReportCard(
                  title: "Active Users",
                  value: "1,250",
                  icon: Icons.people,
                  color: Colors.orange,
                ),
                _ReportCard(
                  title: "Farmers",
                  value: "320",
                  icon: Icons.agriculture,
                  color: Colors.teal,
                ),
              ],
            ),

            const SizedBox(height: 25),

            // 🗓 FILTER
            const Text(
              "Report Period",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            Wrap(
              spacing: 10,
              children: const [
                _FilterChip("Today"),
                _FilterChip("This Week"),
                _FilterChip("This Month"),
                _FilterChip("This Year"),
              ],
            ),

            const SizedBox(height: 25),

            // 📈 REPORT LIST
            const Text(
              "Detailed Reports",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            _reportTile(
              context,
              icon: Icons.show_chart,
              title: "Sales Overview",
              subtitle: "Daily and monthly sales summary",
            ),
            _reportTile(
              context,
              icon: Icons.trending_up,
              title: "Order Trends",
              subtitle: "Order growth analysis",
            ),
            _reportTile(
              context,
              icon: Icons.person_add,
              title: "User Registrations",
              subtitle: "New users & farmers",
            ),
            _reportTile(
              context,
              icon: Icons.inventory,
              title: "Product Performance",
              subtitle: "Top selling products",
            ),
          ],
        ),
      ),
    );
  }

  // 📄 REPORT TILE
  Widget _reportTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
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
        onTap: () {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text("$title clicked (Demo)")));
        },
      ),
    );
  }
}

// 📊 SUMMARY CARD
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

// 🏷 FILTER CHIP
class _FilterChip extends StatelessWidget {
  final String label;

  const _FilterChip(this.label);

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(label),
      backgroundColor: Colors.indigo.withOpacity(0.15),
      labelStyle: const TextStyle(color: Colors.indigo),
    );
  }
}
