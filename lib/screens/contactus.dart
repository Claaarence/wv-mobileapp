import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart'; // For social media icons
import 'navigation.dart';
import '../helper/exithelper.dart';
class ContactUsPage extends StatelessWidget {
  const ContactUsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final TextEditingController messageController = TextEditingController();
    

    ModalRoute.of(context)?.addScopedWillPopCallback(() async {
      return await showExitConfirmationDialog(context);
    });
 return Scaffold(
    backgroundColor: const Color(0xFFeb7f35),
    drawer: const AppDrawer(selectedItem: 'Contact Us'),
    body: Column(
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
                    "Contact Us",
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

        const Text(
          "Your Feedback Matters!",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 10),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            "Please send us a message below, or contact us using the details provided.",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 20),
        const SizedBox(height: 10),
        Expanded(
          child: Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.fromLTRB(16, 25, 16, bottomPadding + 30),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight + bottomPadding,
                    ),
                    child: IntrinsicHeight(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Card(
                            elevation: 5,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Header with orange background and white text
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(16),
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFeb7f35),
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(20),
                                      topRight: Radius.circular(20),
                                    ),
                                  ),
                                  child: const Text(
                                    "Connect with us!",
                                    style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(20.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [ 
                                      RichText(
                                        text: const TextSpan(
                                          style: TextStyle(color: Colors.black),
                                          children: [
                                            TextSpan(
                                                text: "📞 Phone: ",
                                                style: TextStyle(fontWeight: FontWeight.bold)),
                                            TextSpan(
                                                text: "+(632) 8372 7777",
                                                style: TextStyle(fontWeight: FontWeight.bold)),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 5),
                                      const Text(
                                        "(Available MON-FRI from 9:00am to 6:00pm)",
                                        style: TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                      const Divider(thickness: 1, color: Color(0xFFeb7f35)),
                                      const SizedBox(height: 5),
                                      const Text(
                                        "🏢 Address: World Vision Development Foundation, 389 Quezon Avenue corner West 6th St. West Triangle, Quezon City 1104 Philippines",
                                        style: TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                      const Divider(thickness: 1, color: Color(0xFFeb7f35)),
                                      const SizedBox(height: 5),
                                      const Text(
                                        "📧 Email: wv_phil@wvi.org",
                                        style: TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(height: 5),
                                      const Divider(thickness: 1, color: Color(0xFFeb7f35)),
                                      const SizedBox(height: 5),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: const [
                                          Row(
                                            children: [
                                              FaIcon(FontAwesomeIcons.facebook,
                                                  size: 20, color: Color(0xFFeb7f35)),
                                              SizedBox(width: 10),
                                              Text("World Vision Philippines",
                                                  style: TextStyle(color: Color(0xFFeb7f35))),
                                            ],
                                          ),
                                          SizedBox(height: 10),
                                          Row(
                                            children: [
                                              FaIcon(FontAwesomeIcons.twitter,
                                                  size: 20, color: Color(0xFFeb7f35)),
                                              SizedBox(width: 10),
                                              Text("@worldvisionph",
                                                  style: TextStyle(color: Color(0xFFeb7f35))),
                                            ],
                                          ),
                                          SizedBox(height: 10),
                                          Row(
                                            children: [
                                              FaIcon(FontAwesomeIcons.instagram,
                                                  size: 20, color: Color(0xFFeb7f35)),
                                              SizedBox(width: 10),
                                              Text("@worldvisionphl",
                                                  style: TextStyle(color: Color(0xFFeb7f35))),
                                            ],
                                          ),
                                          SizedBox(height: 10),
                                          Row(
                                            children: [
                                              FaIcon(FontAwesomeIcons.youtube,
                                                  size: 20, color: Color(0xFFeb7f35)),
                                              SizedBox(width: 10),
                                              Text("@worldvisionph",
                                                  style: TextStyle(color: Color(0xFFeb7f35))),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                          Card(
                            elevation: 5,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "✉️ Message us here!",
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const Divider(thickness: 1, color: Color(0xFFeb7f35)),
                                  const SizedBox(height: 10),
                                  TextField(
                                    controller: messageController,
                                    minLines: 10,
                                    maxLines: null,
                                    keyboardType: TextInputType.multiline,
                                    decoration: InputDecoration(
                                      hintText: "Type your message here...",
                                      filled: true,
                                      fillColor: Colors.white,
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: const BorderSide(color: Color(0xFFeb7f35)),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: const BorderSide(color: Colors.orange, width: 2),
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  const Divider(thickness: 1, color: Color(0xFFeb7f35)),
                                  const SizedBox(height: 10),
                                  Center(
                                    child: ElevatedButton.icon(
                                      onPressed: () {
                                        // Handle send logic
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.orange,
                                        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(16),
                                        ),
                                      ),
                                      icon: const Icon(Icons.send, color: Colors.white),
                                      label: const Text(
                                        "Send Message",
                                        style: TextStyle(fontSize: 18, color: Colors.white),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 30),
                                ],
                              ),
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
  );
}
}