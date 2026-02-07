import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key}); // NOT const

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool notificationsEnabled = true;
  bool emailAlerts = true;
  bool darkMode = false;

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
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context); // back to previous screen
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
      backgroundColor: const Color(0xFFF4F6F8),
      appBar: AppBar(
        title: const Text("Settings"),
        backgroundColor: Colors.grey.shade900,
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 👤 PROFILE CARD
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            child: ListTile(
              leading: const CircleAvatar(
                radius: 24,
                backgroundColor: Colors.grey,
                child: Icon(Icons.person, color: Colors.white),
              ),
              title: const Text(
                "Admin User",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: const Text("admin@system.com"),
              trailing: const Icon(Icons.edit),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Edit profile (Demo only)")),
                );
              },
            ),
          ),

          const SizedBox(height: 25),

          // ⚙️ GENERAL SETTINGS
          const Text(
            "General Settings",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),

          _switchTile(
            title: "Enable Notifications",
            subtitle: "Receive app notifications",
            icon: Icons.notifications,
            value: notificationsEnabled,
            onChanged: (val) => setState(() => notificationsEnabled = val),
          ),

          _switchTile(
            title: "Email Alerts",
            subtitle: "Receive alerts via email",
            icon: Icons.email,
            value: emailAlerts,
            onChanged: (val) => setState(() => emailAlerts = val),
          ),

          _switchTile(
            title: "Dark Mode",
            subtitle: "Reduce eye strain at night",
            icon: Icons.dark_mode,
            value: darkMode,
            onChanged: (val) => setState(() => darkMode = val),
          ),

          const SizedBox(height: 25),

          // 🔐 SECURITY
          const Text(
            "Security",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),

          _actionTile(
            icon: Icons.lock,
            title: "Change Password",
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Change password (Demo)")),
              );
            },
          ),

          _actionTile(
            icon: Icons.security,
            title: "Two-Factor Authentication",
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("2FA settings (Demo)")),
              );
            },
          ),

          const SizedBox(height: 30),

          // 🚪 LOGOUT
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text(
                "Logout",
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onTap: () => _confirmLogout(context),
            ),
          ),
        ],
      ),
    );
  }

  // 🔁 SWITCH TILE
  Widget _switchTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: SwitchListTile(
        title: Text(title),
        subtitle: Text(subtitle),
        value: value,
        onChanged: onChanged,
        secondary: Icon(icon),
      ),
    );
  }

  // ➡️ ACTION TILE
  Widget _actionTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}
