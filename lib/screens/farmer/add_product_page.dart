// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddProductPage extends StatefulWidget {
  final String? productId;
  final Map<String, dynamic>? productData;

  const AddProductPage({super.key, this.productId, this.productData});

  @override
  State<AddProductPage> createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _quantityController = TextEditingController();
  final _addedStockController = TextEditingController();
  final _descriptionController = TextEditingController();

  String _category = "Vegetables";
  String _unit = "kg";
  bool _inStock = true;
  bool _loading = false;

  int _currentStock = 0; // ✅ ONLY FOR EDIT MODE

  final List<String> _categories = [
    "Vegetables",
    "Fruits",
    "Grains",
    "Dairy",
    "Others",
  ];

  final List<String> _units = ["kg", "litre", "piece"];

  @override
  void initState() {
    super.initState();

    // ✅ EDIT MODE PREFILL
    if (widget.productData != null) {
      final d = widget.productData!;
      _nameController.text = d['name'];
      _priceController.text = d['price'].toString();
      _quantityController.text = d['quantity'].toString();
      _descriptionController.text = d['description'] ?? "";
      _category = d['category'];
      _unit = d['unit'];
      _inStock = d['inStock'];
      _currentStock = d['currentStock'];
    }
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        _show("User not logged in");
        return;
      }

      final addedStock = _addedStockController.text.isEmpty
          ? 0
          : int.parse(_addedStockController.text.trim());

      // ✅ ADD PRODUCT
      if (widget.productId == null) {
        await FirebaseFirestore.instance.collection('products').add({
          'name': _nameController.text.trim(),
          'category': _category,
          'price': double.parse(_priceController.text.trim()),
          'quantity': double.parse(_quantityController.text.trim()),
          'unit': _unit,
          'added_stock': addedStock,
          'currentStock': addedStock,
          'description': _descriptionController.text.trim(),
          'inStock': addedStock > 0,
          'addedBy': user.email,
          'farmerId': user.uid,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
      // ✅ EDIT PRODUCT
      else {
        await FirebaseFirestore.instance
            .collection('products')
            .doc(widget.productId)
            .update({
              'name': _nameController.text.trim(),
              'category': _category,
              'price': double.parse(_priceController.text.trim()),
              'quantity': double.parse(_quantityController.text.trim()),
              'unit': _unit,
              'currentStock': _currentStock + addedStock,
              'added_stock': FieldValue.increment(addedStock),
              'description': _descriptionController.text.trim(),
              'inStock': (_currentStock + addedStock) > 0,
            });
      }

      Navigator.pop(context);
    } catch (_) {
      _show("Failed to save product. Please try again.");
    } finally {
      setState(() => _loading = false);
    }
  }

  void _show(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.productId != null;

    return Scaffold(
      backgroundColor: const Color(0xFFF1F8E9),
      appBar: AppBar(
        title: Text(isEdit ? "Edit Product" : "Add Product"),
        backgroundColor: Colors.green,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // ✅ ONLY NEW UI LINE (EDIT MODE)
              if (isEdit)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Text(
                    "Current Stock: $_currentStock",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ),

              // 🔽 EVERYTHING BELOW IS YOUR SAME UI 🔽
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: "Product Name",
                  prefixIcon: Icon(Icons.shopping_bag),
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v!.isEmpty ? "Enter product name" : null,
              ),

              const SizedBox(height: 15),

              DropdownButtonFormField<String>(
                value: _category,
                items: _categories
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (v) => setState(() => _category = v!),
                decoration: const InputDecoration(
                  labelText: "Category",
                  prefixIcon: Icon(Icons.category),
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 15),

              TextFormField(
                controller: _priceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Price",
                  prefixIcon: Icon(Icons.currency_rupee),
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v!.isEmpty || double.tryParse(v) == null
                    ? "Enter valid price"
                    : null,
              ),

              const SizedBox(height: 15),

              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _quantityController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: "Quantity",
                        prefixIcon: Icon(Icons.scale),
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) => v!.isEmpty || double.tryParse(v) == null
                          ? "Enter valid quantity"
                          : null,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _unit,
                      items: _units
                          .map(
                            (u) => DropdownMenuItem(value: u, child: Text(u)),
                          )
                          .toList(),
                      onChanged: (v) => setState(() => _unit = v!),
                      decoration: const InputDecoration(
                        labelText: "Unit",
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 15),

              // ✅ SAME FIELD – NOW USED FOR INCREMENT
              TextFormField(
                controller: _addedStockController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Added Stock",
                  prefixIcon: Icon(Icons.inventory),
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v!.isNotEmpty && int.tryParse(v) == null
                    ? "Enter valid stock quantity"
                    : null,
              ),
              if (widget.productId != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Current Stock: $_currentStock",
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 15),

              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: "Description",
                  prefixIcon: Icon(Icons.description),
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 10),

              SwitchListTile(
                title: const Text("In Stock"),
                value: _inStock,
                onChanged: (v) => setState(() => _inStock = v),
              ),

              const SizedBox(height: 25),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.save),
                  label: _loading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(isEdit ? "Update Product" : "Add Product"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: _loading ? null : _saveProduct,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
