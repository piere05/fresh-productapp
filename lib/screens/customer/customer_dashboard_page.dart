// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

import 'browse_products_page.dart';
import 'cart_page.dart';
import 'my_orders_page.dart';
import 'wishlist_page.dart';
import 'customer_profile_page.dart';
import 'delivery_address_page.dart';
import 'settings_page.dart';
import 'support_page.dart';
import 'notifications_page.dart';

class CustomerDashboardPage extends StatelessWidget {
  const CustomerDashboardPage({super.key});

  // 🔁 Common navigation
  void _go(BuildContext context, Widget page) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }

  // 🔐 Logout confirmation (SAFE)
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
              Navigator.pop(context); // close dialog
              Navigator.popUntil(context, (route) => route.isFirst);
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
      backgroundColor: const Color(0xFFE3F2FD),
      appBar: AppBar(
        title: const Text("Customer Dashboard"),
        backgroundColor: Colors.blue,
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: "Notifications",
            icon: const Icon(Icons.notifications),
            onPressed: () => _go(context, NotificationsPage()),
          ),
          IconButton(
            tooltip: "Logout",
            icon: const Icon(Icons.logout),
            onPressed: () => _confirmLogout(context),
          ),
        ],
      ),

      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 👋 WELCOME CARD
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Welcome 👋",
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
                SizedBox(height: 6),
                Text(
                  "Browse fresh products and manage your orders",
                  style: TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // 📊 DASHBOARD GRID
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 15,
            mainAxisSpacing: 15,
            children: [
              _dashboardCard(
                context,
                icon: Icons.store,
                title: "Browse Products",
                color: Colors.blue,
                page: BrowseProductsPage(),
              ),
              _dashboardCard(
                context,
                icon: Icons.shopping_cart,
                title: "My Cart",
                color: Colors.green,
                page: CartPage(),
              ),
              _dashboardCard(
                context,
                icon: Icons.receipt_long,
                title: "My Orders",
                color: Colors.orange,
                page: MyOrdersPage(),
              ),
              _dashboardCard(
                context,
                icon: Icons.favorite,
                title: "Wishlist",
                color: Colors.pink,
                page: WishlistPage(),
              ),
              _dashboardCard(
                context,
                icon: Icons.person,
                title: "Profile",
                color: Colors.purple,
                page: CustomerProfilePage(),
              ),
              _dashboardCard(
                context,
                icon: Icons.location_on,
                title: "Delivery Address",
                color: Colors.indigo,
                page: DeliveryAddressPage(),
              ),
              _dashboardCard(
                context,
                icon: Icons.settings,
                title: "Settings",
                color: Colors.brown,
                page: SettingsPage(),
              ),
              _dashboardCard(
                context,
                icon: Icons.support_agent,
                title: "Support",
                color: Colors.teal,
                page: SupportPage(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 🧩 DASHBOARD CARD WIDGET
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
              child: Icon(icon, size: 32, color: color),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
