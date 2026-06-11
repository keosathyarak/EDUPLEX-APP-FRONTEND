import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import 'package:EduPlex/features/home/widgets/header.dart';
import 'package:EduPlex/routes/app_routes.dart';

import '../../core/api/api_config.dart';
import '../../routes/app_router.dart';
import '../home/widgets/header.dart';

class CoursePage extends StatefulWidget {
  final VoidCallback onToggleTheme;

  const CoursePage({
    super.key,
    required this.onToggleTheme,
  });

  @override
  State<CoursePage> createState() => _CoursePageState();
}

class _CoursePageState extends State<CoursePage> {
  final GlobalKey<HeaderState> headerKey = GlobalKey<HeaderState>();

  List<dynamic> courses = [];
  bool isLoading = true;
  int imageRefreshKey = 0;

  static String get baseUrl => ApiConfig.baseUrl;

  @override
  void initState() {
    super.initState();
    fetchCourses();
  }

  Future<void> fetchCourses() async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/courses"),
        headers: {"Accept": "application/json"},
      );

      debugPrint("COURSE RESPONSE: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        setState(() {
          courses = data['courses'] ?? [];
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      debugPrint("Fetch error: $e");
      setState(() => isLoading = false);
    }
  }

  Future<void> _refresh() async {
    await fetchCourses();
    setState(() => imageRefreshKey++);
    headerKey.currentState?.refreshFromParent();
  }

  Future<void> _onLearnMore(BuildContext context, dynamic course) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");

    final bool isFree = course["price"] == null || course["price"] == 0;

    if (token == null || token.isEmpty) {
      await prefs.setBool("redirect_after_login", true);
      await prefs.setString("redirect_course", jsonEncode(course));

      Navigator.pushNamed(context, AppRoutes.login);
      return;
    }

    if (isFree) {
      Navigator.pushNamed(
        context,
        AppRoutes.courseDetail,
        arguments: course,
      );
      return;
    }

    await _checkPurchase(context, course, token);
  }

  Future<void> _checkPurchase(
      BuildContext context,
      dynamic course,
      String token,
      ) async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/check-purchase/${course["id"]}"),
        headers: {
          "Accept": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data["purchased"] == true) {
          Navigator.pushNamed(
            context,
            AppRoutes.courseDetail,
            arguments: course,
          );
        } else {
          Navigator.pushNamed(
            context,
            AppRoutes.payments,
            arguments: course,
          );
        }
      }
    } catch (e) {
      debugPrint("Purchase error: $e");
    }
  }

  String getCourseImageUrl(dynamic course) {
    final imagePath = course["image"];

    if (imagePath == null || imagePath.toString().isEmpty) {
      return "";
    }

    if (imagePath.toString().startsWith("http")) {
      return imagePath.toString();
    }

    final domain = ApiConfig.baseUrl.replaceAll('/api', '');

    return "$domain/storage/$imagePath";
  }

  Widget _noCoursesUI() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 90),
        child: Column(
          children: [
            Icon(
              Icons.menu_book_rounded,
              size: 90,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 18),
            Text(
              "No Courses Available",
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Please pull down to refresh or check again later.",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _courseCard(dynamic course) {
    final price = course["price"];
    final bool isFree = price == null || price == 0;

    final imageUrl = getCourseImageUrl(course);

    debugPrint("IMAGE URL: $imageUrl");

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(22),
            ),
            child: imageUrl.isEmpty
                ? _imageFallback()
                : Stack(
              children: [
                Image.network(
                  imageUrl,
                  key: ValueKey("$imageUrl-$imageRefreshKey"),
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;

                    return Container(
                      height: 180,
                      width: double.infinity,
                      alignment: Alignment.center,
                      child: const CircularProgressIndicator(),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    debugPrint("IMAGE ERROR: $error");
                    debugPrint("FAILED IMAGE URL: $imageUrl");

                    return _imageFallback();
                  },
                ),
                _priceBadge(isFree, price),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  course["title"] ?? "",
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.person, size: 16),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        course["teacher"] ?? "",
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.book, size: 16),
                    const SizedBox(width: 4),
                    Text("${course["lessons_count"] ?? 0} Lessons"),
                  ],
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: ElevatedButton(
                    onPressed: () => _onLearnMore(context, course),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isFree ? Colors.green : Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(
                      isFree ? "Start Learning" : "Buy Now",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _imageFallback() {
    return Container(
      height: 180,
      width: double.infinity,
      color: Colors.blue,
      child: const Center(
        child: Icon(
          Icons.school,
          color: Colors.white,
          size: 40,
        ),
      ),
    );
  }

  Widget _priceBadge(bool isFree, dynamic price) {
    return Positioned(
      top: 12,
      right: 12,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 6,
        ),
        decoration: BoxDecoration(
          color: isFree ? Colors.green : Colors.blue,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          isFree ? "FREE" : "\$$price",
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refresh,
          child: isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 110),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Header.header(
                  key: headerKey,
                  onToggleTheme: widget.onToggleTheme,
                ),
                const SizedBox(height: 16),
                Text(
                  "Courses",
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 22),
                courses.isEmpty
                    ? _noCoursesUI()
                    : ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: courses.length,
                  separatorBuilder: (_, __) =>
                  const SizedBox(height: 20),
                  itemBuilder: (context, index) {
                    return _courseCard(courses[index]);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}