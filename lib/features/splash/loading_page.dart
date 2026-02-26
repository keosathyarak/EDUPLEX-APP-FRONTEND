import 'dart:async';
import 'package:flutter/material.dart';
import '../../routes/app_router.dart';
import '../../routes/app_routes.dart';

class LoadingPage extends StatefulWidget {
  const LoadingPage({super.key});

  @override
  State<LoadingPage> createState() => _LoadingPageState();
}

class _LoadingPageState extends State<LoadingPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  late Animation<double> _rotateToDiamond;
  late Animation<double> _rotateBack;
  late Animation<double> _scalePulse;
  late Animation<double> _fadeText;
  late Animation<Offset> _slideText;
  late Animation<double> _glow;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    );

    // Rotation
    _rotateToDiamond = Tween<double>(begin: 0, end: 0.125).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.15, 0.45, curve: Curves.easeInOut),
      ),
    );

    _rotateBack = Tween<double>(begin: 0.125, end: 0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.45, 0.75, curve: Curves.easeInOut),
      ),
    );

    // Pulse scale
    _scalePulse = Tween<double>(begin: 0.85, end: 1.05).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.75, curve: Curves.easeInOut),
      ),
    );

    // Glow strength
    _glow = Tween<double>(begin: 0, end: 12).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.5, 0.9, curve: Curves.easeOut),
      ),
    );

    // Text animation
    _fadeText = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.75, 1.0, curve: Curves.easeIn),
      ),
    );

    _slideText = Tween<Offset>(
      begin: const Offset(0, 0.4),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.75, 1.0, curve: Curves.easeOut),
      ),
    );

    _controller.forward();

    Timer(const Duration(milliseconds: 3300), () {
      Navigator.pushReplacementNamed(context, AppRoutes.getStarted);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedBuilder(
              animation: _controller,
              builder: (_, __) {
                final t = _controller.value;

                double turns = 0;
                if (t < 0.45) {
                  turns = _rotateToDiamond.value;
                } else if (t < 0.75) {
                  turns = _rotateBack.value;
                }

                return Transform.scale(
                  scale: _scalePulse.value,
                  child: Transform.rotate(
                    angle: turns * 2 * 3.1415926535,
                    child: Container(
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF8BC34A)
                                .withOpacity(0.35),
                            blurRadius: _glow.value,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: _blockLogo(),
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 20),

            SlideTransition(
              position: _slideText,
              child: FadeTransition(
                opacity: _fadeText,
                child: const Text(
                  "E-Learning",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontFamily: 'JainiPurva',
                    fontWeight: FontWeight.w500,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _blockLogo() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 14,
          height: 46,
          decoration: BoxDecoration(
            color: const Color(0xFF8BC34A),
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 6),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            _WhiteBlock(),
            SizedBox(height: 6),
            _WhiteBlock(),
            SizedBox(height: 6),
            _WhiteBlock(),
          ],
        ),
      ],
    );
  }
}

class _WhiteBlock extends StatelessWidget {
  const _WhiteBlock();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 14,
      height: 14,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(3),
      ),
    );
  }
}
