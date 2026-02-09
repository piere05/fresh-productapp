// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'farmer_dashboard_page.dart';
import 'create_farmer_account_page.dart';

class FarmerLoginPage extends StatefulWidget {
  const FarmerLoginPage({super.key});

  @override
  State<FarmerLoginPage> createState() => _FarmerLoginPageState();
}

class _FarmerLoginPageState extends State<FarmerLoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _loading = false;

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  Future<void> _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (!_isValidEmail(email)) {
      _show("Please enter a valid email address");
      return;
    }

    if (password.length < 8) {
      _show("Password must be at least 8 characters");
      return;
    }

    setState(() => _loading = true);

    try {
      // 🔐 Firebase Auth
      final cred = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final uid = cred.user!.uid;

      // 📄 Farmer document
      final doc = await FirebaseFirestore.instance
          .collection('farmers')
          .doc(uid)
          .get();

      if (!doc.exists) {
        await FirebaseAuth.instance.signOut();
        _show("Farmer account not found");
        return;
      }

      final data = doc.data()!;

      // 🚫 Blocked
      if (data['isBlocked'] == true) {
        await FirebaseAuth.instance.signOut();
        _show("Your account has been blocked. Please contact support.");
        return;
      }

      // ⏳ Not approved
      if (data['isApproved'] != true) {
        await FirebaseAuth.instance.signOut();
        _show("Your account is awaiting admin approval");
        return;
      }

      // ✅ Success
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const FarmerDashboardPage()),
      );
    } on FirebaseAuthException catch (e) {
      _handleAuthError(e.code);
    } catch (_) {
      _show("Login failed. Please try again later.");
    } finally {
      setState(() => _loading = false);
    }
  }

  void _handleAuthError(String code) {
    String message;

    switch (code) {
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        message = "Invalid email or password";
        break;
      case 'user-disabled':
        message = "This account has been disabled";
        break;
      case 'too-many-requests':
        message = "Too many attempts. Please try again later";
        break;
      default:
        message = "Login failed. Please try again";
    }

    _show(message);
  }

  void _show(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8F5E9),
      appBar: AppBar(
        title: const Text("Farmer Login"),
        backgroundColor: Colors.green,
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(25),
            margin: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 10,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.agriculture, size: 60, color: Colors.green),
                const SizedBox(height: 15),

                const Text(
                  "Farmer Login",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 25),

                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: "Email",
                    prefixIcon: const Icon(Icons.email),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),

                const SizedBox(height: 15),

                TextField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: "Password",
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                const SizedBox(height: 15),

                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _loading ? null : _login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: _loading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text("Login", style: TextStyle(fontSize: 16)),
                  ),
                ),

                const SizedBox(height: 15),

                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const CreateFarmerAccountPage(),
                      ),
                    );
                  },
                  child: const Text(
                    "Don't have an account? Create Farmer Account",
                    style: TextStyle(color: Colors.green),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
