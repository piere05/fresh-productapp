// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'cash_on_delivery_page.dart';
import 'upi_payment_page.dart';

class PaymentMethodPage extends StatelessWidget {
  const PaymentMethodPage({super.key});

  void _go(BuildContext context, Widget page) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text("Select Payment Method"),
        backgroundColor: Colors.blue,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _paymentCard(
              context,
              icon: Icons.money,
              title: "Cash on Delivery",
              subtitle: "Pay when product arrives",
              color: Colors.green,
              onTap: () => _go(context, CashOnDeliveryPage()),
            ),
            const SizedBox(height: 15),
            _paymentCard(
              context,
              icon: Icons.qr_code,
              title: "UPI / Online Payment",
              subtitle: "Google Pay, PhonePe, Paytm",
              color: Colors.blue,
              onTap: () => _go(context, UpiPaymentPage()),
            ),
          ],
        ),
      ),
    );
  }

  Widget _paymentCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.15),
          child: Icon(icon, color: color),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}
