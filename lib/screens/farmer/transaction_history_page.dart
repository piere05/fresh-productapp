import 'package:flutter/material.dart';

class TransactionHistoryPage extends StatelessWidget {
  const TransactionHistoryPage({super.key}); // ✅ const fixed

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F8E9),
      appBar: AppBar(
        title: const Text("Transaction History"),
        backgroundColor: Colors.indigo,
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: const [
          _TransactionCard(
            orderId: "#ORD101",
            amount: "₹1,200",
            type: "Credited",
            date: "12 Aug 2026",
          ),
          _TransactionCard(
            orderId: "#ORD102",
            amount: "₹450",
            type: "Credited",
            date: "13 Aug 2026",
          ),
          _TransactionCard(
            orderId: "#ORD103",
            amount: "₹300",
            type: "Debited",
            date: "14 Aug 2026",
          ),
        ],
      ),
    );
  }
}

// 💳 TRANSACTION CARD
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
    final bool isCredit = type == "Credited";

    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isCredit
              ? Colors.green.shade100
              : Colors.red.shade100,
          child: Icon(
            isCredit ? Icons.arrow_downward : Icons.arrow_upward,
            color: isCredit ? Colors.green : Colors.red,
          ),
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
              style: TextStyle(
                color: isCredit ? Colors.green : Colors.red,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            Text(
              type,
              style: TextStyle(
                color: isCredit ? Colors.green : Colors.red,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
