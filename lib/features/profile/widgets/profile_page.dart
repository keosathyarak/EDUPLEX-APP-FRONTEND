import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../routes/app_router.dart';
import '../../../routes/app_routes.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String name = "User";
  String email = "";
  bool isLoggedIn = false;

  static const Color primaryBlue = Color(0xFF3D21F3);

  @override
  void initState() {
    super.initState();
    loadUser();
  }

  Future<void> loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");

    setState(() {
      isLoggedIn = token != null && token.isNotEmpty;

      if (isLoggedIn) {
        name = prefs.getString("name") ?? "User";
        email = prefs.getString("email") ?? "";
      }
    });
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    setState(() {
      isLoggedIn = false;
      name = "Guest";
      email = "";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryBlue,
      body: SafeArea(
        child: Column(
          children: [
            // ================= HEADER =================
            Padding(
              padding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "My Profile",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (isLoggedIn)
                    Row(
                      children: [
                        _circleIcon(Icons.edit),
                        const SizedBox(width: 12),
                        _circleIcon(Icons.notifications_none),
                      ],
                    )
                ],
              ),
            ),

            // ================= BODY =================
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(30),
                  ),
                ),
                child:
                isLoggedIn ? _loggedInUI() : _notLoggedInUI(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= LOGGED IN UI =================
  Widget _loggedInUI() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 50,
                backgroundColor: primaryBlue,
                backgroundImage:
                AssetImage("assets/icon/logologin.png"),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      email,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 30),

          const Text(
            "About",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 10),

          const Text(
            "Welcome to your profile page. "
                "You can manage your personal information here.",
            style: TextStyle(
              height: 1.5,
              color: Colors.black87,
            ),
          ),

          const SizedBox(height: 40),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: logout,
              icon: const Icon(Icons.logout),
              label: const Text("Logout"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding:
                const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================= NOT LOGGED IN UI =================
  Widget _notLoggedInUI() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.person_outline,
            size: 90,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 20),
          const Text(
            "You are not logged in",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Login to access your profile",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: 200,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, AppRoutes.login);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryBlue,
                foregroundColor: Colors.white,
                padding:
                const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius:
                  BorderRadius.circular(30),
                ),
              ),
              child: const Text("Login Now"),
            ),
          ),
        ],
      ),
    );
  }

  // ================= CIRCLE ICON =================
  Widget _circleIcon(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        shape: BoxShape.circle,
      ),
      child: Icon(
        icon,
        color: Colors.white,
      ),
    );
  }
}