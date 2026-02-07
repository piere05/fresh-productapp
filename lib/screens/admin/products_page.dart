import 'package:flutter/material.dart';
import 'add_product_page.dart';

class ProductsPage extends StatefulWidget {
  const ProductsPage({super.key});

  @override
  State<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  final List<Map<String, String>> _products = [
    {
      "name": "Tomatoes",
      "category": "Vegetables",
      "price": "₹40 / kg",
      "stock": "In Stock",
    },
    {
      "name": "Onions",
      "category": "Vegetables",
      "price": "₹30 / kg",
      "stock": "Out of Stock",
    },
    {
      "name": "Apples",
      "category": "Fruits",
      "price": "₹120 / kg",
      "stock": "In Stock",
    },
  ];

  String _search = "";

  @override
  Widget build(BuildContext context) {
    final filteredProducts = _products.where((product) {
      return product["name"]!.toLowerCase().contains(_search.toLowerCase());
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Products"),
        backgroundColor: Colors.orange,
        centerTitle: true,
      ),

      // ADD PRODUCT
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.orange,
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => AddProductPage()),
          );
        },
      ),

      body: Column(
        children: [
          // SEARCH
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              onChanged: (value) => setState(() => _search = value),
              decoration: InputDecoration(
                hintText: "Search products...",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.grey.shade200,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // LIST
          Expanded(
            child: filteredProducts.isEmpty
                ? const Center(child: Text("No products found"))
                : ListView.builder(
                    itemCount: filteredProducts.length,
                    itemBuilder: (context, index) {
                      final product = filteredProducts[index];
                      final actualIndex = _products.indexOf(
                        product,
                      ); // important

                      return _productCard(
                        name: product["name"]!,
                        category: product["category"]!,
                        price: product["price"]!,
                        stock: product["stock"]!,
                        onEdit: () => _editProduct(actualIndex),
                        onDelete: () => _deleteProduct(actualIndex),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  // PRODUCT CARD
  Widget _productCard({
    required String name,
    required String category,
    required String price,
    required String stock,
    required VoidCallback onEdit,
    required VoidCallback onDelete,
  }) {
    final bool inStock = stock == "In Stock";

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: const Icon(Icons.shopping_bag, color: Colors.orange),
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text("Category: $category\nPrice: $price"),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              stock,
              style: TextStyle(
                color: inStock ? Colors.green : Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, size: 18, color: Colors.blue),
                  onPressed: onEdit,
                ),
                IconButton(
                  icon: const Icon(Icons.delete, size: 18, color: Colors.red),
                  onPressed: onDelete,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ✏️ EDIT PRODUCT (REAL)
  void _editProduct(int index) {
    final nameCtrl = TextEditingController(text: _products[index]["name"]);
    final categoryCtrl = TextEditingController(
      text: _products[index]["category"],
    );
    final priceCtrl = TextEditingController(text: _products[index]["price"]);
    String stock = _products[index]["stock"]!;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Edit Product"),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: "Product Name"),
              ),
              TextField(
                controller: categoryCtrl,
                decoration: const InputDecoration(labelText: "Category"),
              ),
              TextField(
                controller: priceCtrl,
                decoration: const InputDecoration(labelText: "Price"),
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                initialValue: stock,
                items: const [
                  DropdownMenuItem(value: "In Stock", child: Text("In Stock")),
                  DropdownMenuItem(
                    value: "Out of Stock",
                    child: Text("Out of Stock"),
                  ),
                ],
                onChanged: (value) => stock = value!,
                decoration: const InputDecoration(labelText: "Stock Status"),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _products[index] = {
                  "name": nameCtrl.text,
                  "category": categoryCtrl.text,
                  "price": priceCtrl.text,
                  "stock": stock,
                };
              });
              Navigator.pop(context);
            },
            child: const Text("Update"),
          ),
        ],
      ),
    );
  }

  // 🗑 DELETE PRODUCT
  void _deleteProduct(int index) {
    setState(() => _products.removeAt(index));
  }
}
