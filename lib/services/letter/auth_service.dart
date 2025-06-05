import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class InboxAuthService {
  final String _baseUrl = "https://explusmobile.worldvision.org.ph/explus-mobile/developer/laravel-backend/public/api/mobile/v2";

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<List<dynamic>> fetchInboxLetter(String childId) async {
    final token = await _getToken();
    if (token == null) {
      print("No token found in SharedPreferences.");
      return [];
    }

    final String url = "$_baseUrl/view-letter?child_id=$childId";

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded is List) return decoded;
        if (decoded is Map && decoded.containsKey('data')) return decoded['data'];
        return [];
      } else {
        print("Failed to fetch inbox letter: ${response.statusCode} - ${response.body}");
        return [];
      }
    } catch (e) {
      print("Error fetching inbox letter: $e");
      return [];
    }
  }

  Future<List<dynamic>> fetchOutboxLetter(String childId) async {
    final token = await _getToken();
    if (token == null) {
      print("No token found in SharedPreferences.");
      return [];
    }

    final String url = "$_baseUrl/view-letter-outbox?child_id=$childId";

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded is List) return decoded;
        if (decoded is Map && decoded.containsKey('data')) return decoded['data'];
        return [];
      } else {
        print("Failed to fetch outbox letter: ${response.statusCode} - ${response.body}");
        return [];
      }
    } catch (e) {
      print("Error fetching outbox letter: $e");
      return [];
    }
  }
}
