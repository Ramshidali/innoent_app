import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../components/AppBar.dart';
import '../components/AppDrawer.dart';
import '../components/ApiConfig.dart';
import '../sales/salesAddScreen.dart';
import 'salesInfoScreen.dart';
import './salesEditScreen.dart';

class SalesReportScreen extends StatefulWidget {
  static String baseUrl = ApiConfig.baseUrl;
  final String token;

  const SalesReportScreen({Key? key, required this.token}) : super(key: key);

  @override
  _salesReportScreenState createState() => _salesReportScreenState();
}

class _salesReportScreenState extends State<SalesReportScreen> {
  late List<Map<String, dynamic>> _salesReportData;
  List<Map<String, dynamic>> _salesParties = [];
  List<Map<String, dynamic>> _salesCountries = [];
  bool _isLoading = false;
  bool _canAddSales = false;
  String _errorMessage = '';
  DateTimeRange? _selectedDateRange;
  String? _selectedParty;
  String? _selectedCountry;
  TextEditingController _dateRangeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _checkUserPermissions();
    _fetchSalesReportData();
    _fetchSalesParties();
    _fetchSalesCountries();
  }

  Future<void> _checkUserPermissions() async {
    try {
      final response = await http.get(
        Uri.parse('${SalesReportScreen.baseUrl}auth/nav-profile/'),
        headers: {'Authorization': 'Bearer ${widget.token}'},
      );

      if (response.statusCode == 200) {
        final userData = json.decode(response.body)['data'];
        final List<String> userGroups = List<String>.from(userData['group_names']);

        setState(() {
          _canAddSales = userGroups.contains('sales'); // Check if 'Sales' is in user groups
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

  Future<void> _fetchSalesReportData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.get(
        Uri.parse('${SalesReportScreen.baseUrl}sales/sales-report/'),
        headers: {'Authorization': 'Bearer ${widget.token}'},
      );

      if (response.statusCode == 200) {
        setState(() {
          _salesReportData = List<Map<String, dynamic>>.from(json.decode(response.body)['data']);
        });
      } else {
        setState(() {
          _errorMessage = 'Failed to load sales list data';
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

  Future<void> _fetchSalesParties() async {
    try {
      final response = await http.get(
        Uri.parse('${SalesReportScreen.baseUrl}sales/sales-parties/'),
      );

      if (response.statusCode == 200) {
        setState(() {
          _salesParties = List<Map<String, dynamic>>.from(json.decode(response.body)['data']);
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

  Future<void> _fetchSalesCountries() async {
    try {
      final response = await http.get(
        Uri.parse('${SalesReportScreen.baseUrl}sales/export-countries/'),
      );

      if (response.statusCode == 200) {
        setState(() {
          _salesCountries = List<Map<String, dynamic>>.from(json.decode(response.body)['data']);
        });
      } else {
        setState(() {
          _errorMessage = 'Failed to load sales counties data';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error fetching data: $e';
      });
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
      appBar: CustomAppBar(title: 'Sales'), // Pass the title dynamically
      drawer: AppDrawer(currentRoute: '/sales'),
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
                  height: 40, // Specify the desired height
                  child: Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: OutlinedButton.icon(
                      onPressed: () {
                        // Button action logic here
                      },
                      icon: Icon(
                        Icons.download, // Download icon
                        size: 14, // Adjust the size of the icon as needed
                        color: Colors.black, // Icon color
                      ),
                      style: ButtonStyle(
                        side: MaterialStateProperty.all<BorderSide>(
                          BorderSide(color: Colors.black), // Dark outline color
                        ),
                        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0), // Rounded corners
                          ),
                        ),
                      ),
                      label: Text(
                        'Export',
                        style: TextStyle(
                          color: Colors.black, // Text color
                        ),
                      ),
                    ),
                  ),
                ),
                if (_canAddSales)
                  SizedBox(
                    height: 40, // Specify the desired height
                    child: Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: [Color(0xFF17AD37), Color(0xFF98EC2D)], // Green gradient colors
                          ),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: ElevatedButton(
                          onPressed: () {
                            // Navigate to Sales Add screen and pass the token
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => SalesAddScreen(token: widget.token)),
                            );
                          },
                          child: Text(
                            'Add',
                            style: TextStyle(color: Colors.white),
                          ),
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all<Color>(Colors.transparent), // Transparent button background
                            elevation: MaterialStateProperty.all<double>(0), // No elevation
                            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0), // Rounded corners
                              ),
                            ),
                          ),
                        ),

                      ),
                    ),
                  ),

                SizedBox(
                  height: 40, // Specify the desired height
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
                                Text('Sales Parties'),
                                DropdownButtonFormField<String>(
                                  value: _selectedParty,
                                  items: _salesParties
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
                                Text('Country'),
                                DropdownButtonFormField<String>(
                                  value: _selectedCountry,
                                  items: _salesCountries
                                      .map((country) {
                                        if (country != null && country['id'] != null && country['country_name'] != null) {
                                          return DropdownMenuItem<String>(
                                            value: country['id'].toString(),
                                            child: Text(country['country_name'].toString()), // Change 'name' to 'fullname'
                                          );
                                        } else {
                                          return null; // Skip invalid party items
                                        }
                                      })
                                      .whereType<DropdownMenuItem<String>>() // Remove null items
                                      .toList(),
                                  onChanged: (value) {
                                    setState(() {
                                      _selectedCountry = value;
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
                    : _salesReportData != null
                        ? SingleChildScrollView(
                            scrollDirection: Axis.vertical,
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: DataTable(
                                columnSpacing: 30, // Adjust column spacing as needed
                                columns: [
                                  DataColumn(label: Text('Sl.No')),
                                  DataColumn(label: Text('Sales ID')),
                                  DataColumn(label: Text('Date')),
                                  DataColumn(label: Text('Sales Party Name')),
                                  DataColumn(label: Text('Country')),
                                  DataColumn(label: Text('Qty')),
                                  DataColumn(label: Text('Exchange Rate')),
                                  DataColumn(label: Text('Amount')),
                                  DataColumn(label: Text('Amount(INR)')),
                                  DataColumn(label: Text('Expense')),
                                  DataColumn(label: Text('Expense(INR)')),
                                  DataColumn(label: Text('Grand Total')),
                                  DataColumn(label: Text('Grand Total(INR)')),
                                  DataColumn(label: Text('Action')),
                                ],
                                rows: _salesReportData.asMap().entries.map<DataRow>((entry) {
                                  final index = entry.key;
                                  final sales = entry.value;
                                  return DataRow(
                                    cells: [
                                      DataCell(Text('${index + 1}')),
                                      DataCell(Text('${sales['sales_id']}')),
                                      DataCell(Text('${sales['date']}')),
                                      DataCell(Text('${sales['sales_party']}')),
                                      DataCell(Text('${sales['country_name']}')),
                                      DataCell(Text('${sales['total_qty']}')),
                                      DataCell(Text('${sales['exchange_rate']}')),
                                      DataCell(Text('${sales['items_total_amount']}')),
                                      DataCell(Text('${sales['items_total_inr_amount']}')),
                                      DataCell(Text('${sales['items_total_expence']}')),
                                      DataCell(Text('${sales['expenses_items_total_inr_amount']}')),
                                      DataCell(Text('${sales['sub_total']}')),
                                      DataCell(Text('${sales['exchange_sub_total']}')),
                                      if (_canAddSales)
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
                                                    builder: (context) => SalesInfoScreen(token: widget.token, salesPk: sales['id']),
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
                                            //         builder: (context) => SalesEditScreen(salesId: sales['sales_id']),
                                            //       ),
                                            //     );
                                            //   },
                                            // ),
                                            IconButton(
                                              icon: Icon(Icons.delete),
                                              color: Color(0xFF8392AB),
                                              onPressed: () {
                                                // Delete the item
                                                _showDeleteConfirmationDialog(token: widget.token, salesId: sales['id']);
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
      final Uri uri = Uri.parse('${SalesReportScreen.baseUrl}sales/sales-report/')
        .replace(queryParameters: {
          'startDate': _selectedDateRange?.start.toString(),
          'endDate': _selectedDateRange?.end.toString(),
          'salesParty': _selectedParty ?? '',
          'country': _selectedCountry ?? '',
        });

      final response = await http.get(
        uri,
        headers: {'Authorization': 'Bearer ${widget.token}'},
      );

      if (response.statusCode == 200) {
        setState(() {
          _salesReportData = List<Map<String, dynamic>>.from(json.decode(response.body)['data']);
        });
      } else {
        setState(() {
          _errorMessage = 'Failed to load sales list data';
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

  void _showDeleteConfirmationDialog({required String token, required String salesId}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirm Deletion'),
        content: Text('Are you sure you want to delete this sales record?'),
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
              _deleteSales(token: token, salesId: salesId); // Proceed with deletion
            },
            child: Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _deleteSales({required String token, required String salesId}) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse('${SalesReportScreen.baseUrl}sales/delete-sales/$salesId/'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Request successful
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Success'),
            content: Text('Sales record deleted successfully'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => SalesReportScreen(token: widget.token),
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
        String errorMessage = 'Failed to delete sales record';
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
        _errorMessage = 'Error deleting the sales: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

}
