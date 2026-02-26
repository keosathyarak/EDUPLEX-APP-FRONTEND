import 'dart:ui';
import 'package:flutter/material.dart';

class Navitem {

  // ================= NAV ITEM =================
  static BottomNavigationBarItem navItem(String icon, String label) {
    return BottomNavigationBarItem(
      icon: Image.asset(
        icon,
        width: 22,
        height: 22,
      ),
      label: label,
    );
  }

  // ================= FLOATING NAV =================
  static Widget floatingNavButton({
    required int currentIndex,
    required Function(int) onTap,
  }) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: Container(
              height: 90, // ✅ FIXED OVERFLOW (was 70)
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.20),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color: Colors.white.withOpacity(0.25),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.12),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: BottomNavigationBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                currentIndex: currentIndex,
                onTap: onTap,
                type: BottomNavigationBarType.fixed,

                // ================= COLORS =================
                selectedItemColor: Colors.red,
                unselectedItemColor: Colors.black,

                // ================= SIZE FIX =================
                iconSize: 22,
                selectedFontSize: 12,
                unselectedFontSize: 11,
                showUnselectedLabels: true,

                selectedLabelStyle: const TextStyle(
                  fontFamily: 'KellySlab',
                  fontWeight: FontWeight.bold,
                ),
                unselectedLabelStyle: const TextStyle(
                  fontFamily: 'KellySlab',
                ),

                items: [
                  navItem('assets/icon/home.png', 'Home'),
                  navItem('assets/icon/course.png', 'Courses'),
                  navItem('assets/icon/contact.png', 'Chat'),
                  navItem('assets/icon/profile.png', 'Profile'),
                  navItem('assets/icon/search.png', 'About'),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}