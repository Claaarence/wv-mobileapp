import 'package:flutter/material.dart';
import 'navigation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import '../services/partnerInfo/auth_service.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Map<String, dynamic>? profileData;
  String avatarUrl = "N/A";
  final String baseUrl = "https://myspon.worldvision.org.ph/public/uploads/";

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }


  Future<void> _loadProfile() async {
  try {
    final data = await AuthService().fetchProfile();
    if (data != null) {
      setState(() {
        profileData = data;
      });
      debugPrint("Profile data loaded.");
    } else {
      debugPrint("No profile data fetched from API.");
    }

    // Now load avatar URL from SharedPreferences
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? storedAvatarUrl = prefs.getString('avatar_url');

    if (storedAvatarUrl != null && storedAvatarUrl.isNotEmpty) {
      setState(() {
        avatarUrl = baseUrl + storedAvatarUrl; // Combine base URL with stored avatar URL
      });
      debugPrint("Loaded Avatar URL from SharedPreferences: $avatarUrl");
    } else {
      debugPrint("No Avatar URL found in SharedPreferences.");
    }
  } catch (e) {
    debugPrint("Error loading profile or avatar: $e");
  }
}

@override
Widget build(BuildContext context) {
  final bottomPadding = MediaQuery.of(context).padding.bottom;

  return Scaffold(
    backgroundColor: const Color(0xFFeb7f35),
    drawer: const AppDrawer(selectedItem: 'Profile'),
    body: Column(
      children: [
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
            child: Row(
              children: [
                Builder(
                  builder: (context) => IconButton(
                    icon: const Icon(Icons.menu, color: Colors.white),
                    onPressed: () => Scaffold.of(context).openDrawer(),
                  ),
                ),
                const Expanded(
                  child: Text(
                    "Your Profile",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 48),
              ],
            ),
          ),
        ),

        profileData == null
            ? const Expanded(
                child: Center(
                  child: CircularProgressIndicator(color: Colors.white),
                ),
              )
            : Expanded(
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        CircleAvatar(
                          radius: 60,
                          backgroundColor: Colors.grey[300],
                          backgroundImage: avatarUrl.isNotEmpty
                              ? NetworkImage(avatarUrl)
                              : null,
                          child: avatarUrl.isEmpty
                              ? const Icon(Icons.person, size: 60, color: Colors.white)
                              : null,
                        ),
                        Positioned(
                          bottom: 0,
                          right: 5,
                          child: GestureDetector(
                            onTap: () {},
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.orange,
                                boxShadow: [
                                  BoxShadow(
                                      color: Colors.black26, blurRadius: 5, offset: Offset(0, 2)),
                                ],
                              ),
                              padding: const EdgeInsets.all(6),
                              child: const Icon(Icons.edit, color: Colors.white, size: 18),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                   
                    const SizedBox(height: 20),

                    /// Scrollable Container Overlapping Gesture Area
                    Expanded(
                      child: Container(
                        width: double.infinity,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
                        ),
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            return SingleChildScrollView(
                              physics: const BouncingScrollPhysics(),
                              padding: EdgeInsets.fromLTRB(16, 25, 16, bottomPadding + 30),
                              child: ConstrainedBox(
                                constraints: BoxConstraints(
                                  minHeight: constraints.maxHeight + bottomPadding,
                                ),
                                child: IntrinsicHeight(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: [
                                      // Basic Info
                                      Card(
                                        elevation: 5,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(20.0),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              const Text(
                                                "Basic Information",
                                                style: TextStyle(
                                                    fontSize: 22,
                                                    fontWeight: FontWeight.bold),
                                              ),
                                              const Divider(thickness: 1, color: Colors.grey),
                                              _buildProfileInfo("👤 Name", profileData!["partnership_name"]),
                                              _buildProfileInfo("🎩 Salutation", profileData!["salutation"]),
                                              _buildProfileInfo("🎂 Birthdate", profileData!["birthdate"]),
                                            ],
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 20),

                                      // Contact Info
                                      Card(
                                        elevation: 5,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(20.0),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              const Text(
                                                "Contact Information",
                                                style: TextStyle(
                                                    fontSize: 22,
                                                    fontWeight: FontWeight.bold),
                                              ),
                                              const Divider(thickness: 1, color: Colors.grey),
                                              _buildProfileInfo("🏠 Address", profileData!["address"]),
                                              const Divider(thickness: 1, color: Colors.grey),
                                              _buildProfileInfo("📧 Email", profileData!["email"]),
                                              const Divider(thickness: 1, color: Colors.grey),
                                              _buildProfileInfo("📅 Sponsorship Start", profileData!["start_of_sponsorship"]),
                                              const Divider(thickness: 1, color: Colors.grey),
                                              _buildProfileInfo("📞 Phone", profileData!["phone_number"][0]["phone_number"]),
                                            ],
                                          ),
                                        ),
                                      ),
                                      const Spacer(),

                                      // Edit Button
                                      Center(
                                        child: ElevatedButton.icon(
                                          onPressed: () {},
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.orange,
                                            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(16),
                                            ),
                                          ),
                                          icon: const Icon(Icons.edit, color: Colors.white),
                                          label: const Text(
                                            "Edit Profile",
                                            style: TextStyle(fontSize: 18, color: Colors.white),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 30),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ],
    ),
  );
}

Widget _buildProfileInfo(String title, String value) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 5),
    child: Row(
      children: [
        Text(
          "$title: ",
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 16),
          ),
        ),
      ],
    ),
  );
}
}