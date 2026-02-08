// ignore_for_file: use_build_context_synchronously, deprecated_member_use

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:file_picker/file_picker.dart';

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

  int _currentStock = 0;
  String? _imageBase64;

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

    if (widget.productData != null) {
      final d = widget.productData!;
      _nameController.text = d['name'];
      _priceController.text = d['price'].toString();
      _quantityController.text = d['quantity'].toString();
      _descriptionController.text = d['description'] ?? '';
      _category = d['category'];
      _unit = d['unit'];
      _inStock = d['inStock'];
      _currentStock = d['currentStock'];
      _imageBase64 = d['imageBase64'];
    }
  }

  // ✅ WORKS ON WEB + ANDROID
  Future<void> _pickImage() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true,
    );

    if (result == null) return;
    if (result.files.single.bytes == null) return;

    setState(() {
      _imageBase64 = base64Encode(result.files.single.bytes!);
    });
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

      final baseData = {
        'name': _nameController.text.trim(),
        'category': _category,
        'price': double.parse(_priceController.text.trim()),
        'quantity': double.parse(_quantityController.text.trim()),
        'unit': _unit,
        'description': _descriptionController.text.trim(),
        'imageBase64': _imageBase64,
        'inStock': (_currentStock + addedStock) > 0,
      };

      if (widget.productId == null) {
        await FirebaseFirestore.instance.collection('products').add({
          ...baseData,
          'added_stock': addedStock,
          'currentStock': addedStock,
          'addedBy': user.email,
          'farmerId': user.uid,
          'createdAt': FieldValue.serverTimestamp(),
        });
      } else {
        await FirebaseFirestore.instance
            .collection('products')
            .doc(widget.productId)
            .update({
              ...baseData,
              'currentStock': _currentStock + addedStock,
              'added_stock': FieldValue.increment(addedStock),
            });
      }

      Navigator.pop(context);
    } catch (e) {
      _show("Failed to save product");
    } finally {
      setState(() => _loading = false);
    }
  }

  void _show(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
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
              // 🖼 IMAGE TOP
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 180,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green),
                    color: Colors.grey.shade200,
                  ),
                  child: _imageBase64 == null
                      ? const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.camera_alt,
                                size: 40,
                                color: Colors.green,
                              ),
                              SizedBox(height: 8),
                              Text("Tap to add product image"),
                            ],
                          ),
                        )
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.memory(
                            base64Decode(_imageBase64!),
                            fit: BoxFit.cover,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 20),

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

              TextFormField(
                controller: _addedStockController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Added Stock",
                  prefixIcon: Icon(Icons.inventory),
                  border: OutlineInputBorder(),
                ),
              ),

              if (isEdit)
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Current Stock: $_currentStock",
                      style: const TextStyle(
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
