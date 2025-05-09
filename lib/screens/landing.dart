// ignore_for_file: library_private_types_in_public_api, deprecated_member_use, depend_on_referenced_packages, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'dashboard.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../helper/exithelper.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  _LandingPageState createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
     ModalRoute.of(context)?.addScopedWillPopCallback(() async {
      return await showExitConfirmationDialog(context);
    });
    return Scaffold(
      body: Stack(
        children: [
          PageView(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            children: [
              _buildPage(
                imagePath: 'assets/bgdash.jpg',
                title: 'Helping Vulnerable Children',
                description: 'Helping the most vulnerable children overcome poverty and thrive.',
                    imageAlignment: Alignment(-0.4, 0.5),
              ),
              _buildPage(
                imagePath: 'assets/community.png',
                title: 'Our Vision',
                description: 'A future where every child experiences life in all its fullness.',
                 imageAlignment: Alignment(-0.1, 0.5),
              ),
              _buildPage(
                imagePath: 'assets/mission2.jpg',
                title: 'Our Mission',
                description: 'Working to promote human transformation and seek justice.',
                imageAlignment: Alignment(-0.5, 0.5),
              ),
            ],
          ),
          
          Positioned(
            top: 50,
            left: 0,
            right: 0,
            child: Center(
              child: Image.asset(
                'assets/wvlogowhite.png',
                width: 120,
                height: 120,
                fit: BoxFit.contain,
              ),
            ),
          ),
          Positioned(
            top: 110,
            left: 0,
            right: 0,
            child: Center(
              child: Image.asset(
                'assets/wv2.png', 
                width: 180,
                height: 180,
                fit: BoxFit.contain,
              ),
            ),
          ),
          
          Positioned(
            bottom: 50,
            left: 0,
            right: 0,
            child: Column(
              children: [
                _buildPageIndicator(),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: ElevatedButton(
                    onPressed: () async {
                      if (_currentPage == 2) {
                        SharedPreferences prefs = await SharedPreferences.getInstance();
                        await prefs.setBool('isNewUser', false);
                        if (mounted) {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => const DashboardPage()),
                          );
                        }
                      } else {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.easeInOut,
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF6600),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      minimumSize: const Size(260, 60),
                    ),
                    child: Text(
                      _currentPage == 2 ? "GET STARTED" : "NEXT",
                      style: const TextStyle(
                        color: Color.fromARGB(255, 255, 255, 255),
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPage({required String imagePath, required String title, required String description, Alignment imageAlignment = Alignment.center}) {
    return Stack(
      children: [
        Positioned.fill(
          child: Container(
            height: MediaQuery.of(context).size.height * 0.6,
            child: Image.asset(
              imagePath,
              fit: BoxFit.cover,
              alignment: imageAlignment,
            ),
          ),
        ),
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.3),
                  Colors.black.withOpacity(0.8),
                ],
              ),
            ),
          ),
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color.fromARGB(255, 255, 255, 255),
                  fontSize: 34,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                description,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                ),
              ),
            ),
            const Spacer(),
          ],
        ),
      ],
    );
  }

  Widget _buildPageIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        3,
        (index) => Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: _currentPage == index ? 16 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: _currentPage == index ? Colors.orangeAccent : Colors.white38,
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }
}
