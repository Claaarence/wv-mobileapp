// ignore_for_file: library_private_types_in_public_api, deprecated_member_use
import 'package:flutter/material.dart';
import 'login.dart';
import 'home.dart';
import 'profile.dart';
import 'child.dart';
import 'donation.dart';
import 'devotion.dart';
import 'rewards.dart';
import 'badges.dart';
import 'contactus.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class AppDrawer extends StatefulWidget {
  final String selectedItem;

  const AppDrawer({super.key, required this.selectedItem});

  @override
  _AppDrawerState createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  late String _selectedItem;
  String userName = "";
  String userId = "";
  String avatarUrl = "";
  final baseUrl = "https://myspon.worldvision.org.ph/public/uploads/";

  @override
  void initState() {
    super.initState();
    _selectedItem = widget.selectedItem;
    loadUserData();
  }

  Future<void> loadUserData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? userData = prefs.getString('userData');

    if (userData != null) {
      try {
        final Map<String, dynamic> decodedData = jsonDecode(userData);

        debugPrint("Decoded JSON: $decodedData"); 

        if (decodedData.containsKey('user') && decodedData['user'] is Map) {
          final Map<String, dynamic> user = decodedData['user'];

          if (user.containsKey('partner') && user['partner'] is Map) {
            final Map<String, dynamic> partner = user['partner'];

            String fullName = partner['given_name'] ?? "Guest";
            String displayName = fullName;

            setState(() {
              userName = displayName;
              userId = partner['partner_id']?.toString() ?? "N/A";
            });
          }

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



  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double drawerWidth = screenWidth < 600 ? screenWidth * 0.75 : screenWidth * 0.5;

    return Drawer(
      width: drawerWidth,
      child: Stack(
        children: [
          Container(color: const Color(0xFFeb7f35)),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(screenWidth),
              const SizedBox(height: 20),
              buildDrawerItem(Icons.home, 'Home', const HomePage(), color: Color(0xFFEB7F35)),
              buildDrawerItem(Icons.person, 'Profile', const ProfilePage(), color: Color(0xFFEB7F35)),
              buildDrawerItem(Icons.child_care, 'Child', const ChildPage(), color: Color(0xFFEB7F35)),
              buildDrawerItem(Icons.volunteer_activism, 'Donation', const DonationPage(), color: Color(0xFFEB7F35)),
              buildDrawerItem(Icons.church, 'Devotion', const DevotionPage(), color: Color(0xFFEB7F35)),
              buildDrawerItem(Icons.card_giftcard, 'Rewards', const RewardsPage(), color: Color(0xFFEB7F35)),
              buildDrawerItem(Icons.emoji_events, 'Badges', const BadgesPage(), color: Color(0xFFEB7F35)),
              buildDrawerItem(Icons.contact_mail, 'Contact Us', const ContactUsPage(), color: Color(0xFFEB7F35)),
              const Spacer(),
              Divider(color: Colors.white.withOpacity(0.6), thickness: 1),
              buildDrawerItemSignout(Icons.logout, 'Sign Out', context),
              const SizedBox(height: 20),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(double screenWidth) {
    return Container(
      padding: const EdgeInsets.only(top: 50, left: 20, right: 20, bottom: 20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(bottomRight: Radius.circular(80)),
      ),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.asset(
              'assets/vw.png',
              width: screenWidth * 0.3,
            ),
          ),
          const SizedBox(height: 10),
          Divider(color: Colors.grey.withOpacity(0.6), thickness: 1),
          const SizedBox(height: 10),
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
              const SizedBox(width: 15),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    userName,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFeb7f35),
                    ),
                  ),
                  Text(
                    userId,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFeb7f35),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildDrawerItem(IconData icon, String title, Widget page, {required Color color}) {
    bool isSelected = _selectedItem == title;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 3),
      child: Container(
        decoration: isSelected
            ? BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Colors.white, Colors.white70],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(10),
              )
            : null,
        child: ListTile(
          leading: Icon(
            icon,
            color: isSelected ? const Color(0xFFeb7f35) : Colors.white,
          ),
          title: Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isSelected ? const Color(0xFFeb7f35) : Colors.white,
            ),
          ),
          onTap: () {
            if (_selectedItem != title) {
              setState(() => _selectedItem = title);
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => page),
              );
            }
          },
        ),
      ),
    );
  }

  Widget buildDrawerItemSignout(IconData icon, String title, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      child: ListTile(
        leading: Icon(icon, color: Colors.white),
        title: const Text(
          'Sign Out',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        onTap: () {
          Navigator.pop(context);
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const LoginPage()),
          );
        },
      ),
    );
  }
}
