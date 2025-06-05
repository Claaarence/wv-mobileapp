import 'package:flutter/material.dart';
import 'navigation.dart';
import '/services/child/auth_service.dart';
import '/models/child_info.dart';
import '../helper/exithelper.dart';
import 'package:wvmobile/screens/child_connect/connect.dart';

class ChildPage extends StatefulWidget {
  const ChildPage({super.key});

  @override
  State<ChildPage> createState() => _ChildPageState();
}

class NotepadLinesPainter extends CustomPainter {
  final double lineSpacing;

  NotepadLinesPainter({this.lineSpacing = 32.0});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFeb7f35).withOpacity(0.5) // soft orange lines
      ..strokeWidth = 1;

    for (double y = 0; y < size.height; y += lineSpacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant NotepadLinesPainter oldDelegate) =>
      oldDelegate.lineSpacing != lineSpacing;
}



class _ChildPageState extends State<ChildPage> {
  bool _showContent = false;
  List<ChildInfo> _childData = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showPopup();
    });
  }

  void _showPopup() {
  bool isChecked = false;

  showGeneralDialog(
    context: context,
    barrierDismissible: false,
    barrierLabel: 'Popup',
    barrierColor: Colors.black.withOpacity(0.5),
    transitionDuration: const Duration(milliseconds: 300),
    pageBuilder: (context, animation, secondaryAnimation) {
      return StatefulBuilder(
        builder: (context, setState) {
          return Center(
            child: Container(
              width: MediaQuery.of(context).size.width * 0.85,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.95),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Material(
                color: Colors.transparent,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.privacy_tip_rounded, size: 40, color: Color(0xFFeb7f35)),
                    const SizedBox(height: 12),
                    const Text(
                      'Before We Proceed',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
                      textAlign: TextAlign.center,
                    ),
                    Divider(color: const Color(0xFFeb7f35), thickness: 1),
                    const SizedBox(height: 16),
                    const Text(
                      'To protect my sponsored child from cyber exploitation, '
                      'I will not share his/her profile on Social Media and the like.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: Colors.black87),
                    ),
                    const SizedBox(height: 20),
                    Divider(color: const Color(0xFFeb7f35), thickness: 1),
                    CheckboxListTile(
                          value: isChecked,
                          onChanged: (value) {
                            setState(() {
                              isChecked = value ?? false;
                            });
                          },
                          contentPadding: EdgeInsets.zero,
                          controlAffinity: ListTileControlAffinity.leading,
                          activeColor: const Color(0xFFeb7f35),
                          checkColor: const Color.fromRGBO(255, 255, 255, 1),
                          title: const Text(
                            'I understand and agree to this.',
                            style: TextStyle(
                              fontSize: 15,
                              color: Color.fromARGB(255, 0, 0, 0),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                       Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).pop(); // Close the dialog
                              Navigator.of(context).pushReplacementNamed('/home');
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text('Cancel'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: isChecked
                                ? () async {
                                    Navigator.of(context).pop();
                                    await _fetchChildData();
                                  }
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFeb7f35),
                              disabledBackgroundColor: const Color(0xFFeb7f35).withOpacity(0.5),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text('Proceed'),
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
      );
    },
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      return ScaleTransition(
        scale: CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutBack,
        ),
        child: child,
      );
    },
  );
}


  Future<void> _fetchChildData() async {
    try {
      final data = await AuthService().fetchChildInfo();
      setState(() {
        _childData = data;
        _showContent = true;
      });
    } catch (e) {
      print("❌ Error loading child data: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to load sponsored child info.")),
      );
    }
  }

  // Method to show the child details modal
