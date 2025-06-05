import 'package:flutter/material.dart';
import '../../services/homepage/campaign/auth_service.dart';


class CampaignsPage extends StatefulWidget {
  const CampaignsPage({super.key});

  @override
  State<CampaignsPage> createState() => _CampaignsPageState();
}

class _CampaignsPageState extends State<CampaignsPage> {
  List campaigns = [];
  bool isLoading = true;
  final String imageBaseUrl =
      "https://explusmobile.worldvision.org.ph/explus-mobile/developer/laravel-backend/public/temp/";

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    fetchCampaigns();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  }

  Future<void> fetchCampaigns() async {
    try {
      final fetchedCampaigns = await CampaignAuthService().fetchCampaigns();

      final filtered = fetchedCampaigns.where((campaign) {
        final image = campaign['image'];
        return image != null && image.toString().trim().isNotEmpty;
      }).toList();

      setState(() {
        campaigns = filtered;
        isLoading = false;
      });
    } catch (e) {
      debugPrint('Failed to fetch campaigns: $e');
      setState(() {
        isLoading = false;
      });
    }
  }
void _showCampaignModal(
  BuildContext context, String title, String imageUrl, String message) {
  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    transitionDuration: const Duration(milliseconds: 300),
    pageBuilder: (context, animation, secondaryAnimation) {
      return Center(
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: MediaQuery.of(context).size.width * 0.85,
            height: MediaQuery.of(context).size.height * 0.75,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Image with shadow below and close button inside
                  Stack(
                    children: [
                      Container(
                        decoration: const BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 10,
                              offset: Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Image.network(
                          imageUrl,
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        top: 10,
                        right: 10,
                        child: GestureDetector(
                          onTap: () => Navigator.of(context).pop(),
                          child: Container(
                            width: 36,
                            height: 36,
                            child: const Icon(
                              Icons.close,
                              color: Color(0xFFeb7f35),
                              size: 28,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            Text(
                              title,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                                color: Color(0xFFeb7f35),
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 12),
                            UrlBoldText(_cleanHtml(message)),
                          ],
                        ),
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
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      return ScaleTransition(
        scale: CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
        child: child,
      );
    },
  );
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
                  const Text(
                    'Campaigns',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
                child: SafeArea(
                  top: true,
                  bottom: false,
                  child: Container(
                    color: Colors.white,
                    child: isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : ListView.builder(
                            controller: _scrollController,
                            reverse: true,
                            padding: EdgeInsets.zero,
                            itemCount: campaigns.length,
                            itemBuilder: (context, index) {
                              final campaign = campaigns[index];
                              final fullImageUrl = "$imageBaseUrl${campaign['image']}";
                              final shortDesc =
                                  _stripHtmlTags(campaign['short_description'] ?? '');

                              return GestureDetector(
                                onTap: () => _showCampaignModal(
                                  context,
                                  campaign['subject'] ?? '',
                                  fullImageUrl,
                                  campaign['message'] ?? '',
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 8),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(16),
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color.fromARGB(255, 65, 65, 65).withOpacity(0.3),
                                          blurRadius: 8,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        ClipRRect(
                                          borderRadius: const BorderRadius.vertical(
                                              top: Radius.circular(16)),
                                          child: Image.network(
                                            fullImageUrl,
                                            width: double.infinity,
                                            height: 200,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(12),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                campaign['subject'] ?? '',
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 20,
                                                  color: Color(0xFFeb7f35),
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                shortDesc,
                                                style: const TextStyle(
                                                    fontSize: 13, color: Color.fromARGB(255, 44, 44, 44)),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _stripHtmlTags(String htmlText) {
    String withoutTags = RegExp(r'<[^>]*>', multiLine: true, caseSensitive: true)
        .allMatches(htmlText)
        .fold(htmlText, (str, match) => str.replaceAll(match.group(0)!, ''))
        .trim();
    return withoutTags.replaceAll('&nbsp;', ' ').trim();
  }

  String _cleanHtml(String htmlText) {
    String withoutTags = htmlText
        .replaceAll(RegExp(r'<br\s*\/?>', caseSensitive: false), '\n')
        .replaceAll(RegExp(r'</p>', caseSensitive: false), '\n\n')
        .replaceAll(RegExp(r'<[^>]*>', multiLine: true), '')
        .replaceAll('&nbsp;', ' ')
        .trim();

    return withoutTags;
  }
}
class UrlBoldText extends StatelessWidget {
  final String text;

  UrlBoldText(this.text);

  static final urlRegExp = RegExp(
    r'((https?:\/\/)|(www\.))[^\s]+',
    caseSensitive: false,
  );

  @override
  Widget build(BuildContext context) {
    final paragraphs = text.split(RegExp(r'\n+'));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: paragraphs.map((paragraph) {
        final spans = <TextSpan>[];
        final matches = urlRegExp.allMatches(paragraph);

        int start = 0;
        for (final match in matches) {
          if (match.start > start) {
            spans.add(TextSpan(text: paragraph.substring(start, match.start)));
          }
          final urlText = paragraph.substring(match.start, match.end);
          spans.add(TextSpan(
            text: urlText,
            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
          ));
          start = match.end;
        }
        if (start < paragraph.length) {
          spans.add(TextSpan(text: paragraph.substring(start)));
        }

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: RichText(
            textAlign: TextAlign.justify,
            text: TextSpan(
              style: const TextStyle(fontSize: 14, color: Colors.black87, height: 1.5),
              children: spans,
            ),
          ),
        );
      }).toList(),
    );
  }
}
