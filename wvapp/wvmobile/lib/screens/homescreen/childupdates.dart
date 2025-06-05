import 'package:flutter/material.dart';
import '../../services/homepage/child_module/auth_service.dart';
import '../homescreen/child_details.dart';

class ChildUpdatesPage extends StatefulWidget {
  const ChildUpdatesPage({super.key});

  @override
  State<ChildUpdatesPage> createState() => _ChildUpdatesPageState();
}

class _ChildUpdatesPageState extends State<ChildUpdatesPage> {
  List<Map<String, dynamic>> children = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchChildren();
  }

Future<void> fetchChildren() async {
  try {
    final childList = await ChildAuthService().fetchChildInfo();
    print('Child list received in UI: $childList'); // Debug log

    setState(() {
      children = childList;
      isLoading = false;
    });
  } catch (e) {
    print('Error loading children: $e');
    setState(() => isLoading = false);
  }
}

@override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: const Color(0xFFeb7f35),
    body: SafeArea(
      top: true,
      bottom: false,  // ignore bottom safe area to overlap bottom edge
      child: Column(
        children: [
          // Header: back button + title
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
                  'Child Updates',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // Expanded white container, overlaps bottom edge
          Expanded(
            child: Stack(
              children: [
                // White container with rounded top corners and shadow
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
                        : children.isEmpty
                            ? const Center(child: Text('No children found'))
                            : ListView.builder(
                                padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 24),
                                itemCount: children.length,
                                itemBuilder: (context, index) {
                                  final child = children[index];
                                  print('Rendering child: $child');

                                  final imageUrl = child['image'] ?? '';
                                  final name = child['given_name'] ?? 'Unknown';

                                return GestureDetector(
                                          onTap: () {
                                            print('Clicked child ID: ${child['child_id']}');
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => ChildDetailPage(
                                                  childId: child['child_id'].toString(),
                                                  childName: child['given_name'] ?? 'Unknown',
                                                ),
                                              ),
                                            );
                                          },
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
                                              children: [
                                                ClipOval(
                                                  child: imageUrl.isNotEmpty
                                                      ? Image.network(
                                                          imageUrl,
                                                          width: 70,
                                                          height: 70,
                                                          fit: BoxFit.cover,
                                                          errorBuilder: (context, error, stackTrace) {
                                                            return Container(
                                                              width: 70,
                                                              height: 70,
                                                              color: Colors.grey[300],
                                                              child: const Icon(Icons.person, size: 40),
                                                            );
                                                          },
                                                        )
                                                      : Container(
                                                          width: 70,
                                                          height: 70,
                                                          color: Colors.grey[300],
                                                          child: const Icon(Icons.person, size: 40),
                                                        ),
                                                ),
                                                const SizedBox(width: 16),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Text(
                                                        name,
                                                        style: const TextStyle(
                                                          fontSize: 20,
                                                          fontWeight: FontWeight.bold,
                                                          color: Colors.black87,
                                                        ),
                                                      ),
                                                      const SizedBox(height: 4),
                                                      const Text(
                                                        'Click to view update',
                                                        style: TextStyle(
                                                          fontSize: 14,
                                                          fontStyle: FontStyle.italic,
                                                          color: Color(0xFFeb7f35),
                                                          fontWeight: FontWeight.w600,
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
}