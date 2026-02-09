// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ReportsPage extends StatefulWidget {
  const ReportsPage({super.key});

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  String _period = "All";

  // ================= DATE FILTER =================
  DateTime? _fromDate() {
    final now = DateTime.now();
    switch (_period) {
      case "Today":
        return DateTime(now.year, now.month, now.day);
      case "This Week":
        return now.subtract(const Duration(days: 7));
      case "This Month":
        return DateTime(now.year, now.month, 1);
      case "This Year":
        return DateTime(now.year, 1, 1);
      default:
        return null;
    }
  }

  // ================= BUILD =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F8E9),
      appBar: AppBar(
        title: const Text("Reports & Analytics"),
        backgroundColor: Colors.indigo,
        centerTitle: true,
      ),
      body: FutureBuilder<List<QuerySnapshot>>(
        future: Future.wait([
          FirebaseFirestore.instance.collection('customers').get(),
          FirebaseFirestore.instance.collection('farmers').get(),
          FirebaseFirestore.instance.collection('orders').get(),
        ]),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final customers = snapshot.data![0].docs;
          final farmers = snapshot.data![1].docs;
          final orders = snapshot.data![2].docs;

          final from = _fromDate();

          // ================= FILTER =================
          List<QueryDocumentSnapshot> filteredOrders = from == null
              ? List.from(orders)
              : orders.where((o) {
                  final data = o.data() as Map<String, dynamic>;
                  if (data['createdAt'] == null) return false;
                  final d = (data['createdAt'] as Timestamp).toDate();
                  return d.isAfter(from);
                }).toList();

          // ================= SORT (LATEST FIRST) =================
          filteredOrders.sort((a, b) {
            final aDate =
                (a.data() as Map<String, dynamic>)['createdAt'] as Timestamp?;
            final bDate =
                (b.data() as Map<String, dynamic>)['createdAt'] as Timestamp?;

            if (aDate == null || bDate == null) return 0;
            return bDate.toDate().compareTo(aDate.toDate());
          });

          // ================= REVENUE =================
          double revenue = 0;
          for (var o in filteredOrders) {
            final data = o.data() as Map<String, dynamic>;
            revenue += (data['grandTotal'] ?? 0).toDouble();
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                  children: [
                    _StatCard(
                      title: "Customers",
                      value: customers.length.toString(),
                      icon: Icons.people,
                      color: Colors.blue,
                    ),
                    _StatCard(
                      title: "Farmers",
                      value: farmers.length.toString(),
                      icon: Icons.agriculture,
                      color: Colors.green,
                    ),
                    _StatCard(
                      title: "Orders",
                      value: filteredOrders.length.toString(),
                      icon: Icons.receipt_long,
                      color: Colors.orange,
                    ),
                    _StatCard(
                      title: "Revenue",
                      value: "₹${revenue.toStringAsFixed(0)}",
                      icon: Icons.currency_rupee,
                      color: Colors.purple,
                    ),
                  ],
                ),

                const SizedBox(height: 25),

                const Text(
                  "Report Period",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),

                Wrap(
                  spacing: 10,
                  children: [
                    _filterChip("All"),
                    _filterChip("Today"),
                    _filterChip("This Week"),
                    _filterChip("This Month"),
                    _filterChip("This Year"),
                  ],
                ),

                const SizedBox(height: 30),

                const Text(
                  "Recent Activity",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),

                filteredOrders.isEmpty
                    ? const Padding(
                        padding: EdgeInsets.all(20),
                        child: Center(child: Text("No orders found")),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: filteredOrders.length,
                        itemBuilder: (context, index) {
                          final o = filteredOrders[index];
                          final data = o.data() as Map<String, dynamic>;
                          final orderNo = data['orderId'] ?? o.id;

                          return _activityTile(
                            icon: Icons.shopping_cart,
                            title: "New Order",
                            subtitle: "Order $orderNo",
                            time: _timeAgo(data['createdAt']),
                          );
                        },
                      ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ================= FILTER CHIP =================
  Widget _filterChip(String label) {
    final selected = _period == label;
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      selectedColor: Colors.indigo.withOpacity(0.25),
      onSelected: (_) => setState(() => _period = label),
    );
  }

  // ================= TIME AGO =================
  String _timeAgo(dynamic ts) {
    if (ts == null) return "-";
    final d = (ts as Timestamp).toDate();
    final diff = DateTime.now().difference(d);

    if (diff.inMinutes < 60) return "${diff.inMinutes} mins ago";
    if (diff.inHours < 24) return "${diff.inHours} hrs ago";
    return "${diff.inDays} days ago";
  }

  // ================= ACTIVITY TILE =================
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

// ================= STAT CARD =================
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
          mainAxisSize: MainAxisSize.min,
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
            Text(title, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
