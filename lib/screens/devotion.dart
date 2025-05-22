import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart'; // Add this import for the spinner
import '../screens/navigation.dart';
import '../services/devotion/auth_service.dart';
import '../models/devotion.dart';
import '../helper/exithelper.dart';



class DevotionPage extends StatefulWidget {
  const DevotionPage({super.key});

  @override
  _DevotionPageState createState() => _DevotionPageState();
}

class _DevotionPageState extends State<DevotionPage> {
  List<Devotion> allDevotions = [];
  List<Devotion> displayedDevotions = [];
  bool isLoading = false;
  int itemsToLoad = 5;
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadDevotions();
  }

  Future<void> _loadDevotions() async {
    setState(() {
      isLoading = true;
    });

    final authService = AuthService();
    try {
      final devotions = await authService.fetchDevotions();
      setState(() {
        allDevotions = devotions;
        displayedDevotions = allDevotions.take(itemsToLoad).toList();
        isLoading = false;
      });
    } catch (error) {
      setState(() {
        isLoading = false;
      });
      // Handle error
    }
  }

  void _loadMoreItems() {
    if (itemsToLoad < allDevotions.length) {
      setState(() {
        itemsToLoad += 5;
        displayedDevotions = allDevotions.take(itemsToLoad).toList();
      });
    }
  }

  void _filterDevotions(String query) {
    if (query.isEmpty) {
      setState(() {
        displayedDevotions = allDevotions.take(itemsToLoad).toList();
      });
    } else {
      setState(() {
        displayedDevotions = allDevotions
            .where((devotion) =>
                devotion.title.toLowerCase().contains(query.toLowerCase()))
            .take(itemsToLoad)
            .toList();
      });
    }
  }

  void _showZoomedImage(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(10),
        child: GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: InteractiveViewer(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(
                imageUrl,
                fit: BoxFit.contain,
              ),
            ),
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
      drawer: const AppDrawer(selectedItem: 'Devotion'),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Builder(
                    builder: (context) => GestureDetector(
                      onTap: () => Scaffold.of(context).openDrawer(),
                      child: Container(
                        color: Colors.transparent,
                        child: IconButton(
                          icon: const Icon(Icons.menu, color: Colors.white),
                          onPressed: () => Scaffold.of(context).openDrawer(),
                        ),
                      ),
                    ),
                  ),
                  const Text(
                    "Weekly Devotion",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: TextField(
                controller: searchController,
                onChanged: _filterDevotions,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search, color: Color(0xFFeb7f35)),
                  hintText: 'Search devotions...',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                    boxShadow: [
                        BoxShadow(
                        color: Colors.black.withOpacity(0.4),
                        blurRadius: 10,
                        offset: const Offset(0, -3),
                        ),
                      ],
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                ),
               child: isLoading && displayedDevotions.isEmpty
                    ? const Center(child: CircularProgressIndicator(color: Color(0xFFeb7f35)))
                    : !isLoading && displayedDevotions.isEmpty
                        ? const Center(
                            child: Text(
                              "There are currently no devotion listed,\nPlease come back later.",
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 16, color: Colors.black54),
                            ),
                          )
                        : NotificationListener<ScrollNotification>(
                        onNotification: (ScrollNotification scrollInfo) {
                          if (!isLoading &&
                              scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent) {
                            print("Reached the bottom, loading more items...");
                            _loadMoreItems(); 
                          }
                          return true;
                        },
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: displayedDevotions.length + (isLoading ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (index == displayedDevotions.length && isLoading) {
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
                                      'Loading more devotions...',
                                      style: TextStyle(color: Colors.black, fontSize: 16),
                                    ),
                                  ],
                                ),
                              );
                            }
                            final devotion = displayedDevotions[index];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 20),
                              elevation: 3,
                              color: const Color(0xFFEB7F35),
                              shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25)),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          devotion.title,
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white, 
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Published: ${devotion.createdAt} • Devotion Date: ${devotion.devoDate}',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Colors.white, 
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () => _showZoomedImage(context, devotion.url),
                                    child: ClipRRect(
                                      borderRadius: const BorderRadius.only(
                                        bottomLeft: Radius.circular(15),
                                        bottomRight: Radius.circular(15),
                                      ),
                                      child:Image.network(
                                              devotion.url,
                                              width: double.infinity,
                                              height: 350,
                                              fit: BoxFit.cover,
                                              loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                                                if (loadingProgress == null) return child;
                                                return SizedBox(
                                                  width: double.infinity,
                                                  height: 350,
                                                  child: const Center(
                                                    child: CircularProgressIndicator(
                                                      color: Color(0xFFFF9800),
                                                    ),
                                                  ),
                                                );
                                              },
                                              errorBuilder: (context, error, stackTrace) =>
                                                  const SizedBox(
                                                    height: 350,
                                                    child: Center(
                                                      child: Icon(Icons.broken_image, size: 100, color: Colors.grey),
                                                    ),
                                                  ),
                                            ),
                                    ),
                                  ),
                                ],
                              ),
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
