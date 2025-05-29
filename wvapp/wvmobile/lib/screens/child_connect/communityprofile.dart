import 'package:flutter/material.dart';
import '/services/community/auth_service.dart';

class CommunityProfilePage extends StatefulWidget {
  final String childId;
  const CommunityProfilePage({super.key, required this.childId});

  @override
  State<CommunityProfilePage> createState() => _CommunityProfilePageState();
}

class _CommunityProfilePageState extends State<CommunityProfilePage> {
  late Future<Map<String, dynamic>> _communityData;

  @override
  void initState() {
    super.initState();
    _communityData = ConnectAuthService().fetchCommunityProfile(widget.childId);
  }

  String stripHtmlTags(String htmlText) {
    final RegExp exp = RegExp(r'<[^>]*>', multiLine: true, caseSensitive: true);
    return htmlText.replaceAll(exp, '');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFeb7f35),
      body: SafeArea(
        top: true,
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Community Profile',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
                child: Container(
                  color: Colors.white,
                  padding: const EdgeInsets.all(16),
                  child: FutureBuilder<Map<String, dynamic>>(
                    future: _communityData,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Center(child: Text('No data found.'));
                      }

                      final data = snapshot.data!;
                      final projectName = data['project_name'] ?? 'Unnamed Project';
                      final mapUrl = data['map_url'];
                      final rawDescription = data['short_description'] ?? 'No description available.';
                      final cleanedDescription = stripHtmlTags(rawDescription);

                      final words = cleanedDescription.trim().split(' ');
                      final firstWord = words.isNotEmpty ? words.first : '';
                      final remainingText = words.length > 1 ? words.sublist(1).join(' ') : '';

                      return ListView(
                        children: [
                          Center(
                            child: Text(
                              projectName.toUpperCase(),
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          if (mapUrl != null && mapUrl.toString().isNotEmpty)
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                mapUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => const Text("Image failed to load."),
                              ),
                            )
                          else
                            const Text("No image available."),
                          const SizedBox(height: 20),
                          RichText(
                            textAlign: TextAlign.justify,
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: '$firstWord ',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFFeb7f35),
                                    fontSize: 16,
                                  ),
                                ),
                                TextSpan(
                                  text: remainingText,
                                  style: const TextStyle(
                                    color: Colors.black87,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
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
