import 'package:flutter/material.dart';
import '../services/rewards/auth_service.dart'; // Make sure this path matches your project structure
import 'navigation.dart';
import 'package:shimmer/shimmer.dart';
import '../helper/exithelper.dart';
import '../screens/orderspage.dart';


class RewardsPage extends StatefulWidget {
  const RewardsPage({super.key});

  @override
  State<RewardsPage> createState() => _RewardsPageState();
}

class _RewardsPageState extends State<RewardsPage> {
  List<Map<String, dynamic>> rewards = [];
  bool isLoading = false;
  bool hasMore = true;
  String? lastId;
  String imageUrl = "";
  String? userPoints;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _fetchRewards();
    _fetchUserPoints();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200 && !isLoading) {
        _fetchRewards();
      }
    });
  }

  Future<void> _fetchUserPoints() async {
  final authService = AuthService();
  final points = await authService.fetchUserPoints();

  if (points != null) {
    setState(() {
      userPoints = points;
    });
  }
}

Future<void> _fetchRewards() async {
  if (isLoading || !hasMore) return;

  setState(() => isLoading = true);
  final authService = AuthService();
  final response = await authService.fetchRewardsData(lastId: lastId);
  

  if (response != null && response['data'] != null) {
    final List<dynamic> newData = response['data'];
    setState(() {
      rewards.addAll(List<Map<String, dynamic>>.from(newData));
      if (newData.isNotEmpty) {
        lastId = newData.last['id'].toString();
      } else {
        hasMore = false;
      }
      imageUrl = "https://explusmobile.worldvision.org.ph/explus-mobile/developer/laravel-backend/public/temp/" ;
    });
  }

  setState(() => isLoading = false);
}

void _showRewardModal(
  BuildContext context,
  String title,
  String imageUrl,
  String description,
  int qty, 
  int id,
) {
  qty = 1; // <---------- comment this line to use the actual qty
  final isOutOfStock = qty == 0;

  void _showSuccessOrErrorDialog(bool success) {
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) {
        return Center(
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: MediaQuery.of(context).size.width * 0.6,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: success ? Colors.green[300] : Colors.red[300],
                borderRadius: BorderRadius.circular(15),
              ),
              child: Text(
                success ? "Redeemed successfully!" : "Redemption failed.",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        );
      },
    );

    // Auto dismiss after 2 seconds
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.of(context).pop(); // dismiss success/error dialog
    });
  }

  void _showConfirmationDialog() {


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
              width: MediaQuery.of(context).size.width * 0.8,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFeb7f35), width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFeb7f35).withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Confirm Redemption",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: Color(0xFFeb7f35),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                 Text(
                    "Please be advised that the items are for pick-up at the World Vision Development Foundation located in 389 Quezon Ave., cor. West 6th st., West Triangle, QC. \n\nIf you wish to have the item/s delivered kindly let us know so we could make special arrangement.",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: Color.fromARGB(255, 65, 65, 65),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                   OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.red),
                        foregroundColor: Colors.red, // text color
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop(); // dismiss confirmation
                      },
                      child: const Text(
                        "Cancel",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFeb7f35),
                          padding: const EdgeInsets.symmetric(
                              vertical: 12, horizontal: 24),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: () async {
                          Navigator.of(context).pop(); // dismiss confirmation
                          final authService = AuthService();
                          final result = await authService.redeemReward(
                            itemId: id.toString(),
                            qtyOrdered: 1,
                          );

                          if (result != null && result['status'] == 200) { // or check the key your API uses
                            _showSuccessOrErrorDialog(true);
                          } else {
                            _showSuccessOrErrorDialog(false);
                          }
                        },
                        child: const Text(
                          "Proceed",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
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
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFeb7f35), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFeb7f35).withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(imageUrl, height: 180, fit: BoxFit.cover),
                ),
                const SizedBox(height: 16),
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
                Text(
                  description,
                  style: const TextStyle(fontSize: 14, color: Colors.black87),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isOutOfStock
                          ? Colors.grey
                          : const Color(0xFFeb7f35),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: isOutOfStock
                        ? null
                        : () {
                            // Instead of redeem directly, show confirmation dialog
                            _showConfirmationDialog();
                          },
                    child: Text(
                      isOutOfStock ? "Temporarily Out of Stock" : "Redeem",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
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
     ModalRoute.of(context)?.addScopedWillPopCallback(() async {
      return await showExitConfirmationDialog(context);
    });
    return Scaffold(
      backgroundColor: const Color(0xFFeb7f35),
      drawer: const AppDrawer(selectedItem: 'Rewards'),
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
                      "Rewards",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.shopping_cart, color: Colors.white),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const OrdersPage()),
                      );
                    },
                  ),

                ],
              ),
            ),
          ),
          Column(
            children: [
              const Text(
                "Your total Points",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                userPoints != null ? "$userPoints pts" : "Loading points...",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
            ],
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
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: rewards.length + (isLoading ? 1 : 0),
                itemBuilder: (context, index) {
                   if (index < rewards.length) {
                      final reward = rewards[index];
                      final fullImageUrl = "$imageUrl${reward['item_image']}";
                      final description = _stripHtmlTags(reward['item_description'] ?? "");

                  return GestureDetector(
                    onTap: () => _showRewardModal(context, reward['item_name'], fullImageUrl, description, reward['qty'], reward['id']),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                       ClipRRect(
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                          child: Image.network(
                            fullImageUrl,
                            width: double.infinity,
                            height: 300,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Container(
                                width: double.infinity,
                                height: 300,
                                color: Colors.white,
                                child: const Center(
                                  child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFeb7f35)), // orange
                                  ),
                                ),
                              );
                            },
                          ),
                        ),

                          Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFeb7f35),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    "${reward['points_required']} Points",
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  reward['item_name'] ?? "",
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  description,
                                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                                ),
                                
                              ],
                            ),
                          )
                          
                        ],
                        
                      ),
                    ),
                  );
                   }
                    else {
                    return Center(
                      child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                     child: Shimmer.fromColors(
                        baseColor: const Color(0xFFE0E0E0), 
                        highlightColor: const Color(0xFFF5F5F5), 
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 500,
                            height: 300,
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(color: Colors.orange, width: 2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          Container(
                            width: 500,
                            height: 300,
                            margin: const EdgeInsets.only(bottom: 8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(color: Colors.orange, width: 2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          Container(
                            width: 500,
                            height: 300,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(color: Colors.orange, width: 2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                    );
                  }
                                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _stripHtmlTags(String htmlText) {
    return RegExp(r'<[^>]*>', multiLine: true, caseSensitive: true)
        .allMatches(htmlText)
        .fold(htmlText, (str, match) => str.replaceAll(match.group(0)!, ''))
        .trim();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
