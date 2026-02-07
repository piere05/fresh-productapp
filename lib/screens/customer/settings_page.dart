// ignore_for_file: prefer_const_constructors_in_immutables

import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool notificationsEnabled = true;
  bool darkModeEnabled = false;
  bool emailAlertsEnabled = true;

  // 🔐 LOGOUT CONFIRMATION
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
              Navigator.pop(context); // back to dashboard/login
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
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text("Settings"),
        backgroundColor: Colors.blue,
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 👤 PROFILE CARD
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            child: const ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.blue,
                child: Icon(Icons.person, color: Colors.white),
              ),
              title: Text(
                "Customer Name",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text("customer@email.com"),
              trailing: Icon(Icons.edit),
            ),
          ),

          const SizedBox(height: 20),

          // ⚙️ GENERAL SETTINGS
          const Text(
            "General",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),

          SwitchListTile(
            title: const Text("Enable Notifications"),
            value: notificationsEnabled,
            secondary: const Icon(Icons.notifications),
            onChanged: (value) {
              setState(() => notificationsEnabled = value);
            },
          ),

          SwitchListTile(
            title: const Text("Email Alerts"),
            value: emailAlertsEnabled,
            secondary: const Icon(Icons.email),
            onChanged: (value) {
              setState(() => emailAlertsEnabled = value);
            },
          ),

          SwitchListTile(
            title: const Text("Dark Mode"),
            value: darkModeEnabled,
            secondary: const Icon(Icons.dark_mode),
            onChanged: (value) {
              setState(() => darkModeEnabled = value);
            },
          ),

          const SizedBox(height: 20),

          // 🔐 SECURITY
          const Text(
            "Security",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),

          ListTile(
            leading: const Icon(Icons.lock),
            title: const Text("Change Password"),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Change password (Demo)")),
              );
            },
          ),

          ListTile(
            leading: const Icon(Icons.privacy_tip),
            title: const Text("Privacy Policy"),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Privacy policy (Demo)")),
              );
            },
          ),

          const SizedBox(height: 20),

          // 🚪 LOGOUT
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text("Logout", style: TextStyle(color: Colors.red)),
            onTap: () => _confirmLogout(context),
          ),
        ],
      ),
    );
  }
}
