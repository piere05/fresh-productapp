// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

class SupportPage extends StatelessWidget {
  const SupportPage({super.key}); // NOT const

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        title: const Text("Support & Help"),
        backgroundColor: Colors.teal.shade700,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: "Create Ticket",
            onPressed: () => _showCreateTicketDialog(context),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 📞 CONTACT OPTIONS
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                _ContactCard(
                  icon: Icons.phone,
                  label: "Call",
                  color: Colors.green,
                ),
                _ContactCard(
                  icon: Icons.email,
                  label: "Email",
                  color: Colors.blue,
                ),
                _ContactCard(
                  icon: Icons.help_outline,
                  label: "FAQ",
                  color: Colors.orange,
                ),
              ],
            ),
          ),

          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              "Support Tickets",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),

          const SizedBox(height: 8),

          // 🎫 TICKETS LIST
          Expanded(
            child: ListView(
              padding: const EdgeInsets.only(bottom: 16),
              children: const [
                _TicketCard(
                  title: "Order not updating",
                  status: "Open",
                  priority: "High",
                ),
                _TicketCard(
                  title: "Unable to add product",
                  status: "In Progress",
                  priority: "Medium",
                ),
                _TicketCard(
                  title: "Account verification issue",
                  status: "Closed",
                  priority: "Low",
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 📝 CREATE TICKET DIALOG
  void _showCreateTicketDialog(BuildContext context) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Create Support Ticket"),
        content: TextField(
          controller: controller,
          maxLines: 4,
          decoration: const InputDecoration(
            hintText: "Describe your issue clearly...",
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Ticket created successfully")),
              );
            },
            child: const Text("Submit"),
          ),
        ],
      ),
    );
  }
}

// 📞 CONTACT CARD
class _ContactCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _ContactCard({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        elevation: 4,
        margin: const EdgeInsets.symmetric(horizontal: 6),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("$label support selected (Demo)")),
            );
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 18),
            child: Column(
              children: [
                Icon(icon, color: color, size: 32),
                const SizedBox(height: 8),
                Text(
                  label,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// 🎫 TICKET CARD
class _TicketCard extends StatelessWidget {
  final String title;
  final String status;
  final String priority;

  const _TicketCard({
    required this.title,
    required this.status,
    required this.priority,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(status);
    final priorityColor = _priorityColor(priority);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ListTile(
        leading: const Icon(Icons.support_agent, color: Colors.teal),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Wrap(
          spacing: 8,
          children: [
            _chip(status, statusColor),
            _chip(priority, priorityColor),
          ],
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 14),
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Ticket details (Demo)")),
          );
        },
      ),
    );
  }

  static Widget _chip(String text, Color color) {
    return Chip(
      label: Text(text),
      backgroundColor: color.withOpacity(0.15),
      labelStyle: TextStyle(color: color),
    );
  }

  static Color _statusColor(String status) {
    switch (status) {
      case "Closed":
        return Colors.grey;
      case "In Progress":
        return Colors.orange;
      default:
        return Colors.green;
    }
  }

  static Color _priorityColor(String priority) {
    switch (priority) {
      case "High":
        return Colors.red;
      case "Medium":
        return Colors.orange;
      default:
        return Colors.blue;
    }
  }
}
