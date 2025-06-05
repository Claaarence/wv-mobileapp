import 'package:flutter/material.dart';
import 'package:wvmobile/screens/child_connect/childvisit.dart';
import 'package:wvmobile/screens/child_connect/communityprofile.dart';
// If you have a ChildInfo model, import it:
import '/models/child_info.dart';
import 'package:wvmobile/screens/homescreen/child_details.dart';
import 'package:wvmobile/screens/child_connect/sendletter.dart';
import 'package:wvmobile/screens/child_connect/viewletters.dart';

class ConnectPage extends StatelessWidget {
  final ChildInfo child;

  const ConnectPage({super.key, required this.child});

   void _onMenuTap(BuildContext context, String menu) {
  Widget? destination;

  switch (menu) {
    case 'Community Profile':
      destination = CommunityProfilePage(  childId: child.childId,);
      break;
    case 'Child Updates':
      destination = ChildDetailPage(
        childId: child.childId,
        childName: child.givenName,
      );
      break;
    case 'Send Letter':
      destination = SendLetterPage(childName: child.givenName, childId: child.childId,);
      break;
    case 'View Letters':
      destination = ViewLettersPage(childId: child.childId);
      break;
    case 'Child Visit':
      destination = const ChildVisitPage();
      break;
  }

  if (destination != null) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => destination!));
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Page for "$menu" not implemented yet')),
    );
  }
}

  @override
  Widget build(BuildContext context) {
    final menuItems = [
      {'icon': Icons.group, 'label': 'Community Profile'},
      {'icon': Icons.child_care, 'label': 'Child Updates'},
      {'icon': Icons.send, 'label': 'Send Letter'},
      {'icon': Icons.mail_outline, 'label': 'View Letters'},
      {'icon': Icons.home, 'label': 'Child Visit'},
    ];

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
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Connect with ${child.givenName}', // Dynamic title here
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
                child: SafeArea(
                  top: true,
                  bottom: false,
                  child: Container(
                    color: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                    child: ListView.separated(
                      itemCount: menuItems.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 16),
                      itemBuilder: (context, index) {
                        final item = menuItems[index];
                        return GestureDetector(
                          onTap: () => _onMenuTap(context, item['label'] as String),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                              border: Border.all(color: const Color(0xFFeb7f35), width: 1.5),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  item['icon'] as IconData,
                                  size: 36,
                                  color: const Color(0xFFeb7f35),
                                ),
                                const SizedBox(width: 16),
                                Text(
                                  item['label'] as String,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                    color: Color(0xFFeb7f35),
                                  ),
                                ),
                                const Spacer(),
                                const Icon(
                                  Icons.arrow_forward_ios,
                                  size: 18,
                                  color: Color(0xFFeb7f35),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
