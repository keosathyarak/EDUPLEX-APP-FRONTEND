import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class ApiChatBot {
  // ⚠️ DO NOT COMMIT REAL KEY
  static const String _apiKey = "AIzaSyCNu2k4PCSBRLaXkkUW4mFmCRxTeqAP5y0";

  static const String _endpoint =
      "https://generativelanguage.googleapis.com/v1beta/models/"
      "gemini-2.5-flash:generateContent";

  static Future<String> sendMessageWithMemory({
    required String userMessage,
    required List<Map<String, String>> memory,
  }) async {
    try {
      final contents = memory
          .map((m) => {
        "parts": [
          {"text": m["text"]}
        ]
      })
          .toList();

      contents.add({
        "parts": [
          {"text": userMessage}
        ]
      });

      final response = await http
          .post(
        Uri.parse("$_endpoint?key=$_apiKey"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"contents": contents}),
      )
          .timeout(const Duration(minutes: 10)); // ⏳ slow internet

      if (response.statusCode != 200) {
        return "⚠️ AI service is unavailable right now. Please try again.";
      }

      final data = jsonDecode(response.body);

      if (data["candidates"] == null || data["candidates"].isEmpty) {
        return "⚠️ I couldn’t generate a response. Try again.";
      }

      return data["candidates"][0]["content"]["parts"][0]["text"]
          .toString()
          .trim();
    }

    // ❌ No internet
    on SocketException {
      return "❌ No internet connection. Please check your network.";
    }

    // ⏳ Timeout (slow internet)
    on TimeoutException {
      return "⏳ Internet is too slow. Please try again.";
    }

    // ❌ Unknown error
    catch (e) {
      return "⚠️ Something went wrong. Please try again.";
    }
  }
}



