// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously, avoid_print, deprecated_member_use

import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_custom_tabs/flutter_custom_tabs.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'home.dart';
import 'package:audioplayers/audioplayers.dart';
import '../services/login/auth_service.dart';
import 'dart:convert'; 
import 'package:shared_preferences/shared_preferences.dart';
import '../helper/exithelper.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _glowAnimation;
  int _clickCount = 0;
  bool _isModalVisible = false;
  final AudioPlayer _audioPlayer = AudioPlayer(); // 🎵 Audio player instance

  final AuthService _authService = AuthService();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  


void _launchURLPrivacy(BuildContext context) async {
    final theme = Theme.of(context);
    try {
      await launchUrl(
        Uri.parse('https://www.worldvision.org.ph/privacy-notice/'),  
        customTabsOptions: CustomTabsOptions(
          colorSchemes: CustomTabsColorSchemes.defaults(
            toolbarColor: theme.colorScheme.surface,  
          ),
          shareState: CustomTabsShareState.on,
          urlBarHidingEnabled: true,
          showTitle: true,
          closeButton: CustomTabsCloseButton(
            icon: CustomTabsCloseButtonIcons.back,
          ),
        ),
        safariVCOptions: SafariViewControllerOptions(
          preferredBarTintColor: theme.colorScheme.surface, 
          preferredControlTintColor: theme.colorScheme.onSurface, 
          barCollapsingEnabled: true,
          dismissButtonStyle: SafariViewControllerDismissButtonStyle.close,  
        ),
      );
    } catch (e) {
      debugPrint('Failed to launch URL: $e');
    }
  }

  void _launchURLForgotPW(BuildContext context) async {
    final theme = Theme.of(context);
    try {
      await launchUrl(
        Uri.parse('https://myspon.worldvision.org.ph/forgotpassword'),  
        customTabsOptions: CustomTabsOptions(
          colorSchemes: CustomTabsColorSchemes.defaults(
            toolbarColor: theme.colorScheme.surface,  
          ),
          shareState: CustomTabsShareState.on,
          urlBarHidingEnabled: true,
          showTitle: true,
          closeButton: CustomTabsCloseButton(
            icon: CustomTabsCloseButtonIcons.back, 
          ),
        ),
        safariVCOptions: SafariViewControllerOptions(
          preferredBarTintColor: theme.colorScheme.surface,  
          preferredControlTintColor: theme.colorScheme.onSurface, 
          barCollapsingEnabled: true,
          dismissButtonStyle: SafariViewControllerDismissButtonStyle.close,  
        ),
      );
    } catch (e) {
      debugPrint('Failed to launch URL: $e');
    }
  }

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
  }

  void _handleSecretClick() {
    if (_isModalVisible) return; 

    _clickCount++;

    if (_clickCount == 20) {
      _clickCount = 0; 
      _showSecretModal();
    }
  }

