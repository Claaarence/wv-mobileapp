import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart'; 
import 'package:http/http.dart' as http; 
import '../services/donations/auth_service.dart';  
import 'navigation.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_custom_tabs/flutter_custom_tabs.dart';

class DonationPage extends StatefulWidget {
  const DonationPage({super.key});

  @override
  _DonationPageState createState() => _DonationPageState();
}

class _DonationPageState extends State<DonationPage> {
  late Future<List<Map<String, dynamic>>?> donationData;
  List<Map<String, dynamic>> donations = []; 
  bool isLoading = false;
  String? lastId; 

  @override
  void initState() {
    super.initState();
    donationData = _fetchDonationData();
  }

  
  Future<List<Map<String, dynamic>>?> _fetchDonationData() async {
    final newDonations = await AuthService().fetchDonationData(lastId: lastId);

    if (newDonations != null && newDonations.isNotEmpty) {
      setState(() {
        donations.addAll(newDonations); 
        lastId = newDonations.last['id'].toString(); 
      });
    }

    return newDonations;
  }

 
  void _viewReceipt(String receiptUrl) async {
    bool isPdf = await _isPdf(receiptUrl); 
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PDFOrImageViewerScreen(receiptUrl: receiptUrl, isPdf: isPdf),
      ),
    );
  }

  Future<bool> _isPdf(String url) async {
    try {
      final response = await http.head(Uri.parse(url));
      final contentType = response.headers['content-type'];
      return contentType != null && contentType.contains('pdf');
    } catch (e) {
      return false; 
    }
  }

@override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: const Color(0xFFeb7f35),
    drawer: const AppDrawer(selectedItem: 'Donation'),
      body: SafeArea(
      child: Column(
        children: [
          // HEADER remains unchanged
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
            child: Row(
              children: [
                Builder(
                  builder: (context) => IconButton(
                    icon: const Icon(Icons.menu, color: Colors.white),
                    onPressed: () => Scaffold.of(context).openDrawer(),
                  ),
                ),
                Expanded(
                  child: Text(
                    "Your Donations",
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.white),
                  onPressed: () {
                    // Notification action
                  },
                ),
              ],
            ),
          ),

          // WHITE CONTAINER FOR CONTENT
          Expanded(
            child: Container(
              color: Colors.white,
              child: FutureBuilder<List<Map<String, dynamic>>?>(
                future: donationData,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFFeb7f35),
                      ),
                    );
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data == null || snapshot.data!.isEmpty) {
                    return const Center(child: Text('No donation data available.'));
                  } else {
                    return NotificationListener<ScrollNotification>(
                      onNotification: (scrollNotification) {
                        if (scrollNotification is ScrollEndNotification &&
                            !isLoading &&
                            scrollNotification.metrics.pixels == scrollNotification.metrics.maxScrollExtent) {
                          _loadMoreData();
                        }
                        return true;
                      },
                      child: ListView.builder(
                        itemCount: donations.length + (isLoading ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index == donations.length && isLoading) {
                            return const Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(height: 10),
                                  SpinKitThreeBounce(
                                    color: Color(0xFFeb7f35),
                                    size: 20.0,
                                  ),
                                  SizedBox(height: 10),
                                  Text(
                                    'Loading more donations...',
                                    style: TextStyle(color: Color(0xFFeb7f35), fontSize: 16),
                                  ),
                                ],
                              ),
                            );
                          }

                          return _buildDonationItem(donations[index]);
                        },
                      ),
                    );
                  }
                },
              ),
            ),
          ),

          // FOOTER remains unchanged
          Container(
            padding: const EdgeInsets.symmetric(vertical: 5),
            color: const Color(0xFFeb7f35),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.credit_card, size: 30, color: Colors.white),
                      onPressed: () => _launchURL(context),
                    ),
                    const Text("Use Card", style: TextStyle(color: Colors.white)),
                  ],
                ),
                Column(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.upload_file, size: 30, color: Colors.white),
                      onPressed: () {
                        // Handle upload receipt action
                      },
                    ),
                    const Text("Upload Receipt", style: TextStyle(color: Colors.white)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    ),
      );
    }

// Function to open the browser using flutter_custom_tabs
void _launchURL(BuildContext context) async {
    final theme = Theme.of(context);
    try {
      await launchUrl(
        Uri.parse('https://self-service-payment.worldvision.org.ph/?_gl=1*1f709bf*_ga*MTkzOTI2NDc2OC4xNzQzMDYzNDM2*_ga_Z7N0QFHDT2*MTc0MzU3NzkwOS4zLjEuMTc0MzU3ODEwOS4yMy4wLjIyMjU5MDEzNw..'),  
        customTabsOptions: CustomTabsOptions(
          colorSchemes: CustomTabsColorSchemes.defaults(
            toolbarColor: theme.colorScheme.surface,  
          ),
          shareState: CustomTabsShareState.on,
          urlBarHidingEnabled: true,
          showTitle: true,
          closeButton: CustomTabsCloseButton(
            icon: CustomTabsCloseButtonIcons.back,
          ),
        ),
        safariVCOptions: SafariViewControllerOptions(
          preferredBarTintColor: theme.colorScheme.surface, 
          preferredControlTintColor: theme.colorScheme.onSurface, 
          barCollapsingEnabled: true,
          dismissButtonStyle: SafariViewControllerDismissButtonStyle.close,  
        ),
      );
    } catch (e) {
      debugPrint('Failed to launch URL: $e');
    }
  }

  // Build individual donation item widget
Widget _buildDonationItem(Map<String, dynamic> donation) {
  final amount = donation['amount'] ?? 'N/A';
  final receiptDate = donation['receipt_date'] ?? 'N/A';
  final paymentMethod = donation['payment_method'] ?? 'N/A';
  final receiptUrl = donation['receipt_url'] ?? 'N/A';

  return Padding(
    padding: const EdgeInsets.only(top: 16.0, left: 16, right: 16),
    child: GestureDetector(
      onTap: () {
        _viewReceipt(receiptUrl); // Open appropriate viewer based on file type
      },
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.white, // cleaner and more contrasty against background
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              spreadRadius: 2,
              blurRadius: 12,
              offset: const Offset(0, 6), // softer vertical elevation
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.calendar_today, color: Color(0xFFeb7f35)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "Receipt Date: $receiptDate",
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.attach_money, color: Color(0xFFeb7f35)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "Amount: \$ $amount",
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.payment, color: Color(0xFFeb7f35)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "Payment Method: $paymentMethod",
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Center(
              child: Text(
                "Tap this to view receipt",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Color.fromARGB(143, 126, 126, 126),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}



  // Function to load more data when user reaches the bottom
  Future<void> _loadMoreData() async {
    if (isLoading) return; // Prevent multiple requests

    setState(() {
      isLoading = true; // Indicate loading is in progress
    });

    try {
      await Future.delayed(const Duration(seconds: 2)); // Simulate a delay
      await _fetchDonationData(); // Fetch the next batch of donations
    } finally {
      setState(() {
        isLoading = false; // Reset loading state
      });
    }
  }
}

// PDF/Image Viewer screen to display either the PDF or Image
class PDFOrImageViewerScreen extends StatelessWidget {
  final String receiptUrl;
  final bool isPdf;

  const PDFOrImageViewerScreen({super.key, required this.receiptUrl, required this.isPdf});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Receipt Viewer"),
      ),
      body: isPdf 
        ? SfPdfViewer.network(receiptUrl)  // PDF viewer for PDFs
        : Image.network(receiptUrl)
         );     // Image widget for JPG/PNG
  }
}
