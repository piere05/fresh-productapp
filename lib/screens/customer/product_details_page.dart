// ignore_for_file: prefer_const_constructors_in_immutables

import 'package:flutter/material.dart';

class ProductDetailsPage extends StatelessWidget {
  ProductDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text("Product Details"),
        backgroundColor: Colors.blue,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🖼 PRODUCT IMAGE (UI DEMO)
            Center(
              child: Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.blue.shade100,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.shopping_bag,
                  size: 100,
                  color: Colors.blue,
                ),
              ),
            ),

            const SizedBox(height: 20),

            // 🏷 PRODUCT NAME
            const Text(
              "Tomatoes",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 6),

            // CATEGORY
            const Chip(
              label: Text("Vegetables"),
              backgroundColor: Color(0xFFD6EAF8),
              labelStyle: TextStyle(color: Colors.blue),
            ),

            const SizedBox(height: 12),

            // 💰 PRICE
            const Text(
              "₹40 / kg",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),

            const SizedBox(height: 10),

            // ⭐ RATING
            Row(
              children: const [
                Icon(Icons.star, color: Colors.orange, size: 20),
                Icon(Icons.star, color: Colors.orange, size: 20),
                Icon(Icons.star, color: Colors.orange, size: 20),
                Icon(Icons.star_half, color: Colors.orange, size: 20),
                Icon(Icons.star_border, color: Colors.orange, size: 20),
                SizedBox(width: 8),
                Text("3.5 / 5"),
              ],
            ),

            const SizedBox(height: 20),

            // 📄 DESCRIPTION
            const Text(
              "Description",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 6),

            const Text(
              "Fresh farm-grown tomatoes harvested daily. "
              "Rich in nutrients and perfect for cooking and salads.",
              style: TextStyle(height: 1.4),
            ),

            const SizedBox(height: 20),

            // 🚚 DELIVERY INFO
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: const ListTile(
                leading: Icon(Icons.local_shipping, color: Colors.blue),
                title: Text("Free Delivery"),
                subtitle: Text("Delivered within 2–3 days"),
              ),
            ),

            const SizedBox(height: 25),

            // 🛒 ACTION BUTTONS
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.shopping_cart),
                    label: const Text("Add to Cart"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      _showSnack(context, "Added to cart (Demo)");
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.favorite_border),
                    label: const Text("Wishlist"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.pink,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      _showSnack(context, "Added to wishlist (Demo)");
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // ⚡ BUY NOW
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  _showSnack(context, "Proceed to checkout (Demo)");
                },
                child: const Text("Buy Now", style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 🔔 SNACKBAR
  void _showSnack(BuildContext context, String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}
