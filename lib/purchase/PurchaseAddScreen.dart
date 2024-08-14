import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../components/ApiConfig.dart';
import './PurchaseListScreen.dart';

class PurchaseParty {
  final String id;
  final String fullName;

  PurchaseParty({
    required this.id,
    required this.fullName,
  });

  factory PurchaseParty.fromJson(Map<String, dynamic> json) {
    return PurchaseParty(
      id: json['id'],
      fullName: json['fullname'],
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PurchaseParty && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

class PurchaseItem {
  String id = '';
  String name = '';
  double quantity = 0.0;
  double amount_per_kg = 0.0;
  double amount = 0.0;

  PurchaseItem(
      {this.id = '', this.name = '', this.quantity = 0.0, this.amount_per_kg = 0.0, this.amount = 0.0});

  factory PurchaseItem.fromJson(Map<String, dynamic> json) {
    return PurchaseItem(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      quantity: (json['quantity'] as num?)?.toDouble() ?? 0.0,
      amount_per_kg: (json['amount_per_kg'] as num?)?.toDouble() ?? 0.0,
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class PurchaseExpense {
  String expenseTitle = '';
  double expenseAmount = 0.0;
}

void main() {
  runApp(MaterialApp(
    home: PurchaseAddScreen(token: 'your_access_token_here'), // Pass your token here
  ));
}

class PurchaseAddScreen extends StatefulWidget {
  final String token;

  PurchaseAddScreen({Key? key, required this.token}) : super(key: key);

  static String baseUrl = ApiConfig.baseUrl;

  @override
  _PurchaseAddScreenState createState() => _PurchaseAddScreenState();
}

class _PurchaseAddScreenState extends State<PurchaseAddScreen> {
  late Future<List<PurchaseParty>> _fetchPurchasePartiesFuture;
  late Future<List<PurchaseItem>> _fetchPurchaseItemsFuture;
  List<PurchaseItem> purchaseItems = [];
  List<PurchaseExpense> purchaseExpenses = [];
  String? selectedPurchasePartyId;
  DateTime selectedDate = DateTime.now();
  String dateText = DateFormat('yyyy-MM-dd').format(DateTime.now());
  late TextEditingController _dateController;

  @override
  void initState() {
    super.initState();
    _dateController = TextEditingController(text: dateText);
    fetchData();
  }

  @override
  void dispose() {
    _dateController.dispose();
    super.dispose();
  }

  Future<void> fetchData() async {
    _fetchPurchasePartiesFuture = fetchPurchaseParties();
    _fetchPurchaseItemsFuture = fetchPurchaseItems();
    await Future.wait([_fetchPurchasePartiesFuture, _fetchPurchaseItemsFuture]);
    setState(() {});
  }

  Future<List<PurchaseParty>> fetchPurchaseParties() async {
    final url = Uri.parse('${PurchaseAddScreen.baseUrl}purchase/purchase-parties/');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List<dynamic> partiesData = data['data'];
      if (partiesData != null) {
        return partiesData.map((partyMap) {
          return PurchaseParty.fromJson(partyMap);
        }).toList();
      }
    }
    throw Exception('Failed to load purchase parties');
  }

  Future<List<PurchaseItem>> fetchPurchaseItems() async {
    final url = Uri.parse('${PurchaseAddScreen.baseUrl}purchase/purchase-items/');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List<dynamic> itemsData = data['data'];
      if (itemsData != null) {
        return itemsData.map((itemMap) {
          return PurchaseItem.fromJson(itemMap);
        }).toList();
      }
    }
    throw Exception('Failed to load purchase items');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Purchase'),
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
              controller: _dateController,
              readOnly: true,
            ),
            SizedBox(height: 16),
            FutureBuilder<List<PurchaseParty>>(
              future: _fetchPurchasePartiesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else {
                  return DropdownButtonFormField<String>(
                    value: selectedPurchasePartyId,
                    items: snapshot.data!.map((purchaseParty) {
                      return DropdownMenuItem<String>(
                        value: purchaseParty.id,
                        child: Text('${purchaseParty.fullName}'),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedPurchasePartyId = value;
                      });
                    },
                    decoration: InputDecoration(labelText: 'Purchase Party'),
                  );
                }
              },
            ),
            SizedBox(height: 16),
            _buildPurchasedItems(),
            SizedBox(height: 16),
            _buildPurchasedExpenses(),
            SizedBox(height: 32),
            ElevatedButton(
              onPressed: _savePurchaseData,
              child: Text('SUBMIT'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPurchasedItems() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Purchase Items:',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        ...purchaseItems.asMap().entries.map((entry) {
          return PurchaseItemWidget(
            key: UniqueKey(),
            item: entry.value,
            itemList: _fetchPurchaseItemsFuture,
            onItemChanged: (id) {
              setState(() {
                purchaseItems[entry.key].id = id;
              });
            },
            onRemove: () {
              setState(() {
                purchaseItems.removeAt(entry.key);
              });
            },
          );
        }).toList(),
        ElevatedButton(
          onPressed: () {
            setState(() {
              purchaseItems.add(PurchaseItem());
            });
          },
          child: Text('Add Purchase'),
        ),
      ],
    );
  }

