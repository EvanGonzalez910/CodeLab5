import 'package:flutter/material.dart';

import 'dart:math';

import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart';

import 'package:shared_preferences/shared_preferences.dart';

//Teamed with Nathalia Coronado

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => MortgageData(),
      child: MaterialApp(
        home: MortgageCalculator(),
        debugShowCheckedModeBanner: false,
      ),
    ),
  );
}

class Mortgage {
  double _amount = 0.00;
  double _years = 10.00;
  double _rate = 0.00;

  void setAmount(double newAmount) {
    if (newAmount >= 0) {
      _amount = newAmount;
    }
  }

  void setYears(double newYears) {
    if (newYears >= 0) {
      _years = newYears;
    }
  }

  void setRate(double newRate) {
    if (newRate >= 0) {
      _rate = newRate;
    }
  }

  double monthlyPayment() {
    double n = _years * 12;
    double r = _rate / 100 / 12;

    double MonthlyPayment = (_amount * r * pow(1 + r, n)) / (pow(1 + r, n) - 1);

    return MonthlyPayment;
  }
}

class MortgageData extends ChangeNotifier {
  double amount = 0.00;
  double years = 10.00;
  double rate = 2.00;

  void setAmount(double newAmount) {
    amount = newAmount;
    notifyListeners();
  }

  void setYears(double newYears) {
    years = newYears;
    notifyListeners();
  }

  void setRate(double newRate) {
    rate = newRate;
    notifyListeners();
  }
}

class ResultsScreen extends StatefulWidget {
  double result;
  double price;
  double years;
  double interest;

  ResultsScreen({
    required this.result,
    required this.price,
    required this.years,
    required this.interest,
  });

  @override
  _ResultsScreenState createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen> {
  bool _acceptedTerms = false;

  @override
  Widget build(BuildContext context) {
    final mortgageData = context.watch<MortgageData>();

    double Results = widget.result;
    double Years = mortgageData.years;
    double InterestRate = mortgageData.rate;
    double Price = mortgageData.amount;

    String MonthlyPayment = Results.toStringAsFixed(2);

    return Scaffold(
      appBar: AppBar(
        title: Text("Mortgage Plan"),
        backgroundColor: Colors.blueAccent,
      ),
      body: Column(
        children: [
          SizedBox(height: 15),

          Row(
            children: [
              SizedBox(width: 10),

              Expanded(child: Text("Amount:", style: TextStyle(fontSize: 15))),

              Expanded(child: Text("${Price}", style: TextStyle(fontSize: 15))),
            ],
          ),

          SizedBox(height: 15),

          Row(
            children: [
              SizedBox(width: 10),

              Expanded(child: Text("Years:", style: TextStyle(fontSize: 15))),

              Expanded(child: Text("${Years}", style: TextStyle(fontSize: 15))),
            ],
          ),

          SizedBox(height: 15),

          Row(
            children: [
              SizedBox(width: 10),

              Expanded(
                child: Text("Interest Rate:", style: TextStyle(fontSize: 15)),
              ),

              Expanded(
                child: Text("${InterestRate}", style: TextStyle(fontSize: 15)),
              ),
            ],
          ),

          SizedBox(height: 15),

          Row(
            children: [
              SizedBox(width: 10),

              Expanded(
                child: Text("Monthly Payment:", style: TextStyle(fontSize: 15)),
              ),

              Expanded(
                child: Text(
                  "${MonthlyPayment}",
                  style: TextStyle(fontSize: 15),
                ),
              ),
            ],
          ),

          SizedBox(height: 15),

          Row(
            children: [
              SizedBox(width: 10),

              Expanded(
                child: Text("Total Payment:", style: TextStyle(fontSize: 15)),
              ),

              Expanded(
                child: Text(
                  "${(Results * (Years * 12)).toStringAsFixed(2)}",
                  style: TextStyle(fontSize: 15),
                ),
              ),
            ],
          ),

          SizedBox(height: 15),

          CheckboxListTile(
            title: Text("Terms and Conditions"),
            value: _acceptedTerms,
            onChanged: (value) {
              setState(() {
                _acceptedTerms = value!;
              });

              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: Text("Terms and Conditions"),
                    content: Text(
                      "Press 'Accept' to comfirm that you accept the Terms and Conditions",
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text("Accept"),
                      ),
                    ],
                  );
                },
              );
            },
          ),

          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text("Modify"),
          ),
        ],
      ),
    );
  }
}

