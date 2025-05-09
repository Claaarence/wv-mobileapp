import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:async';
import 'package:wvmobile/widgets/skeleton_screen.dart';

import 'navigation.dart'; 
import 'profile.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isLoading = true;
  String userName = "Guest";
  double starOpacity = 1.0;
  String avatarUrl = "N/A";
  String userId = "N/A";
  final String baseUrl = "https://myspon.worldvision.org.ph/public/uploads/";
  Timer? _twinkleTimer;

@override
void initState() {
  super.initState();
  loadUserData();
  startTwinkleEffect();

  Future.delayed(const Duration(seconds: 3), () {
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  });
}

 Future<void> loadUserData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? userData = prefs.getString('userData');

    if (userData != null) {
      try {
        final Map<String, dynamic> decodedData = jsonDecode(userData);

        debugPrint("Decoded JSON: $decodedData"); // Debugging: Check full JSON output

        if (decodedData.containsKey('user') && decodedData['user'] is Map) {
          final Map<String, dynamic> user = decodedData['user'];

          if (user.containsKey('partner') && user['partner'] is Map) {
            final Map<String, dynamic> partner = user['partner'];

            String fullName = partner['given_name'] ?? "Guest";
            String displayName = fullName.split(' ').first;

            setState(() {
              userName = displayName;
              userId = partner['partner_id']?.toString() ?? "N/A";
            });
          }

          // Extract avatar_url from user (not inside partner)
          setState(() {
            avatarUrl = user['avatar_url'] != null && user['avatar_url'].isNotEmpty 
                ? baseUrl + user['avatar_url']
                : "";
          });
        }

        debugPrint("Extracted Name: $userName, ID: $userId, Avatar: $avatarUrl"); // Debugging: Verify extracted values
      } catch (e) {
        debugPrint("JSON Parsing Error: $e");
      }
    } else {
      debugPrint("No user data found in SharedPreferences.");
    }
  }

void startTwinkleEffect() {
  _twinkleTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
    if (mounted) {
      setState(() {
        starOpacity = starOpacity == 1.0 ? 0.1 : 1.0;
      });
    }
  });
}


 @override
  void dispose() {
    _twinkleTimer?.cancel(); 
    super.dispose();
  }


@override
Widget build(BuildContext context) {
  return Scaffold(
    drawer: const AppDrawer(selectedItem: 'Home'),
    body: _isLoading
        ? const SkeletonScreen() 
        : buildMainContent(context),
  );
}

Widget buildMainContent(BuildContext context) {
  return Stack(
    children: [
      Positioned.fill(
        child: Container(
          color: const Color(0xFFeb7f35),
        ),
      ),
          Positioned.fill(
            child: Column(
              children: [
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Builder(
                          builder: (context) => IconButton(
                            icon: const Icon(Icons.menu, color: Colors.white),
                            onPressed: () => Scaffold.of(context).openDrawer(),
                          ),
                        ),
                       Row(
                        children: [
                          const SizedBox(width: 10),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const ProfilePage()),
                              );
                            },
                            child: CircleAvatar(
                              radius: 20,
                              backgroundColor: Colors.white,
                              backgroundImage: avatarUrl.isNotEmpty 
                                  ? NetworkImage(avatarUrl) 
                                  : null,
                              child: avatarUrl.isEmpty
                                  ? const Icon(Icons.person, color: Colors.grey, size: 30)
                                  : null,
                            ),
                          ),
                        ],
                      ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Container(
                    width: double.infinity,
                    color: Colors.transparent,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Hello $userName!",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 45,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                const Text(
                                  "Glad to have you here!",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 5),
                              ],
                            ),
                            AnimatedOpacity(
                              duration: const Duration(seconds: 1),
                              opacity: starOpacity,
                              child: Image.asset(
                                "assets/star2.png",
                                width: 140,
                                height: 100,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 8,
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: Container(
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        child: ListView(
                          padding: EdgeInsets.zero,
                          children: [
                            buildCard("Child Updates", "assets/bgdash.jpg"),
                            const SizedBox(height: 16),
                            buildCard("Community Updates", "assets/community.png"),
                            const SizedBox(height: 16),
                            buildCard("Campaigns", "assets/campaigns.png"),
                            const SizedBox(height: 16),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      );
  }
Widget buildCard(String title, String imagePath) {
  return GestureDetector(
    onTap: () {
      switch (title) {
        case "Child Updates":
          Navigator.pushNamed(context, '/childupdates');
          break;
        case "Community Updates":
          Navigator.pushNamed(context, '/community');
          break;
        case "Campaigns":
          Navigator.pushNamed(context, '/campaigns');
          break;
        default:
          print('$title card clicked');
      }
    },
    child: Container(
      decoration: BoxDecoration(
        color: const Color(0xFFeb7f35),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            child: Image.asset(
              imagePath,
              height: 150,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Text(
              title,
              style: const TextStyle(
                color: Color.fromARGB(255, 255, 255, 255),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
}