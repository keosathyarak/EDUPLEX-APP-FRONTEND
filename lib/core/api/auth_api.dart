import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;

import 'api_config.dart';

class AuthApi {

  static String get baseUrl => ApiConfig.baseUrl;

  // ================= REGISTER =================
  static Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/register"),
        headers: _headers(),
        body: jsonEncode({
          "email": email,
          "password": password,
          "password_confirmation": passwordConfirmation,
        }),
      );

      return _safeResponse(response);
    } catch (e) {
      return _errorResponse("Network error");
    }
  }

  // ================= LOGIN =================
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/login"),
        headers: _headers(),
        body: jsonEncode({
          "email": email,
          "password": password,
        }),
      );

      return _safeResponse(response);
    } catch (e) {
      return _errorResponse("Network error");
    }
  }

  // ================= UPDATE PROFILE =================
  static Future<Map<String, dynamic>> updateProfile({
    required String token,
    String? name,
    String? email,
    String? password,
    String? passwordConfirmation,
  }) async {
    try {
      final response = await http.put(
        Uri.parse("$baseUrl/profile/update"),
        headers: _headers(token: token),
        body: jsonEncode({
          if (name != null) "name": name,
          if (email != null) "email": email,
          if (password != null) "password": password,
          if (passwordConfirmation != null)
            "password_confirmation": passwordConfirmation,
        }),
      );

      return _safeResponse(response);
    } catch (e) {
      return _errorResponse("Network error");
    }
  }

  // ================= UPLOAD PROFILE IMAGE (WEB + MOBILE) =================
  static Future<Map<String, dynamic>> uploadProfileImage({
    required String token,
    File? file,            // mobile
    Uint8List? bytes,      // web
  }) async {
    try {
      final uri = Uri.parse("$baseUrl/profile/upload-image");

      final request = http.MultipartRequest("POST", uri);

      request.headers.addAll({
        "Accept": "application/json",
        "Authorization": "Bearer $token",
      });

      if (!kIsWeb && file != null) {
        // 🔹 MOBILE
        request.files.add(
          await http.MultipartFile.fromPath(
            "profile_picture",
            file.path,
          ),
        );
      } else if (kIsWeb && bytes != null) {
        // 🔹 WEB
        request.files.add(
          http.MultipartFile.fromBytes(
            "profile_picture",
            bytes,
            filename: "profile.jpg",
          ),
        );
      } else {
        return _errorResponse("No image selected");
      }

      final streamed = await request.send();
      final response = await http.Response.fromStream(streamed);

      return {
        "status": response.statusCode,
        "body": jsonDecode(response.body),
      };
    } catch (e) {
      return _errorResponse("Upload failed");
    }
  }

  // ================= LOGOUT =================
  static Future<Map<String, dynamic>> logout({
    required String token,
  }) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/logout"),
        headers: _headers(token: token),
      );

      return _safeResponse(response);
    } catch (e) {
      return _errorResponse("Network error");
    }
  }

  // ================= SAFE RESPONSE =================
  static Map<String, dynamic> _safeResponse(http.Response response) {
    try {
      final decoded = jsonDecode(response.body);
      return {
        "status": response.statusCode,
        "body": decoded,
      };
    } catch (e) {
      return {
        "status": response.statusCode,
        "body": {
          "success": false,
          "message": "Invalid server response"
        }
      };
    }
  }

  static Map<String, dynamic> _errorResponse(String message) {
    return {
      "status": 500,
      "body": {
        "success": false,
        "message": message,
      }
    };
  }

  // ================= HEADERS =================
  static Map<String, String> _headers({String? token}) {
    return {
      "Content-Type": "application/json",
      "Accept": "application/json",
      if (token != null) "Authorization": "Bearer $token",
    };
  }
}