import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import '../../services/letter/auth_service.dart'; // adjust the path if needed

class ViewLettersPage extends StatefulWidget {
  final String childId;
  const ViewLettersPage({super.key, required this.childId});

  @override
  State<ViewLettersPage> createState() => _ViewLettersPageState();
}

class _ViewLettersPageState extends State<ViewLettersPage> with TickerProviderStateMixin {
  late TabController _tabController;
  final InboxAuthService _authService = InboxAuthService();

  List<dynamic> inboxLetters = [];
  List<dynamic> outboxLetters = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    fetchLetters();
  }

  Future<void> fetchLetters() async {
    final inbox = await _authService.fetchInboxLetter(widget.childId);
    final outbox = await _authService.fetchOutboxLetter(widget.childId);

    setState(() {
      inboxLetters = inbox;
      outboxLetters = outbox;
      isLoading = false;
    });
  }

  void openPdf(String url) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            backgroundColor: const Color(0xFFeb7f35),
            title: const Text('PDF Viewer', style: TextStyle(color: Colors.white)),
            iconTheme: const IconThemeData(color: Colors.white),
          ),
          body: SfPdfViewer.network(url),
        ),
      ),
    );
  }

  Widget buildInboxCard(dynamic letter) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        child: Row(
          children: [
            const Icon(Icons.picture_as_pdf, size: 40, color: Colors.red),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    letter['label'] ?? 'No Label',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFFeb7f35)),
                  ),
               
                ],
              ),
            ),
            TextButton(
              onPressed: () {
                final url = letter['url'];
                if (url != null) openPdf(url);
              },
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFFeb7f35),
                textStyle: const TextStyle(fontSize: 12),
              ),
              child: const Text('View Letter'),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildOutboxCard(dynamic letter) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.mail_outline, size: 40, color: Color(0xFFeb7f35)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
               children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "To: ${letter['given_name'] ?? 'Unknown'}",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        letter['created_at'] ?? 'Unknown',
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text("${letter['message'] ?? 'No message'}"),
                ],

              ),
            ),

          ],
        ),
      ),
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
                  const Expanded(
                    child: Text(
                      'View Letters',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Tab Bar with rounded top container
            Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
              ),
              child: TabBar(
                controller: _tabController,
                labelColor: const Color(0xFFeb7f35),
                unselectedLabelColor: Colors.grey,
                indicator: const UnderlineTabIndicator(
                  borderSide: BorderSide(width: 4.0, color: Color(0xFFeb7f35)),
                  insets: EdgeInsets.symmetric(horizontal: 40.0),
                ),
                tabs: const [
                  Tab(text: 'Inbox'),
                  Tab(text: 'Outbox'),
                ],
              ),
            ),
            // Content
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(0)),
                child: Container(
                  color: Colors.white,
                  padding: const EdgeInsets.all(16),
                  child: isLoading
                      ? const Center(child: CircularProgressIndicator(color: Color(0xFFeb7f35)))
                      : TabBarView(
                          controller: _tabController,
                          children: [
                            inboxLetters.isEmpty
                                ? const Center(child: Text("No Inbox Letters"))
                                : ListView.builder(
                                    itemCount: inboxLetters.length,
                                    itemBuilder: (context, index) => buildInboxCard(inboxLetters[index]),
                                  ),
                            outboxLetters.isEmpty
                                ? const Center(child: Text("No Outbox Letters"))
                                : ListView.builder(
                                    itemCount: outboxLetters.length,
                                    itemBuilder: (context, index) => buildOutboxCard(outboxLetters[index]),
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
