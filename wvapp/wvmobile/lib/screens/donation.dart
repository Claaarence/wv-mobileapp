import 'dart:io';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart'; 
import 'package:http/http.dart' as http; 
import '../services/donations/auth_service.dart';  
import 'navigation.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_custom_tabs/flutter_custom_tabs.dart';
import '../helper/exithelper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/services.dart';

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

  
  Future<List<Map<String, dynamic>>?> _fetchDonationData({
  String? dateFrom,
  String? dateTo,
}) async {
  final newDonations = await AuthService().fetchDonationData(
    lastId: lastId,
    dateFrom: dateFrom,
    dateTo: dateTo,
  );

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
  ModalRoute.of(context)?.addScopedWillPopCallback(() async {
    return await showExitConfirmationDialog(context);
  });

  return AnnotatedRegion<SystemUiOverlayStyle>(
    value: const SystemUiOverlayStyle(
      statusBarColor: Color(0xFFeb7f35),
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
    child: Scaffold(
      backgroundColor: const Color(0xFFeb7f35),
      extendBody: true,
      drawer: const AppDrawer(selectedItem: 'Donation'),
      body: Column(
        children: [
      SafeArea(
          bottom: false,
          child: Container(
            color: const Color(0xFFeb7f35),
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12), // Reduced vertical padding
            child: Row(
              children: [
                Builder(
                  builder: (context) => IconButton(
                    icon: const Icon(Icons.menu, color: Colors.white),
                    onPressed: () => Scaffold.of(context).openDrawer(),
                  ),
                ),
                const Spacer(),
                const Text(
                  "Your Donations",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 26, // Slightly smaller
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const Spacer(),
              IconButton(
                icon: const Icon(Icons.calendar_today, color: Colors.white),
                onPressed: () async {
                  final DateTimeRange? picked = await showDateRangePicker(
                    context: context,
                    firstDate: DateTime(2000),
                    lastDate: DateTime.now(),
                    initialDateRange: DateTimeRange(
                      start: DateTime.now().subtract(const Duration(days: 30)),
                      end: DateTime.now(),
                    ),
                  );

                  if (picked != null) {
                    final String dateFrom = picked.start.toIso8601String().substring(0, 10);
                    final String dateTo = picked.end.toIso8601String().substring(0, 10);

                    // Fetch the filtered data
                    final authService = AuthService();
                    final newDonations = await authService.fetchDonationData(
                      dateFrom: dateFrom,
                      dateTo: dateTo,
                    );

                    if (newDonations != null && newDonations.isNotEmpty) {
                      setState(() {
                        donations.clear(); // Clear existing list
                        donations.addAll(newDonations); // Add new results
                        lastId = newDonations.last['id'].toString(); // Update lastId
                      });
                    } else {
                      setState(() {
                        donations.clear();
                        lastId = '';
                      });
                    }
                  }
                },
              ),
              ],
            ),
          ),
        ),
        Expanded(
          child: Container(
            decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                           boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 8,
                          offset: Offset(0, -3),
                        ),
                      ],
                        ),
                        padding: EdgeInsets.zero, // Removes any unexpected space
                        child: FutureBuilder<List<Map<String, dynamic>>?>(
                          future: donationData,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return const Center(
                                child: CircularProgressIndicator(color: Color(0xFFeb7f35)),
                              );
                            } else if (snapshot.hasError) {
                              return Center(child: Text('Error: ${snapshot.error}'));
                            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
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
                                padding: const EdgeInsets.only(bottom: 150), // Makes sure content touches header
                                  itemCount: donations.length + (isLoading ? 1 : 0),
                                  itemBuilder: (context, index) {
                                    if (index == donations.length && isLoading) {
                                      return const Center(
                                        child: Column(
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
                  ],
                ),
              bottomNavigationBar: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -3), // Shadow goes upward from bottom
                ),
              ],
            ),
            padding: const EdgeInsets.only(top: 6, bottom: 10),
            child: SafeArea(
              top: false,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.credit_card, size: 30, color: Color(0xFFeb7f35)),
                        onPressed: () => _launchURL(context),
                      ),
                      const Text("Use Card", style: TextStyle(color: Color(0xFFeb7f35))),
                    ],
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                   IconButton(
                      icon: const Icon(Icons.upload_file, size: 30, color: Color(0xFFeb7f35)),
                      onPressed: () async {
                        final ImagePicker picker = ImagePicker();
                        final authService = AuthService();

                        // Show dialog to choose source
                        final source = await showModalBottomSheet<ImageSource>(
                          context: context,
                          builder: (BuildContext context) {
                            return SafeArea(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  ListTile(
                                    leading: const Icon(Icons.photo_camera),
                                    title: const Text('Take Photo'),
                                    onTap: () => Navigator.pop(context, ImageSource.camera),
                                  ),
                                  ListTile(
                                    leading: const Icon(Icons.photo_library),
                                    title: const Text('Choose from Gallery'),
                                    onTap: () => Navigator.pop(context, ImageSource.gallery),
                                  ),
                                ],
                              ),
                            );
                          },
                        );

                        if (source == null) return;

                        final XFile? image = await picker.pickImage(
                          source: source,
                          maxWidth: 800,
                          maxHeight: 800,
                        );

                        if (image != null) {
                          File imageFile = File(image.path);

                          bool success = await authService.uploadReceiptImage(imageFile);
                          if (success) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Upload successful")),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Upload failed")),
                            );
                          }
                        }
                      },
                    ),

                      const Text("Upload Deposit Slip", style: TextStyle(color: Color(0xFFeb7f35))),
                    ],
                  ),
                ],
              ),
            ),
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
  final id = donation['id'] ?? 'N/A';
  final receiptDate = donation['receipt_date'] ?? 'N/A';
  final paymentMethod = donation['payment_method'] ?? 'N/A';
  final receiptUrl = donation['receipt_url'] ?? 'N/A';

    return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
    child: Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: Color(0xFFeb7f35),
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: const Center(
              child: Text(
                "Donations",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text.rich(
                  TextSpan(
                    children: [
                      const TextSpan(
                        text: 'ID: ',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      TextSpan(
                        text: id.toString(),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  receiptDate.toString(),
                  style: const TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
                ),
                const SizedBox(height: 16),
                const Divider(
                  color: Color(0xFFeb7f35),
                  thickness: 1,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.payments, color: Color(0xFFeb7f35)),
                    const SizedBox(width: 8),
                    RichText(
                      text: TextSpan(
                        text: "Amount: ",
                        style: const TextStyle(color: Colors.black),
                        children: [
                          TextSpan(
                            text: "\₱ $amount",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.credit_card, color: Color(0xFFeb7f35)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        text: "Payment Method: ",
                        style: const TextStyle(color: Colors.black),
                        children: [
                          TextSpan(
                            text: paymentMethod,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    decoration: BoxDecoration(
                      boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 6,
                    offset: const Offset(0, 5),
                        ),
                              ],
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                backgroundColor: const Color(0xFFeb7f35),
                                foregroundColor: Colors.white,
                                side: const BorderSide(color: Color(0xFFeb7f35)),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(13),
                                ),
                                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                              ),
                              onPressed: () {
                                _viewReceipt(receiptUrl);
                              },
                              child: const Text(
                                "View Receipt",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                          ),
                        ),
                      ),
                    ),
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




  Future<void> _loadMoreData() async {
    if (isLoading) return; 

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
        ? SfPdfViewer.network(receiptUrl)  
        : Image.network(receiptUrl)
         );     
  }
}
