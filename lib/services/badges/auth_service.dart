import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static Future<List<dynamic>> getBadges() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');

    if (token == null) {
      print("Error: No authentication token found.");
      throw Exception("No authentication token found.");
    }

    final String url =
        "https://explusmobile.worldvision.org.ph/explus-mobile/developer/laravel-backend/public/api/mobile/v2/get-badges";

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );

      print("HTTP Status Code: ${response.statusCode}");
      print("Raw API Response: ${response.body}");

      if (response.statusCode == 200) {
        final dynamic jsonResponse = jsonDecode(response.body);

        if (jsonResponse is List) {
          return jsonResponse;
        } else {
          throw Exception("Unexpected response format: Expected a list, got ${jsonResponse.runtimeType}");
        }
      } else {
        throw Exception("Failed to load badges: ${response.reasonPhrase}");
      }
    } catch (e) {
      print("Error fetching badges: $e");
      throw Exception("Error fetching badges: $e");
    }
  }
}
