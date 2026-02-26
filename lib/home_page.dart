import 'package:flutter/material.dart';

void main() => runApp(const EduplexApp());

class EduplexApp extends StatelessWidget {
  const EduplexApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Eduplex",
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: "Roboto",
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int navIndex = 0;
  int bannerIndex = 0;
  int filterIndex = 0;

  final PageController _page = PageController(viewportFraction: 0.92);

  final List<_BannerItem> banners = const [
    _BannerItem(
      title: "BEST\nprogramming",
      subtitle: "COURSES",
      imageUrl:
      "https://images.unsplash.com/photo-1515879218367-8466d910aaa4?w=1200",
      tint: Color(0xFF7C3AED),
    ),
    _BannerItem(
      title: "FLUTTER",
      subtitle: "CRASH COURSE",
      imageUrl:
      "https://images.unsplash.com/photo-1555099962-4199c345e5dd?w=1200",
      tint: Color(0xFF2563EB),
    ),
    _BannerItem(
      title: "Spring Boot",
      subtitle: "Backend Skills",
      imageUrl:
      "https://images.unsplash.com/photo-1555949963-aa79dcee981c?w=1200",
      tint: Color(0xFF16A34A),
    ),
  ];

  final List<_FilterItem> filters = const [
    _FilterItem("All Course", Icons.grid_view_rounded),
    _FilterItem("Popular", Icons.local_fire_department_rounded),
    _FilterItem("Newest", Icons.fiber_new_rounded),
    _FilterItem("Top Rating", Icons.star_rounded),
  ];

  final List<_Course> courses = const [
    _Course(
      title: "Tailwind Advance Course",
      author: "Mr. Dim Hourt",
      duration: "2h:30mins",
      lessons: "10 lessons",
      rating: "5.5",
      coverUrl:
      "https://images.unsplash.com/photo-1526378722484-bd91ca387e72?w=1200",
      avatarUrl:
      "https://images.unsplash.com/photo-1502685104226-ee32379fefbe?w=200",
    ),
    _Course(
      title: "Laravel Framework",
      author: "Ms. Long Sola",
      duration: "1h:45mins",
      lessons: "8 lessons",
      rating: "5.0",
      coverUrl:
      "https://images.unsplash.com/photo-1521737604893-d14cc237f11d?w=1200",
      avatarUrl:
      "https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=200",
    ),
    _Course(
      title: "Flutter UI Mastery",
      author: "Mr. Jack",
      duration: "3h:10mins",
      lessons: "12 lessons",
      rating: "5.4",
      coverUrl:
      "https://images.unsplash.com/photo-1555066931-4365d14bab8c?w=1200",
      avatarUrl:
      "https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=200",
    ),
  ];

  @override
  void dispose() {
    _page.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ===== Top Bar =====
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: const [
                          BoxShadow(
                            blurRadius: 18,
                            offset: Offset(0, 8),
                            color: Color(0x14000000),
                          )
                        ],
                      ),
                      child: const Icon(Icons.school_rounded),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            "Eduplex",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF1F2937),
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            "Ignite Your Learning Journey",
                            style: TextStyle(
                              fontSize: 11.5,
                              color: Color(0xFF6B7280),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Stack(
                      children: [
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: const [
                              BoxShadow(
                                blurRadius: 18,
                                offset: Offset(0, 8),
                                color: Color(0x14000000),
                              )
                            ],
                          ),
                          child: const Icon(Icons.notifications_none_rounded),
                        ),
                        Positioned(
                          top: 8,
                          right: 10,
                          child: Container(
                            width: 9,
                            height: 9,
                            decoration: BoxDecoration(
                              color: const Color(0xFFEF4444),
                              borderRadius: BorderRadius.circular(50),
                            ),
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              ),

              // ===== Banner Slider =====
              SizedBox(
                height: w * 0.46,
                child: PageView.builder(
                  controller: _page,
                  itemCount: banners.length,
                  onPageChanged: (i) => setState(() => bannerIndex = i),
                  itemBuilder: (_, i) => _BannerCard(item: banners[i]),
                ),
              ),
              const SizedBox(height: 10),
              _DotsIndicator(
                count: banners.length,
                index: bannerIndex,
              ),
              const SizedBox(height: 14),

              // ===== Top Course Header =====
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    const Text(
                      "Top Course",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF111827),
                      ),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () {},
                      child: const Text(
                        "View all",
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    )
                  ],
                ),
              ),

              // ===== Filters =====
              SizedBox(
                height: 44,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  scrollDirection: Axis.horizontal,
                  itemCount: filters.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 10),
                  itemBuilder: (_, i) {
                    final selected = i == filterIndex;
                    final item = filters[i];
                    return InkWell(
                      borderRadius: BorderRadius.circular(999),
                      onTap: () => setState(() => filterIndex = i),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: selected ? const Color(0xFF111827) : Colors.white,
                          borderRadius: BorderRadius.circular(999),
                          boxShadow: const [
                            BoxShadow(
                              blurRadius: 14,
                              offset: Offset(0, 8),
                              color: Color(0x12000000),
                            )
                          ],
                        ),
                        child: Row(
                          children: [
                            Icon(
                              item.icon,
                              size: 18,
                              color: selected ? Colors.white : const Color(0xFF6B7280),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              item.label,
                              style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w800,
                                color: selected ? Colors.white : const Color(0xFF111827),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 14),

              // ===== Course Cards =====
              SizedBox(
                height: 210,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  scrollDirection: Axis.horizontal,
                  itemCount: courses.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (_, i) => _CourseCard(course: courses[i]),
                ),
              ),
            ],
          ),
        ),
      ),

      // ===== Bottom Navigation =====
      bottomNavigationBar: _BottomNav(
        index: navIndex,
        onChange: (i) => setState(() => navIndex = i),
      ),
    );
  }
}

