import 'package:flutter/material.dart';

class OrderDetailsPage extends StatelessWidget {
  const OrderDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3E5F5),
      appBar: AppBar(
        title: const Text("Order Details"),
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 🧾 ORDER SUMMARY
            _sectionCard(
              title: "Order Summary",
              child: Column(
                children: const [
                  _InfoRow("Order ID", "#ORD101"),
                  _InfoRow("Order Date", "18 Aug 2026"),
                  _InfoRow("Status", "Pending"),
                  _InfoRow("Payment", "Cash on Delivery"),
                ],
              ),
            ),

            const SizedBox(height: 15),

            // 👤 CUSTOMER DETAILS
            _sectionCard(
              title: "Customer Details",
              child: Column(
                children: const [
                  _InfoRow("Name", "Ravi Kumar"),
                  _InfoRow("Email", "ravi@gmail.com"),
                  _InfoRow("Phone", "+91 98765 43210"),
                  _InfoRow("Address", "Chennai, Tamil Nadu"),
                ],
              ),
            ),

            const SizedBox(height: 15),

            // 👨‍🌾 FARMER DETAILS
            _sectionCard(
              title: "Farmer Details",
              child: Column(
                children: const [
                  _InfoRow("Name", "Ramesh Kumar"),
                  _InfoRow("Location", "Coimbatore"),
                ],
              ),
            ),

            const SizedBox(height: 15),

            // 📦 PRODUCT DETAILS
            _sectionCard(
              title: "Products",
              child: Column(
                children: const [
                  _ProductRow("Tomatoes", "2 kg", "₹80"),
                  _ProductRow("Onions", "1 kg", "₹40"),
                  Divider(),
                  _InfoRow("Total Amount", "₹120"),
                ],
              ),
            ),

            const SizedBox(height: 25),

            // ✅ ACTION BUTTONS
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      _showSnack(context, "Order Approved (Demo)");
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text("Approve"),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      _showSnack(context, "Order Rejected (Demo)");
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text("Reject"),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // 🚚 MARK AS DELIVERED
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  _showSnack(context, "Order Delivered (Demo)");
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text("Mark as Delivered"),
              ),
            ),

            const SizedBox(height: 10),

            // ❌ CANCEL ORDER
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _confirmCancel(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text("Cancel Order"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 🔲 SECTION CARD
  Widget _sectionCard({required String title, required Widget child}) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            child,
          ],
        ),
      ),
    );
  }

  // 🔔 SNACKBAR
  void _showSnack(BuildContext context, String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  // ❗ CANCEL CONFIRMATION
  void _confirmCancel(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Cancel Order"),
        content: const Text("Are you sure you want to cancel this order?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("No"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text("Yes, Cancel"),
          ),
        ],
      ),
    );
  }
}

// 🔹 INFO ROW WIDGET
class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              "$label:",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}

// 🔹 PRODUCT ROW WIDGET
class _ProductRow extends StatelessWidget {
  final String name;
  final String qty;
  final String price;

  const _ProductRow(this.name, this.qty, this.price);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [Text(name), Text(qty), Text(price)],
      ),
    );
  }
}