  Widget _buildPurchasedExpenses() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Purchase Expenses:',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: purchaseExpenses.asMap().entries.map((entry) {
            return PurchaseExpenseWidget(
              key: UniqueKey(),
              expense: entry.value,
              onRemove: () {
                setState(() {
                  purchaseExpenses.removeAt(entry.key);
                });
              },
            );
          }).toList(),
        ),
        ElevatedButton(
          onPressed: () {
            setState(() {
              purchaseExpenses.add(PurchaseExpense());
            });
          },
          child: Text('Add Purchase Expense'),
        ),
      ],
    );
  }

  void _savePurchaseData() async {
    String formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate);
    // Prepare data in the required JSON structure
    Map<String, dynamic> requestData = {
      'date': formattedDate,
      'purchase_party': selectedPurchasePartyId,
      'purchased_items': purchaseItems
          .map((item) => {
                'qty': item.quantity,
                'amount': item.amount,
                'amount_per_kg': item.amount_per_kg,
                'purchase_item': item.id,
              })
          .toList(),
      'purchased_expenses': purchaseExpenses
          .map((expense) => {
                'title': expense.expenseTitle,
                'amount': expense.expenseAmount,
              })
          .toList(),
    };

    // Convert the requestData map to JSON
    String jsonData = jsonEncode(requestData);

    try {
      // Send an HTTP POST request with the token in the headers
      final url = Uri.parse('${PurchaseAddScreen.baseUrl}purchase/create-purchase/');
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer ${widget.token}', // Include the token in the Authorization header
        },
        body: jsonData,
      );

      // Handle the response
      if (response.statusCode == 200 || response.statusCode == 201) {
        // Request successful
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
    } catch (e) {
      // Handle network or other errors
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Error'),
          content: Text('$e'),
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


  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        dateText = DateFormat('yyyy-MM-dd').format(selectedDate);
        _dateController.text = dateText;
      });
    }
  }
}

class PurchaseItemWidget extends StatefulWidget {
  final PurchaseItem item;
  final Future<List<PurchaseItem>> itemList;
  final ValueChanged<String> onItemChanged;
  final VoidCallback onRemove;

  const PurchaseItemWidget({
    Key? key,
    required this.item,
    required this.itemList,
    required this.onItemChanged,
    required this.onRemove,
  }) : super(key: key);

  @override
  _PurchaseItemWidgetState createState() => _PurchaseItemWidgetState();
}

class _PurchaseItemWidgetState extends State<PurchaseItemWidget> {
  late TextEditingController quantityController;
  late TextEditingController amountPerQtyController;
  late TextEditingController amountController;

  @override
  void initState() {
    super.initState();
    quantityController = TextEditingController(text: widget.item.quantity.toString());
    amountPerQtyController = TextEditingController(text: widget.item.amount_per_kg.toString());
    amountController = TextEditingController(text: widget.item.amount.toString());

    quantityController.addListener(_updateAmount);
    amountPerQtyController.addListener(_updateAmount);
  }

  @override
  void dispose() {
    quantityController.dispose();
    amountPerQtyController.dispose();
    amountController.dispose();
    super.dispose();
  }

  void _updateAmount() {
    setState(() {
      widget.item.quantity = double.tryParse(quantityController.text) ?? 0.0;
      widget.item.amount_per_kg = double.tryParse(amountPerQtyController.text) ?? 0.0;
      widget.item.amount = widget.item.quantity * widget.item.amount_per_kg;
      amountController.text = widget.item.amount.toStringAsFixed(2);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FutureBuilder<List<PurchaseItem>>(
            future: widget.itemList,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator();
              } else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else {
                return DropdownButtonFormField<String>(
                  value: widget.item.id.isNotEmpty ? widget.item.id : null,
                  items: snapshot.data!.map((item) {
                    return DropdownMenuItem<String>(
                      value: item.id,
                      child: Text(item.name),
                    );
                  }).toList(),
                  onChanged: (value) {
                    widget.onItemChanged(value!);
                  },
                  decoration: InputDecoration(labelText: 'Item Name'),
                );
              }
            },
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Flexible(
                child: TextField(
                  controller: quantityController,
                  decoration: InputDecoration(labelText: 'Quantity'),
                  keyboardType: TextInputType.number,
                ),
              ),
              SizedBox(width: 16),
              Flexible(
                child: TextField(
                  controller: amountPerQtyController,
                  decoration: InputDecoration(labelText: 'Amount/KG'),
                  keyboardType: TextInputType.number,
                ),
              ),
              SizedBox(width: 16),
              Flexible(
                child: TextField(
                  controller: amountController,
                  decoration: InputDecoration(labelText: 'Amount'),
                  keyboardType: TextInputType.number,
                  readOnly: true, // Make this field read-only as it is auto-calculated
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
}

class PurchaseExpenseWidget extends StatefulWidget {
  final PurchaseExpense expense;
  final VoidCallback onRemove;

  const PurchaseExpenseWidget({
    Key? key,
    required this.expense,
    required this.onRemove,
  }) : super(key: key);

  @override
  _PurchaseExpenseWidgetState createState() => _PurchaseExpenseWidgetState();
}

class _PurchaseExpenseWidgetState extends State<PurchaseExpenseWidget> {
  late TextEditingController expenseTitleController;
  late TextEditingController expenseAmountController;

  @override
  void initState() {
    super.initState();
    expenseTitleController = TextEditingController(text: widget.expense.expenseTitle);
    expenseAmountController = TextEditingController(text: widget.expense.expenseAmount.toString());
  }

  @override
  void dispose() {
    expenseTitleController.dispose();
    expenseAmountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Flexible(
            child: TextField(
              controller: expenseTitleController,
              decoration: InputDecoration(labelText: 'Expense Title'),
              onChanged: (value) {
                widget.expense.expenseTitle = value;
              },
            ),
          ),
          SizedBox(width: 16),
          Flexible(
            child: TextField(
              controller: expenseAmountController,
              decoration: InputDecoration(labelText: 'Expense Amount'),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                widget.expense.expenseAmount = double.tryParse(value) ?? 0.0;
              },
            ),
          ),
          IconButton(
            icon: Icon(Icons.remove),
            onPressed: widget.onRemove,
          ),
        ],
      ),
    );
  }
}
