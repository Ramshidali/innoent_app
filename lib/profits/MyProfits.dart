import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../components/AppBar.dart';
import '../components/AppDrawer.dart';
import '../components/ApiConfig.dart';

class MyProfitReportScreen extends StatefulWidget {
  static String baseUrl = ApiConfig.baseUrl;
  final String token;

  const MyProfitReportScreen({Key? key, required this.token}) : super(key: key);

  @override
  _myProfitReportScreenState createState() => _myProfitReportScreenState();
}

class _myProfitReportScreenState extends State<MyProfitReportScreen> {
  late List<Map<String, dynamic>> _myProfitReportData = [];
  bool _isLoading = false;
  String _errorMessage = '';
  DateTimeRange? _selectedDateRange;
  TextEditingController _dateRangeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchMyProfitReportData();
  }

  Future<void> _fetchMyProfitReportData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.get(
        Uri.parse('${MyProfitReportScreen.baseUrl}profit/profit-my/'),
        headers: {'Authorization': 'Bearer ${widget.token}'},
      );

      if (response.statusCode == 200) {
        setState(() {
          _myProfitReportData = List<Map<String, dynamic>>.from(json.decode(response.body)['data']);
        });
      } else {
        setState(() {
          _errorMessage = 'Failed to load totalProfit list data';
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
      appBar: CustomAppBar(title: 'MyProfit'), // Pass the title dynamically
      drawer: AppDrawer(currentRoute: '/myProfits'),
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
                    : _myProfitReportData.isNotEmpty
                        ? SingleChildScrollView(
                            scrollDirection: Axis.vertical,
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: DataTable(
                                columnSpacing: 30, // Adjust column spacing as needed
                                columns: [
                                  DataColumn(label: Text('#')),
                                  DataColumn(label: Text('Date Added')),
                                  DataColumn(label: Text('Month')),
                                  DataColumn(label: Text('Year')),
                                  DataColumn(label: Text('Profit')),
                                ],
                                rows: _myProfitReportData.asMap().entries.map<DataRow>((entry) {
                                  final index = entry.key;
                                  final profit = entry.value;
                                  final profitValue = double.tryParse(profit['profit']) ?? 0.0;
                                  return DataRow(
                                    cells: [
                                      DataCell(Text('${index + 1}')),
                                      DataCell(Text('${profit['date_added']}')),
                                      DataCell(Text('${profit['month']}')),
                                      DataCell(Text('${profit['year']}')),
                                      DataCell(Row(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          Icon(
                                            profitValue > 0 ? Icons.arrow_upward : Icons.arrow_downward,
                                            color: profitValue > 0 ? Colors.green : Colors.red,
                                            size: 16,
                                          ),
                                          SizedBox(width: 4),
                                          Text(
                                            '$profitValue',
                                            style: TextStyle(
                                              color: profitValue > 0 ? Colors.green : Colors.red,
                                            ),
                                          ),
                                        ],
                                      )),
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
      final Uri uri = Uri.parse('${MyProfitReportScreen.baseUrl}profit/profit-my/')
        .replace(queryParameters: {
          'startDate': _selectedDateRange?.start.toString(),
          'endDate': _selectedDateRange?.end.toString(),
        });

      final response = await http.get(
        uri,
        headers: {'Authorization': 'Bearer ${widget.token}'},
      );

      if (response.statusCode == 200) {
        setState(() {
          _myProfitReportData = List<Map<String, dynamic>>.from(json.decode(response.body)['data']);
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



}
