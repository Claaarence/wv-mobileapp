import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart'; // assuming token is stored here

class ChildAuthService {
  final String childInfoUrl = 'https://explusmobile.worldvision.org.ph/explus-mobile/developer/laravel-backend/public/api/mobile/v2/get-child-info'; 
  final String baseSrsUrl = 'https://explusmobile.worldvision.org.ph/explus-mobile/developer/laravel-backend/public/api/mobile/v2/get-srs-child?child_id=';

  Future<String?> getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token'); // adjust key if needed
  }

  Future<List<Map<String, dynamic>>> fetchChildInfo() async {
    final token = await getToken();
    if (token == null) {
      print('Token is null');
      return [];
    }

    try {
      final response = await http.get(
        Uri.parse(childInfoUrl),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      print('Status code: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        print('Raw API data: $data');
        return data.cast<Map<String, dynamic>>();
      } else {
        print('Request failed: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching child info: $e');
    }
    return [];
  }

  Future<List<Map<String, dynamic>>> fetchSrsListForChild(String childId) async {
    final token = await getToken();
    if (token == null) return [];

    final String url = '$baseSrsUrl$childId';

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.cast<Map<String, dynamic>>();
      }
    } catch (e) {
      print('Error fetching SRS list for child $childId: $e');
    }
    return [];
  }
}
