import 'package:flutter/material.dart';

// ================= SEARCH =================
class Searchbar {
  static Widget searchBar(Function(String) onTap) {
    return Builder(
      builder: (context) {
        final theme = Theme.of(context);
        final isDark = theme.brightness == Brightness.dark;

        return Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: theme.cardColor, // 🌙 theme-aware
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              if (!isDark)
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                ),
            ],
          ),
          child: TextField(
            style: theme.textTheme.bodyMedium,
            decoration: InputDecoration(
              icon: Icon(
                Icons.search,
                color: isDark ? Colors.grey.shade400 : Colors.grey,
              ),
              hintText: "Search courses...",
              hintStyle: theme.textTheme.bodySmall?.copyWith(
                color: isDark ? Colors.grey.shade400 : Colors.grey,
              ),
              border: InputBorder.none,
            ),
            onChanged: onTap,
          ),
        );
      },
    );
  }
}
