// ignore_for_file: prefer_const_constructors_in_immutables

import 'package:flutter/material.dart';
import 'payment_success_page.dart';

class UpiPaymentPage extends StatelessWidget {
  UpiPaymentPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE3F2FD),
      appBar: AppBar(
        title: const Text("UPI Payment"),
        backgroundColor: Colors.blue,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Icon(Icons.qr_code, size: 80, color: Colors.blue),
            const SizedBox(height: 20),

            const Text(
              "Scan QR or choose a UPI app to pay",
              style: TextStyle(fontSize: 16),
            ),

            const SizedBox(height: 25),

            Card(
              child: ListTile(
                leading: const Icon(Icons.currency_rupee),
                title: const Text("Amount"),
                trailing: const Text(
                  "₹120",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),

            const SizedBox(height: 20),

            Wrap(
              spacing: 12,
              children: const [
                Chip(label: Text("Google Pay")),
                Chip(label: Text("PhonePe")),
                Chip(label: Text("Paytm")),
                Chip(label: Text("BHIM")),
              ],
            ),

            const Spacer(),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.payment),
                label: const Text("Pay Now"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const PaymentSuccessPage(
                        paymentMethod: "UPI / Online Payment",
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
