import 'package:flutter/material.dart';
import '/services/sendletter/auth_service.dart'; // ✅ your existing AuthService path

class SendLetterPage extends StatefulWidget {
  final String childName;
  final String childId;

  const SendLetterPage({super.key, required this.childName, required this.childId});

  @override
  State<SendLetterPage> createState() => _SendLetterPageState();
}

class _SendLetterPageState extends State<SendLetterPage> {
  final TextEditingController _controller = TextEditingController();
  int _charCount = 0;
  final LetterAuthService _authService = LetterAuthService(); // ✅ use your separated service

  Future<void> _sendLetter() async {
  final message = _controller.text.trim();

  if (message.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Please write a message.')),
    );
    return;
  }

  try {
    bool success = await _authService.sendLetter(
      message: message,
      childId: widget.childId,
    );

    if (success) {
      showSuccessOrErrorDialog(true);
      // Wait 2 seconds then pop this SendLetterPage
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) {
        Navigator.of(context).pop(); // Close SendLetterPage
      }
    } else {
      showSuccessOrErrorDialog(false);
    }
  } catch (e) {
    print("❌ Send error: $e");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error: ${e.toString()}')),
    );
  }
}

// Add this method inside your State class
void showSuccessOrErrorDialog(bool success) {
  showGeneralDialog(
    context: context,
    barrierDismissible: false,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    transitionDuration: const Duration(milliseconds: 300),
    pageBuilder: (context, animation, secondaryAnimation) {
      return Center(
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: MediaQuery.of(context).size.width * 0.6,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: success ? Colors.green[300] : Colors.red[300],
              borderRadius: BorderRadius.circular(15),
            ),
            child: Text(
              success ? "Successfully sent!" : "Sending failed.",
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    },
  );

  // Auto dismiss after 2 seconds
  Future.delayed(const Duration(seconds: 2), () {
    if (mounted) {
      Navigator.of(context).pop(); // dismiss success/error dialog
    }
  });
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFeb7f35),
      body: SafeArea(
        top: true,
        bottom: false,
        child: Column(
          children: [
            // Header
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
                      'Send Letter to ${widget.childName}',
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

            // Body
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
                child: Container(
                  color: Colors.white,
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(8),
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade100,
                          border: Border.all(color: Colors.orange),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'Write your letter below:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      TextField(
                        controller: _controller,
                        maxLines: 8,
                        maxLength: 1000,
                        onChanged: (value) {
                          setState(() {
                            _charCount = value.length;
                          });
                        },
                        decoration: InputDecoration(
                          hintText: 'Dear ${widget.childName},',
                          filled: true,
                          fillColor: Colors.orange.shade50,
                          contentPadding: const EdgeInsets.all(12),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          counterText: 'Characters: $_charCount/300',
                          counterStyle: const TextStyle(color: Colors.grey),
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _sendLetter,
                          icon: const Icon(Icons.send, color: Colors.white),
                          label: const Text(
                            'Send',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFeb7f35),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                        ),
                      ),
                    ],
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
