// ignore_for_file: prefer_const_constructors_in_immutables, deprecated_member_use

import 'package:flutter/material.dart';

class SupportPage extends StatelessWidget {
  SupportPage({super.key});

  // 📨 CREATE SUPPORT TICKET
  void _createTicket(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Create Support Ticket"),
        content: TextField(
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: "Describe your issue...",
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Ticket submitted (Demo)")),
              );
            },
            child: const Text("Submit"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        title: const Text("Support"),
        backgroundColor: Colors.blue,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: "Create Ticket",
            onPressed: () => _createTicket(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // 📞 CONTACT OPTIONS
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
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

          const Divider(),

          // 🎫 SUPPORT TICKETS
          Expanded(
            child: ListView(
              children: const [
                _TicketCard(
                  title: "Order not delivered",
                  status: "Open",
                  priority: "High",
                ),
                _TicketCard(
                  title: "Payment issue",
                  status: "In Progress",
                  priority: "Medium",
                ),
                _TicketCard(
                  title: "App login problem",
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
}

// 📱 CONTACT CARD
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
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("$label support clicked (Demo)")),
          );
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            children: [
              Icon(icon, color: color, size: 30),
              const SizedBox(height: 8),
              Text(label),
            ],
          ),
        ),
      ),
    );
  }
}

// 🎟 SUPPORT TICKET CARD
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
    Color statusColor = status == "Closed"
        ? Colors.grey
        : status == "In Progress"
        ? Colors.orange
        : Colors.green;

    Color priorityColor = priority == "High"
        ? Colors.red
        : priority == "Medium"
        ? Colors.orange
        : Colors.blue;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: const Icon(Icons.support_agent, color: Colors.blue),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Row(
          children: [
            Chip(
              label: Text(status),
              backgroundColor: statusColor.withOpacity(0.15),
              labelStyle: TextStyle(color: statusColor),
            ),
            const SizedBox(width: 8),
            Chip(
              label: Text(priority),
              backgroundColor: priorityColor.withOpacity(0.15),
              labelStyle: TextStyle(color: priorityColor),
            ),
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
}
