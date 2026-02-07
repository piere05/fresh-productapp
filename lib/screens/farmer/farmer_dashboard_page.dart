// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

import 'add_product_page.dart';
import 'my_products_page.dart';
import 'orders_page.dart';
import 'reports_page.dart';
import 'farmer_profile_page.dart';
import 'settings_page.dart';
import 'earnings_page.dart';
import 'notifications_page.dart';
import 'stock_management_page.dart';
import 'support_page.dart';

class FarmerDashboardPage extends StatelessWidget {
  const FarmerDashboardPage({super.key});

  void _go(BuildContext context, Widget page) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }

  // 🔐 Logout confirmation
  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Logout"),
        content: const Text("Are you sure you want to logout?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context); // back to login
            },
            child: const Text("Logout"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8F5E9),
      appBar: AppBar(
        title: const Text("Farmer Dashboard"),
        backgroundColor: Colors.green,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            tooltip: "Profile",
            onPressed: () {
              _go(context, FarmerProfilePage());
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: "Logout",
            onPressed: () => _confirmLogout(context),
          ),
        ],
      ),

      body: GridView.count(
        padding: const EdgeInsets.all(16),
        crossAxisCount: 2,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
        children: [
          _dashboardCard(
            context,
            icon: Icons.add_box,
            title: "Add Products",
            color: Colors.green,
            page: AddProductPage(),
          ),
          _dashboardCard(
            context,
            icon: Icons.inventory,
            title: "My Products",
            color: Colors.teal,
            page: MyProductsPage(),
          ),
          _dashboardCard(
            context,
            icon: Icons.shopping_cart,
            title: "Orders",
            color: Colors.orange,
            page: OrdersPage(),
          ),
          _dashboardCard(
            context,
            icon: Icons.bar_chart,
            title: "Reports",
            color: Colors.blue,
            page: ReportsPage(),
          ),
          _dashboardCard(
            context,
            icon: Icons.person,
            title: "Profile",
            color: Colors.purple,
            page: FarmerProfilePage(),
          ),
          _dashboardCard(
            context,
            icon: Icons.settings,
            title: "Settings",
            color: Colors.grey,
            page: SettingsPage(),
          ),
          _dashboardCard(
            context,
            icon: Icons.attach_money,
            title: "Earnings",
            color: Colors.indigo,
            page: EarningsPage(),
          ),
          _dashboardCard(
            context,
            icon: Icons.notifications,
            title: "Notifications",
            color: Colors.redAccent,
            page: NotificationsPage(),
          ),
          _dashboardCard(
            context,
            icon: Icons.store,
            title: "Stock Management",
            color: Colors.brown,
            page: StockManagementPage(),
          ),
          _dashboardCard(
            context,
            icon: Icons.support_agent,
            title: "Support",
            color: Colors.deepOrange,
            page: SupportPage(),
          ),
        ],
      ),
    );
  }

  // 🧩 DASHBOARD CARD
  Widget _dashboardCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required Color color,
    required Widget page,
  }) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => _go(context, page),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: color.withOpacity(0.15),
              child: Icon(icon, size: 30, color: color),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
