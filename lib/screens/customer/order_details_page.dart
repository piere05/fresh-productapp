// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

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

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.picture_as_pdf),
                    label: const Text("Download Invoice"),
                    onPressed: () {
                      if (kIsWeb) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              "Invoice download is available on mobile app only",
                            ),
                          ),
                        );
                        return;
                      }
                      _downloadInvoice(data);
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

  // ================= PDF (SAFE – NO WEB CRASH) =================
  Future<void> _downloadInvoice(Map<String, dynamic> order) async {
    final pdf = pw.Document();
    final products = List<Map<String, dynamic>>.from(order['products']);
    final address = Map<String, dynamic>.from(order['deliveryAddress']);

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(20),
        build: (_) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                "Fresh Product App",
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.Text(
                "Invoice Date: ${DateTime.now().toString().split(' ').first}",
              ),
              pw.SizedBox(height: 20),
              pw.Table.fromTextArray(
                headers: ["S.No", "Product", "Qty", "Price", "Total"],
                data: products.map((p) {
                  return [
                    p['sno'].toString(),
                    p['productName'],
                    p['qty'].toString(),
                    "Rs. ${p['price']}",
                    "Rs. ${p['total']}",
                  ];
                }).toList(),
              ),
              pw.SizedBox(height: 20),
              pw.Align(
                alignment: pw.Alignment.centerRight,
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text("Items Total: Rs. ${order['itemsTotal']}"),
                    pw.Text("Delivery Fee: Rs. ${order['deliveryFee']}"),
                    pw.Text(
                      "Grand Total: Rs. ${order['grandTotal']}",
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 30),
              pw.Text(
                "Delivery Address",
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
              pw.Text(address['name']),
              pw.Text(address['address']),
              pw.Text("${address['city']} - ${address['pincode']}"),
              pw.Text("Phone: ${address['phone']}"),
            ],
          );
        },
      ),
    );

    final dir = await getApplicationDocumentsDirectory();
    final file = File(
      "${dir.path}/invoice_${DateTime.now().millisecondsSinceEpoch}.pdf",
    );
    await file.writeAsBytes(await pdf.save());
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
