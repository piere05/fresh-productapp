// ignore_for_file: prefer_const_constructors_in_immutables

import 'package:flutter/material.dart';
import 'payment_success_page.dart';

class CashOnDeliveryPage extends StatelessWidget {
  CashOnDeliveryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8F5E9),
      appBar: AppBar(
        title: const Text("Cash on Delivery"),
        backgroundColor: Colors.green,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Icon(Icons.money, size: 80, color: Colors.green),
            const SizedBox(height: 20),

            const Text(
              "Pay cash when the product is delivered to your address.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),

            const SizedBox(height: 30),

            ListTile(
              leading: const Icon(Icons.location_on),
              title: const Text("Delivery Address"),
              subtitle: const Text("Chennai, Tamil Nadu"),
            ),

            ListTile(
              leading: const Icon(Icons.currency_rupee),
              title: const Text("Amount Payable"),
              subtitle: const Text("₹120"),
            ),

            const Spacer(),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const PaymentSuccessPage(
                        paymentMethod: "Cash on Delivery",
                      ),
                    ),
                  );
                },
                child: const Text("Confirm Order"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
