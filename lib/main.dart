import 'package:flutter/material.dart';

import 'routes/app_routes.dart';
import 'routes/app_router.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool isDarkMode = false;

  void toggleTheme() {
    setState(() {
      isDarkMode = !isDarkMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color(0xFFF6F7FB),
        cardColor: Colors.white,
      ),

      darkTheme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF121212),
        cardColor: const Color(0xFF1E1E1E),
      ),

      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,

      // ✅ ROUTER (CORRECT)
      initialRoute: AppRoutes.loading, // 🔥 FIX HERE
      onGenerateRoute: (settings) =>
          AppRouter.generateRoute(settings, toggleTheme),
    );
  }
}
