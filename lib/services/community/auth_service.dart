import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ConnectAuthService {
  Future<Map<String, dynamic>> fetchCommunityProfile(String childId) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');

    if (token == null) {
      print("No token found in SharedPreferences.");
      return {}; // or throw Exception("No token found");
    }

    final String url = "https://explusmobile.worldvision.org.ph/explus-mobile/developer/laravel-backend/public/api/mobile/v2/get-project-info?project_id=$childId";

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        print("Failed to fetch community profile: ${response.statusCode} - ${response.body}");
        return {};
      }
    } catch (e) {
      print("Error fetching community profile: $e");
      return {};
    }
  }
}

