import 'package:flutter/material.dart';
import '../../routes/app_router.dart';
import '../../routes/app_routes.dart';
import '../../core/api/auth_api.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmController = TextEditingController();

  bool obscurePassword = true;
  bool obscureConfirm = true;
  bool isLoading = false;
  bool agree = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),

                IconButton(
                  onPressed: isLoading ? null : () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back),
                ),

                const SizedBox(height: 20),

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
                        "Create your learning account",
                        style: theme.textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

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
                              "Create Account",
                              style: theme.textTheme.titleLarge
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                          ),

                          const SizedBox(height: 24),

                          _inputField(
                            controller: emailController,
                            hint: "Email",
                            icon: Icons.person,
                          ),

                          const SizedBox(height: 16),

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

                          const SizedBox(height: 16),

                          _inputField(
                            controller: confirmController,
                            hint: "Confirm Password",
                            icon: Icons.key,
                            obscureText: obscureConfirm,
                            suffixIcon: IconButton(
                              icon: Icon(
                                obscureConfirm
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                              ),
                              onPressed: () {
                                setState(() {
                                  obscureConfirm = !obscureConfirm;
                                });
                              },
                            ),
                          ),

                          const SizedBox(height: 12),

                          Row(
                            children: [
                              Checkbox(
                                value: agree,
                                onChanged: (v) {
                                  setState(() {
                                    agree = v!;
                                  });
                                },
                              ),
                              const Text("Agree with "),
                              const Text(
                                "Terms & Conditions",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 16),

                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.black,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            onPressed:
                            isLoading || !agree ? null : _handleRegister,
                            child: const Text("Create Account"),
                          ),

                          const SizedBox(height: 40),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text("Already have an account? "),
                              GestureDetector(
                                onTap:
                                isLoading ? null : () => Navigator.pop(context),
                                child: const Text(
                                  "Login",
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

            if (isLoading)
              Positioned.fill(
                child: Container(
                  color: Colors.white.withOpacity(0.7),
                  child: const Center(
                    child: CircularProgressIndicator(strokeWidth: 3),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // 🔗 API CONNECTED (ONLY LOGIC ADDED)
  Future<void> _handleRegister() async {
    if (passwordController.text != confirmController.text) {
      _showMessage("Passwords do not match");
      return;
    }

    setState(() => isLoading = true);

    try {
      final result = await AuthApi.register(
        email: emailController.text.trim(),
        password: passwordController.text,
        passwordConfirmation: confirmController.text,
      );

      setState(() => isLoading = false);

      if (result["status"] == 201) {
        _showMessage("Account created successfully");
        Navigator.pushReplacementNamed(context, AppRoutes.login);
      } else {
        final errors = result["body"]["errors"];
        _showMessage(errors.values.first[0]);
      }
    } catch (e) {
      setState(() => isLoading = false);
      _showMessage("Server error. Please try again.");
    }
  }
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

  Widget _socialIcon(IconData icon, Color color) {
    return CircleAvatar(
      radius: 22,
      backgroundColor: Colors.white,
      child: Icon(icon, color: color, size: 28),
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
