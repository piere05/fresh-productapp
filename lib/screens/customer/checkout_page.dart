// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  String _selectedPayment = "COD";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text("Checkout"),
        backgroundColor: Colors.blue,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 📍 DELIVERY ADDRESS
            _sectionCard(
              title: "Delivery Address",
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    "Ravi Kumar",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 4),
                  Text("No. 12, Anna Nagar"),
                  Text("Chennai, Tamil Nadu - 600001"),
                  Text("📞 +91 98765 43210"),
                ],
              ),
            ),

            const SizedBox(height: 15),

            // 🛒 ORDER SUMMARY
            _sectionCard(
              title: "Order Summary",
              child: Column(
                children: const [
                  _RowText("Tomatoes (2 kg)", "₹80"),
                  _RowText("Onions (1 kg)", "₹30"),
                  Divider(),
                  _RowText("Total Amount", "₹110", bold: true),
                ],
              ),
            ),

            const SizedBox(height: 15),

            // 💳 PAYMENT METHOD
            _sectionCard(
              title: "Payment Method",
              child: Column(
                children: [
                  RadioListTile(
                    value: "COD",
                    groupValue: _selectedPayment,
                    title: const Text("Cash on Delivery"),
                    onChanged: (val) {
                      setState(() => _selectedPayment = val.toString());
                    },
                  ),
                  RadioListTile(
                    value: "UPI",
                    groupValue: _selectedPayment,
                    title: const Text("UPI / Online Payment"),
                    onChanged: (val) {
                      setState(() => _selectedPayment = val.toString());
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            // ✅ PLACE ORDER BUTTON
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.check_circle),
                label: const Text(
                  "Place Order",
                  style: TextStyle(fontSize: 16),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  _showSuccessDialog(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 📦 SECTION CARD
  Widget _sectionCard({required String title, required Widget child}) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            child,
          ],
        ),
      ),
    );
  }

  // 🎉 SUCCESS DIALOG
  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Order Placed"),
        content: const Text(
          "Your order has been placed successfully.\n\nThank you for shopping!",
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }
}

// 🔹 REUSABLE ROW TEXT
class _RowText extends StatelessWidget {
  final String left;
  final String right;
  final bool bold;

  const _RowText(this.left, this.right, {this.bold = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            left,
            style: TextStyle(
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            right,
            style: TextStyle(
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
