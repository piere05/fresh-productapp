// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'add_address_page.dart';
import 'order_placed_page.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  String _selectedPayment = "COD";
  String? _selectedAddressId;

  final user = FirebaseAuth.instance.currentUser;
  static const int deliveryFee = 50;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text("Checkout"),
        backgroundColor: Colors.blue,
        centerTitle: true,
      ),
      body: user == null
          ? const Center(child: Text("Please login"))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _addressSection(),
                  const SizedBox(height: 15),
                  _orderSummarySection(),
                  const SizedBox(height: 15),
                  _paymentSection(),
                  const SizedBox(height: 25),
                  _placeOrderButton(),
                ],
              ),
            ),
    );
  }

  // ===================== ADDRESS SECTION =====================
  Widget _addressSection() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('customers')
          .doc(user!.uid)
          .collection('addresses')
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return _card(
            "Delivery Address",
            const Center(child: CircularProgressIndicator()),
          );
        }

        final docs = snapshot.data!.docs;

        // ✅ FIX: AUTO SELECT FIRST ADDRESS WITH setState
        if (_selectedAddressId == null && docs.isNotEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              setState(() {
                _selectedAddressId = docs.first.id;
              });
            }
          });
        }

        return _card(
          "Delivery Address",
          Column(
            children: [
              if (docs.isEmpty) const Text("No address found"),
              ...docs.map((doc) {
                final d = doc.data() as Map<String, dynamic>;
                return RadioListTile(
                  value: doc.id,
                  groupValue: _selectedAddressId,
                  onChanged: (v) =>
                      setState(() => _selectedAddressId = v.toString()),
                  title: Text(
                    d['name'],
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    "${d['address']}\n${d['city']} - ${d['pincode']}\n📞 ${d['phone']}",
                  ),
                  isThreeLine: true,
                );
              }),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.add_location_alt),
                  label: const Text("Add New Address"),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AddAddressPage()),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ===================== ORDER SUMMARY =====================
  Widget _orderSummarySection() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('cart')
          .where('userEmail', isEqualTo: user!.email)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return _card(
            "Order Summary",
            const Center(child: CircularProgressIndicator()),
          );
        }

        int totalQty = 0;
        int itemsTotal = 0;

        for (var d in snapshot.data!.docs) {
          final int qty = (d['qty'] as num).toInt();
          final int price = (d['price'] as num).toInt();
          totalQty += qty;
          itemsTotal += qty * price;
        }

        final int grandTotal = itemsTotal + deliveryFee;

        return _card(
          "Order Summary",
          Column(
            children: [
              ...snapshot.data!.docs.map(
                (d) => _row(
                  "${d['productName']} (x${d['qty']})",
                  "₹${(d['qty'] as num).toInt() * (d['price'] as num).toInt()}",
                ),
              ),
              const Divider(),
              _row("Total Items", "$totalQty"),
              _row("Items Total", "₹$itemsTotal"),
              _row("Delivery Fee", "₹$deliveryFee"),
              const Divider(),
              _row("Grand Total", "₹$grandTotal", bold: true),
            ],
          ),
        );
      },
    );
  }

  // ===================== PAYMENT =====================
  Widget _paymentSection() {
    return _card(
      "Payment Method",
      Column(
        children: [
          RadioListTile(
            value: "COD",
            groupValue: _selectedPayment,
            title: const Text("Cash on Delivery"),
            onChanged: (v) => setState(() => _selectedPayment = v.toString()),
          ),
          RadioListTile(
            value: "UPI",
            groupValue: _selectedPayment,
            title: const Text("UPI / Online Payment"),
            onChanged: (v) => setState(() => _selectedPayment = v.toString()),
          ),
        ],
      ),
    );
  }

  // ===================== PLACE ORDER =====================
  Widget _placeOrderButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton.icon(
        icon: const Icon(Icons.check_circle),
        label: const Text("Place Order", style: TextStyle(fontSize: 16)),
        style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
        onPressed: _selectedAddressId == null ? null : _placeOrder,
      ),
    );
  }

  // ===================== ORDER SAVE (UNCHANGED) =====================
  Future<void> _placeOrder() async {
    final firestore = FirebaseFirestore.instance;

    final cartSnap = await firestore
        .collection('cart')
        .where('userEmail', isEqualTo: user!.email)
        .get();

    final addressDoc = await firestore
        .collection('customers')
        .doc(user!.uid)
        .collection('addresses')
        .doc(_selectedAddressId)
        .get();

    if (cartSnap.docs.isEmpty) return;

    await firestore.runTransaction((transaction) async {
      int itemsTotal = 0;
      int totalQty = 0;
      final products = <Map<String, dynamic>>[];

      for (int i = 0; i < cartSnap.docs.length; i++) {
        final cartDoc = cartSnap.docs[i];
        final data = cartDoc.data();

        final qty = (data['qty'] as num).toInt();
        final price = (data['price'] as num).toInt();
        final total = qty * price;

        totalQty += qty;
        itemsTotal += total;

        final productRef = firestore
            .collection('products')
            .doc(data['productId']);
        final productSnap = await transaction.get(productRef);
        final productData = productSnap.data() as Map<String, dynamic>;

        int stock = (productData['currentStock'] as num).toInt();
        int updatedStock = stock - qty;
        if (updatedStock < 0) updatedStock = 0;

        transaction.update(productRef, {
          'currentStock': updatedStock,
          'inStock': updatedStock > 0,
        });

        products.add({
          'sno': i + 1,
          'productId': data['productId'],
          'productName': data['productName'],
          'qty': qty,
          'price': price,
          'total': total,
          'addedBy': data['addedBy'],
        });
      }

      final orderRef = firestore.collection('orders').doc();

      transaction.set(orderRef, {
        'orderBy': user!.email,
        'paymentMethod': _selectedPayment,
        'status': 'placed',
        'totalItems': totalQty,
        'itemsTotal': itemsTotal,
        'deliveryFee': deliveryFee,
        'grandTotal': itemsTotal + deliveryFee,
        'deliveryAddress': addressDoc.data(),
        'products': products,
        'createdAt': FieldValue.serverTimestamp(),
      });

      for (final d in cartSnap.docs) {
        transaction.delete(d.reference);
      }
    });

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const OrderPlacedPage()),
      (_) => false,
    );
  }

  // ===================== HELPERS =====================
  Widget _card(String title, Widget child) {
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

  Widget _row(String l, String r, {bool bold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(l, style: TextStyle(fontWeight: bold ? FontWeight.bold : null)),
        Text(r, style: TextStyle(fontWeight: bold ? FontWeight.bold : null)),
      ],
    );
  }
}
