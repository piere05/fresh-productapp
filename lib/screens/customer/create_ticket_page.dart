// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CreateTicketPage extends StatefulWidget {
  final String orderId;

  const CreateTicketPage({super.key, required this.orderId});

  @override
  State<CreateTicketPage> createState() => _CreateTicketPageState();
}

class _CreateTicketPageState extends State<CreateTicketPage> {
  final _formKey = GlobalKey<FormState>();
  final _subject = TextEditingController();
  final _description = TextEditingController();

  final user = FirebaseAuth.instance.currentUser;

  Future<void> _submitTicket() async {
    if (!_formKey.currentState!.validate()) return;
    if (user == null) return;

    final firestore = FirebaseFirestore.instance;

    // ================= CUSTOMER =================
    final customerSnap = await firestore
        .collection('customers')
        .doc(user!.uid)
        .get();

    String customerName = '';
    if (customerSnap.exists) {
      final data = customerSnap.data();
      if (data != null && data['name'] != null) {
        customerName = data['name'];
      }
    }

    // ================= ORDER / FARMER =================
    final orderSnap = await firestore
        .collection('orders')
        .doc(widget.orderId)
        .get();

    String farmerEmail = '';

    if (orderSnap.exists) {
      final orderData = orderSnap.data();
      if (orderData != null && orderData['products'] != null) {
        final products = List<Map<String, dynamic>>.from(orderData['products']);
        if (products.isNotEmpty && products.first['addedBy'] != null) {
          farmerEmail = products.first['addedBy'];
        }
      }
    }

    // ================= CREATE TICKET =================
    await firestore.collection('tickets').add({
      'orderId': widget.orderId,
      'subject': _subject.text.trim(),
      'description': _description.text.trim(),
      'userEmail': user!.email,
      'customerName': customerName,
      'addedBy': farmerEmail, // farmer email
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Support ticket created")));

    Navigator.pop(context);
  }

  @override
  void dispose() {
    _subject.dispose();
    _description.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Create Support Ticket"),
        backgroundColor: Colors.orange,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _subject,
                decoration: const InputDecoration(
                  labelText: "Subject",
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v!.isEmpty ? "Enter subject" : null,
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: _description,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: "Description",
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v!.isEmpty ? "Enter description" : null,
              ),
              const SizedBox(height: 25),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _submitTicket,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                  ),
                  child: const Text("Submit Ticket"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