void _showChildDetailsModal(ChildInfo child) {
  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Child Details',
    barrierColor: Colors.black.withOpacity(0.6),
    transitionDuration: const Duration(milliseconds: 300),
    pageBuilder: (context, animation, secondaryAnimation) {
      double iconScale = 1.0; // local state for icon scale

      return StatefulBuilder(
        builder: (context, setState) {
          return Center(
            child: Material(
              color: Colors.transparent,
              child: Container(
                width: MediaQuery.of(context).size.width * 0.85,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFeb7f35).withOpacity(1),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.black.withOpacity(0.1), width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: const Color.fromARGB(255, 255, 255, 255).withOpacity(0.3),
                      spreadRadius: 4,
                      blurRadius: 20,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: SafeArea(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Align(
                          alignment: Alignment.topRight,
                          child: GestureDetector(
                            onTapDown: (_) {
                              setState(() => iconScale = 0.85);
                            },
                            onTapUp: (_) async {
                              setState(() => iconScale = 1.0);
                              await Future.delayed(const Duration(milliseconds: 100));
                              Navigator.of(context).pop();
                            },
                            onTapCancel: () {
                              setState(() => iconScale = 1.0);
                            },
                            child: MouseRegion(
                              cursor: SystemMouseCursors.click,
                              child: AnimatedScale(
                                scale: iconScale,
                                duration: const Duration(milliseconds: 100),
                                child: const Icon(
                                  Icons.close,
                                  color: Color.fromARGB(255, 255, 255, 255),
                                  size: 26,
                                ),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 12),
                        Center(
                          child: CircleAvatar(
                            radius: 70,
                            backgroundImage: NetworkImage(child.thumb),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Center(
                          child: Text(
                            "Hi, I'm ${child.givenName}",
                            style: const TextStyle(
                              fontSize: 26,
                              fontFamily: 'PastelCrayon',
                              fontWeight: FontWeight.w400,
                              color: Color.fromARGB(255, 255, 255, 255),
                              height: 1.3,
                              shadows: [
                                Shadow(
                                  offset: Offset(0, 0.5),
                                  blurRadius: 1.0,
                                  color: Color.fromARGB(255, 255, 255, 255),
                                ),
                              ],
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Container(
                          width: double.infinity,
                          height: 300,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(255, 255, 255, 255).withOpacity(1),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFFeb7f35), width: 1),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: SingleChildScrollView(
                              child: CustomPaint(
                                painter: NotepadLinesPainter(lineSpacing: 36),
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 10),
                                  child: Text(
                                    child.text,
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontFamily: 'PastelCrayon',
                                      fontWeight: FontWeight.w400,
                                      height: 1.8,
                                      color: Color.fromARGB(206, 0, 0, 0),
                                    ),
                                    textAlign: TextAlign.left,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 28),
                        Center(
                          child: SizedBox(
                            width: 230,
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ConnectPage(child: child),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                backgroundColor: const Color(0xFFFFFFFF),
                                foregroundColor: const Color(0xFFeb7f35),
                                textStyle: const TextStyle(
                                  fontSize: 18,
                                  fontFamily: 'PastelCrayon',
                                  fontWeight: FontWeight.w400,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                elevation: 6,
                                shadowColor: const Color(0xFFFFFFFF).withOpacity(0.6),
                              ),
                              child: const Text('Connect with Me'),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      );
    },
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      return ScaleTransition(
        scale: CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutBack,
        ),
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
      drawer: const AppDrawer(selectedItem: 'Child'),
      body: _showContent
          ? Column(
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
                            "Sponsored Child",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 48),
                      ],
                    ),
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
                            blurRadius: 8,
                            offset: Offset(0, -3),
                          ),
                        ],
                      ),
                      child: ListView.builder(
                        padding: const EdgeInsets.only(top: 16, bottom: 16),
                        itemCount: _childData.length,
                        itemBuilder: (context, index) {
                          final child = _childData[index];
                          return GestureDetector(
                            onTap: () {
                              _showChildDetailsModal(child);
                            },
                            child: Card(
                              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16)),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                               Row(
                                  children: [
                                    Column(
                                      children: [
                                        CircleAvatar(
                                          radius: 40,
                                          backgroundImage: NetworkImage(child.thumb),
                                        ),
                                        const SizedBox(height: 8),
                                        TextButton(
                                          onPressed: () {
                                            _showChildDetailsModal(child);
                                          },
                                          style: TextButton.styleFrom(
                                            side: const BorderSide(color: Color(0xFFeb7f35)),
                                            foregroundColor: const Color(0xFFeb7f35),
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                          ),
                                          child: const Text(
                                            'View',
                                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            child.givenName,
                                                  style: const TextStyle(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.w900,
                                                  color: Color.fromARGB(255, 0, 0, 0),
                                                ),
                                              ),
                                            Divider(color: const Color(0xFF9B9B9B), thickness: 1),
                                              Text.rich(
                                                TextSpan(
                                                  children: [
                                                    TextSpan(
                                                      text: "Status: ",
                                                      style: TextStyle(fontWeight: FontWeight.bold, color: Color.fromARGB(255, 0, 0, 0)),
                                                      
                                                    ),
                                                    TextSpan(
                                                      text: "${child.status}",
                                                      style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFeb7f35)),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Text.rich(
                                                TextSpan(
                                                  children: [
                                                    TextSpan(
                                                      text: "Gender: ",
                                                      style: TextStyle(fontWeight: FontWeight.bold, color: Color.fromARGB(255, 0, 0, 0)),
                                                    ),
                                                    TextSpan(
                                                      text: "${child.genderCode}",
                                                      style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFeb7f35)),
                                                    
                                                    
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Text.rich(
                                                TextSpan(
                                                  children: [
                                                    TextSpan(
                                                      text: "Birthdate: ",
                                                      style: TextStyle(fontWeight: FontWeight.bold, color: Color.fromARGB(255, 0, 0, 0)),
                                                    ),
                                                    TextSpan(
                                                      text: "${child.birthdate}",
                                                      style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFeb7f35)),
                                                      ),
                                                  ],
                                                ),
                                              ),
                                              Divider(color: const Color(0xFF9B9B9B), thickness: 1),
                                              Text.rich(
                                                TextSpan(
                                                  children: [
                                                    TextSpan(
                                                      text: "Favorite Subject: ",
                                                      style: TextStyle(fontWeight: FontWeight.bold, color: Color.fromARGB(255, 0, 0, 0)),
                                                    ),
                                                    TextSpan(
                                                      text: "${child.favoriteSubject}",
                                                      style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFeb7f35)),
                                                      ),
                                                  ],
                                                ),
                                              ),
                                              Text.rich(
                                                TextSpan(
                                                  children: [
                                                    TextSpan(
                                                      text: "Favorite Play: ",
                                                      style: TextStyle(fontWeight: FontWeight.bold, color: Color.fromARGB(255, 0, 0, 0)),
                                                    ),
                                                    TextSpan(
                                                      text: "${child.favoritePlay}",
                                                      style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFeb7f35)),
                                                      ),
                                                  ],
                                                ),
                                              ),
                                              Text.rich(
                                                TextSpan(
                                                  children: [
                                                    TextSpan(
                                                      text: "School Level: ",
                                                      style: TextStyle(fontWeight: FontWeight.bold, color: Color.fromARGB(255, 0, 0, 0)),
                                                    ),
                                                    TextSpan(
                                                      text: "${child.schoolLevel}",
                                                      style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFeb7f35)),
                                                      ),
                                                  ],
                                                ),
                                              ),
                                              Divider(color: const Color(0xFF9B9B9B), thickness: 1),
                                            ],
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
                      ),
                    ),
                  ),
              
              ],
            )
          : const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
    );
  }
}


