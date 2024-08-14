import 'package:flutter/material.dart';

class SalesEditScreen extends StatelessWidget {
  final String salesId;

  SalesEditScreen({required this.salesId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sales Details'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sales ID: $salesId',
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
