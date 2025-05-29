import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:async';
import 'package:wvmobile/widgets/skeleton_screen.dart';
import '../helper/exithelper.dart';
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
  bool _assetsLoaded = false;


@override
void initState() {
  super.initState();
  loadUserData();
  startTwinkleEffect();

  // Preload image assets to detect when they're fully loaded
  _preloadImages().then((_) {
    if (mounted) {
      setState(() {
        _assetsLoaded = true;
        _isLoading = false;
      });
    }
  });
}

Future<void> _preloadImages() async {
  try {
    await Future.wait([
      precacheImage(const AssetImage("assets/star2.png"), context),
      precacheImage(const AssetImage("assets/bgdash.jpg"), context),
      precacheImage(const AssetImage("assets/community.png"), context),
      precacheImage(const AssetImage("assets/campaigns.png"), context),
    ]);
  } catch (e) {
    // Optional: handle errors or retry if needed
  }
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
    body: (!_assetsLoaded || _isLoading)
        ? const SkeletonScreen()
        : buildMainContent(context),
  );
}

Widget buildMainContent(BuildContext context) {
  ModalRoute.of(context)?.addScopedWillPopCallback(() async {
  return await showExitConfirmationDialog(context);
    });
  return Stack(
    children: [
      Positioned.fill(
       child: Column(
  children: [
    // Top 20% image with gradient overlay
    Expanded(
      flex: 5, // 20%
      child: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/hp.jpg', // Replace with your image
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.5),
                    const Color.fromARGB(255, 255, 102, 0).withOpacity(0.47),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    ),

    // Remaining 80% empty or with other content
    Expanded(
      flex: 8,
      child: Container(
        color: Colors.white, // Change this if needed
      ),
    ),
  ],
),
      ),
          Positioned.fill(
            child: Column(
              children: [
             SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 0),
                  child: Row(
                    children: [
                      // Left: Menu icon
                      Builder(
                        builder: (context) => IconButton(
                          icon: const Icon(Icons.menu, color: Colors.white),
                          onPressed: () => Scaffold.of(context).openDrawer(),
                        ),
                      ),
                      const Spacer(),
                      Image.asset(
                        'assets/wv2.png',
           
                        height: 25,
                      ),
                      const Spacer(),
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
                ),
              ),

                Expanded(
                      flex: 2,
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Row: Hello + Logo
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    // Greeting text
                                    Expanded(
                                      flex: 6,
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 8),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            FittedBox(
                                              fit: BoxFit.scaleDown,
                                              alignment: Alignment.centerLeft,
                                              child: Text(
                                                "Hello $userName!",
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 45,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            const Text(
                                              "Glad to have you here!",
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 20,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),

                                    // WV Logo
                                    Flexible(
                                      flex: 4,
                                      child: Align(
                                        alignment: Alignment.center,
                                        child: Image.asset(
                                          "assets/wvlogowhite.png",
                                          width: constraints.maxWidth * 0.4,
                                          height: 100,
                                          fit: BoxFit.contain,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 12),

                                // Vision text (spans below the entire row)
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(horizontal: 8),
                                  child: const Text(
                                    "Our vision for every child, life in all its fullness. Our prayer for every heart, the will to make it so.",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w400,
                                    ),
                                    textAlign: TextAlign.start,
                                  ),
                                ),

                                const SizedBox(height: 8),
                              ],
                            ),
                          );
                        },
                      ),
                    ),

                Expanded(
                  flex: 8,
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 11,
                          offset: Offset(0, -9),
                        ),
                      ],
                    ),
                    child: ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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