// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'users_page.dart';
import 'farmers_page.dart';
import 'customers_page.dart';
import 'products_page.dart';
import 'orders_page.dart';
import 'reports_page.dart';
import 'settings_page.dart';
import 'support_page.dart';
import 'admin_profile_page.dart';

class AdminDashboardPage extends StatelessWidget {
  const AdminDashboardPage({super.key});

  void _go(BuildContext context, Widget page) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }

  // 🔐 Logout confirmation dialog
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
      backgroundColor: const Color(0xFFFCE4EC),
      appBar: AppBar(
        title: const Text("Admin Dashboard"),
        backgroundColor: Colors.redAccent,
        centerTitle: true,
        actions: [
          // 🔔 Notifications (Demo)
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("No new notifications")),
              );
            },
          ),

          // 👤 Admin Profile
          IconButton(
            icon: const Icon(Icons.person),
            tooltip: "Profile",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => AdminProfilePage()),
              );
            },
          ),

          // 🚪 Logout
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: "Logout",
            onPressed: () => _confirmLogout(context),
          ),
        ],
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // ✅ WELCOME CARD
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.redAccent,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Welcome Admin 👋",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    "Manage users, products, and orders efficiently",
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ✅ DASHBOARD GRID
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
                children: [
                  _card(context, Icons.people, "Users", UsersPage()),
                  _card(context, Icons.agriculture, "Farmers", FarmersPage()),
                  _card(
                    context,
                    Icons.shopping_cart,
                    "Customers",
                    CustomersPage(),
                  ),
                  _card(
                    context,
                    Icons.shopping_bag,
                    "Products",
                    ProductsPage(),
                  ),
                  _card(context, Icons.receipt_long, "Orders", OrdersPage()),
                  _card(context, Icons.bar_chart, "Reports", ReportsPage()),
                  _card(context, Icons.settings, "Settings", SettingsPage()),
                  _card(context, Icons.support_agent, "Support", SupportPage()),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 🧱 DASHBOARD CARD
  Widget _card(BuildContext context, IconData icon, String title, Widget page) {
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
              backgroundColor: Colors.redAccent.withOpacity(0.15),
              child: Icon(icon, size: 32, color: Colors.redAccent),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
