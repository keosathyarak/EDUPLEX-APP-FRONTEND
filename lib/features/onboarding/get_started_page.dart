import 'dart:async';
import 'package:flutter/material.dart';
import '../../routes/app_router.dart';
import '../../routes/app_routes.dart';

class GetStartedPage extends StatefulWidget {
  const GetStartedPage({super.key});

  @override
  State<GetStartedPage> createState() => _GetStartedPageState();
}

class _GetStartedPageState extends State<GetStartedPage>
    with SingleTickerProviderStateMixin {
  bool _isLoading = false;
  late AnimationController _fadeController;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
  }

  void _onGetStarted() {
    if (_isLoading) return;

    setState(() => _isLoading = true);
    _fadeController.forward();

    Timer(const Duration(milliseconds: 2000), () {
      Navigator.pushReplacementNamed(context, AppRoutes.home);
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // ===== BACKGROUND IMAGE =====
          Positioned.fill(
            child: Image.asset(
              'assets/images/loading.png',
              fit: BoxFit.cover,
            ),
          ),

          // ===== DARK OVERLAY =====
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.45),
            ),
          ),

          // ===== MAIN CONTENT =====
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Spacer(),

                  const Text(
                    "Improve your\nskill with",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 6),

                  const Text(
                    "E-Learning",
                    style: TextStyle(
                      color: Color(0xFF8BC34A),
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 12),

                  const Text(
                    "E-learning is learning through the internet\n"
                        "using digital tools, allowing students to\n"
                        "study anytime and anywhere.",
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),

                  const SizedBox(height: 30),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _onGetStarted,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: const Text("Get Started"),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ===== FULL SCREEN LOADING =====
          if (_isLoading)
            FadeTransition(
              opacity: _fadeController,
              child: Container(
                color: Colors.black.withOpacity(0.9),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      SizedBox(
                        width: 42,
                        height: 42,
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          color: Color(0xFF8BC34A),
                        ),
                      ),
                      SizedBox(height: 16),
                      Text(
                        "Loading...",
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                          letterSpacing: 1.1,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
