// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

class ReportsPage extends StatelessWidget {
  const ReportsPage({super.key}); // NOT const

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F8E9),
      appBar: AppBar(
        title: const Text("Reports & Analytics"),
        backgroundColor: Colors.indigo,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 📊 OVERVIEW
            const Text(
              "Overview",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 15,
              mainAxisSpacing: 15,
              children: const [
                _StatCard(
                  title: "Total Users",
                  value: "1,250",
                  icon: Icons.people,
                  color: Colors.blue,
                ),
                _StatCard(
                  title: "Farmers",
                  value: "320",
                  icon: Icons.agriculture,
                  color: Colors.green,
                ),
                _StatCard(
                  title: "Orders",
                  value: "980",
                  icon: Icons.receipt_long,
                  color: Colors.orange,
                ),
                _StatCard(
                  title: "Revenue",
                  value: "₹1.8L",
                  icon: Icons.currency_rupee,
                  color: Colors.purple,
                ),
              ],
            ),

            const SizedBox(height: 25),

            // 🕒 FILTER
            const Text(
              "Report Period",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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

            const SizedBox(height: 30),

            // 📈 ANALYTICS SECTIONS
            const Text(
              "Analytics",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            _reportSection(
              title: "Sales Overview",
              subtitle: "Daily & monthly sales performance",
              icon: Icons.show_chart,
            ),
            _reportSection(
              title: "Order Trends",
              subtitle: "Placed vs Delivered orders",
              icon: Icons.trending_up,
            ),
            _reportSection(
              title: "User Growth",
              subtitle: "New customer & farmer registrations",
              icon: Icons.group_add,
            ),

            const SizedBox(height: 30),

            // 🧾 RECENT ACTIVITY
            const Text(
              "Recent Activity",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            _activityTile(
              icon: Icons.shopping_cart,
              title: "New Order",
              subtitle: "Order placed by Ravi Kumar",
              time: "2 mins ago",
            ),
            _activityTile(
              icon: Icons.person_add,
              title: "New Farmer",
              subtitle: "Ramesh registered as farmer",
              time: "1 hour ago",
            ),
            _activityTile(
              icon: Icons.check_circle,
              title: "Order Delivered",
              subtitle: "Order #ORD1023 delivered",
              time: "Today",
            ),
          ],
        ),
      ),
    );
  }

  // 📊 REPORT SECTION CARD
  Widget _reportSection({
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.indigo.withOpacity(0.15),
          child: Icon(icon, color: Colors.indigo),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          // future navigation / charts page
        },
      ),
    );
  }

  // 🧾 ACTIVITY TILE
  Widget _activityTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required String time,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.indigo.withOpacity(0.15),
          child: Icon(icon, color: Colors.indigo),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: Text(
          time,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ),
    );
  }
}

// 📦 STAT CARD
class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
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
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
