import 'package:flutter/material.dart';
import 'package:wvmobile/screens/home.dart';
import 'dart:async';
import 'dashboard.dart';
import 'landing.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);

    _glowAnimation = Tween<double>(begin: 0.3, end: 1.0)
        .animate(_animationController);

    _handleSplashNavigation();
  }

  Future<void> _handleSplashNavigation() async {
    await Future.delayed(const Duration(seconds: 4));

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');
    final bool? isNewUser = prefs.getBool('isNewUser');

    if (!mounted) return;

    if (token != null && token.isNotEmpty) {
      // Logged in
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    } else if (isNewUser == null || isNewUser == true) {
      // New user
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LandingPage()),
      );
    } else {
      // Returning user, not logged in
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const DashboardPage()),
      );
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFFFF6600),
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: screenSize.width * 0.05),
                  child: Image.asset(
                    'assets/wvlogowhite.png',
                    width: screenSize.width * 0.6,
                  ),
                ),
                SizedBox(height: screenSize.height * 0.1),
                Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: screenSize.width * 0.05),
                  child: Image.asset(
                    'assets/wv2.png',
                    width: screenSize.width * 0.4,
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: screenSize.height * 0.52,
            right: screenSize.width * 0.15,
            child: AnimatedBuilder(
              animation: _glowAnimation,
              builder: (context, child) {
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: screenSize.width * 0.2,
                      height: screenSize.width * 0.2,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            const Color.fromARGB(255, 255, 255, 255)
                                .withOpacity(_glowAnimation.value),
                            const Color.fromARGB(28, 255, 255, 255),
                          ],
                          stops: const [0.1, 0.9],
                        ),
                      ),
                    ),
                    Image.asset(
                      'assets/star2.png',
                      width: screenSize.width * 0.15,
                      height: screenSize.width * 0.15,
                      color: Colors.white.withOpacity(_glowAnimation.value),
                    ),
                  ],
                );
              },
            ),
          ),
          Positioned(
            bottom: screenSize.height * 0.05,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                "www.worldvision.org.ph",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: screenSize.width * 0.04,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
