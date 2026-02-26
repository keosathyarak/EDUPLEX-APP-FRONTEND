import 'package:flutter/material.dart';

class Popularcourses extends StatefulWidget {
  const Popularcourses({super.key});

  @override
  PopularcoursesState createState() => PopularcoursesState();
}

class PopularcoursesState extends State<Popularcourses> {
  // 🔑 force image reload
  int imageRefreshKey = 0;

  // 🔄 refresh from inside Popularcourses
  Future<void> _refreshPopular() async {
    await Future.delayed(const Duration(seconds: 2));
    setState(() {
      imageRefreshKey++;
    });
  }

  // 🔄 EXPOSE refresh for HomeScreen
  void refreshFromParent() {
    setState(() {
      imageRefreshKey++;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return RefreshIndicator(
      onRefresh: _refreshPopular,
      color: theme.colorScheme.primary,
      child: SizedBox(
        height: 170,
        child: ListView.separated(
          physics: const AlwaysScrollableScrollPhysics(),
          scrollDirection: Axis.horizontal,
          itemCount: 5,
          separatorBuilder: (_, __) => const SizedBox(width: 12),
          itemBuilder: (_, index) => popularCard(context, index),
        ),
      ),
    );
  }

  Widget popularCard(BuildContext context, int index) {
    final theme = Theme.of(context);

    final images = [
      "https://i.pinimg.com/736x/32/6f/ed/326fed0996df090c51c17b7a2ff51773.jpg",
      "https://miro.medium.com/v2/resize:fit:750/format:webp/0*syUfAfQ5v-51iAo1.png",
      "https://laraveldaily.com/storage/930/900-600-laravel-(52).png",
      "https://miro.medium.com/v2/0*N4F70HUeYZQktV6s.png",
      "https://miro.medium.com/v2/1*os-kEY6vkmhbx3TEznlOng.png",
    ];

    final titles = [
      "Java Strings",
      "React JS",
      "Laravel API",
      "MySQL Master",
      "Spring Boot",
    ];

    final lessons = [
      "20 lessons",
      "18 lessons",
      "25 lessons",
      "15 lessons",
      "22 lessons",
    ];

    return Container(
      width: 160,
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(
              theme.brightness == Brightness.dark ? 0.35 : 0.08,
            ),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ===== IMAGE =====
          ClipRRect(
            borderRadius:
            const BorderRadius.vertical(top: Radius.circular(16)),
            child: Image.network(
              images[index],
              key: ValueKey('${images[index]}-$imageRefreshKey'),
              height: 90,
              width: double.infinity,
              fit: BoxFit.cover,

              // ⏳ Loading
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(
                  height: 90,
                  color: theme.dividerColor.withOpacity(0.2),
                  alignment: Alignment.center,
                  child: const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                );
              },

              // ❌ Error
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 90,
                  color: theme.dividerColor.withOpacity(0.3),
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.broken_image,
                    size: 30,
                    color: Colors.grey,
                  ),
                );
              },
            ),
          ),

          // ===== CONTENT =====
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titles[index],
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  lessons[index],
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
