import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  // Function to fetch donation data with pagination (last_id)
Future<List<Map<String, dynamic>>?> fetchDonationData({
  String? lastId,
  String? dateFrom,
  String? dateTo,
}) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  final String? token = prefs.getString('token');

  if (token == null) {
    print("No token found in SharedPreferences.");
    return null;
  }

  String baseUrl = "https://explusmobile.worldvision.org.ph/explus-mobile/developer/laravel-backend/public/api/mobile/v2/get-payments";
  String queryString = '';

  if (dateFrom != null && dateTo != null && lastId == null) {
    queryString = "?date_from=$dateFrom&date_to=$dateTo";
  } else if (dateFrom != null && dateTo != null && lastId != null) {
    queryString = "?date_from=$dateFrom&date_to=$dateTo&last_id=$lastId";
  } else if ((dateFrom == null || dateTo == null) && lastId != null) {
    queryString = "?last_id=$lastId";
  }

  final url = Uri.parse(baseUrl + queryString);
  print("Fetching donations from: $url");

  try {
    final response = await http.get(
      url,
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> responseData = jsonDecode(response.body);
      return List<Map<String, dynamic>>.from(responseData);
    } else {
      print("Failed to fetch data: ${response.body}");
      return null;
    }
  } catch (e) {
    print("Error fetching data: $e");
    return null;
  }
}

Future<bool> uploadReceiptImage(File file) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  final String? token = prefs.getString('token');

  if (token == null) {
    print("❌ Token not found.");
    return false;
  }

  final uri = Uri.parse("https://explusmobile.worldvision.org.ph/explus-mobile/developer/laravel-backend/public/api/mobile/v2/upload-deposit");

  final request = http.MultipartRequest('POST', uri)
    ..headers['Authorization'] = 'Bearer $token'
    ..files.add(
      await http.MultipartFile.fromPath(
        'filename', // API expects this field
        file.path,
        filename: basename(file.path),
      ),
    );

  try {
    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      print("✅ Upload successful.");
      return true;
    } else {
      print("❌ Upload failed with status: ${response.statusCode}");
      print("📩 Response body: ${response.body}");

      // Try decoding and printing JSON error details if available
      try {
        final errorJson = jsonDecode(response.body);
        print("🧾 Decoded error: $errorJson");
      } catch (_) {
        print("⚠️ Failed to decode response as JSON.");
      }

      return false;
    }
  } catch (e) {
    print("🔥 Exception while uploading: $e");
    return false;
  }
}
}