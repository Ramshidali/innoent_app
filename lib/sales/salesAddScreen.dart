import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../components/ApiConfig.dart';
import './SalesReport.dart';

class SalesParty {
  final String id;
  final String fullName;

  SalesParty({
    required this.id,
    required this.fullName,
  });

  factory SalesParty.fromJson(Map<String, dynamic> json) {
    return SalesParty(
      id: json['id'],
      fullName: json['fullname'],
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SalesParty && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

class ExportCountry {
  final String id;
  final String countryName;

  ExportCountry({
    required this.id,
    required this.countryName,
  });

  factory ExportCountry.fromJson(Map<String, dynamic> json) {
    return ExportCountry(
      id: json['id'],
      countryName: json['country_name'],
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ExportCountry && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

class SalesItem {
  String id = '';
  String name = '';
  String saleType = '';
  double qty = 0.0;
  double amount = 0.0;
  double perKgAmount = 0.0;
  int boxCount = 0;

  SalesItem({
    this.id = '',
    this.name = '',
    this.saleType = '',
    this.qty = 0.0,
    this.perKgAmount = 0.0,
    this.amount = 0.0,
    this.boxCount = 0,
  });

  factory SalesItem.fromJson(Map<String, dynamic> json) {
    return SalesItem(
      id: json['id'] ?? '',
      name: json['purchase_item'] ?? '',
      saleType: json['sale_type'] ?? '',
      qty: json['qty'] ?? 0.0,
      amount: json['amount'] ?? 0.0,
      perKgAmount: json['per_kg_amount'] ?? 0.0,
      boxCount: json['no_boxes'] ?? 0,
    );
  }
}

class SalesExpense {
  String expenseTitle = '';
  double expenseAmount = 0.0;
}

void main() {
  runApp(MaterialApp(
    home: SalesAddScreen(token: 'your_access_token_here'), // Pass your token here
  ));
}

class SalesAddScreen extends StatefulWidget {
  final String token;

  SalesAddScreen({Key? key, required this.token}) : super(key: key);

  static String baseUrl = ApiConfig.baseUrl;

  @override
  _SalesAddScreenState createState() => _SalesAddScreenState();
}

class _SalesAddScreenState extends State<SalesAddScreen> {
  late Future<List<SalesParty>> _fetchSalesPartiesFuture;
  late Future<List<ExportCountry>> _fetchExportCountryFuture;
  late Future<List<SalesItem>> _fetchSalesItemsFuture;
  List<SalesItem> salesItems = [];
  List<ExportCountry> exportCountry = [];
  List<SalesExpense> salesExpenses = [];
  String? selectedSalesPartyId;
  String? selectedExportCountryId;
  DateTime selectedDate = DateTime.now();
  String dateText = DateFormat('yyyy-MM-dd').format(DateTime.now());

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    _fetchSalesPartiesFuture = fetchSalesParties();
    _fetchExportCountryFuture = fetchExportCountry();
    _fetchSalesItemsFuture = Future.value([]);
    await Future.wait([_fetchSalesPartiesFuture, _fetchExportCountryFuture]);
    setState(() {});
  }

  Future<List<SalesParty>> fetchSalesParties() async {
    final url = Uri.parse('${SalesAddScreen.baseUrl}sales/sales-parties/');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List<dynamic> partiesData = data['data'];
      if (partiesData != null) {
        return partiesData.map((partyMap) {
          return SalesParty.fromJson(partyMap);
        }).toList();
      }
    }
    throw Exception('Failed to load sales parties');
  }

  Future<List<ExportCountry>> fetchExportCountry() async {
    final url = Uri.parse('${SalesAddScreen.baseUrl}sales/export-countries/');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List<dynamic> countryData = data['data'];
      if (countryData != null) {
        return countryData.map((partyMap) {
          return ExportCountry.fromJson(partyMap);
        }).toList();
      }
    }
    throw Exception('Failed to load export countries');
  }

  Future<List<SalesItem>> fetchSalesItems(String countryId) async {
    final url = Uri.parse('${SalesAddScreen.baseUrl}sales/sales-stock/?country_id=$countryId');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List<dynamic> itemsData = data['data'];
      if (itemsData != null) {
        return itemsData.map((itemMap) {
          return SalesItem.fromJson(itemMap);
        }).toList();
      }
    }
    return [];
  }

  @override
  Widget build(BuildContext context) {
    if (_fetchExportCountryFuture == null ||
        _fetchSalesPartiesFuture == null ||
        _fetchSalesItemsFuture == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Loading...'),
        ),
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Add Sales'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: 'Date',
                suffixIcon: IconButton(
                  onPressed: () => _selectDate(context),
                  icon: Icon(Icons.calendar_today),
                ),
              ),
              controller: TextEditingController(text: dateText),
              readOnly: true,
            ),
            SizedBox(height: 16),
            FutureBuilder<List<ExportCountry>>(
              future: _fetchExportCountryFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else {
                  return DropdownButtonFormField<String>(
                    value: selectedExportCountryId,
                    items: snapshot.data!.map((exportCountry) {
                      return DropdownMenuItem<String>(
                        value: exportCountry.id,
                        child: Text('${exportCountry.countryName}'),
                      );
                    }).toList(),
                    onChanged: _selectCountry,
                    decoration: InputDecoration(labelText: 'Country'),
                  );
                }
              },
            ),
            SizedBox(height: 16),
            FutureBuilder<List<SalesParty>>(
              future: _fetchSalesPartiesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else {
                  return DropdownButtonFormField<String>(
                    value: selectedSalesPartyId,
                    items: snapshot.data!.map((salesParty) {
                      return DropdownMenuItem<String>(
                        value: salesParty.id,
                        child: Text('${salesParty.fullName}'),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedSalesPartyId = value;
                      });
                    },
                    decoration: InputDecoration(labelText: 'Sales Party'),
                  );
                }
              },
            ),
            SizedBox(height: 16),
            _buildSalesItems(),
            SizedBox(height: 16),
            _buildSalesExpenses(),
            SizedBox(height: 32),
            ElevatedButton(
              onPressed: _saveSalesData,
              child: Text('SUBMIT'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSalesItems() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Sales Items:',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        ...salesItems.asMap().entries.map((entry) {
          return SalesItemWidget(
            itemList: _fetchSalesItemsFuture,
            selectedCountryId: selectedExportCountryId,
            onItemChanged: (id) {
              setState(() {
                salesItems[entry.key].id = id;
              });
            },
            onSalesTypeChanged: (saleType) {
              setState(() {
                salesItems[entry.key].saleType = saleType;
              });
            },
            onBoxCountChanged: (boxCount) {
              setState(() {
                salesItems[entry.key].boxCount = boxCount;
              });
            },
            onQuantityChanged: (qty) {
              setState(() {
                salesItems[entry.key].qty = qty;
              });
            },
            onPerAmountChanged: (perKgAmount) {
              setState(() {
                salesItems[entry.key].perKgAmount = perKgAmount;
              });
            },
            onAmountChanged: (amount) {
              setState(() {
                salesItems[entry.key].amount = amount;
              });
            },
            onRemove: () {
              setState(() {
                salesItems.removeAt(entry.key);
              });
            },
          );
        }).toList(),
        TextButton(
          onPressed: () {
            setState(() {
              // print(salesItems[0].qty);
              salesItems.add(SalesItem());
            });
          },
          child: Text('Add Sales Item'),
        ),
      ],
    );
  }

  Widget _buildSalesExpenses() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Sales Expenses:',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        ...salesExpenses.asMap().entries.map((entry) {
          return SalesExpenseWidget(
            onExpenseTitleChanged: (title) {
              setState(() {
                salesExpenses[entry.key].expenseTitle = title;
              });
            },
            onExpenseAmountChanged: (amount) {
              setState(() {
                salesExpenses[entry.key].expenseAmount = amount;
              });
            },
            onRemove: () {
              setState(() {
                salesExpenses.removeAt(entry.key);
              });
            },
          );
        }).toList(),
        TextButton(
          onPressed: () {
            setState(() {
              salesExpenses.add(SalesExpense());
            });
          },
          child: Text('Add Expense'),
        ),
      ],
    );
  }

  void _selectCountry(String? countryId) {
    setState(() {
      selectedExportCountryId = countryId;
      salesItems.clear();
      _fetchSalesItemsFuture = fetchSalesItems(countryId!);
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        dateText = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  void _saveSalesData() async {
    if (salesItems.isEmpty) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Error'),
          content: Text('Please add at least one sales item.'),
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
      return; // Exit the function early since there are no sales items
    }

    final salesData = {
      'date': dateText,
      'sales_party': selectedSalesPartyId,
      'country': selectedExportCountryId,
      'sales_items': salesItems.map((item) => {
        'sale_type': item.saleType,
        'qty': item.qty,
        'per_kg_amount': item.perKgAmount,
        'amount': item.amount,
        'no_boxes': item.boxCount,
        'sale_item': item.id
      }).toList(),
      'sales_expenses': salesExpenses.map((expense) => {
        'title': expense.expenseTitle,
        'amount': expense.expenseAmount,
      }).toList(),
    };

    print(jsonEncode(salesData)); // Log the data before sending

    final url = Uri.parse('${SalesAddScreen.baseUrl}sales/create-sales/');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${widget.token}',
      },
      body: json.encode(salesData),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Success'),
          content: Text('Data saved successfully'),
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
      String errorMessage = 'Failed to save data';
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
  }
}