class _BannerItem {
  final String title;
  final String subtitle;
  final String imageUrl;
  final Color tint;

  const _BannerItem({
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    required this.tint,
  });
}

class _BannerCard extends StatelessWidget {
  final _BannerItem item;

  const _BannerCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: item.tint,
        boxShadow: const [
          BoxShadow(
            blurRadius: 18,
            offset: Offset(0, 10),
            color: Color(0x1A000000),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(item.imageUrl, fit: BoxFit.cover),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    item.tint.withOpacity(0.92),
                    item.tint.withOpacity(0.55),
                    Colors.transparent,
                  ],
                  begin: Alignment.bottomLeft,
                  end: Alignment.topRight,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      item.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        height: 1.05,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFD54A),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        item.subtitle,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF111827),
                        ),
                      ),
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

class _DotsIndicator extends StatelessWidget {
  final int count;
  final int index;

  const _DotsIndicator({required this.count, required this.index});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (i) {
        final active = i == index;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: active ? 18 : 7,
          height: 7,
          decoration: BoxDecoration(
            color: active ? const Color(0xFF111827) : const Color(0xFFD1D5DB),
            borderRadius: BorderRadius.circular(99),
          ),
        );
      }),
    );
  }
}

class _FilterItem {
  final String label;
  final IconData icon;
  const _FilterItem(this.label, this.icon);
}

class _Course {
  final String title;
  final String author;
  final String duration;
  final String lessons;
  final String rating;
  final String coverUrl;
  final String avatarUrl;

  const _Course({
    required this.title,
    required this.author,
    required this.duration,
    required this.lessons,
    required this.rating,
    required this.coverUrl,
    required this.avatarUrl,
  });
}

class _CourseCard extends StatelessWidget {
  final _Course course;

  const _CourseCard({required this.course});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 280,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: const [
            BoxShadow(
              blurRadius: 18,
              offset: Offset(0, 10),
              color: Color(0x14000000),
            )
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // cover
              Expanded(
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: Image.network(course.coverUrl, fit: BoxFit.cover),
                    ),
                    Positioned(
                      top: 10,
                      right: 10,
                      child: Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.95),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.favorite_border_rounded, size: 20),
                      ),
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 14,
                          backgroundImage: NetworkImage(course.avatarUrl),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            course.author,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF111827),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const Icon(Icons.star_rounded, size: 18, color: Color(0xFFF59E0B)),
                        const SizedBox(width: 2),
                        Text(
                          course.rating,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF111827),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      course.title,
                      style: const TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF111827),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.schedule_rounded, size: 16, color: Color(0xFF6B7280)),
                        const SizedBox(width: 4),
                        Text(
                          course.duration,
                          style: const TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Icon(Icons.list_alt_rounded, size: 16, color: Color(0xFF6B7280)),
                        const SizedBox(width: 4),
                        Text(
                          course.lessons,
                          style: const TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      height: 36,
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2563EB),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          "Learn now",
                          style: TextStyle(fontWeight: FontWeight.w900),
                        ),
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class _BottomNav extends StatelessWidget {
  final int index;
  final ValueChanged<int> onChange;

  const _BottomNav({required this.index, required this.onChange});

  @override
  Widget build(BuildContext context) {
    final items = const [
      _NavItem("Home", Icons.home_rounded),
      _NavItem("Course", Icons.menu_book_rounded),
      _NavItem("About", Icons.info_rounded),
      _NavItem("Contact", Icons.support_agent_rounded),
      _NavItem("Profile", Icons.person_rounded),
    ];

    return Container(
      padding: const EdgeInsets.only(top: 6, bottom: 10),
      decoration: const BoxDecoration(
        color: Color(0xFFE5E7EB),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(items.length, (i) {
          final active = i == index;
          final it = items[i];

          return Expanded(
            child: InkWell(
              onTap: () => onChange(i),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 160),
                    width: active ? 28 : 0,
                    height: 3,
                    decoration: BoxDecoration(
                      color: active ? const Color(0xFF2563EB) : Colors.transparent,
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Icon(it.icon, size: 22, color: active ? const Color(0xFF111827) : const Color(0xFF6B7280)),
                  const SizedBox(height: 2),
                  Text(
                    it.label,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: active ? const Color(0xFF111827) : const Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _NavItem {
  final String label;
  final IconData icon;
  const _NavItem(this.label, this.icon);
}
