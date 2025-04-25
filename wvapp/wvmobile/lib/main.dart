import 'package:flutter/material.dart';
import 'package:wvmobile/screens/contactus.dart';
import 'package:wvmobile/screens/dashboard.dart';
import 'package:wvmobile/screens/login.dart';
import 'package:wvmobile/screens/home.dart';
import 'package:wvmobile/screens/profile.dart';
import 'package:wvmobile/screens/child.dart';
import 'package:wvmobile/screens/donation.dart';
import 'package:wvmobile/screens/rewards.dart';
import 'package:wvmobile/screens/badges.dart';
import 'package:wvmobile/screens/splashscreen.dart';
import 'package:wvmobile/screens/devotion.dart';
import 'package:wvmobile/screens/homescreen/campaigns.dart';
import 'package:wvmobile/screens/homescreen/childupdates.dart';
import 'package:wvmobile/screens/homescreen/community.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
         '/childupdates': (context) => ChildupdatesPage(),
         '/community': (context) => CommunityPage(),

      },
    );
  } 
}
