// ignore_for_file: use_build_context_synchronously, unused_import

import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();

  String? _base64Image;
  bool _loading = true;

  final user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final doc = await FirebaseFirestore.instance
        .collection('customers')
        .doc(user!.uid)
        .get();

    final data = doc.data() ?? {};

    _nameController.text = data['name'] ?? '';
    _phoneController.text = data['phone'] ?? '';
    _base64Image = data['imageBase64'];

    setState(() => _loading = false);
  }

  // 📷 PICK IMAGE
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image == null) return;

    final bytes = await image.readAsBytes();
    setState(() => _base64Image = base64Encode(bytes));
  }

  // 💾 SAVE PROFILE
  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    await FirebaseFirestore.instance
        .collection('customers')
        .doc(user!.uid)
        .update({
          'name': _nameController.text.trim(),
          'phone': _phoneController.text.trim(),
          'imageBase64': _base64Image,
          'updatedAt': FieldValue.serverTimestamp(),
        });

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text("Edit Profile"),
        backgroundColor: Colors.blue,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // 👤 IMAGE
              Stack(
                children: [
                  CircleAvatar(
                    radius: 55,
                    backgroundColor: Colors.blue,
                    backgroundImage: _base64Image != null
                        ? MemoryImage(base64Decode(_base64Image!))
                        : null,
                    child: _base64Image == null
                        ? const Icon(
                            Icons.person,
                            size: 55,
                            color: Colors.white,
                          )
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: CircleAvatar(
                      backgroundColor: Colors.white,
                      child: IconButton(
                        icon: const Icon(Icons.camera_alt, color: Colors.blue),
                        onPressed: _pickImage,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 25),

              // NAME
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: "Full Name",
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v!.isEmpty ? "Enter name" : null,
              ),

              const SizedBox(height: 15),

              // EMAIL (READ ONLY)
              TextFormField(
                initialValue: user!.email,
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: "Email",
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 15),

              // PHONE
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: "Phone",
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v!.length < 10 ? "Enter valid phone" : null,
              ),

              const SizedBox(height: 30),

              // SAVE
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _saveProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text("Save Changes"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
