import 'package:flutter/material.dart';
import '../../services/orders/auth_service.dart';

class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  List orders = [];
  bool isLoading = true;

  final String imageBaseUrl = 
    'https://explusmobile.worldvision.org.ph/explus-mobile/developer/laravel-backend/public/temp/';

  @override
  void initState() {
    super.initState();
    fetchOrders();
  }

  Future<void> fetchOrders() async {
    try {
      final fetchedOrders = await OrdersAuthService().fetchOrders();
      setState(() {
        orders = fetchedOrders!;
        isLoading = false;
      });
    } catch (e) {
      debugPrint('Failed to fetch orders: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

void _showOrderDetailsModal(
  BuildContext context,
  Map<String, dynamic> order,
) {
  final fullImageUrl = "$imageBaseUrl${order['item_image']}";
  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    transitionDuration: const Duration(milliseconds: 300),
    pageBuilder: (context, animation, secondaryAnimation) {
      double iconScale = 1.0; // local state for scale

      return Center(
        child: Material(
          color: Colors.transparent,
          child: StatefulBuilder(
            builder: (context, localSetState) {
              return Stack(
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width * 0.85,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFFeb7f35), // Dialog background
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: const Color.fromARGB(255, 110, 110, 110)
                              .withOpacity(0.7),
                          blurRadius: 12,
                          offset: const Offset(0, 7),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.4),
                                blurRadius: 10,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              fullImageUrl,
                              height: 180,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          order['item_name'] ?? '',
                          style: const TextStyle(
                            fontWeight: FontWeight.w900, // more bold
                            fontSize: 22,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            style:
                                const TextStyle(fontSize: 14, color: Colors.white),
                            children: [
                              const TextSpan(
                                  text: 'Status: ',
                                  style: TextStyle(fontWeight: FontWeight.bold)),
                              TextSpan(text: '${order['order_status']}\n'),
                              const TextSpan(
                                  text: 'Quantity: ',
                                  style: TextStyle(fontWeight: FontWeight.bold)),
                              TextSpan(text: '${order['qty_ordered']}\n'),
                              const TextSpan(
                                  text: 'Points Taken: ',
                                  style: TextStyle(fontWeight: FontWeight.bold)),
                              TextSpan(text: '${order['points_taken']}\n'),
                              const TextSpan(
                                  text: 'Order Date: ',
                                  style: TextStyle(fontWeight: FontWeight.bold)),
                              TextSpan(text: '${order['order_date']}'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Animated X icon with scaling tap animation
                  Positioned(
                    top: 10,
                    right: 10,
                    child: GestureDetector(
                      onTapDown: (_) {
                        localSetState(() => iconScale = 0.85);
                      },
                      onTapUp: (_) async {
                        localSetState(() => iconScale = 1.0);
                        await Future.delayed(const Duration(milliseconds: 100));
                        Navigator.of(context).pop();
                      },
                      onTapCancel: () {
                        localSetState(() => iconScale = 1.0);
                      },
                      child: AnimatedScale(
                        scale: iconScale,
                        duration: const Duration(milliseconds: 100),
                        child: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
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
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Your Orders',
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
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 11,
                      offset: Offset(0, -9),
                    ),
                  ],
                ),
                child: isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ListView.builder(
                        padding: EdgeInsets.zero,
                        itemCount: orders.length,
                        itemBuilder: (context, index) {
                          final order = orders[index];
                          final fullImageUrl = "$imageBaseUrl${order['item_image']}";
                          return GestureDetector(
                            onTap: () => _showOrderDetailsModal(context, order),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              child: Container(
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
                                      child: Stack(
                                        children: [
                                          Image.network(
                                            fullImageUrl,
                                            width: double.infinity,
                                            height: 200,
                                            fit: BoxFit.cover,
                                            loadingBuilder: (context, child, loadingProgress) {
                                              if (loadingProgress == null) return child;
                                              return Container(
                                                width: double.infinity,
                                                height: 200,
                                                alignment: Alignment.center,
                                                child: const CircularProgressIndicator(
                                                  color: Color(0xFFeb7f35),
                                                ),
                                              );
                                            },
                                            errorBuilder: (context, error, stackTrace) {
                                              return Container(
                                                width: double.infinity,
                                                height: 200,
                                                color: Colors.grey.shade200,
                                                alignment: Alignment.center,
                                                child: const Icon(Icons.broken_image, color: Colors.grey),
                                              );
                                            },
                                          ),
                                          Positioned(
                                            top: 20,
                                            right: -50,
                                            child: Transform.rotate(
                                              angle: 0.785398, // 45 degrees in radians
                                              child: Container(
                                                width: 160,
                                                padding: const EdgeInsets.symmetric(vertical: 6),
                                                color: const Color(0xFFeb7f35),
                                                child: const Center(
                                                  child: Text(
                                                    'Click Me',
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(12),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  order['item_name'] ?? '',
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 20,
                                                    color: Color(0xFFeb7f35),
                                                  ),
                                                ),
                                              ),
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                                decoration: BoxDecoration(
                                                  color: Colors.orange.shade100,
                                                  borderRadius: BorderRadius.circular(20),
                                                  border: Border.all(color: Color(0xFFeb7f35), width: 1),
                                                ),
                                                child: Text(
                                                  order['order_status'] ?? '',
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                    color: Color(0xFFeb7f35),
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 6),
                                          Text(
                                            'Qty: ${order['qty_ordered']} | Points: ${order['points_taken']}',
                                            style: const TextStyle(fontSize: 13, color: Colors.grey),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'Order Date: ${order['order_date']}',
                                            style: const TextStyle(fontSize: 13, color: Colors.grey),
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
                ],
              ),
            ),
          );
        }
      }