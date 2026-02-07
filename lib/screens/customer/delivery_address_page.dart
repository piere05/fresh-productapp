// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'add_address_page.dart';

class DeliveryAddressPage extends StatelessWidget {
  const DeliveryAddressPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text("Delivery Address"),
        backgroundColor: Colors.indigo,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 📍 SAVED ADDRESSES
            _addressCard(
              title: "Home",
              address: "12, Anna Nagar, Chennai, Tamil Nadu - 600040",
              isDefault: true,
            ),
            _addressCard(
              title: "Office",
              address: "IT Park Road, Tidel Park, Chennai - 600113",
              isDefault: false,
            ),

            const Spacer(),

            // ➕ ADD ADDRESS BUTTON
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.add_location_alt),
                label: const Text("Add New Address"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => AddAddressPage()),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 📦 ADDRESS CARD
  Widget _addressCard({
    required String title,
    required String address,
    required bool isDefault,
  }) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        leading: Icon(
          Icons.location_on,
          color: isDefault ? Colors.green : Colors.indigo,
        ),
        title: Row(
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            if (isDefault) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  "Default",
                  style: TextStyle(color: Colors.green, fontSize: 12),
                ),
              ),
            ],
          ],
        ),
        subtitle: Text(address),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {},
          itemBuilder: (_) => const [
            PopupMenuItem(value: "edit", child: Text("Edit")),
            PopupMenuItem(value: "delete", child: Text("Delete")),
          ],
        ),
        onTap: () {},
      ),
    );
  }
}
