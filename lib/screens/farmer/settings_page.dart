import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool notifications = true;
  bool darkMode = false;
  bool emailAlerts = true;

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
              Navigator.pop(context); // back to previous page
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
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text("Settings"),
        backgroundColor: Colors.grey.shade800,
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 👤 PROFILE
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            child: ListTile(
              leading: const CircleAvatar(
                backgroundColor: Colors.grey,
                child: Icon(Icons.person, color: Colors.white),
              ),
              title: const Text(
                "User Name",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: const Text("user@email.com"),
              trailing: const Icon(Icons.edit),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Edit profile (Demo)")),
                );
              },
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
            value: notifications,
            secondary: const Icon(Icons.notifications),
            onChanged: (val) => setState(() => notifications = val),
          ),

          SwitchListTile(
            title: const Text("Email Alerts"),
            value: emailAlerts,
            secondary: const Icon(Icons.email),
            onChanged: (val) => setState(() => emailAlerts = val),
          ),

          SwitchListTile(
            title: const Text("Dark Mode"),
            value: darkMode,
            secondary: const Icon(Icons.dark_mode),
            onChanged: (val) => setState(() => darkMode = val),
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
            leading: const Icon(Icons.security),
            title: const Text("Two-Factor Authentication"),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("2FA settings (Demo)")),
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
