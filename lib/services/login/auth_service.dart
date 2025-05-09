import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  Future<http.Response> login(String email, String password) async {
    final url = Uri.parse("https://explusmobile.worldvision.org.ph/explus-mobile/developer/laravel-backend/public/api/authenticate");
    
    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email, "password": password}),
      );

      return response; 
    } catch (e) {
      print("Login request failed: $e");
      return http.Response('{"error": "Network error"}', 500);
    }
  }
}


  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

