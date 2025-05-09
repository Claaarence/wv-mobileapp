import 'dart:convert';
import 'package:http/http.dart' as http;
import '/models/devotion.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final String baseUrl =
      'https://explusmobile.worldvision.org.ph/explus-mobile/developer/laravel-backend/public/api/mobile/v2';

  Future<Map<String, dynamic>> post(String endpoint, Map<String, dynamic> body) async {
    final url = Uri.parse("$baseUrl/$endpoint");
    final response = await http.post(
      url,
      body: json.encode(body),
      headers: {"Content-Type": "application/json"},
    );

    print("🔵 POST Request to: $url");
    print("📦 Body: $body");
    print("📥 Response: ${response.statusCode} => ${response.body}");

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception("❌ Failed to post data: ${response.statusCode}");
    }
  }

  // GET method
  Future<dynamic> get(String endpoint) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("token");

    if (token == null) {
      throw Exception("❌ No token found, user not logged in.");
    }

    final url = Uri.parse("$baseUrl/$endpoint");
    final response = await http.get(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    print("🟢 GET Request to: $url");
    print("📥 Response: ${response.statusCode} => ${response.body}");

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception("❌ Failed to fetch data: ${response.statusCode}");
    }
  }

  // Fetch devotion list
  Future<List<Devotion>> fetchDevotions() async {
    final response = await get('get-devo-list');

    print("🧾 Parsed Response: $response");

    if (response is List) {
      return response.map((json) => Devotion.fromJson(json)).toList();
    } else if (response is Map<String, dynamic> && response['data'] is List) {
      return (response['data'] as List)
          .map((json) => Devotion.fromJson(json))
          .toList();
    } else {
      throw Exception("⚠️ Unexpected API structure: ${response.runtimeType}");
    }
  }
}
