import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void handleExitApp() {
  if (Platform.isAndroid) {
    SystemNavigator.pop(); 
  } else if (Platform.isIOS) {
  }
}

Future<bool> showExitConfirmationDialog(BuildContext context) async {
  return await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          backgroundColor: Colors.white,
          title: Row(
            children: const [
              Icon(Icons.warning_amber_rounded, color: Colors.orange),
              SizedBox(width: 8),
              Text(
                'Exit App',
                style: TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Divider(),
              SizedBox(height: 8),
              Text(
                'Are you sure you want to exit?',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 8),
              Divider(),
            ],
          ),
          actionsAlignment: MainAxisAlignment.center,
          actionsPadding: const EdgeInsets.only(bottom: 12),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
                handleExitApp(); // Exit the app
              },
              child: const Text('Exit'),
            ),
          ],
        ),
      ) ??
      false;
}
