import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../components/AppBar.dart';
import '../components/AppDrawer.dart';
import '../components/ApiConfig.dart';

class PurchaseInfoScreen extends StatefulWidget {
  static String baseUrl = ApiConfig.baseUrl;
  final String token;
  final String purchasePk;

  const PurchaseInfoScreen({Key? key, required this.token, required this.purchasePk}) : super(key: key);

  @override
  _PurchaseInfoScreenState createState() => _PurchaseInfoScreenState();
}

class _PurchaseInfoScreenState extends State<PurchaseInfoScreen> {
  Map<String, dynamic>? _purchaseInfoData;
  bool _isLoading = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchPurchaseInfoData();
  }

  Future<void> _fetchPurchaseInfoData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.get(
        Uri.parse('${PurchaseInfoScreen.baseUrl}purchase/purchase-info/${widget.purchasePk}/'),
        headers: {'Authorization': 'Bearer ${widget.token}'},
      );

      if (response.statusCode == 200) {
        setState(() {
          _purchaseInfoData = json.decode(response.body)['data'];
        });
      } else {
        setState(() {
          _errorMessage = 'Failed to load purchase info data';
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
      appBar: CustomAppBar(title: 'Purchase Info'),
      drawer: AppDrawer(currentRoute: '/purchase-info'),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
              ? Center(child: Text(_errorMessage))
              : _purchaseInfoData != null
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
                                  'Purchase ID: ${_purchaseInfoData!['purchase_id']}',
                                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  'Date: ${_purchaseInfoData!['purchase_date']}',
                                  style: TextStyle(fontSize: 14),
                                ),
                              ],
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Purchase Party: ${_purchaseInfoData!['purchase_party']}',
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 16),
                            Text(
                              'Items:',
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
                                        DataColumn(label: Text('Item')),
                                        DataColumn(label: Text('Quantity (kg)')),
                                        DataColumn(label: Text('Amount per kg')),
                                        DataColumn(label: Text('Total Amount')),
                                      ],
                                      rows: (_purchaseInfoData!['purchase_items']['items_data'] as List)
                                          .map((item) => DataRow(cells: [
                                                DataCell(Text(item['purchase_item_name'])),
                                                DataCell(Text(item['qty'])),
                                                DataCell(Text(item['amount_per_kg'])),
                                                DataCell(Text(item['amount'])),
                                              ]))
                                          .toList(),
                                    ),
                                  ),
                                );
                              },
                            ),
                            SizedBox(height: 8),
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
                                      ],
                                      rows: (_purchaseInfoData!['purchase_expenses']['expense_data'] as List)
                                          .map((expense) => DataRow(cells: [
                                                DataCell(Text(expense['title'])),
                                                DataCell(Text(expense['amount'])),
                                              ]))
                                          .toList(),
                                    ),
                                  ),
                                );
                              },
                            ),
                            SizedBox(height: 4),
                            Align(
                              alignment: Alignment.centerRight,
                              child: DataTable(
                                columns: [
                                  DataColumn(label: Text('')),
                                  DataColumn(label: Text('')),
                                ],
                                rows: [
                                  DataRow(cells: [
                                    DataCell(
                                      Text(
                                        'Total Quantity',
                                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                        )
                                      ),
                                    DataCell(Text('${_purchaseInfoData!['purchase_items']['total_qty']} kg')),
                                  ]),
                                  DataRow(cells: [
                                    DataCell(
                                      Text(
                                        'Total Amount per kg',
                                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                      )
                                    ),
                                    DataCell(Text('\u20B9${_purchaseInfoData!['purchase_items']['total_amount_per_kg']}')),
                                  ]),
                                  DataRow(cells: [
                                    DataCell(Text(
                                        'Total Amount',
                                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                      )
                                    ),
                                    DataCell(Text('\u20B9${_purchaseInfoData!['purchase_items']['total_amount']}')),
                                  ]),
                                  DataRow(cells: [
                                    DataCell(Text(
                                        'Total Expense',
                                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                        )
                                      ),
                                    DataCell(Text('\u20B9${_purchaseInfoData!['purchase_expenses']['total_expense']}')),
                                  ]),
                                  DataRow(cells: [
                                    DataCell(Text(
                                        'Grand Total',
                                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                        )
                                      ),
                                    DataCell(Text(
                                        '\u20B9${_purchaseInfoData!['grand_total']}',
                                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                      )
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
