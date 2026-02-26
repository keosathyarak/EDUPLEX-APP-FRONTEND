import 'package:flutter/material.dart';
import '../../../routes/app_router.dart';

final List<Map<String, String>> backendCourseList = [
  {
    "title": "ReactJS",
    "teacher": "Mr. Leng Saroth",
    "time": "1h 45mins | 30 lessons",
    "rating": "9.5",
    "image":
    "https://miro.medium.com/v2/resize:fit:750/format:webp/0*syUfAfQ5v-51iAo1.png",
  },
  {
    "title": "Laravel",
    "teacher": "Mr. Keo Sathyarak",
    "time": "30mins | 30 lessons",
    "rating": "9.2",
    "image":
    "https://picperf.io/https://laravelnews.s3.amazonaws.com/images/laravel-featured.png",
  },
  {
    "title": "Node.js",
    "teacher": "Mr. Sok Dara",
    "time": "2h 10mins | 42 lessons",
    "rating": "9.3",
    "image":
    "https://images.ctfassets.net/aq13lwl6616q/7cS8gBoWulxkWNWEm0FspJ/c7eb42dd82e27279307f8b9fc9b136fa/nodejs_cover_photo_smaller_size.png",
  },
  {
    "title": "Django",
    "teacher": "Ms. Lina",
    "time": "1h 20mins | 28 lessons",
    "rating": "9.1",
    "image":
    "https://i.pinimg.com/736x/32/6f/ed/326fed0996df090c51c17b7a2ff51773.jpg",
  },
];

class Backendcourses extends StatefulWidget {
  const Backendcourses({super.key});

  @override
  BackendcoursesState createState() => BackendcoursesState();
}

class BackendcoursesState extends State<Backendcourses> {
  int imageRefreshKey = 0;

  Future<void> _refreshBackend() async {
    await Future.delayed(const Duration(seconds: 2));
    setState(() => imageRefreshKey++);
  }

  void refreshFromParent() {
    setState(() => imageRefreshKey++);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return RefreshIndicator(
      onRefresh: _refreshBackend,
      color: theme.colorScheme.primary,
      child: SizedBox(
        height: 250,
        child: ListView.separated(
          physics: const AlwaysScrollableScrollPhysics(),
          scrollDirection: Axis.horizontal,
          itemCount: backendCourseList.length,
          separatorBuilder: (_, __) => const SizedBox(width: 14),
          itemBuilder: (context, index) {
            final course = backendCourseList[index];
            return _backendCard(
              context: context,
              title: course["title"]!,
              teacher: course["teacher"]!,
              time: course["time"]!,
              rating: course["rating"]!,
              image: course["image"]!,
            );
          },
        ),
      ),
    );
  }

  Widget _backendCard({
    required BuildContext context,
    required String title,
    required String teacher,
    required String time,
    required String rating,
    required String image,
  }) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          AppRoutes.courseDetail,
        );
      },
      child: Container(
        width: 260,
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(
                theme.brightness == Brightness.dark ? 0.3 : 0.08,
              ),
              blurRadius: 12,
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
                image,
                key: ValueKey('$image-$imageRefreshKey'),
                height: 120,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),

            // ===== CONTENT =====
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      teacher,
                      style: theme.textTheme.bodySmall,
                    ),
                    const SizedBox(height: 6),

                    Row(
                      children: [
                        Icon(Icons.timer,
                            size: 14, color: theme.iconTheme.color),
                        const SizedBox(width: 4),
                        Text(time,
                            style: theme.textTheme.bodySmall),
                        const Spacer(),
                        const Icon(Icons.star,
                            color: Colors.orange, size: 14),
                        const SizedBox(width: 4),
                        Text(rating,
                            style: theme.textTheme.bodySmall),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}