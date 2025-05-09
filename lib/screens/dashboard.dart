// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'login.dart';
import 'package:flutter_custom_tabs/flutter_custom_tabs.dart';
import '../helper/exithelper.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

@override
Widget build(BuildContext context) {
   ModalRoute.of(context)?.addScopedWillPopCallback(() async {
      return await showExitConfirmationDialog(context);
    });
  final double screenWidth = MediaQuery.of(context).size.width;
  final double screenHeight = MediaQuery.of(context).size.height;

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
        Padding(
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.06, vertical: screenHeight * 0.04),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: screenHeight * 0.02), 
              _buildLogo(screenWidth),
              SizedBox(height: screenHeight * 0.07),
              _buildAboutSection(screenWidth),
              SizedBox(height: screenHeight * 0.05),
              _buildButtons(context, screenWidth), // ✅ FIXED: Passing both context and screenWidth
              Spacer(), // Push footer to bottom
              _buildFooter(screenWidth),
            ],
          ),
        ),
      ],
    ),
  );
}


  Widget _buildLogo(double screenWidth) {
    return Image.asset(
      'assets/wv2.png',
      width: screenWidth * 0.4, // Scales proportionally
    );
  }

  Widget _buildAboutSection(double screenWidth) {
    return Column(
      children: [
        Text(
          "About World Vision",
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: screenWidth * 0.06,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.0,
          ),
        ),
        SizedBox(height: screenWidth * 0.02),
        Text(
          "World Vision is the world's largest international charity. For more than 60 years in the Philippines, we bring hope to thousands of children in the hardest places in rural and urban poor areas as a sign of God's unconditional love.",
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            color: Colors.white70,
            fontSize: screenWidth * 0.04,
            height: 1.5,
          ),
        ),
      ],
    );
  }




  Widget _buildFooter(double screenWidth) {
    return Padding(
      padding: EdgeInsets.only(bottom: screenWidth * 0.05),
      child: Text(
        "www.worldvision.org.ph",
        style: GoogleFonts.poppins(
          color: Colors.white,
          fontSize: screenWidth * 0.04,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

 Widget _buildButtons(BuildContext context, double screenWidth) {
  return Container(
    width: double.infinity,
    padding: EdgeInsets.all(screenWidth * 0.04),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // "Get Started" title + Logo Row
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
        SizedBox(height: screenWidth * 0.02),

        // Buttons
        _buildNavigationButton(context, screenWidth, "Already a Sponsor?", "Login here", Icons.login, LoginPage()),
        _buildUrlButtonSponsor(screenWidth, "Not yet a Sponsor?", "Become one", Icons.person_add, context),
        _buildUrlButtonDonate(screenWidth, "Want to Donate?", "Click me", Icons.volunteer_activism, context),
      ],
    ),
  );
}

// **Button for Internal Navigation (to LoginPage)**
Widget _buildNavigationButton(BuildContext context, double screenWidth, String title, String subtitle, IconData icon, Widget page) {
  return Padding(
    padding: EdgeInsets.symmetric(vertical: screenWidth * 0.02),
    child: ElevatedButton(
      style: _buttonStyle(screenWidth),
      onPressed: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => page),
      ),
      child: _buildButtonContent(screenWidth, title, subtitle, icon),
    ),
  );
}

// **Button for External URL**
Widget _buildUrlButtonDonate(double screenWidth, String title, String subtitle, IconData icon, BuildContext context) {
  return Padding(
    padding: EdgeInsets.symmetric(vertical: screenWidth * 0.02),
    child: ElevatedButton(
      style: _buttonStyle(screenWidth),
      onPressed: () => _launchURLDonate(context),
      child: _buildButtonContent(screenWidth, title, subtitle, icon),
    ),
  );
}

Widget _buildUrlButtonSponsor(double screenWidth, String title, String subtitle, IconData icon, BuildContext context) {
  return Padding(
    padding: EdgeInsets.symmetric(vertical: screenWidth * 0.02),
    child: ElevatedButton(
      style: _buttonStyle(screenWidth),
      onPressed: () => _launchUrlSponsor(context),
      child: _buildButtonContent(screenWidth, title, subtitle, icon),
    ),
  );
}

// **Reusable Button Style**
ButtonStyle _buttonStyle(double screenWidth) {
  return ElevatedButton.styleFrom(
    backgroundColor: const Color(0xFFeb7f35),
    foregroundColor: Colors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(15),
    ),
    elevation: 6,
    padding: EdgeInsets.symmetric(vertical: screenWidth * 0.04),
  );
}

// **Reusable Button Content**
Widget _buildButtonContent(double screenWidth, String title, String subtitle, IconData icon) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Icon(icon, size: screenWidth * 0.06, color: Colors.white),
      SizedBox(width: screenWidth * 0.03),
      Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: screenWidth * 0.045,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            subtitle,
            style: GoogleFonts.poppins(
              fontSize: screenWidth * 0.035,
              color: Colors.white.withOpacity(0.6),
            ),
          ),
        ],
      ),
    ],
  );
}

// Function to open URL
void _launchURLDonate(BuildContext context) async {
    final theme = Theme.of(context);
    try {
      await launchUrl(
        Uri.parse('https://www.worldvision.org.ph/donate/'),  
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

  void _launchUrlSponsor(BuildContext context) async {
    final theme = Theme.of(context);
    try {
      await launchUrl(
        Uri.parse('https://worldvision.org.ph/sponsor-child/'), 
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


}