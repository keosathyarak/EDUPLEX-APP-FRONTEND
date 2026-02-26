import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../routes/app_router.dart';
import '../../routes/app_routes.dart';
import '../../core/api/auth_api.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool obscurePassword = true;
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            // ================= MAIN CONTENT =================
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),

                // ===== BACK BUTTON =====
                IconButton(
                  onPressed: isLoading ? null : () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back),
                ),

                const SizedBox(height: 20),

                // ===== LOGO (LEFT) =====
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Image.asset(
                        'assets/icon/logologin.png',
                        height: 70,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        "EduPlex",
                        style: theme.textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Ignite Your Learning Journey",
                        style: theme.textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // ===== FULL HEIGHT LOGIN FORM =====
                Expanded(
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: const BoxDecoration(
                      color: Color(0xFFDDEBC0),
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(24),
                      ),
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Center(
                            child: Text(
                              "Login",
                              style: theme.textTheme.titleLarge
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                          ),

                          const SizedBox(height: 24),

                          // ===== EMAIL =====
                          _inputField(
                            controller: emailController,
                            hint: "Email",
                            icon: Icons.person,
                          ),

                          const SizedBox(height: 16),

                          // ===== PASSWORD =====
                          _inputField(
                            controller: passwordController,
                            hint: "Password",
                            icon: Icons.key,
                            obscureText: obscurePassword,
                            suffixIcon: IconButton(
                              icon: Icon(
                                obscurePassword
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                              ),
                              onPressed: () {
                                setState(() {
                                  obscurePassword = !obscurePassword;
                                });
                              },
                            ),
                          ),

                          const SizedBox(height: 8),

                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: isLoading ? null : () {},
                              child: const Text(
                                "Forgot Password",
                                style: TextStyle(color: Colors.deepPurple),
                              ),
                            ),
                          ),

                          const SizedBox(height: 12),

                          // ===== LOGIN BUTTON =====
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.black,
                              padding:
                              const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            onPressed: isLoading ? null : _handleLogin,
                            child: const Text("Login"),
                          ),

                          const SizedBox(height: 24),

                          // ===== LOGIN WITH =====
                          Row(
                            children: const [
                              Expanded(child: Divider()),
                              Padding(
                                padding:
                                EdgeInsets.symmetric(horizontal: 8),
                                child: Text("Login with"),
                              ),
                              Expanded(child: Divider()),
                            ],
                          ),

                          const SizedBox(height: 16),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _socialIcon(Icons.facebook, Colors.blue),
                              const SizedBox(width: 16),
                              _socialIcon(Icons.g_mobiledata, Colors.red),
                            ],
                          ),

                          const SizedBox(height: 40),

                          // ===== CREATE ACCOUNT =====
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text("Don’t have an account? "),
                              GestureDetector(
                                onTap: isLoading
                                    ? null
                                    : () {
                                  Navigator.pushNamed(
                                    context,
                                    AppRoutes.register,
                                  );
                                },
                                child: const Text(
                                  "Create new",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // ================= FULL PAGE LOADING =================
            if (isLoading)
              Positioned.fill(
                child: Container(
                  color: Colors.white.withOpacity(0.7),
                  child: const Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ================= LOGIN HANDLER (REAL API) =================
  Future<void> _handleLogin() async {
    if (emailController.text.trim().isEmpty ||
        passwordController.text.isEmpty) {
      _showMessage("Email and password are required");
      return;
    }

    setState(() => isLoading = true);

    try {
      final result = await AuthApi.login(
        email: emailController.text.trim(),
        password: passwordController.text,
      );

      if (!mounted) return;

      setState(() => isLoading = false);

      final body = result["body"];

      if (result["status"] == 200 && body["success"] == true) {
        final token = body["token"];
        final user = body["user"];

        final prefs = await SharedPreferences.getInstance();

        await prefs.setString("token", token ?? "");
        await prefs.setString("name", user?["name"] ?? "");
        await prefs.setString("email", user?["email"] ?? "");
        await prefs.setString("avatar", user?["avatar"] ?? "");

        Navigator.pushReplacementNamed(
          context,
          AppRoutes.home,
        );
      } else {
        _showMessage(
          body["message"] ?? "Invalid email or password",
        );
      }
    } catch (e) {
      if (!mounted) return;

      setState(() => isLoading = false);
      _showMessage("Network error. Please try again.");
    }
  }

  // ================= INPUT FIELD =================
  Widget _inputField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscureText = false,
    Widget? suffixIcon,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      enabled: !isLoading,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: Colors.white,
        contentPadding:
        const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  // ================= SOCIAL ICON =================
  Widget _socialIcon(IconData icon, Color color) {
    return CircleAvatar(
      radius: 22,
      backgroundColor: Colors.white,
      child: Icon(icon, color: color, size: 28),
    );
  }

  // ================= MESSAGE =================
  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
