import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class CourseDetailPage extends StatefulWidget {
  final Map<String, dynamic>? course;

  const CourseDetailPage({
    super.key,
    this.course,
  });

  @override
  State<CourseDetailPage> createState() => _CourseDetailPageState();
}

class _CourseDetailPageState extends State<CourseDetailPage> {
  late YoutubePlayerController _controller;

  int activeIndex = 0;
  int selectedTab = 0;

  final List<Map<String, String>> lessons = [
    {
      "title": "1-Installing CodeBlocks and Getting Started",
      "views": "288K views",
      "videoUrl": "https://youtu.be/e1YafrxYOWw?si=oVL-nwXHrRIbhtE7",
    },
    {
      "title": "2-Understanding C++ Program Structure",
      "views": "830K views",
      "videoUrl": "https://youtu.be/XWE3hA4PAoI?si=AhIfj1uZPrUpM9_8",
    },
    {
      "title": "3-Understanding Variables",
      "views": "505 views",
      "videoUrl": "https://youtu.be/tkPjecc0ViY?si=QQHlWvs2CfSqDty9",
    },
    {
      "title": "4-Basic Calculator",
      "views": "505 views",
      "videoUrl": "https://youtu.be/fta0zpX05vk?si=oijms8aUkgCtukmJ",
    },
  ];

  @override
  void initState() {
    super.initState();
    final firstVideoId =
    YoutubePlayer.convertUrlToId(lessons[0]['videoUrl']!);

    _controller = YoutubePlayerController(
      initialVideoId: firstVideoId!,
      flags: const YoutubePlayerFlags(autoPlay: true),
    );
  }

  void _changeVideo(int index) {
    final videoId =
    YoutubePlayer.convertUrlToId(lessons[index]['videoUrl']!);
    if (videoId == null) return;

    setState(() {
      activeIndex = index;
    });

    _controller.load(videoId);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final courseTitle =
        widget.course?["title"] ?? "Course Detail";

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [

            // ================= VIDEO + PREMIUM BACK =================
            Stack(
              children: [
                YoutubePlayer(
                  controller: _controller,
                  showVideoProgressIndicator: true,
                ),

                Positioned(
                  top: 16,
                  left: 16,
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(30),
                      onTap: () {
                        if (Navigator.canPop(context)) {
                          Navigator.pop(context);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.black.withOpacity(0.7)
                              : Colors.white.withOpacity(0.9),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              blurRadius: 10,
                              color:
                              Colors.black.withOpacity(0.3),
                            )
                          ],
                        ),
                        child: Icon(
                          Icons.arrow_back_rounded,
                          color: isDark
                              ? Colors.white
                              : Colors.black,
                          size: 22,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // ================= COURSE INFO =================
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.cardColor,
                boxShadow: [
                  BoxShadow(
                    blurRadius: 8,
                    color: Colors.black
                        .withOpacity(isDark ? 0.3 : 0.05),
                  )
                ],
              ),
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [

                  Row(
                    children: [
                      Icon(Icons.school,
                          color:
                          theme.colorScheme.primary),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          courseTitle,
                          style: theme
                              .textTheme.titleLarge
                              ?.copyWith(
                            fontWeight:
                            FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  Row(
                    children: [
                      const Icon(Icons.play_circle,
                          size: 18,
                          color: Colors.blue),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          lessons[activeIndex]
                          ['title']!,
                          style: theme
                              .textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // ================= TABS =================
            Container(
              color: theme.cardColor,
              child: Row(
                children: [
                  _TabItem(
                    icon: Icons.menu_book,
                    title: "Lessons",
                    selected: selectedTab == 0,
                    onTap: () =>
                        setState(() => selectedTab = 0),
                  ),
                  _TabItem(
                    icon: Icons.assignment,
                    title: "Exercise",
                    selected: selectedTab == 1,
                    onTap: () =>
                        setState(() => selectedTab = 1),
                  ),
                  _TabItem(
                    icon: Icons.chat_bubble,
                    title: "Comments",
                    selected: selectedTab == 2,
                    onTap: () =>
                        setState(() => selectedTab = 2),
                  ),
                ],
              ),
            ),

            Expanded(
              child: selectedTab == 0
                  ? _buildLessons()
                  : _buildComingSoon(
                selectedTab == 1
                    ? "📝 Exercises coming soon"
                    : "💬 Comments coming soon",
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLessons() {
    final theme = Theme.of(context);

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: lessons.length,
      itemBuilder: (context, index) {
        final lesson = lessons[index];
        final isActive = index == activeIndex;

        return GestureDetector(
          onTap: () => _changeVideo(index),
          child: AnimatedContainer(
            duration:
            const Duration(milliseconds: 250),
            margin:
            const EdgeInsets.only(bottom: 14),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isActive
                  ? theme.colorScheme.primary
                  .withOpacity(0.1)
                  : theme.cardColor,
              borderRadius:
              BorderRadius.circular(16),
              border: Border.all(
                color: isActive
                    ? theme.colorScheme.primary
                    : theme.dividerColor,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        theme.colorScheme.primary,
                        theme.colorScheme.primary
                            .withOpacity(0.7),
                      ],
                    ),
                    borderRadius:
                    BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.play_arrow,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    lesson['title']!,
                    style: theme
                        .textTheme.bodyMedium
                        ?.copyWith(
                      fontWeight:
                      FontWeight.w600,
                    ),
                  ),
                ),
                if (isActive)
                  Icon(Icons.check_circle,
                      color: theme
                          .colorScheme.primary),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildComingSoon(String text) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisAlignment:
        MainAxisAlignment.center,
        children: [
          Icon(Icons.lock_clock,
              size: 60,
              color:
              theme.colorScheme.primary),
          const SizedBox(height: 16),
          Text(
            text,
            style:
            theme.textTheme.titleMedium,
          ),
        ],
      ),
    );
  }
}

class _TabItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool selected;
  final VoidCallback onTap;

  const _TabItem({
    required this.icon,
    required this.title,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Column(
          children: [
            Padding(
              padding:
              const EdgeInsets.symmetric(
                  vertical: 12),
              child: Row(
                mainAxisAlignment:
                MainAxisAlignment.center,
                children: [
                  Icon(
                    icon,
                    size: 18,
                    color: selected
                        ? theme
                        .colorScheme.primary
                        : theme.hintColor,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: selected
                          ? FontWeight.bold
                          : FontWeight.normal,
                      color: selected
                          ? theme.colorScheme
                          .primary
                          : theme.hintColor,
                    ),
                  ),
                ],
              ),
            ),
            AnimatedContainer(
              duration:
              const Duration(milliseconds: 200),
              height: 3,
              width: selected ? 40 : 0,
              decoration: BoxDecoration(
                color:
                theme.colorScheme.primary,
                borderRadius:
                BorderRadius.circular(4),
              ),
            ),
          ],
        ),
      ),
    );
  }
}