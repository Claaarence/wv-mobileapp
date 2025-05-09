import 'package:flutter/material.dart';
import 'navigation.dart';
import '../services/badges/auth_service.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../helper/exithelper.dart';

class BadgesPage extends StatefulWidget {
  const BadgesPage({super.key});

  @override
  _BadgesPageState createState() => _BadgesPageState();
}

class _BadgesPageState extends State<BadgesPage> {
  List<dynamic> earnedBadges = [];
  List<dynamic> moreBadges = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchBadges();
  }

  Future<void> fetchBadges() async {
    try {
      List<dynamic> badges = await AuthService.getBadges();
      setState(() {
        earnedBadges = badges.where((b) => !b['hide']).toList();
        moreBadges = badges.where((b) => b['hide']).toList();
        isLoading = false; // 🔥 Done loading, show UI
      });
    } catch (e) {
      print('Error fetching badges: $e');
      setState(() {
        isLoading = false; // Also stop loading on error
      });
    }
  }


  Widget buildImage(String imageUrl, {double size = 80}) {
    if (imageUrl.toLowerCase().endsWith(".svg")) {
      return SvgPicture.network(
        imageUrl,
        height: size,
        width: size,
        placeholderBuilder: (context) => CircularProgressIndicator(),
        errorBuilder: (context, error, stackTrace) {
          return Icon(Icons.broken_image, size: size, color: Colors.grey);
        },
      );
    } else {
      return Image.network(
        imageUrl,
        height: size,
        width: size,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(child: CircularProgressIndicator());
        },
        errorBuilder: (context, error, stackTrace) {
          return Icon(Icons.broken_image, size: size, color: Colors.grey);
        },
      );
    }
  }

  void showBadgeDetails(BuildContext context, dynamic badge, {bool isMoreBadge = false}) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: Colors.orangeAccent.withOpacity(0.4), blurRadius: 20)],
                ),
                child: buildImage(badge['img_url'], size: 100),
              ),
              const SizedBox(height: 15),
              Text(
                badge['title'],
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
              if (!isMoreBadge) ...[
                const SizedBox(height: 10),
                Text(
                  badge['description'] ?? "No description available.",
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 14, color: Colors.black54),
                ),
              ],
              if (isMoreBadge) ...[
                const SizedBox(height: 20),
                const Text(
                  "How to Achieve?",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.orangeAccent),
                ),
                const SizedBox(height: 5),
                Text(
                  badge['description'] ?? "No description available.",
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 14, color: Colors.black54),
                ),
              ],
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    backgroundColor: Colors.orangeAccent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text("Close", style: TextStyle(fontSize: 16, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
     ModalRoute.of(context)?.addScopedWillPopCallback(() async {
      return await showExitConfirmationDialog(context);
    });
    return Scaffold(
      backgroundColor: const Color(0xFFeb7f35),
      drawer: const AppDrawer(selectedItem: 'Badges'),
      body: SafeArea(
        bottom: false,
        child: isLoading
            ? const Center(
                    child: CircularProgressIndicator(
                      color: Colors.white,
                    ),
                    )
            : Column(
                children: [
            // Header
            Container(
              color: const Color(0xFFeb7f35),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Builder(
                      builder: (context) => IconButton(
                        icon: const Icon(Icons.menu, color: Colors.white),
                        onPressed: () => Scaffold.of(context).openDrawer(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        "Your Badges",
                        textAlign: TextAlign.center,
                        style: const TextStyle(
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

            // Subheader Text
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
              child: const Text(
                "What you've earned so far!",
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),

            const SizedBox(height: 20),

            // Earned Badges List (Horizontal scroll)
            SizedBox(
              height: 180,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                itemCount: earnedBadges.length,
                itemBuilder: (context, index) {
                  var badge = earnedBadges[index];
                  return GestureDetector(
                    onTap: () => showBadgeDetails(context, badge),
                    child: Container(
                      width: 200,
                      margin: const EdgeInsets.only(right: 14, bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(3, 3))],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          buildImage(badge['img_url']),
                          const SizedBox(height: 10),
                          Text(
                            badge['title'],
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 20),

            // More Badges Section
            Expanded(
              child: SingleChildScrollView(
                child: Container(
                  color: Colors.white,
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "More Badges You Can Earn",
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black),
                      ),
                      const SizedBox(height: 10),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const BouncingScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 15,
                          mainAxisSpacing: 15,
                          childAspectRatio: 1,
                        ),
                        itemCount: moreBadges.length,
                        itemBuilder: (context, index) {
                          var badge = moreBadges[index];
                          return GestureDetector(
                            onTap: () => showBadgeDetails(context, badge, isMoreBadge: true),
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.orangeAccent.withOpacity(0.7),
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Opacity(opacity: 0.6, child: buildImage(badge['img_url'])),
                                  const SizedBox(height: 10),
                                  Text(
                                    badge['title'],
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white70),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
