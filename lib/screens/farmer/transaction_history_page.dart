import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TransactionHistoryPage extends StatelessWidget {
  const TransactionHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final farmerEmail = FirebaseAuth.instance.currentUser!.email!;

    return Scaffold(
      backgroundColor: const Color(0xFFF1F8E9),
      appBar: AppBar(
        title: const Text("Transaction History"),
        backgroundColor: Colors.indigo,
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('orders')
            .where('status', isEqualTo: 'delivered')
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final List<Map<String, dynamic>> transactions = [];

          for (var doc in snapshot.data!.docs) {
            final data = doc.data() as Map<String, dynamic>;
            final createdAt = (data['createdAt'] as Timestamp).toDate();
            final products = data['products'] as List;

            for (var p in products) {
              if (p['addedBy'] == farmerEmail) {
                transactions.add({
                  'orderId': doc.id,
                  'amount': p['total'],
                  'date': createdAt,
                });
              }
            }
          }

          return ListView(
            padding: const EdgeInsets.all(12),
            children: transactions.map((t) {
              return _TransactionCard(
                orderId: "Order ${t['orderId']}",
                amount: "₹${t['amount']}",
                type: "Credited",
                date: "${t['date'].day}-${t['date'].month}-${t['date'].year}",
              );
            }).toList(),
          );
        },
      ),
    );
  }
}

// 💳 TRANSACTION CARD (UNCHANGED UI)
class _TransactionCard extends StatelessWidget {
  final String orderId;
  final String amount;
  final String type;
  final String date;

  const _TransactionCard({
    required this.orderId,
    required this.amount,
    required this.type,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.green.shade100,
          child: const Icon(Icons.arrow_downward, color: Colors.green),
        ),
        title: Text(
          orderId,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(date),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              amount,
              style: const TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const Text(
              "Credited",
              style: TextStyle(color: Colors.green, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
