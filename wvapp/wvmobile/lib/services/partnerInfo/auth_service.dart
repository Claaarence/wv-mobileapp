import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http_parser/http_parser.dart';

class AuthService {
  Future<Map<String, dynamic>?> fetchProfile() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');

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


Future<bool> uploadAvatar(File imageFile) async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('token');

  if (token == null) {
    print("No token found");
    return false;
  }

  final uri = Uri.parse("https://explusmobile.worldvision.org.ph/explus-mobile/developer/laravel-backend/public/api/mobile/v2/upload-avatar");

  try {
    final request = http.MultipartRequest('POST', uri);
    request.headers['Authorization'] = 'Bearer $token';
    // Do NOT manually set content-type here — MultipartRequest handles it

    // Upload the file under the name "avatar" — which Laravel expects
    request.files.add(await http.MultipartFile.fromPath(
      'avatar',
      imageFile.path,
      contentType: MediaType('image', 'jpeg'), // or png if needed
    ));

    final response = await request.send();
    final responseBody = await response.stream.bytesToString();

    print("Status: ${response.statusCode}");
    print("Body: $responseBody");

    // Laravel returns 406 if validation fails (e.g., no file sent)
    return response.statusCode == 200;
  } catch (e) {
    print("Upload failed: $e");
    return false;
  }
}




  // NEW method for updating profile data via POST
  Future<Map<String, dynamic>?> updateProfile(Map<String, dynamic> updatedData) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');

    if (token == null) {
      print("No token found in SharedPreferences.");
      return null;
    }

    // <-- Use the actual update URL here
    final String updateUrl = "https://explusmobile.worldvision.org.ph/explus-mobile/developer/laravel-backend/public/api/mobile/v2/update-partner-info";

    try {
      final response = await http.post(
        Uri.parse(updateUrl),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        body: jsonEncode(updatedData),
      );

      print("HTTP Status Code (update): ${response.statusCode}");
      print("Raw API Response (update): ${response.body}");

      final Map<String, dynamic> responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return responseData;
      } else {
        // Return errors or response for handling in UI
        return responseData;
      }
    } catch (e) {
      print("Error updating profile: $e");
      return null;
    }
  }
}
