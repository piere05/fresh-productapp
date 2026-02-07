import 'package:flutter/material.dart';

class StockManagementPage extends StatefulWidget {
  const StockManagementPage({super.key});

  @override
  State<StockManagementPage> createState() => _StockManagementPageState();
}

class _StockManagementPageState extends State<StockManagementPage> {
  String _search = "";

  // 📦 DEMO STOCK DATA (Frontend only)
  final List<Map<String, dynamic>> _stocks = [
    {"name": "Tomatoes", "qty": 5, "unit": "kg"},
    {"name": "Onions", "qty": 25, "unit": "kg"},
    {"name": "Apples", "qty": 8, "unit": "kg"},
    {"name": "Potatoes", "qty": 40, "unit": "kg"},
  ];

  @override
  Widget build(BuildContext context) {
    final filteredStock = _stocks.where((item) {
      return item["name"].toString().toLowerCase().contains(
        _search.toLowerCase(),
      );
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF1F8E9),
      appBar: AppBar(
        title: const Text("Stock Management"),
        backgroundColor: Colors.green,
        centerTitle: true,
      ),
      body: Column(
        children: [
          // 🔍 SEARCH BAR
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              onChanged: (value) {
                setState(() => _search = value);
              },
              decoration: InputDecoration(
                hintText: "Search products...",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // 📦 STOCK LIST
          Expanded(
            child: filteredStock.isEmpty
                ? const Center(
                    child: Text(
                      "No products found",
                      style: TextStyle(fontSize: 16),
                    ),
                  )
                : ListView.builder(
                    itemCount: filteredStock.length,
                    itemBuilder: (context, index) {
                      final item = filteredStock[index];
                      final int qty = item["qty"];
                      final bool lowStock = qty <= 10;

                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: lowStock
                                ? Colors.red.shade100
                                : Colors.green.shade100,
                            child: Icon(
                              Icons.inventory,
                              color: lowStock ? Colors.red : Colors.green,
                            ),
                          ),
                          title: Text(
                            item["name"],
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text("Quantity: $qty ${item["unit"]}"),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                lowStock ? "Low Stock" : "Available",
                                style: TextStyle(
                                  color: lowStock ? Colors.red : Colors.green,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(
                                      Icons.remove,
                                      color: Colors.orange,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        if (item["qty"] > 0) {
                                          item["qty"]--;
                                        }
                                      });
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.add,
                                      color: Colors.green,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        item["qty"]++;
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
