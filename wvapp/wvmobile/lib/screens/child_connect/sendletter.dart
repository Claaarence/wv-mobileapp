import 'package:flutter/material.dart';


class SendLetterPage extends StatefulWidget {
  final String childName;

  const SendLetterPage({super.key, required this.childName});

  @override
  State<SendLetterPage> createState() => _SendLetterPageState();
}

class _SendLetterPageState extends State<SendLetterPage> {
  final TextEditingController _controller = TextEditingController();
  int _charCount = 0;

  
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
                      // Notebook-style label
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

                      // Text area with counter
                      TextField(
                        controller: _controller,
                        maxLines: 8,
                        maxLength: 300,
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
                      const SizedBox(height: 10),

                      // Attach file
                  

                      const SizedBox(height: 20),

                      // Send button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {},
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


