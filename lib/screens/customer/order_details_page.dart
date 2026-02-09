// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:path_provider/path_provider.dart';

import 'create_ticket_page.dart';

class OrderDetailsPage extends StatelessWidget {
  final String orderId;

  const OrderDetailsPage({super.key, required this.orderId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        title: const Text("Order Details"),
        backgroundColor: Colors.blue,
        centerTitle: true,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('orders')
            .doc(orderId)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;
          final products = List<Map<String, dynamic>>.from(data['products']);
          final address = Map<String, dynamic>.from(data['deliveryAddress']);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _card(
                  "Order Status",
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        data['status'].toString().toUpperCase(),
                        style: const TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Chip(
                        label: Text(data['paymentMethod']),
                        backgroundColor: Colors.green.shade100,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 15),

                _card(
                  "Order Info",
                  Column(
                    children: [
                      _info("Order ID", orderId),
                      _info(
                        "Date",
                        (data['createdAt'] as Timestamp)
                            .toDate()
                            .toString()
                            .split(' ')
                            .first,
                      ),
                      _info("Payment", data['paymentMethod']),
                    ],
                  ),
                ),
                const SizedBox(height: 15),

                _card(
                  "Products",
                  Column(
                    children: [
                      ...products.map(
                        (p) => _row(
                          "${p['productName']} (x${p['qty']})",
                          "Rs. ${p['total']}",
                        ),
                      ),
                      const Divider(),
                      _info("Items Total", "Rs. ${data['itemsTotal']}"),
                      _info("Delivery Fee", "Rs. ${data['deliveryFee']}"),
                      _info(
                        "Grand Total",
                        "Rs. ${data['grandTotal']}",
                        bold: true,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 15),

                _card(
                  "Delivery Address",
                  Text(
                    "${address['name']}\n"
                    "${address['address']}\n"
                    "${address['city']} - ${address['pincode']}\n"
                    "Phone: ${address['phone']}",
                  ),
                ),
                const SizedBox(height: 25),

                // ⬇️ DOWNLOAD RECEIPT (TXT)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.receipt_long),
                    label: const Text("Download Receipt"),
                    onPressed: () {
                      if (kIsWeb) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              "Receipt download is available on mobile app only",
                            ),
                          ),
                        );
                        return;
                      }
                      _downloadReceipt(context, data);
                    },
                  ),
                ),
                const SizedBox(height: 10),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.support_agent),
                    label: const Text("Request Support"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => CreateTicketPage(orderId: orderId),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ================= RECEIPT (TXT FILE) =================
  Future<void> _downloadReceipt(
    BuildContext context,
    Map<String, dynamic> order,
  ) async {
    final products = List<Map<String, dynamic>>.from(order['products']);
    final address = Map<String, dynamic>.from(order['deliveryAddress']);

    final buffer = StringBuffer();
    buffer.writeln("Fresh Product App");
    buffer.writeln("Order ID: $orderId");
    buffer.writeln("Date: ${DateTime.now().toString().split(' ').first}");
    buffer.writeln("----------------------------------");

    for (var p in products) {
      buffer.writeln("${p['productName']} x${p['qty']} = Rs. ${p['total']}");
    }

    buffer.writeln("----------------------------------");
    buffer.writeln("Items Total: Rs. ${order['itemsTotal']}");
    buffer.writeln("Delivery Fee: Rs. ${order['deliveryFee']}");
    buffer.writeln("Grand Total: Rs. ${order['grandTotal']}");
    buffer.writeln("----------------------------------");
    buffer.writeln("Delivery Address:");
    buffer.writeln(address['name']);
    buffer.writeln(address['address']);
    buffer.writeln("${address['city']} - ${address['pincode']}");
    buffer.writeln("Phone: ${address['phone']}");

    final dir = await getApplicationDocumentsDirectory();
    final file = File(
      "${dir.path}/receipt_${DateTime.now().millisecondsSinceEpoch}.txt",
    );

    await file.writeAsString(buffer.toString());

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Receipt downloaded successfully")),
    );
  }

  // ================= UI HELPERS =================
  Widget _card(String title, Widget child) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 10),
            child,
          ],
        ),
      ),
    );
  }

  Widget _info(String l, String v, {bool bold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(l, style: const TextStyle(fontWeight: FontWeight.bold)),
        Text(v, style: TextStyle(fontWeight: bold ? FontWeight.bold : null)),
      ],
    );
  }

  Widget _row(String l, String r) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [Text(l), Text(r)],
      ),
    );
  }
}
