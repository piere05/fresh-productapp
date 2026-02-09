// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

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

  late Razorpay _razorpay;
  int _payableAmount = 0;

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  // ===================== RAZORPAY =====================
  void _openRazorpay(int amount) {
    var options = {
      'key': 'rzp_test_S6S0e6VGPJ5FMo',
      'amount': amount * 100,
      'currency': 'INR',
      'name': 'Fresh Products',
      'description': 'Order Payment',
      'prefill': {'email': user!.email},
      'retry': {'enabled': true, 'max_count': 1},
      'timeout': 120,
    };

    _razorpay.open(options);
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    await _placeOrder(paymentId: response.paymentId);
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Payment Failed"),
        backgroundColor: Colors.red,
      ),
    );
  }

  // ===================== BUILD =====================
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

  // ===================== ADDRESS =====================
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

        if (_selectedAddressId == null && docs.isNotEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              setState(() => _selectedAddressId = docs.first.id);
            }
          });
        }

        return _card(
          "Delivery Address",
          Column(
            children: [
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

  // ===================== SUMMARY =====================
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

        int itemsTotal = 0;

        for (var d in snapshot.data!.docs) {
          itemsTotal += (d['qty'] as num).toInt() * (d['price'] as num).toInt();
        }

        _payableAmount = itemsTotal + deliveryFee;

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
              _row("Items Total", "₹$itemsTotal"),
              _row("Delivery Fee", "₹$deliveryFee"),
              const Divider(),
              _row("Grand Total", "₹$_payableAmount", bold: true),
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
            value: "ONLINE",
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
        onPressed: _selectedAddressId == null
            ? null
            : () {
                if (_selectedPayment == "ONLINE") {
                  _openRazorpay(_payableAmount);
                } else {
                  _placeOrder();
                }
              },
      ),
    );
  }

  // ===================== ORDER SAVE =====================
  Future<void> _placeOrder({String? paymentId}) async {
    final firestore = FirebaseFirestore.instance;

    final cartSnap = await firestore
        .collection('cart')
        .where('userEmail', isEqualTo: user!.email)
        .get();

    final lastOrderSnap = await firestore
        .collection('orders')
        .orderBy('createdAt', descending: true)
        .limit(1)
        .get();

    int nextNumber = 1;
    if (lastOrderSnap.docs.isNotEmpty) {
      final lastId = lastOrderSnap.docs.first.id;
      nextNumber = int.parse(lastId.replaceAll(RegExp(r'[^0-9]'), '')) + 1;
    }

    final orderId = "FRESH${nextNumber.toString().padLeft(3, '0')}";

    final addressDoc = await firestore
        .collection('customers')
        .doc(user!.uid)
        .collection('addresses')
        .doc(_selectedAddressId)
        .get();

    await firestore.runTransaction((tx) async {
      int itemsTotal = 0;
      final products = <Map<String, dynamic>>[];

      for (var d in cartSnap.docs) {
        final int qty = (d['qty'] as num).toInt();
        final int price = (d['price'] as num).toInt();

        itemsTotal += qty * price;

        products.add({
          'productName': d['productName'],
          'qty': qty,
          'price': price,
          'total': qty * price,
          'addedBy': d['addedBy'],
        });

        tx.delete(d.reference);
      }

      tx.set(firestore.collection('orders').doc(orderId), {
        'orderId': orderId,
        'orderBy': user!.email,
        'paymentMethod': _selectedPayment == "ONLINE" ? "Razorpay" : "COD",
        'paymentId': paymentId,
        'status': 'placed',
        'itemsTotal': itemsTotal,
        'deliveryFee': deliveryFee,
        'grandTotal': itemsTotal + deliveryFee,
        'deliveryAddress': addressDoc.data(),
        'products': products,
        'createdAt': Timestamp.now(),
      });
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
