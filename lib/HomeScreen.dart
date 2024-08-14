import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import './components/AppBar.dart';
import '../components/ApiConfig.dart';
import './components/AppDrawer.dart';

class HomeScreen extends StatelessWidget {
  final storage = FlutterSecureStorage();
  static String baseUrl = ApiConfig.baseUrl;
  final String apiUrl = '${baseUrl}dashboard/today-status/'; // Update with your actual base URL

  Future<Map<String, dynamic>> fetchStatus() async {
    final token = await storage.read(key: 'token'); // Assuming you store the token in secure storage
    final response = await http.get(
      Uri.parse(apiUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token', // Assuming your API uses Bearer token
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      return data['data'];
    } else {
      throw Exception('Failed to load status'); 
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'Home'),
      drawer: AppDrawer(currentRoute: '/'),
      body: FutureBuilder<Map<String, dynamic>>(
        future: fetchStatus(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return Center(child: Text('No data available'));
          } else {
            final data = snapshot.data!;
            final groupNames = data['group_names']; // Fetch group names
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: 5.0),
                  Expanded(
                    child: GridView.count(
                      crossAxisCount: 2,
                      children: [
                        if (groupNames.contains('purchase')) 
                          _buildCard('Today\'s Purchase', data['todays_purchases'].toString(), [Color(0xff2152ff), Color(0xff21d4fd)]),
                        if (groupNames.contains('purchase')) 
                          _buildCard('Purchase Expenses', data['todays_purchase_expenses'].toString(), [Color(0xFF7928CA), Color(0xFFFF0080)]),
                        if (groupNames.contains('sales')) 
                          _buildCard('Today\'s Sales', data['todays_sales'].toString(), [Color(0xFF17AD37), Color(0xFF98EC2D)]),
                        if (groupNames.contains('sales')) 
                          _buildCard('Sales Expenses', data['todays_sales_expenses'].toString(), [Color(0xFF7928CA), Color(0xFFFF0080)]),
                        if (groupNames.contains('investor')) 
                          _buildCard('Today\'s Profit', data['profit'].toString(), [Colors.orange, Colors.yellow]),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildCard(String title, String value, List<Color> gradientColors) {
    return SizedBox(
      height: 150, // Set the desired height of the card
      child: Card(
        elevation: 4,
        margin: EdgeInsets.all(6),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15.0),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: gradientColors,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10), // Adjust padding
                child: Text(
                  title,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
              Expanded(
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 4), // Adjust padding
                    child: Text(
                      value,
                      style: TextStyle(fontSize: 24, color: Colors.white),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
