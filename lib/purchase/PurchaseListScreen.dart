import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:innoentexim/purchase/purchaseEditScreen.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import '../components/AppBar.dart';
import '../components/AppDrawer.dart';
import '../components/ApiConfig.dart';
import '../components/profileHeader.dart';
import '../authentication/AuthService.dart';
import './PurchaseAddScreen.dart';
import './purchaseInfoScreen.dart';
import './purchaseEditScreen.dart';

class PurchaseListScreen extends StatefulWidget {
  static String baseUrl = ApiConfig.baseUrl;
  final String token;
  

  const PurchaseListScreen({Key? key, required this.token}) : super(key: key);

  @override
  _PurchaseListScreenState createState() => _PurchaseListScreenState();
}

class _PurchaseListScreenState extends State<PurchaseListScreen> {
  List<Map<String, dynamic>> _purchaseListData = [];
  List<Map<String, dynamic>> _purchaseParties = [];
  bool _isLoading = false;
  bool _canAddPurchase = false; // New variable to track permission
  String _errorMessage = '';
  DateTimeRange? _selectedDateRange;
  String? _selectedParty;
  TextEditingController _dateRangeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _checkUserPermissions();
    _fetchPurchaseListData();
    _fetchPurchaseParties();
  }

  Future<void> _checkUserPermissions() async {
    try {
      final response = await http.get(
        Uri.parse('${PurchaseListScreen.baseUrl}auth/nav-profile/'),
        headers: {'Authorization': 'Bearer ${widget.token}'},
      );

      if (response.statusCode == 200) {
        final userData = json.decode(response.body)['data'];
        final List<String> userGroups = List<String>.from(userData['group_names']);

        setState(() {
          _canAddPurchase = userGroups.contains('purchase'); // Check if 'Purchase' is in user groups
        });
      } else {
        setState(() {
          _errorMessage = 'Failed to load user details';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error fetching user details: $e';
      });
    }
  }

  Future<void> _fetchPurchaseListData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.get(
        Uri.parse('${PurchaseListScreen.baseUrl}purchase/purchase-report/'),
        headers: {'Authorization': 'Bearer ${widget.token}'},
      );

      if (response.statusCode == 200) {
        setState(() {
          _purchaseListData = List<Map<String, dynamic>>.from(json.decode(response.body)['data']);
        });
      } else {
        setState(() {
          _errorMessage = 'Failed to load purchase list data';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error fetching data: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchPurchaseParties() async {
    try {
      final response = await http.get(
        Uri.parse('${PurchaseListScreen.baseUrl}purchase/purchase-parties/'),
        headers: {'Authorization': 'Bearer ${widget.token}'},
      );

      if (response.statusCode == 200) {
        setState(() {
          _purchaseParties = List<Map<String, dynamic>>.from(json.decode(response.body)['data']);
        });
      } else {
        setState(() {
          _errorMessage = 'Failed to load purchase parties data';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error fetching data: $e';
      });
    }
  }

  Future<void> exportPurchases() async {
    final response = await http.get(
      Uri.parse('http://64.227.144.183:81/super-admin/purchase/export-purchases/'),
      headers: {'Authorization': 'Bearer ${widget.token}'},
    );

    if (response.statusCode == 200) {
      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/purchases_data.xlsx';
      final file = File(filePath);

      await file.writeAsBytes(response.bodyBytes);
      OpenFile.open(filePath);
    } else {
      // Handle the error
      print('Failed to download file');
    }
  }

  Future<void> _selectDateRange(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      initialDateRange: _selectedDateRange,
    );
    if (picked != null && picked != _selectedDateRange) {
      setState(() {
        _selectedDateRange = picked;
        _dateRangeController.text =
            '${picked.start.toLocal().toString().split(' ')[0]} - ${picked.end.toLocal().toString().split(' ')[0]}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'Purchase'),
      drawer: AppDrawer(currentRoute: '/purchase'),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              onChanged: (value) {
                // Implement search functionality here
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                SizedBox(
                  height: 40,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: OutlinedButton.icon(
                      onPressed: exportPurchases,
                      icon: Icon(
                        Icons.download,
                        size: 14,
                        color: Colors.black,
                      ),
                      style: ButtonStyle(
                        side: MaterialStateProperty.all<BorderSide>(
                          BorderSide(color: Colors.black),
                        ),
                        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                      ),
                      label: Text(
                        'Export',
                        style: TextStyle(
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                ),
                if (_canAddPurchase) // Conditionally show the "Add" button
                  SizedBox(
                    height: 40,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: [Color(0xFF17AD37), Color(0xFF98EC2D)],
                          ),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => PurchaseAddScreen(token: widget.token)),
                            );
                          },
                          child: Text(
                            'Add',
                            style: TextStyle(color: Colors.white),
                          ),
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all<Color>(Colors.transparent),
                            elevation: MaterialStateProperty.all<double>(0),
                            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                SizedBox(
                  height: 40,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: PopupMenuButton(
                      itemBuilder: (BuildContext context) => [
                        PopupMenuItem(
                          child: Container(
                            padding: EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Select Date Range'),
                                TextField(
                                  readOnly: true,
                                  controller: _dateRangeController,
                                  onTap: () {
                                    _selectDateRange(context);
                                  },
                                  decoration: InputDecoration(
                                    hintText: 'Select Date Range',
                                  ),
                                ),
                                SizedBox(height: 16.0),
                                Text('Purchase Parties'),
                                DropdownButtonFormField<String>(
                                  value: _selectedParty,
                                  items: _purchaseParties
                                      .map((party) {
                                        if (party != null && party['id'] != null && party['fullname'] != null) {
                                          return DropdownMenuItem<String>(
                                            value: party['id'].toString(),
                                            child: Text(party['fullname'].toString()), // Change 'name' to 'fullname'
                                          );
                                        } else {
                                          return null; // Skip invalid party items
                                        }
                                      })
                                      .whereType<DropdownMenuItem<String>>() // Remove null items
                                      .toList(),
                                  onChanged: (value) {
                                    setState(() {
                                      _selectedParty = value;
                                    });
                                  },
                                ),
                                SizedBox(height: 16.0),
                                ElevatedButton(
                                  onPressed: () {
                                    // Apply filter logic here
                                    _applyFilters();
                                  },
                                  child: Text('Apply'),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: [Color(0xff2152ff), Color(0xff21d4fd)],
                          ),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: ElevatedButton(
                          onPressed: null,
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all<Color>(Colors.transparent),
                            elevation: MaterialStateProperty.all<double>(0),
                            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.filter_list,
                                size: 14,
                                color: Colors.white,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Filter',
                                style: TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? Center(
                    child: CircularProgressIndicator(),
                  )
                : _errorMessage.isNotEmpty
                    ? Center(
                        child: Text(_errorMessage),
                      )
                    : _purchaseListData.isNotEmpty
                        ? SingleChildScrollView(
                            scrollDirection: Axis.vertical,
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: DataTable(
                                columnSpacing: 30,
                                columns: [
                                  DataColumn(label: Text('Purchase ID')),
                                  DataColumn(label: Text('Date')),
                                  DataColumn(label: Text('Purchase Party Name')),
                                  DataColumn(label: Text('Total Qty')),
                                  DataColumn(label: Text('Total Amount')),
                                  DataColumn(label: Text('Total Expense')),
                                  DataColumn(label: Text('Grand Total')),
                                  DataColumn(label: Text('Action')),
                                ],
                                rows: _purchaseListData.map((purchase) {
                                  return DataRow(
                                    cells: [
                                      DataCell(Text('${purchase['purchase_id']}')),
                                      DataCell(Text('${purchase['date']}')),
                                      DataCell(Text('${purchase['purchase_party_name']}')),
                                      DataCell(Text('${purchase['total_qty']}')),
                                      DataCell(Text('${purchase['total_amount']}')),
                                      DataCell(Text('${purchase['total_expense']}')),
                                      DataCell(Text('${purchase['grand_total']}')),
                                      if (_canAddPurchase)
                                      DataCell(
                                        Row(
                                          children: [
                                            IconButton(
                                              icon: Icon(Icons.remove_red_eye),
                                              color: Color(0xFF8392AB),
                                              onPressed: () {
                                                // Navigate to single page view
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) => PurchaseInfoScreen(token: widget.token, purchasePk: purchase['id']),
                                                  ),
                                                );
                                              },
                                            ),
                                            // IconButton(
                                            //   icon: Icon(Icons.edit),
                                            //   color: Color(0xFF8392AB),
                                            //   onPressed: () {
                                            //     // Navigate to edit page
                                            //     Navigator.push(
                                            //       context,
                                            //       MaterialPageRoute(
                                            //         builder: (context) => PurchaseEditScreen(token: widget.token, purchaseId: purchase['id']),
                                            //       ),
                                            //     );
                                            //   },
                                            // ),
                                            IconButton(
                                              icon: Icon(Icons.delete),
                                              color: Color(0xFF8392AB),
                                              onPressed: () {
                                                // Delete the item
                                                _showDeleteConfirmationDialog(token: widget.token, purchasePk: purchase['id']);
                                              },
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  );
                                }).toList(),
                              ),
                            ),
                          )
                        : Center(
                            child: Text('No data available'),
                          ),
          ),
        ],
      ),
    );
  }

  void _applyFilters() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Constructing URL with query parameters
      final Uri uri = Uri.parse('${PurchaseListScreen.baseUrl}purchase/purchase-report/')
        .replace(queryParameters: {
          'startDate': _selectedDateRange?.start.toString(),
          'endDate': _selectedDateRange?.end.toString(),
          'partyId': _selectedParty ?? '',
        });

      final response = await http.get(
        uri,
        headers: {'Authorization': 'Bearer ${widget.token}'},
      );

      if (response.statusCode == 200) {
        setState(() {
          _purchaseListData = List<Map<String, dynamic>>.from(json.decode(response.body)['data']);
        });
      } else {
        setState(() {
          _errorMessage = 'Failed to load purchase list data';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error fetching data: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showDeleteConfirmationDialog({required String token, required String purchasePk}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirm Deletion'),
        content: Text('Are you sure you want to delete this purchase?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Dismiss the dialog
            },
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Dismiss the dialog
              _deletePurchase(token: token, purchasePk: purchasePk); // Proceed with deletion
            },
            child: Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _deletePurchase({required String token, required String purchasePk}) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse('${PurchaseListScreen.baseUrl}purchase/delete-purchase/$purchasePk/'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Request successful
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Success'),
            content: Text('Purchase deleted successfully'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => PurchaseListScreen(token: widget.token),
                    ),
                  );
                },
                child: Text('OK'),
              ),
            ],
          ),
        );
      } else {
        // Request failed
        String errorMessage = 'Failed to delete purchase';
        try {
          final responseBody = jsonDecode(response.body);
          if (responseBody.containsKey('message')) {
            errorMessage = responseBody['message'];
          }
        } catch (e) {
          // JSON decoding failed, use the default error message
        }

        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Error'),
            content: Text(errorMessage),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error deleting the purchase: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _dateRangeController.dispose();
    super.dispose();
  }
}
