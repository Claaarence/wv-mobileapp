import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart';
import 'package:mime/mime.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LetterAuthService {
  final String baseUrl =
      'https://explusmobile.worldvision.org.ph/explus-mobile/developer/laravel-backend/public/api/mobile/v2';
Future<bool> sendLetter({
  required String message,
  required String childId,
}) async {
  try {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      print('❌ No token found');
      return false;
    }

    final uri = Uri.parse('$baseUrl/send-letter');
    final request = http.MultipartRequest('POST', uri)
      ..fields['message'] = message
      ..fields['child_id'] = childId
      ..headers['Authorization'] = 'Bearer $token';

    // Remove photo upload entirely

    final streamed = await request.send();
    final res = await http.Response.fromStream(streamed);

    print('📤 Status Code: ${res.statusCode}');
    print('📤 Response Body: ${res.body}');

   if (res.statusCode == 200) {
  // The API returns a JSON array like ["success"], not a Map.
  // So just check if the response body contains the word "success".
  if (res.body.contains('success')) {
    return true;
  } else {
    print('❌ API returned failure: ${res.body}');
    return false;
  }
} else {
  print('❌ HTTP error code: ${res.statusCode}');
  return false;
}

  } catch (e) {
    print('❌ Error sending letter: $e');
    return false;
  }
}
}