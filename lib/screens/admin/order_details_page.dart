import 'package:flutter/material.dart';

class OrderDetailsPage extends StatelessWidget {
  const OrderDetailsPage({super.key}); // NOT const

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
            // ORDER SUMMARY
            _sectionCard(
              title: "Order Summary",
              child: Column(
                children: [
                  _InfoText("Order ID", "#ORD12345"),
                  _InfoText("Order Date", "15 Aug 2026"),
                  _InfoText("Status", "Pending"),
                ],
              ),
            ),

            const SizedBox(height: 15),

            // CUSTOMER DETAILS
            _sectionCard(
              title: "Customer Details",
              child: Column(
                children: [
                  _InfoText("Name", "Ravi Kumar"),
                  _InfoText("Email", "ravi@gmail.com"),
                  _InfoText("Phone", "+91 98765 43210"),
                ],
              ),
            ),

            const SizedBox(height: 15),

            // FARMER DETAILS
            _sectionCard(
              title: "Farmer Details",
              child: Column(
                children: [
                  _InfoText("Name", "Ramesh Kumar"),
                  _InfoText("Location", "Coimbatore"),
                ],
              ),
            ),

            const SizedBox(height: 15),

            // PRODUCT LIST
            _sectionCard(
              title: "Products",
              child: Column(
                children: [
                  _ProductRow("Tomatoes", "2 kg", "₹80"),
                  _ProductRow("Onions", "1 kg", "₹40"),
                  const Divider(),
                  _InfoText("Total Amount", "₹120"),
                ],
              ),
            ),

            const SizedBox(height: 25),

            // ACTION BUTTONS
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      _showSnack(context, "Order Approved (Demo)");
                    },
                    child: const Text("Approve"),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      _showSnack(context, "Order Rejected (Demo)");
                    },
                    child: const Text("Reject"),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // DELIVERED
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  _showSnack(context, "Order Delivered (Demo)");
                },
                child: const Text("Mark as Delivered"),
              ),
            ),

            const SizedBox(height: 10),

            // CANCEL
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  _confirmCancel(context);
                },
                child: const Text("Cancel Order"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // SECTION CARD
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

  // SNACKBAR
  void _showSnack(BuildContext context, String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  // CANCEL CONFIRM
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

// INFO TEXT
class _InfoText extends StatelessWidget {
  final String label;
  final String value;

  const _InfoText(this.label, this.value);

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

// PRODUCT ROW
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