Future<void> _playAudio() async {
  try {
    await _audioPlayer.play(AssetSource('starwars.mp3'));
    print("Audio started playing...");
  } catch (e) {
    print("Error playing audio: $e");
  }
}


  Future<void> _stopAudio() async {
    await _audioPlayer.stop();
  }

  void _showSecretModal() {
    setState(() {
      _isModalVisible = true;
    });

    _playAudio(); 

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        Future.delayed(const Duration(seconds: 20), () {
          if (mounted) {
            _stopAudio(); 
            Navigator.of(context).pop();
            setState(() {
              _isModalVisible = false;
            });
          }
        });

        return Dialog(
          backgroundColor: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: const Color(0xFFeb7f35), width: 2),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFeb7f35).withOpacity(0.8), // Glow effect
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.asset(
                      'assets/sw.gif',
                      width: 400,
                      height: 225,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "May the World Vision be with you!",
                    style: GoogleFonts.orbitron(
                      fontSize: 18,
                      color: const Color(0xFFeb7f35),
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(
                          blurRadius: 15,
                          color: const Color(0xFFeb7f35),
                          offset: Offset(0, 0),
                        ),
                        Shadow(
                          blurRadius: 30,
                          color: const Color(0xFFeb7f35).withOpacity(0.5),
                          offset: Offset(0, 0),
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    ).then((_) => _stopAudio());
  }


 @override
  void dispose() {
    _animationController.dispose();
    _audioPlayer.dispose(); 
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

Future<void> _login() async {
  final email = _usernameController.text.trim();
  final password = _passwordController.text.trim();

  final Map<String, String> payload = {
    "email": email,
    "password": password,
  };

  print("Sending login request:");
  print(jsonEncode(payload));

  try {
    // Send login request
    final http.Response response = await _authService.login(email, password);

    print("HTTP Status Code: ${response.statusCode}");
    print("Raw API Response: ${response.body}");

    final Map<String, dynamic> responseData = jsonDecode(response.body);
    print("Decoded API Response: $responseData");

    if (response.statusCode == 200 && responseData.containsKey('token')) {
      final SharedPreferences prefs = await SharedPreferences.getInstance();

      // Store token and user data
      await prefs.setString('token', responseData['token']);
      await prefs.setString('userData', jsonEncode(responseData));

      // Debugging: Check if token is really stored
      String? storedToken = prefs.getString('token');
      print("Stored Token in SharedPreferences: $storedToken");

      if (responseData['user'] != null && responseData['user'].containsKey('partner_id')) {
        await prefs.setString('user_id', responseData['user']['partner_id'].toString());
        print("Stored User ID: ${responseData['user']['partner_id']}");
      } else {
        print("No partner_id found in response.");
      }

      // Check if avatar_url exists inside 'user' and store it
      if (responseData['user'] != null && responseData['user'].containsKey('avatar_url')) {
        await prefs.setString('avatar_url', responseData['user']['avatar_url']);
        print("Stored Avatar URL: ${responseData['user']['avatar_url']}");
      } else {
        print("No avatar_url found in user object.");
      }

      print("Login successful, Token: ${responseData['token']}");

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    } else {
      print("Login failed: ${response.body}");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Login failed: ${response.body}")),
      );
    }
  } catch (e) {
    print("Error processing login: $e");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("An error occurred. Please try again.")),
    );
  }
}



  @override
  Widget build(BuildContext context) {
     ModalRoute.of(context)?.addScopedWillPopCallback(() async {
      return await showExitConfirmationDialog(context);
    });
  final double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
      children: [
        Image.asset(
          'assets/bgdash.jpg',
          fit: BoxFit.cover,
        ),
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color.fromARGB(255, 0, 0, 0).withOpacity(0.6), 
                const Color(0xFFeb7f35).withOpacity(0.8), 
              ],
              stops: [0.4, 1.0], // 60% Orange, 40% Yellow
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
          Positioned(
            top: 50,
            left: 20,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(height: 100),
              GestureDetector(
                onTap: _handleSecretClick,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    AnimatedBuilder(
                      animation: _glowAnimation,
                      builder: (context, child) {
                        return Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                            const Color.fromARGB(255, 255, 255, 255).withOpacity(_glowAnimation.value),
                            const Color.fromARGB(28, 255, 255, 255),
                              ],
                              stops: const [0.1, 0.9],
                            ),
                          ),
                        );
                      },
                    ),
                    Image.asset('assets/star2.png', height: 120, width: 70),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Image.asset('assets/wv2.png', height: 35),
              const SizedBox(height: 60),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                       Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Get Started",
                              style: GoogleFonts.poppins(
                                color: const Color(0xFFeb7f35),
                                fontSize: screenWidth * 0.05,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.8,
                              ),
                            ),
                            Flexible(
                              child: Image.asset(
                                'assets/vw.png',
                                height: screenWidth * 0.07,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ],
                        ),
                        Divider(color: Colors.grey.withOpacity(0.6), thickness: 1),
                        const SizedBox(height: 10),
                        const Text("Username", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                        Container(
                          decoration: BoxDecoration(
                            color: Color.fromARGB(255, 255, 255, 255),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: TextField(
                            controller: _usernameController,
                            style: const TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
                            decoration: InputDecoration(
                             border: OutlineInputBorder(borderSide: const BorderSide(color: Color.fromARGB(255, 0, 0, 0)), borderRadius: BorderRadius.circular(10)),
                             contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text("Password", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                        Container(
                          decoration: BoxDecoration(
                            color: Color.fromARGB(255, 255, 255, 255),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: TextField(
                            controller: _passwordController,
                            style: const TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
                            decoration: InputDecoration(
                             border: OutlineInputBorder(borderSide: const BorderSide(color: Color.fromARGB(255, 0, 0, 0)), borderRadius: BorderRadius.circular(10)),
                             contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                            ),
                          ),
                        ),
                       const SizedBox(height: 10),
                           Divider(color: Colors.grey.withOpacity(0.6), thickness: 1),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              InkWell(
                                onTap: () {
                                  _launchURLPrivacy(context);
                                },
                                child: Text(
                                  "Privacy Policy",
                                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: const Color.fromARGB(132, 0, 0, 0),),
                                ),
                              ),
                              InkWell(
                                onTap: () {
                                  _launchURLForgotPW(context);
                                },
                                child: Text(
                                  "Forgot Password?",
                                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold,  color: const Color.fromARGB(132, 0, 0, 0),),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                         ElevatedButton(
                           onPressed: _login,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFeb7f35),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            elevation: 5,
                            minimumSize: const Size(double.infinity, 40),
                          ),
                          child: const Text(
                            "Login",
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
