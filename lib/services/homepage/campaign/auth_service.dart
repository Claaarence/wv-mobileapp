import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class CampaignAuthService {
  /// Fetch campaigns from the API, exclude those with an empty image
  Future<List<dynamic>> fetchCampaigns() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');

    if (token == null) {
      print("No token found in SharedPreferences.");
      return [];
    }

    const String url = "https://explusmobile.worldvision.org.ph/explus-mobile/developer/laravel-backend/public/api/mobile/v2/card?card_category=6";

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);

        if (responseData.containsKey('data')) {
          final List<dynamic> allCampaigns = responseData['data'];

          // Filter out only those with item_image exactly equal to empty string
          final List<dynamic> filteredCampaigns = allCampaigns.where((campaign) {
            final image = campaign['item_image'];
            return image != '';
          }).toList();

          return filteredCampaigns;
        } else {
          print("Unexpected response structure: $responseData");
          return [];
        }
      } else {
        print("Failed to fetch campaigns: ${response.statusCode} - ${response.body}");
        return [];
      }
    } catch (e) {
      print("Error fetching campaigns: $e");
      return [];
    }
  }
}
