import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ContactUsAuthService {
  static Future<Map<String, dynamic>> sendFeedback(String feedback) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token'); 

    final url = Uri.parse("https://explusmobile.worldvision.org.ph/explus-mobile/developer/laravel-backend/public/api/mobile/v2/save-feedback"); 

    try {
      final response = await http.post(
        url,
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "feedback": feedback,
        }),
      );

      print("HTTP Status Code: ${response.statusCode}");
      print("Raw API Response: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {"success": true};
      } else if (response.statusCode == 422) {
        final data = jsonDecode(response.body);
        return {
          "success": false,
          "error": data["error"]["feedback"]?.first ?? "Unknown validation error"
        };
      } else {
        return {"success": false, "error": "Something went wrong"};
      }
    } catch (e) {
      print("Exception during feedback submission: $e");
      return {"success": false, "error": "Network error"};
    }
  }
}
