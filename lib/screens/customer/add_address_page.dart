// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddAddressPage extends StatefulWidget {
  final String? addressId;
  final Map<String, dynamic>? addressData;

  const AddAddressPage({super.key, this.addressId, this.addressData});

  @override
  State<AddAddressPage> createState() => _AddAddressPageState();
}

class _AddAddressPageState extends State<AddAddressPage> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _pincodeController = TextEditingController();

  bool _loading = false;

  @override
  void initState() {
    super.initState();

    // ✏️ EDIT MODE PREFILL
    if (widget.addressData != null) {
      _nameController.text = widget.addressData!['name'] ?? '';
      _phoneController.text = widget.addressData!['phone'] ?? '';
      _addressController.text = widget.addressData!['address'] ?? '';
      _cityController.text = widget.addressData!['city'] ?? '';
      _pincodeController.text = widget.addressData!['pincode'] ?? '';
    }
  }

  Future<void> _saveAddress() async {
    if (!_formKey.currentState!.validate()) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() => _loading = true);

    try {
      final addressRef = FirebaseFirestore.instance
          .collection('customers')
          .doc(user.uid)
          .collection('addresses');

      if (widget.addressId == null) {
        // ➕ ADD MODE
        final existing = await addressRef.get();

        await addressRef.add({
          'name': _nameController.text.trim(),
          'phone': _phoneController.text.trim(),
          'address': _addressController.text.trim(),
          'city': _cityController.text.trim(),
          'pincode': _pincodeController.text.trim(),
          'isDefault': existing.docs.isEmpty,
          'createdAt': FieldValue.serverTimestamp(),
        });

        _showSnack("Address added successfully");
      } else {
        // ✏️ EDIT MODE
        await addressRef.doc(widget.addressId).update({
          'name': _nameController.text.trim(),
          'phone': _phoneController.text.trim(),
          'address': _addressController.text.trim(),
          'city': _cityController.text.trim(),
          'pincode': _pincodeController.text.trim(),
          'updatedAt': FieldValue.serverTimestamp(),
        });

        _showSnack("Address updated successfully");
      }

      Navigator.pop(context);
    } catch (e) {
      _showSnack("Failed to save address");
    } finally {
      setState(() => _loading = false);
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _pincodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.addressId != null;

    return Scaffold(
      backgroundColor: const Color(0xFFE3F2FD),
      appBar: AppBar(
        title: Text(isEdit ? "Edit Address" : "Add Address"),
        backgroundColor: Colors.blue,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _field(
                controller: _nameController,
                label: "Full Name",
                icon: Icons.person,
                validator: (v) => v!.isEmpty ? "Enter full name" : null,
              ),
              const SizedBox(height: 15),

              _field(
                controller: _phoneController,
                label: "Phone Number",
                icon: Icons.phone,
                keyboard: TextInputType.phone,
                validator: (v) =>
                    v!.length < 10 ? "Enter valid phone number" : null,
              ),
              const SizedBox(height: 15),

              _field(
                controller: _addressController,
                label: "Address",
                icon: Icons.home,
                maxLines: 3,
                validator: (v) => v!.isEmpty ? "Enter address" : null,
              ),
              const SizedBox(height: 15),

              _field(
                controller: _cityController,
                label: "City",
                icon: Icons.location_city,
                validator: (v) => v!.isEmpty ? "Enter city" : null,
              ),
              const SizedBox(height: 15),

              _field(
                controller: _pincodeController,
                label: "Pincode",
                icon: Icons.markunread_mailbox,
                keyboard: TextInputType.number,
                validator: (v) => v!.length < 6 ? "Enter valid pincode" : null,
              ),
              const SizedBox(height: 25),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.save),
                  label: _loading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          isEdit ? "Update Address" : "Save Address",
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: _loading ? null : _saveAddress,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 🔹 INPUT FIELD
  Widget _field({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboard = TextInputType.text,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboard,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: const OutlineInputBorder(),
      ),
      validator: validator,
    );
  }
}
