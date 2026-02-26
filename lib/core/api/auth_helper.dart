import 'package:shared_preferences/shared_preferences.dart';

class AuthHelper {
  static const String _tokenKey = "token";
  static const String _nameKey = "name";
  static const String _emailKey = "email";
  static const String _avatarKey = "avatar";

  // ================= SAVE LOGIN DATA =================
  static Future<void> saveLoginData({
    required String token,
    required String name,
    required String email,
    String? avatar,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    await prefs.setString(_nameKey, name);
    await prefs.setString(_emailKey, email);
    await prefs.setString(_avatarKey, avatar ?? "");
  }

  // ================= CHECK LOGIN =================
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_tokenKey);
    return token != null && token.isNotEmpty;
  }

  // ================= GET TOKEN =================
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  // ================= GET USER INFO =================
  static Future<String?> getName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_nameKey);
  }

  static Future<String?> getEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_emailKey);
  }

  static Future<String?> getAvatar() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_avatarKey);
  }

  // ================= LOGOUT =================
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}