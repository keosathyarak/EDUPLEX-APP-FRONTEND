import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import 'package:EduPlex/features/home/widgets/header.dart';
import 'package:EduPlex/routes/app_routes.dart';

import '../../routes/app_router.dart';

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

  final String baseUrl = "https://keratotic-uninserted-henry.ngrok-free.dev";
  @override
  void initState() {
    super.initState();
    fetchCourses();
  }

  // ================= FETCH COURSES =================
  Future<void> fetchCourses() async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/api/courses"),
        headers: {"Accept": "application/json"},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        setState(() {
          courses = data['courses'] ?? [];
          isLoading = false;
        });
      }
    } catch (e) {
      print("Fetch error: $e");
      setState(() => isLoading = false);
    }
  }

  // ================= REFRESH =================
  Future<void> _refresh() async {
    await fetchCourses();
    setState(() => imageRefreshKey++);
    headerKey.currentState?.refreshFromParent();
  }

  // ================= CLICK BUY =================
  Future<void> _onLearnMore(BuildContext context, dynamic course) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");

    final bool isFree = course["price"] == null || course["price"] == 0;

    // ===== NOT LOGIN =====
    if (token == null || token.isEmpty) {
      await prefs.setBool("redirect_after_login", true);
      await prefs.setString("redirect_course", jsonEncode(course));

      Navigator.pushNamed(context, AppRoutes.login);
      return;
    }

    // ===== FREE COURSE =====
    if (isFree) {
      print("click hi");
      Navigator.pushNamed(
        context,
        AppRoutes.courseDetail,
        arguments: course,
      );
      return;
    }

    // ===== PAID COURSE =====
    await _checkPurchase(context, course, token);
  }

  // ================= CHECK PURCHASE =================
  Future<void> _checkPurchase(
      BuildContext context,
      dynamic course,
      String token,
      ) async {

    try {
      final response = await http.get(
        Uri.parse("$baseUrl/api/check-purchase/${course["id"]}"),
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
      print("Purchase error: $e");
    }
  }

  // ================= UI =================
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
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 22),

                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: courses.length,
                  separatorBuilder: (_, __) =>
                  const SizedBox(height: 20),
                  itemBuilder: (context, index) {

                    final course = courses[index];
                    final price = course["price"];
                    final bool isFree = price == null || price == 0;

                    final imageUrl =
                        "$baseUrl/storage/${course["image"]}";

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

                          // IMAGE
                          ClipRRect(
                            borderRadius:
                            const BorderRadius.vertical(
                              top: Radius.circular(22),
                            ),
                            child: Stack(
                              children: [
                                Image.network(
                                  imageUrl,
                                  key: ValueKey(
                                      "$imageUrl-$imageRefreshKey"),
                                  height: 180,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                  errorBuilder:
                                      (context, error, stackTrace) {
                                    return Container(
                                      height: 180,
                                      color: Colors.blue,
                                      child: const Center(
                                        child: Icon(
                                          Icons.school,
                                          color: Colors.white,
                                          size: 40,
                                        ),
                                      ),
                                    );
                                  },
                                ),

                                Positioned(
                                  top: 12,
                                  right: 12,
                                  child: Container(
                                    padding:
                                    const EdgeInsets.symmetric(
                                      horizontal: 14,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isFree
                                          ? Colors.green
                                          : Colors.blue,
                                      borderRadius:
                                      BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      isFree
                                          ? "FREE"
                                          : "\$${price}",
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // CONTENT
                          Padding(
                            padding: const EdgeInsets.all(18),
                            child: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: [

                                Text(
                                  course["title"] ?? "",
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(
                                      fontWeight:
                                      FontWeight.bold),
                                ),

                                const SizedBox(height: 8),

                                Row(
                                  children: [
                                    const Icon(Icons.person, size: 16),
                                    const SizedBox(width: 6),
                                    Text(course["teacher"] ?? ""),
                                    const Spacer(),
                                    const Icon(Icons.book, size: 16),
                                    const SizedBox(width: 4),
                                    Text(
                                        "${course["lessons_count"]} Lessons"),
                                  ],
                                ),

                                const SizedBox(height: 18),

                                SizedBox(
                                  width: double.infinity,
                                  height: 46,
                                  child: ElevatedButton(
                                    onPressed: () =>
                                        _onLearnMore(context, course),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                      isFree
                                          ? Colors.green
                                          : Colors.blue,
                                      shape:
                                      RoundedRectangleBorder(
                                        borderRadius:
                                        BorderRadius.circular(14),
                                      ),
                                    ),
                                    child: Text(
                                      isFree
                                          ? "Start Learning"
                                          : "Buy Now",
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
