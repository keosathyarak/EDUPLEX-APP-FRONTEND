import 'package:flutter/material.dart';

import '../features/auth/register_page.dart';
import '../features/courses/course_detail_page.dart';
import '../features/onboarding/get_started_page.dart';
import '../features/splash/loading_page.dart';
import '../features/auth/login_page.dart';
import '../features/home/home_screen.dart';
import '../features/chat/chat_bot_page.dart';
import '../features/courses/course_page.dart';
import '../payments.dart'; // ✅ DO NOT HIDE
import 'app_router.dart';

class AppRouter {
  static Route<dynamic> generateRoute(
      RouteSettings settings,
      VoidCallback onToggleTheme,
      ) {
    switch (settings.name) {

    // ===== PAYMENT =====
      case AppRoutes.payments:
        final course =
        settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => EduplexPaymentPage(
            course: course,
          ),
        );

    // ===== LOADING =====
      case AppRoutes.loading:
        return MaterialPageRoute(
          builder: (_) => const LoadingPage(),
        );

      case AppRoutes.getStarted:
        return MaterialPageRoute(
          builder: (_) => const GetStartedPage(),
        );

    // ===== AUTH =====
      case AppRoutes.login:
        return MaterialPageRoute(
          builder: (_) => const LoginPage(),
        );

      case AppRoutes.register:
        return MaterialPageRoute(
          builder: (_) => const RegisterPage(),
        );

    // ===== HOME =====
      case AppRoutes.home:
        return MaterialPageRoute(
          builder: (_) => HomeScreen(
            onToggleTheme: onToggleTheme,
          ),
        );

    // ===== CHAT =====
      case AppRoutes.chatBot:
        return MaterialPageRoute(
          builder: (_) => const ChatBotPage(),
        );
    // ===== COURSES =====
      case AppRoutes.courses:
        return MaterialPageRoute(
          builder: (_) => CoursePage(
            onToggleTheme: onToggleTheme,
          ),
        );

      case AppRoutes.courseDetail:
        final course =
        settings.arguments as Map<String, dynamic>?;

        return MaterialPageRoute(
          builder: (_) => CourseDetailPage(
            course: course,
          ),
        );

    // ===== DEFAULT =====
      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(
              child: Text('❌ Page not found'),
            ),
          ),
        );
    }
  }
}
