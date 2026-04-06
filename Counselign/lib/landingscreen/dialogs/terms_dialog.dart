import 'package:flutter/material.dart';

Widget buildTermsDialog({required VoidCallback onClose}) {
  return Builder(
    builder: (context) => ConstrainedBox(
      constraints: const BoxConstraints(
        maxWidth: 600,
        maxHeight: 700,
      ),
      child: AlertDialog(
      title: Row(
        children: [
          const Expanded(child: Text('Terms and Conditions')),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              Navigator.pop(context);
              onClose();
            },
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text('Last updated: NOVEMBER 2025', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Text('1. Acceptance of Terms', style: TextStyle(fontWeight: FontWeight.bold)),
            Text('By accessing and using the Counselign System, you accept and agree to be bound by these Terms and Conditions.'),
            SizedBox(height: 10),
            Text('2. Privacy Policy', style: TextStyle(fontWeight: FontWeight.bold)),
            Text('Your privacy is important to us. All personal information provided will be handled in accordance with our Privacy Policy.'),
            SizedBox(height: 10),
            Text('3. User Responsibilities', style: TextStyle(fontWeight: FontWeight.bold)),
            Text('Users are responsible for maintaining the confidentiality of their account information and for all activities that occur under their account.'),
            SizedBox(height: 10),
            Text('4. Data Protection', style: TextStyle(fontWeight: FontWeight.bold)),
            Text('We implement appropriate security measures to protect your personal information. However, no method of transmission over the internet is 100% secure.'),
            SizedBox(height: 10),
            Text('5. Changes to Terms', style: TextStyle(fontWeight: FontWeight.bold)),
            Text('We reserve the right to modify these terms at any time. Users will be notified of any significant changes.'),
          ],
        ),
      ),
    ),
    ),
  );
}