import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Add this import
import 'package:wvmobile/screens/contactus.dart';
import 'package:wvmobile/screens/dashboard.dart';
import 'package:wvmobile/screens/login.dart';
import 'package:wvmobile/screens/home.dart';
import 'package:wvmobile/screens/orderspage.dart';
import 'package:wvmobile/screens/profile.dart';
import 'package:wvmobile/screens/child.dart';
import 'package:wvmobile/screens/donation.dart';
import 'package:wvmobile/screens/rewards.dart';
import 'package:wvmobile/screens/badges.dart';
import 'package:wvmobile/screens/devotion.dart';
import 'package:wvmobile/screens/homescreen/campaigns.dart';
import 'package:wvmobile/screens/homescreen/childupdates.dart';
import 'package:wvmobile/screens/homescreen/community.dart';
import 'package:wvmobile/screens/splashscreen.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Required for async in main
  final SharedPreferences prefs = await SharedPreferences.getInstance();

  final String? token = prefs.getString('token');

  runApp(MyApp(initialRoute: token != null ? '/home' : '/login'));
}

class MyApp extends StatelessWidget {
  final String initialRoute;

  const MyApp({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WorldVision Philippines',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      routes: {
         '/': (context) => const SplashScreen(),
         '/dashboard': (context) => DashboardPage(),
         '/login': (context) => LoginPage(),
         '/home': (context) => HomePage(),
         '/profile': (context) => ProfilePage(),
         '/child': (context) => ChildPage(),
         '/donation': (context) => DonationPage(),
         '/rewards': (context) => RewardsPage(),
         '/badges': (context) => BadgesPage(),
         '/contactus': (context) => ContactUsPage(),
         '/devotion': (context) => DevotionPage(),
         '/campaigns': (context) => CampaignsPage(),
         '/childupdates': (context) => ChildUpdatesPage(),
         '/community': (context) => CommunityPage(),
         '/orders': (context) => OrdersPage(),

      },
    );
  } 
}