class SalesItemWidget extends StatefulWidget {
  final Future<List<SalesItem>> itemList;
  final String? selectedCountryId;
  final ValueChanged<String> onItemChanged;
  final ValueChanged<String> onSalesTypeChanged;
  final ValueChanged<int> onBoxCountChanged;
  final ValueChanged<double> onQuantityChanged;
  final ValueChanged<double> onPerAmountChanged;
  final ValueChanged<double> onAmountChanged;
  final VoidCallback onRemove;

  const SalesItemWidget({
    Key? key,
    required this.itemList,
    required this.selectedCountryId,
    required this.onItemChanged,
    required this.onSalesTypeChanged,
    required this.onBoxCountChanged,
    required this.onQuantityChanged,
    required this.onPerAmountChanged,
    required this.onAmountChanged,
    required this.onRemove,
  }) : super(key: key);

  @override
  _SalesItemWidgetState createState() => _SalesItemWidgetState();
}

class _SalesItemWidgetState extends State<SalesItemWidget> {
  String? selectedItemId;
  String selectedSalesType = 'QTY'; // Default to 'QTY'
  double qty = 0.0;
  double perKgAmount = 0.0;
  double amount = 0.0;
  int boxCount = 0;

  // Controllers for the text fields
  TextEditingController qtyController = TextEditingController();
  TextEditingController perKgAmountController = TextEditingController();
  TextEditingController amountController = TextEditingController();
  TextEditingController boxCountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Listen to changes in the text fields and update the respective variables
    qtyController.addListener(_updateAmount);
    perKgAmountController.addListener(_updateAmount);
    amountController.addListener(() {
      widget.onAmountChanged(double.tryParse(amountController.text) ?? 0.0);
    });
    boxCountController.addListener(() {
      setState(() {
        boxCount = int.tryParse(boxCountController.text) ?? 0;
      });
      widget.onBoxCountChanged(boxCount);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FutureBuilder<List<SalesItem>>(
            future: widget.itemList,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator();
              } else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else {
                return DropdownButtonFormField<String>(
                  value: selectedItemId,
                  items: snapshot.data!.map((item) {
                    return DropdownMenuItem<String>(
                      value: item.id,
                      child: Text('${item.name}'),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedItemId = value!;
                    });
                    widget.onItemChanged(value!);
                  },
                  decoration: InputDecoration(labelText: 'Item Name'),
                );
              }
            },
          ),
          SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: selectedSalesType,
            items: [
              DropdownMenuItem(
                value: 'QTY',
                child: Text('QTY'),
              ),
              DropdownMenuItem(
                value: 'Box',
                child: Text('Box'),
              ),
            ],
            onChanged: (value) {
              setState(() {
                selectedSalesType = value!;
                _updateAmount();
              });
              widget.onSalesTypeChanged(value!);
            },
            decoration: InputDecoration(labelText: 'Sales Type'),
          ),
          SizedBox(height: 8),
          if (selectedSalesType == 'Box')
            TextField(
              decoration: InputDecoration(labelText: 'Box Count'),
              keyboardType: TextInputType.number,
              controller: boxCountController,
            ),
          SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(labelText: 'Quantity'),
                  keyboardType: TextInputType.number,
                  controller: qtyController, // Assign the controller
                ),
              ),
              SizedBox(width: 16),
              SizedBox(
                width: 100,
                child: TextField(
                  decoration: InputDecoration(labelText: 'Amount/KG'),
                  keyboardType: TextInputType.number,
                  controller: perKgAmountController, // Assign the controller
                ),
              ),
              SizedBox(width: 16),
              SizedBox(
                width: 100,
                child: TextField(
                  decoration: InputDecoration(labelText: 'Amount'),
                  keyboardType: TextInputType.number,
                  controller: amountController, // Assign the controller
                ),
              ),
            ],
          ),
          IconButton(
            icon: Icon(Icons.remove),
            onPressed: widget.onRemove,
          ),
        ],
      ),
    );
  }

  void _updateAmount() {
    double qty = double.tryParse(qtyController.text) ?? 0.0;
    double perKgAmount = double.tryParse(perKgAmountController.text) ?? 0.0;
    setState(() {
      this.qty = qty;
      this.perKgAmount = perKgAmount;
      if (selectedSalesType == 'QTY') {
        amount = qty * perKgAmount;
      } else if (selectedSalesType == 'Box') {
        int boxCount = int.tryParse(boxCountController.text) ?? 0;
        amount = qty * boxCount * perKgAmount;
      }
      amountController.text = amount.toStringAsFixed(2);
    });
    widget.onQuantityChanged(qty);
    widget.onPerAmountChanged(perKgAmount);
    widget.onAmountChanged(amount);
  }
}

class SalesExpenseWidget extends StatelessWidget {
  final ValueChanged<String> onExpenseTitleChanged;
  final ValueChanged<double> onExpenseAmountChanged;
  final VoidCallback onRemove;

  const SalesExpenseWidget({
    Key? key,
    required this.onExpenseTitleChanged,
    required this.onExpenseAmountChanged,
    required this.onRemove,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            decoration: InputDecoration(labelText: 'Expense Title'),
            onChanged: (value) => onExpenseTitleChanged(value),
          ),
          TextField(
            decoration: InputDecoration(labelText: 'Expense Amount'),
            keyboardType: TextInputType.number,
            onChanged: (value) => onExpenseAmountChanged(double.tryParse(value) ?? 0.0),
          ),
          IconButton(
            icon: Icon(Icons.remove),
            onPressed: onRemove,
          ),
        ],
      ),
    );
  }
}