class MortgageCalculator extends StatefulWidget {
  @override
  _MortgageCalculatorState createState() => _MortgageCalculatorState();
}

class _MortgageCalculatorState extends State<MortgageCalculator> {
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _yearsController = TextEditingController();

  double _interestRate = 2.0;
  double _price = 0.00;
  double _years = 0.00;

  double _result = 0.00;

  static List<double> createInterestRates() {
    List<double> rates = [];

    for (double rate = 2.0; rate <= 15.0; rate += 0.25) {
      rates.add(rate);
    }

    return rates;
  }

  List<double> _interestRates = createInterestRates();

  Future<void> _saveMortgageData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    await prefs.setDouble('amount', context.read<MortgageData>().amount);
    await prefs.setDouble('years', context.read<MortgageData>().years);
    await prefs.setDouble('rate', context.read<MortgageData>().rate);
  }

  

  Future<void> _loadMortgageData() async {
    final prefs = await SharedPreferences.getInstance();

    final mortgageData = context.read<MortgageData>();

    double? amount = prefs.getDouble('amount');
    double? years = prefs.getDouble('years');
    double? rate = prefs.getDouble('rate');

    mortgageData.setAmount(amount ?? 0.00);
    mortgageData.setYears(years ?? 10.00);
    mortgageData.setRate(rate ?? 2.00);

    _priceController.text = amount?.toString() ?? '';
    _yearsController.text = years?.toString() ?? '';
  }

  void _calculateMortgage() {
    final mortgageData = context.read<MortgageData>();

    _price = double.parse(_priceController.text);
    _years = double.parse(_yearsController.text);

    mortgageData.setAmount(_price);
    mortgageData.setYears(_years);

    Mortgage mortgage = Mortgage();

    mortgage.setAmount(mortgageData.amount);
    mortgage.setYears(mortgageData.years);
    mortgage.setRate(mortgageData.rate);

    double MonthlyPayment = mortgage.monthlyPayment();

    setState(() {
      _result = MonthlyPayment;
    });
  }

  @override
  void initState() {
    super.initState();
    _loadMortgageData();
  }

  @override
  Widget build(BuildContext context) {
    final mortgageData = context.watch<MortgageData>();

    return Scaffold(
      appBar: AppBar(
        title: Text("Mortgage Calculator"),
        backgroundColor: Colors.blueAccent,
      ),
      body: Column(
        children: [
          SizedBox(height: 15),

          TextField(
            controller: _yearsController,
            decoration: InputDecoration(labelText: 'Years'),
            onChanged: (value) {
              if (value.isNotEmpty && value != '.') {
                context.read<MortgageData>().setYears(double.parse(value));
                _saveMortgageData();
              }
            },
          ),

          SizedBox(height: 20),

          TextField(
            controller: _priceController,
            decoration: InputDecoration(labelText: 'Amount'),
            onChanged: (value) {
              if (value.isNotEmpty && value != '.') {
                context.read<MortgageData>().setAmount(double.parse(value));
                _saveMortgageData();
              }
            },
          ),

          SizedBox(height: 15),

          DropdownButton<double>(
            items: _interestRates.map<DropdownMenuItem<double>>((double value) {
              return DropdownMenuItem<double>(
                value: value,
                child: Text('$value%'),
              );
            }).toList(),

            value: mortgageData.rate,
            hint: Text("Interest Rate"),

            onChanged: (newValue) {
              context.read<MortgageData>().setRate(newValue!);
              _saveMortgageData();
            },
          ),

          SizedBox(height: 15),

          ElevatedButton(
            onPressed: () {
              _calculateMortgage();

              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => ResultsScreen(
                    result: _result,
                    price: mortgageData.amount,
                    years: mortgageData.years,
                    interest: mortgageData.rate,
                  ),
                ),
              );
            },
            child: Text("Done"),
          ),
        ],
      ),
    );
  }
}
