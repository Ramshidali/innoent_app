import 'package:flutter/material.dart';

class PurchaseEditScreen extends StatelessWidget {
  final String purchaseId;

  PurchaseEditScreen({required this.purchaseId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Purchase Details'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Purchase ID: $purchaseId',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text(
              'This is a dummy page for displaying sales details.',
              style: TextStyle(fontSize: 18),
            ),
            // Add more widgets to display additional sales details
          ],
        ),
      ),
    );
  }
}
