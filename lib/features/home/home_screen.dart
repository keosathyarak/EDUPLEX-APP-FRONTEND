import 'package:flutter/material.dart';
import '../profile/widgets/profile_page.dart';
import '../shared/widgets/navitem.dart';
import 'about.dart';
import 'widgets/header.dart';
import 'widgets/question.dart';
import 'widgets/searchBar.dart' as search;
import 'widgets/categorySection.dart';
import 'widgets/backendCourses.dart';
import 'widgets/popularCourses.dart'; // 🔥 ADD THIS
import '../courses/course_page.dart';
import '../chat/chat_bot_page.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback onToggleTheme;

  const HomeScreen({
    super.key,
    required this.onToggleTheme,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int currentIndex = 0;
  final PageController _pageController = PageController();

  int selectedCategoryIndex = -1;
  String searchText = "";

  final headerKey = GlobalKey<HeaderState>();
  final backendKey1 = GlobalKey<BackendcoursesState>();
  final backendKey2 = GlobalKey<BackendcoursesState>();
  final popularKey = GlobalKey<PopularcoursesState>();

  Future<void> _refreshHome() async {
    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      selectedCategoryIndex = -1;
      searchText = "";
    });

    headerKey.currentState?.refreshFromParent();
    backendKey1.currentState?.refreshFromParent();
    backendKey2.currentState?.refreshFromParent();
    popularKey.currentState?.refreshFromParent();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          SafeArea(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                homeContent(),
                CoursePage(onToggleTheme: widget.onToggleTheme),
                const ChatBotPage(),
                const ProfilePage(),
                const AboutPage(),
              ],
            ),
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 16,
            child: Navitem.floatingNavButton(
              currentIndex: currentIndex,
              onTap: (index) {
                setState(() {
                  currentIndex = index;
                });
                _pageController.jumpToPage(index);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget homeContent() {
    return RefreshIndicator(
      onRefresh: _refreshHome,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Header.header(
              key: headerKey,
              onToggleTheme: widget.onToggleTheme,
            ),

            const SizedBox(height: 20),

            // 🔥 MULTIPLE IMAGE BANNER
            const BannerSlider(),

            const SizedBox(height: 20),

            Question.question(),
            const SizedBox(height: 10),

            search.Searchbar.searchBar((v) {
              searchText = v;
            }),

            const SizedBox(height: 24),

            Text(
              "Back End",
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 12),
            Backendcourses(key: backendKey1),

            const SizedBox(height: 28),

            Text(
              "Popular Courses",
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 12),
            Popularcourses(key: popularKey),

            const SizedBox(height: 28),

            Text(
              "Front End",
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 12),
            Backendcourses(key: backendKey2),

            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}