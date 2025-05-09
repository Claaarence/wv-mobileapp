import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  Future<Map<String, dynamic>?> fetchRewardsData({String? lastId}) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');

    if (token == null) {
      print("No token found in SharedPreferences.");
      return null;
    }

    String url = "https://explusmobile.worldvision.org.ph/explus-mobile/developer/laravel-backend/public/api/mobile/v2/get-reward-items"; // Update to your actual endpoint
    if (lastId != null) {
      url += "?last_id=$lastId";
    }

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return data; // contains "data" and "img_url"
      } else {
        print("Failed to fetch rewards: ${response.body}");
        return null;
      }
    } catch (e) {
      print("Error fetching rewards: $e");
      return null;
    }
  }
    Future<String?> fetchUserPoints() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');

    if (token == null) {
      print("No token found in SharedPreferences.");
      return null;
    }

    const String pointsUrl = "https://explusmobile.worldvision.org.ph/explus-mobile/developer/laravel-backend/public/api/mobile/v2/get-points"; 

    try {
      final response = await http.get(
        Uri.parse(pointsUrl),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return data['points'].toString(); // Assuming API response: { "points": "1200" }
      } else {
        print("Failed to fetch user points: ${response.body}");
        return null;
      }
    } catch (e) {
      print("Error fetching user points: $e");
      return null;
    }
  }
}

