import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/api/api_config.dart';
import '../../../routes/app_router.dart';
import '../../../routes/app_routes.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String name = "User";
  String email = "";
  String? profileImage;

  bool isLoggedIn = false;
  bool isUpdating = false;

  File? selectedImage;
  int imageRefreshKey = 0;

  static String get baseUrl => ApiConfig.baseUrl;
  static String get domain => ApiConfig.domain;

  static const Color primaryBlue = Color(0xFF3D21F3);

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadUser();
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");

    if (token != null && token.isNotEmpty) {
      try {
        final response = await http.get(
          Uri.parse("$baseUrl/profile"),
          headers: {
            "Accept": "application/json",
            "Authorization": "Bearer $token",
          },
        );

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          final user = data["user"];

          final savedImage =
              user["image"] ?? user["profile_picture"] ?? user["image_url"];

          await prefs.setString("name", user["name"] ?? "User");
          await prefs.setString("email", user["email"] ?? "");

          if (savedImage != null && savedImage.toString().isNotEmpty) {
            await prefs.setString("image", savedImage.toString());
          }
        }
      } catch (e) {
        debugPrint("Profile refresh error: $e");
      }
    }

    if (!mounted) return;

    setState(() {
      isLoggedIn = token != null && token.isNotEmpty;
      name = isLoggedIn ? prefs.getString("name") ?? "User" : "Guest";
      email = isLoggedIn ? prefs.getString("email") ?? "" : "";
      profileImage = isLoggedIn ? prefs.getString("image") : null;
      imageRefreshKey++;
    });
  }

  ImageProvider getProfileImage() {
    if (selectedImage != null) {
      return FileImage(selectedImage!);
    }

    if (profileImage != null && profileImage!.isNotEmpty) {
      String imageUrl = profileImage!;

      if (!imageUrl.startsWith("http")) {
        imageUrl = "$domain/storage/$imageUrl";
      }

      return NetworkImage(
        "$imageUrl?t=$imageRefreshKey",
      );
    }

    return const AssetImage("assets/icon/logologin.png");
  }

  Future<void> pickProfileImage(Function setSheetState) async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 75,
    );

    if (picked != null) {
      selectedImage = File(picked.path);

      setState(() {
        imageRefreshKey++;
      });

      setSheetState(() {});
    }
  }

  Future<void> updateProfileApi() async {
    final newName = nameController.text.trim();
    final newEmail = emailController.text.trim();
    final newPassword = passwordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();

    if (newName.isEmpty || newEmail.isEmpty) {
      _snack("Name and email are required");
      return;
    }

    if (newPassword.isNotEmpty && newPassword.length < 8) {
      _snack("Password must be at least 8 characters");
      return;
    }

    if (newPassword.isNotEmpty && newPassword != confirmPassword) {
      _snack("Passwords do not match");
      return;
    }

    setState(() => isUpdating = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token");

      final request = http.MultipartRequest(
        "POST",
        Uri.parse("$baseUrl/profile/update"),
      );

      request.headers.addAll({
        "Accept": "application/json",
        "Authorization": "Bearer $token",
      });

      request.fields["name"] = newName;
      request.fields["email"] = newEmail;

      if (newPassword.isNotEmpty) {
        request.fields["password"] = newPassword;
        request.fields["password_confirmation"] = confirmPassword;
      }

      if (selectedImage != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            "profile_picture",
            selectedImage!.path,
          ),
        );
      }

      final streamedResponse = await request.send();
      final res = await http.Response.fromStream(streamedResponse);

      final data = jsonDecode(res.body);

      if (res.statusCode == 200 && data["success"] == true) {
        final user = data["user"];

        final savedImage =
            user["image"] ?? user["profile_picture"] ?? user["image_url"];

        await prefs.setString("name", user["name"] ?? newName);
        await prefs.setString("email", user["email"] ?? newEmail);

        if (savedImage != null && savedImage.toString().isNotEmpty) {
          await prefs.setString("image", savedImage.toString());
        }

        setState(() {
          name = user["name"] ?? newName;
          email = user["email"] ?? newEmail;
          profileImage = savedImage?.toString() ?? profileImage;
          selectedImage = null;
          imageRefreshKey++;
        });

        if (mounted) Navigator.pop(context);

        await loadUser();

        _snack("Profile updated successfully");
      } else {
        _snack(data["message"] ?? "Update failed");
      }
    } catch (e) {
      _snack("Error: $e");
    }

    if (mounted) setState(() => isUpdating = false);
  }

  void showEditProfileSheet() {
    nameController.text = name;
    emailController.text = email;
    passwordController.clear();
    confirmPasswordController.clear();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Container(
                padding: const EdgeInsets.fromLTRB(22, 14, 22, 24),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(28),
                  ),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 45,
                        height: 5,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      const SizedBox(height: 18),

                      GestureDetector(
                        onTap: () => pickProfileImage(setSheetState),
                        child: CircleAvatar(
                          key: ValueKey(imageRefreshKey),
                          radius: 45,
                          backgroundColor: primaryBlue,
                          backgroundImage: getProfileImage(),
                          child: Align(
                            alignment: Alignment.bottomRight,
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.camera_alt,
                                size: 18,
                                color: primaryBlue,
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      const Text(
                        "Update Profile",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 22),

                      _inputField(
                        controller: nameController,
                        label: "Full Name",
                        icon: Icons.person,
                      ),

                      const SizedBox(height: 14),

                      _inputField(
                        controller: emailController,
                        label: "Email Address",
                        icon: Icons.email,
                        keyboardType: TextInputType.emailAddress,
                      ),

                      const SizedBox(height: 14),

                      _inputField(
                        controller: passwordController,
                        label: "New Password (optional)",
                        icon: Icons.lock,
                        obscureText: true,
                      ),

                      const SizedBox(height: 14),

                      _inputField(
                        controller: confirmPasswordController,
                        label: "Confirm Password",
                        icon: Icons.lock_outline,
                        obscureText: true,
                      ),

                      const SizedBox(height: 24),

                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: isUpdating ? null : updateProfileApi,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryBlue,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                          child: isUpdating
                              ? const CircularProgressIndicator(
                            color: Colors.white,
                          )
                              : const Text(
                            "Save Changes",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      TextButton(
                        onPressed:
                        isUpdating ? null : () => Navigator.pop(context),
                        child: const Text("Cancel"),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    setState(() {
      isLoggedIn = false;
      name = "Guest";
      email = "";
      profileImage = null;
      selectedImage = null;
      imageRefreshKey++;
    });
  }

  void _snack(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Widget _inputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: primaryBlue),
        filled: true,
        fillColor: const Color(0xFFF4F6FA),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryBlue,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: loadUser,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: SizedBox(
              height: MediaQuery.of(context).size.height -
                  MediaQuery.of(context).padding.top,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 20,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "My Profile",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (isLoggedIn)
                          GestureDetector(
                            onTap: showEditProfileSheet,
                            child: _circleIcon(Icons.edit),
                          ),
                      ],
                    ),
                  ),

                  Expanded(
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(30),
                        ),
                      ),
                      child: isLoggedIn ? _loggedInUI() : _notLoggedInUI(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _loggedInUI() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                key: ValueKey(imageRefreshKey),
                radius: 50,
                backgroundColor: primaryBlue,
                backgroundImage: getProfileImage(),
              ),

              const SizedBox(width: 20),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 6),

                    Text(
                      email,
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 30),

          const Text(
            "About",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 10),

          const Text(
            "Welcome to your profile page. You can manage your personal information here.",
            style: TextStyle(
              height: 1.5,
              color: Colors.black87,
            ),
          ),

          const SizedBox(height: 40),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: logout,
              icon: const Icon(Icons.logout),
              label: const Text("Logout"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _notLoggedInUI() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.person_outline,
            size: 90,
            color: Colors.grey.shade400,
          ),

          const SizedBox(height: 20),

          const Text(
            "You are not logged in",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            "Login to access your profile",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade600),
          ),

          const SizedBox(height: 24),

          SizedBox(
            width: 200,
            child: ElevatedButton(
              onPressed: () => Navigator.pushNamed(
                context,
                AppRoutes.login,
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryBlue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text("Login Now"),
            ),
          ),
        ],
      ),
    );
  }

  Widget _circleIcon(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        shape: BoxShape.circle,
      ),
      child: Icon(
        icon,
        color: Colors.white,
      ),
    );
  }
}