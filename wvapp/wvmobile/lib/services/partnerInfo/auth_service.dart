import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
 Future<Map<String, dynamic>?> fetchProfile() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  final String? token = prefs.getString('token');

  // Debugging: Ensure token is retrieved
  print("DEBUG - Retrieved Token: $token");

  if (token == null) {
    print("No token found in SharedPreferences.");
    return null;
  }

  final String url = "https://explusmobile.worldvision.org.ph/explus-mobile/developer/laravel-backend/public/api/mobile/v2/get-partner-info";

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
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      print("Profile fetched successfully: $responseData");
      return responseData;
    } else {
      print("Failed to fetch profile: ${response.body}");
      return null;
    }
  } catch (e) {
    print("Error fetching profile: $e");
    return null;
  }
}
}
