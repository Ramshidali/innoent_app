import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../components/AppBar.dart';
import '../components/AppDrawer.dart';
import '../components/ApiConfig.dart';

class SalesInfoScreen extends StatefulWidget {
  static String baseUrl = ApiConfig.baseUrl;
  final String token;
  final String salesPk;

  const SalesInfoScreen({Key? key, required this.token, required this.salesPk}) : super(key: key);

  @override
  _SalesInfoScreenState createState() => _SalesInfoScreenState();
}

class _SalesInfoScreenState extends State<SalesInfoScreen> {
  Map<String, dynamic>? _salesInfoData;
  bool _isLoading = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchSalesInfoData();
  }

  Future<void> _fetchSalesInfoData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.get(
        Uri.parse('${SalesInfoScreen.baseUrl}sales/sales-info/${widget.salesPk}/'),
        headers: {'Authorization': 'Bearer ${widget.token}'},
      );

      if (response.statusCode == 200) {
        setState(() {
          _salesInfoData = json.decode(response.body)['data'];
        });
      } else {
        setState(() {
          _errorMessage = 'Failed to load sales info data';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sales Info'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
              ? Center(child: Text(_errorMessage))
              : _salesInfoData != null
                  ? Padding(
                      padding: EdgeInsets.all(16.0),
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Sales ID: ${_salesInfoData!['sales_id']}',
                                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  'Date: ${_salesInfoData!['sales_date']}',
                                  style: TextStyle(fontSize: 14),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Sales Party: ${_salesInfoData!['sales_party']}',
                                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  'Country: ${_salesInfoData!['sales_country']}',
                                  style: TextStyle(fontSize: 14),
                                ),
                              ],
                            ),
                            SizedBox(height: 16),
                            Text(
                              'Items:',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            LayoutBuilder(
                              builder: (context, constraints) {
                                return SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: ConstrainedBox(
                                    constraints: BoxConstraints(minWidth: constraints.maxWidth),
                                    child: DataTable(
                                      columns: [
                                        DataColumn(label: Text('Item')),
                                        DataColumn(label: Text('Sales Type')),
                                        DataColumn(label: Text('No.Boxes')),
                                        DataColumn(label: Text('Quantity (kg)')),
                                        DataColumn(label: Text('Amount per kg')),
                                        DataColumn(label: Text('Amount')),
                                        DataColumn(label: Text('Amount (INR)')),
                                      ],
                                      rows: (_salesInfoData!['sales_items']['items_data'] as List)
                                          .map((item) => DataRow(cells: [
                                                DataCell(Text(item['sales_item'])),
                                                DataCell(Text(item['sale_type'])),
                                                DataCell(Text(item['no_boxes'].toString())),
                                                DataCell(Text(item['qty'].toString())),
                                                DataCell(Text(item['per_kg_amount'].toString())),
                                                DataCell(Text(item['amount'].toString())),
                                                DataCell(Text(item['amount_in_inr'].toString())),
                                              ]))
                                          .toList(),
                                    ),
                                  ),
                                );
                              },
                            ),
                            SizedBox(height: 16),
                            Text(
                              'Expenses:',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 4),
                            LayoutBuilder(
                              builder: (context, constraints) {
                                return SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: ConstrainedBox(
                                    constraints: BoxConstraints(minWidth: constraints.maxWidth),
                                    child: DataTable(
                                      columns: [
                                        DataColumn(label: Text('Title')),
                                        DataColumn(label: Text('Amount')),
                                        DataColumn(label: Text('Amount (INR)')),
                                      ],
                                      rows: (_salesInfoData!['sales_expenses']['expense_data'] as List)
                                          .map((expense) => DataRow(cells: [
                                                DataCell(Text(expense['title'])),
                                                DataCell(Text(expense['amount'].toString())),
                                                DataCell(Text(expense['amount_in_inr'].toString())),
                                              ]))
                                          .toList(),
                                    ),
                                  ),
                                );
                              },
                            ),
                            SizedBox(height: 16),
                            Align(
                              alignment: Alignment.centerRight,
                              child: DataTable(
                                columns: [
                                  DataColumn(label: Text('')),
                                  DataColumn(label: Text('')),
                                  DataColumn(label: Text('')),
                                ],
                                rows: [
                                  DataRow(cells: [
                                    DataCell(
                                      Text(
                                        'Total Quantity',
                                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    DataCell(Text('${_salesInfoData!['total_qty'].toString()} kg')),
                                    DataCell(Text('')), // Empty cell for alignment with DataColumn
                                  ]),
                                  DataRow(cells: [
                                    DataCell(
                                      Text(
                                        'Total Amount',
                                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    DataCell(Text('${_salesInfoData!['total_amount'].toString()}')),
                                    DataCell(Text('\u20B9${_salesInfoData!['total_amount_inr'].toString()}')),
                                  ]),
                                  DataRow(cells: [
                                    DataCell(
                                      Text(
                                        'Total Expense',
                                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    DataCell(Text('${_salesInfoData!['total_amount_expense'].toString()}')),
                                    DataCell(Text('\u20B9${_salesInfoData!['total_amount_expense_inr'].toString()}')),
                                  ]),
                                  DataRow(cells: [
                                    DataCell(
                                      Text(
                                        'Grand Total',
                                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    DataCell(
                                      Text(
                                        '${_salesInfoData!['total_sub_total_amount'].toString()}',
                                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    DataCell(
                                      Text(
                                        '\u20B9${_salesInfoData!['total_sub_total_inr_amount'].toString()}',
                                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ]),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : Center(child: Text('No data available')),
    );
  }
}
