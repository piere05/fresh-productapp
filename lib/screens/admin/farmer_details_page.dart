import 'package:flutter/material.dart';

class FarmerDetailsPage extends StatefulWidget {
  const FarmerDetailsPage({super.key}); // NOT const

  @override
  State<FarmerDetailsPage> createState() => _FarmerDetailsPageState();
}

class _FarmerDetailsPageState extends State<FarmerDetailsPage> {
  String _status = "Pending"; // Pending | Approved | Blocked

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8F5E9),
      appBar: AppBar(
        title: const Text("Farmer Details"),
        backgroundColor: Colors.green,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 👨‍🌾 FARMER PROFILE CARD
            Card(
              elevation: 6,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 45,
                      backgroundColor: Colors.green,
                      child: const Icon(
                        Icons.agriculture,
                        size: 45,
                        color: Colors.white,
                      ),
                    ),

                    const SizedBox(height: 15),

                    const Text(
                      "Ramesh Kumar",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 5),

                    const Text(
                      "ramesh@farmer.com",
                      style: TextStyle(color: Colors.grey),
                    ),

                    const SizedBox(height: 10),

                    // STATUS BADGE
                    Chip(
                      label: Text(
                        _status,
                        style: const TextStyle(color: Colors.white),
                      ),
                      backgroundColor: _status == "Approved"
                          ? Colors.green
                          : _status == "Blocked"
                          ? Colors.red
                          : Colors.orange,
                    ),

                    const SizedBox(height: 15),

                    _infoRow(Icons.phone, "Phone", "+91 98765 43210"),
                    _infoRow(
                      Icons.location_on,
                      "Location",
                      "Coimbatore, Tamil Nadu",
                    ),
                    _infoRow(Icons.eco, "Farm Type", "Organic"),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 25),

            // 🔘 APPROVE / REJECT BUTTONS
            if (_status == "Pending")
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.check_circle),
                      label: const Text("Approve"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        setState(() {
                          _status = "Approved";
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.cancel),
                      label: const Text("Reject"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        setState(() {
                          _status = "Blocked";
                        });
                      },
                    ),
                  ),
                ],
              ),

            if (_status == "Approved") const SizedBox(height: 10),

            // 📦 VIEW PRODUCTS
            if (_status == "Approved")
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.inventory),
                  label: const Text("View Products"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueGrey,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    _showInfo(context, "Farmer Products (Demo)");
                  },
                ),
              ),

            const SizedBox(height: 10),

            // 🚫 BLOCK / UNBLOCK
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: Icon(
                  _status == "Blocked" ? Icons.lock_open : Icons.block,
                ),
                label: Text(
                  _status == "Blocked" ? "Unblock Farmer" : "Block Farmer",
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _status == "Blocked"
                      ? Colors.green
                      : Colors.red,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () => _confirmBlock(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ℹ️ INFO ROW
  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.green),
          const SizedBox(width: 10),
          Text("$label: ", style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  // ℹ️ INFO DIALOG
  void _showInfo(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Info"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  // 🚫 BLOCK / UNBLOCK CONFIRMATION
  void _confirmBlock(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(_status == "Blocked" ? "Unblock Farmer" : "Block Farmer"),
        content: Text(
          _status == "Blocked"
              ? "Do you want to unblock this farmer?"
              : "Are you sure you want to block this farmer?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _status = _status == "Blocked" ? "Approved" : "Blocked";
              });
              Navigator.pop(context);
            },
            child: const Text("Confirm"),
          ),
        ],
      ),
    );
  }
}
