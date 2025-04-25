// ignore_for_file: unnecessary_import, deprecated_member_use

import 'package:flutter/material.dart';
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

    _glowAnimation = Tween<double>(begin: 0.4, end: 0.8).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _checkUserStatus();
  }

    // Async function to check user status
  Future<void> _checkUserStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? isNewUser = prefs.getBool('isNewUser');

    await Future.delayed(const Duration(seconds: 8)); // Splash screen duration

    if (mounted) {
      if (isNewUser == null || isNewUser == true) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const LandingPage()),
        );
      } else {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const DashboardPage()),
        );
      }
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
      backgroundColor: const Color(0xFFFF6600), // Orange background
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: screenSize.width * 0.05),
                  child: Image.asset(
                    'assets/wvlogowhite.png',
                    width: screenSize.width * 0.6,
                  ),
                ),
                SizedBox(height: screenSize.height * 0.1),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: screenSize.width * 0.05),
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