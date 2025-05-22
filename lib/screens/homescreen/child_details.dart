import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../services/homepage/child_module/auth_service.dart';

class ChildDetailPage extends StatefulWidget {
  final String childId;
  final String childName;

  const ChildDetailPage({super.key, required this.childId, required this.childName});

  @override
  State<ChildDetailPage> createState() => _ChildDetailPageState();
}

class _ChildDetailPageState extends State<ChildDetailPage> {
  List<Map<String, dynamic>> srsList = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchSrsUpdates();
  }

  Future<void> fetchSrsUpdates() async {
    final data = await ChildAuthService().fetchSrsListForChild(widget.childId);
    setState(() {
      srsList = data;
      isLoading = false;
    });
  }

void showDescription(String srsDescription, String title) {
  showGeneralDialog(
    context: context,
    barrierLabel: "Description",
    barrierDismissible: true,
    barrierColor: Colors.black.withOpacity(0.5),
    transitionDuration: const Duration(milliseconds: 300),
    pageBuilder: (_, __, ___) {
      return Center(
        child: Material(
          color: Colors.transparent,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 24),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFeb7f35).withOpacity(0.3),
                  blurRadius: 20,
                  spreadRadius: 1,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFeb7f35),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 3,
                    width: 60,
                    color: const Color(0xFFeb7f35),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    srsDescription,
                    textAlign: TextAlign.justify, // 👈 This makes the text justified
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFeb7f35),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text(
                      "Close",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    },
    transitionBuilder: (_, anim, __, child) {
      return ScaleTransition(
        scale: CurvedAnimation(
          parent: anim,
          curve: Curves.easeOutBack,
        ),
        child: child,
      );
    },
  );
}


  Future<WebViewController> createSvgController(String svgUrl) async {
    final controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted);

    final svgText = await NetworkAssetBundle(Uri.parse(svgUrl)).loadString('');

    final htmlContent = '''
      <!DOCTYPE html>
      <html>
        <head>
          <meta name="viewport" content="width=device-width, initial-scale=1.0">
          <style>
            html, body {
              margin: 0;
              padding: 0;
              background: transparent;
              overflow: hidden;
              width: 100%;
              height: 100%;
            }
            svg {
              display: block;
              width: 100%;
              height: 100%;
            }
          </style>
        </head>
        <body>
          $svgText
        </body>
      </html>
    ''';

    await controller.loadHtmlString(htmlContent);
    return controller;
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
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 8),
                  Text(
                  "${widget.childName}'s Update",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            // White rounded container with list
            Expanded(
              child: Stack(
                children: [
                  Positioned.fill(
                    top: 0,
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 8,
                            offset: Offset(0, -3),
                          ),
                        ],
                      ),
                      child: isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : srsList.isEmpty
                              ? const Center(child: Text('No updates found'))
                              : ListView.builder(
                                  padding: const EdgeInsets.all(16),
                                  itemCount: srsList.length,
                                  itemBuilder: (context, index) {
                                    final update = srsList[index];
                                    final title = update['sector_name'] ?? 'Untitled';
                                    final description = update['participation_date'] ?? 'No description';
                                    final srs_description = update['srs_description'] ?? 'No description';
                                    final rawIcon = update['icon'] ?? '';
                                    final imageUrl = formatImageUrl(rawIcon);

                                    return GestureDetector(
                                      onTap: () => showDescription(srs_description, title),
                                      child: Container(
                                        margin: const EdgeInsets.only(bottom: 12),
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(12),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(0.1),
                                              blurRadius: 6,
                                              offset: const Offset(0, 3),
                                            ),
                                          ],
                                        ),
                                        child: Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            imageUrl.endsWith('.svg')
                                                ? FutureBuilder<WebViewController>(
                                                    future: createSvgController(imageUrl),
                                                    builder: (context, snapshot) {
                                                      if (!snapshot.hasData) {
                                                        return const SizedBox(
                                                          width: 60,
                                                          height: 60,
                                                          child: Center(child: CircularProgressIndicator()),
                                                        );
                                                      }
                                                      return GestureDetector(
                                                        onTap: () {
                                                          showDialog(
                                                            context: context,
                                                            builder: (_) => AlertDialog(
                                                              contentPadding: const EdgeInsets.all(0),
                                                              content: SizedBox(
                                                                width: 300,
                                                                height: 300,
                                                                child: WebViewWidget(controller: snapshot.data!),
                                                              ),
                                                            ),
                                                          );
                                                        },
                                                        child: SizedBox(
                                                          width: 60,
                                                          height: 60,
                                                          child: ClipRRect(
                                                            borderRadius: BorderRadius.circular(30),
                                                            child: WebViewWidget(controller: snapshot.data!),
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                  )
                                                : ClipOval(
                                                    child: Image.network(
                                                      imageUrl,
                                                      width: 60,
                                                      height: 60,
                                                      fit: BoxFit.cover,
                                                      errorBuilder: (context, error, stackTrace) {
                                                        return Container(
                                                          width: 60,
                                                          height: 60,
                                                          color: Colors.grey[300],
                                                          child: const Icon(Icons.person, size: 30),
                                                        );
                                                      },
                                                    ),
                                                  ),
                                            const SizedBox(width: 16),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    title,
                                                    style: const TextStyle(
                                                      fontSize: 18,
                                                      fontWeight: FontWeight.bold,
                                                      color: Colors.black87,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    description.length > 60
                                                        ? '${description.substring(0, 60)}...'
                                                        : description,
                                                    style: const TextStyle(
                                                      fontSize: 14,
                                                      color: Colors.black54,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 4),
                                                  const Text(
                                                    'Tap to read more',
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      fontStyle: FontStyle.italic,
                                                      color: Colors.deepOrange,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
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
      ),
    );
  }

  String formatImageUrl(String rawUrl) {
    if (rawUrl.isEmpty) return '';
    final trimmedUrl = rawUrl.trim();
    if (trimmedUrl.startsWith('http')) return trimmedUrl;
    return 'https://$trimmedUrl';
  }
}
