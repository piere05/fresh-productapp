import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// LOGIN PAGES
import '../admin/admin_login_page.dart';
import '../farmer/farmer_login_page.dart';
import '../customer/customer_login_page.dart';

// DASHBOARDS
import '../admin/admin_dashboard_page.dart';
import '../farmer/farmer_dashboard_page.dart';
import '../customer/customer_dashboard_page.dart';

class RoleSelectionPage extends StatefulWidget {
  const RoleSelectionPage({super.key});

  @override
  State<RoleSelectionPage> createState() => _RoleSelectionPageState();
}

class _RoleSelectionPageState extends State<RoleSelectionPage> {
  bool _checkingSession = true;

  @override
  void initState() {
    super.initState();
    _checkSavedLogin();
  }

  Future<void> _checkSavedLogin() async {
    final prefs = await SharedPreferences.getInstance();

    final role = prefs.getString('role');
    final email = prefs.getString('userEmail');

    if (role != null && email != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;

        Widget target;

        switch (role) {
          case 'admin':
            target = const AdminDashboardPage();
            break;
          case 'farmer':
            target = const FarmerDashboardPage();
            break;
          case 'customer':
            target = const CustomerDashboardPage();
            break;
          default:
            return;
        }

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => target),
        );
      });
    } else {
      if (mounted) {
        setState(() => _checkingSession = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_checkingSession) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF1F8E9),
      body: Center(
        child: Container(
          margin: const EdgeInsets.all(20),
          padding: const EdgeInsets.all(25),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(25),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(25),
                decoration: const BoxDecoration(
                  color: Color(0xFF69F0AE),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.agriculture,
                  size: 50,
                  color: Colors.green,
                ),
              ),

              const SizedBox(height: 20),

              const Text(
                "Fresh Products App",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),

              const SizedBox(height: 5),

              const Text(
                "Select Your Role",
                style: TextStyle(color: Colors.grey),
              ),

              const SizedBox(height: 25),

              RoleButton(
                text: "Admin",
                icon: Icons.admin_panel_settings,
                color: Colors.redAccent,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AdminLoginPage()),
                  );
                },
              ),

              const SizedBox(height: 15),

              RoleButton(
                text: "Farmer",
                icon: Icons.agriculture,
                color: Colors.green,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const FarmerLoginPage()),
                  );
                },
              ),

              const SizedBox(height: 15),

              RoleButton(
                text: "Customer",
                icon: Icons.shopping_cart,
                color: Colors.blue,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const CustomerLoginPage(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// 🔘 ROLE BUTTON WIDGET
class RoleButton extends StatelessWidget {
  final String text;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const RoleButton({
    super.key,
    required this.text,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, color: Colors.white),
        label: Text(text, style: const TextStyle(fontSize: 16)),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
      ),
    );
  }
}
