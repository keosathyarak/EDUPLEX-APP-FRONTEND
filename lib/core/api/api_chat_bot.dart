import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import '../core/api/api_config.dart';
import 'api_config.dart';

class ApiChatBot {
  static String get _endpoint => "${ApiConfig.baseUrl}/chatbot";

  static Future<String> sendMessageWithMemory({
    required String userMessage,
    required List<Map<String, String>> memory,
  }) async {
    try {
      final response = await http
          .post(
        Uri.parse(_endpoint),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode({
          "message": userMessage,
          "memory": memory,
        }),
      )
          .timeout(const Duration(seconds: 60));

      if (response.statusCode != 200) {
        return "⚠️ AI service is unavailable right now. Please try again.";
      }

      final data = jsonDecode(response.body);

      return data["reply"]?.toString().trim() ??
          "⚠️ I couldn’t generate a response. Try again.";
    } on SocketException {
      return "❌ No internet connection. Please check your network.";
    } on TimeoutException {
      return "⏳ Internet is too slow. Please try again.";
    } catch (e) {
      print("ChatBot Error: $e");
      return "⚠️ Something went wrong. Please try again.";
    }
  }
}