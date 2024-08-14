import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../HomeScreen.dart';
import '../purchase/PurchaseListScreen.dart';
import '../sales/SalesReport.dart';
import '../profits/DialyProfits.dart';
import '../profits/MonthlyProfits.dart';
import '../profits/MyProfits.dart';
import '../authentication/AuthService.dart';
import '../components/profileHeader.dart';
import '../authentication/loginScreen.dart';

class AppDrawer extends StatefulWidget {
  final String currentRoute;

  AppDrawer({this.currentRoute = '/'});

  @override
  _AppDrawerState createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  late int _selectedIndex; // Track the selected index
  bool _canAddPurchase = false; // Flag to check user permissions for purchasing
  bool _canAddSales = false; // Flag to check user permissions for sales
  bool _canViewProfit = false; // Flag to check user permissions for viewing my profit
  List<String> _userGroups = []; // List to store user groups

  @override
  void initState() {
    super.initState();
    _selectedIndex = _getSelectedIndex(widget.currentRoute);
    _checkUserPermissions(); // Check user permissions when the drawer is initialized
  }

  int _getSelectedIndex(String currentRoute) {
    switch (currentRoute) {
      case '/':
        return 0;
      case '/purchase':
        return 1;
      case '/sales':
        return 2;
      case '/profits':
        return 3;
      default:
        return 0; // Default to HomeScreen
    }
  }

  Future<void> _logout() async {
    final token = await AuthService.getToken();
    if (token != null) {
      final url = Uri.parse('${AuthService.baseUrl}/auth/logout/');
      final response = await http.post(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 200) {
        // Logout successful, navigate to login screen or perform other actions
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginScreen()));
      } else {
        // Handle logout failure
        print('Logout failed: ${response.body}');
      }
    }
  }

  Future<void> _checkUserPermissions() async {
    try {
      final response = await http.get(
        Uri.parse('${PurchaseListScreen.baseUrl}auth/nav-profile/'),
        headers: {'Authorization': 'Bearer ${await AuthService.getToken()}'},
      );

      if (response.statusCode == 200) {
        final userData = json.decode(response.body)['data'];
        setState(() {
          _userGroups = List<String>.from(userData['group_names']);
          _canAddPurchase = _userGroups.contains('purchase');
          _canAddSales = _userGroups.contains('sales');
          _canViewProfit = _userGroups.contains('investor');
        });
      } else {
        setState(() {
          _canAddPurchase = false; // Reset permission flag
          _canAddSales = false; // Reset permission flag
          _canViewProfit = false; // Reset permission flag
        });
      }
    } catch (e) {
      setState(() {
        _canAddPurchase = false; // Reset permission flag
        _canAddSales = false; // Reset permission flag
        _canViewProfit = false; // Reset permission flag
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          ProfileHeader(), // Use the new ProfileHeader component
          ListTile(
            selected: _selectedIndex == 0,
            leading: Icon(Icons.home),
            title: Text('Home'),
            onTap: () {
              setState(() {
                _selectedIndex = 0; // Set the selected index
              });
              Navigator.pop(context); // Close the drawer
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomeScreen()));
            },
          ),
          if (_canAddPurchase) // Conditionally render the Purchase tab based on user permissions
            ListTile(
              selected: _selectedIndex == 1,
              leading: Icon(Icons.shopping_cart),
              title: Text('Purchase'),
              onTap: () async {
                setState(() {
                  _selectedIndex = 1; // Set the selected index
                });
                Navigator.pop(context); // Close the drawer
                final token = await AuthService.getToken() ?? ''; // Provide a default value if token is null
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PurchaseListScreen(token: token),
                  ),
                );
              },
            ),
          if (_canAddSales) // Conditionally render the Sales tab based on user permissions
            ListTile(
              selected: _selectedIndex == 2,
              leading: Icon(Icons.bar_chart),
              title: Text('Sales'),
              onTap: () async {
                setState(() {
                  _selectedIndex = 2; // Set the selected index
                });
                Navigator.pop(context); // Close the drawer
                final token = await AuthService.getToken() ?? ''; // Provide a default value if token is null
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SalesReportScreen(token: token),
                  ),
                );
              },
            ),
          if (_canViewProfit) 
            ListTile(
              selected: _selectedIndex == 3,
              leading: Icon(Icons.attach_money),
              title: Text('Dialy Profit'),
              onTap: () async {
                setState(() {
                  _selectedIndex = 3; // Set the selected index
                });
                Navigator.pop(context); // Close the drawer
                final token = await AuthService.getToken() ?? ''; // Provide a default value if token is null
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DialyProfitReportScreen(token: token),
                  ),
                );
              },
            ),
          if (_canViewProfit) 
            ListTile(
              selected: _selectedIndex == 3,
              leading: Icon(Icons.attach_money),
              title: Text('Monthly Profit'),
              onTap: () async {
                setState(() {
                  _selectedIndex = 3; // Set the selected index
                });
                Navigator.pop(context); // Close the drawer
                final token = await AuthService.getToken() ?? ''; // Provide a default value if token is null
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MonthlyProfitReportScreen(token: token),
                  ),
                );
              },
            ),
          if (_canViewProfit) // Conditionally render the My Profit tab based on user permissions
            ListTile(
              selected: _selectedIndex == 3,
              leading: Icon(Icons.attach_money),
              title: Text('My Profit'),
              onTap: () async {
                setState(() {
                  _selectedIndex = 3; // Set the selected index
                });
                Navigator.pop(context); // Close the drawer
                final token = await AuthService.getToken() ?? ''; // Provide a default value if token is null
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MyProfitReportScreen(token: token),
                  ),
                );
              },
            ),
          ListTile(
            leading: Icon(Icons.logout),
            title: Text('Logout'),
            onTap: _logout,
          ),
        ],
      ),
    );
  }
}
