import 'package:flutter/material.dart';

class CheckpriceScreen extends StatefulWidget {
  final Map<String, dynamic> data;

  CheckpriceScreen({required this.data});

  @override
  _CheckpriceScreenState createState() => _CheckpriceScreenState();
}

class _CheckpriceScreenState extends State<CheckpriceScreen> {
  // Declare a GlobalKey<FormState> in your _DisplayScreenState class

// ...

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: Text('Check Price'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Form(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Display the data in a DataTable
                DataTable(
                  columns: [
                    DataColumn(label: Text('Field')),
                    DataColumn(label: Text('Value')),
                  ],
                  rows: [
                    DataRow(
                      cells: [
                        DataCell(Text("Item Name")),
                        DataCell(
                            Text(widget.data['item']['itemName'].toString())),
                      ],
                    ),
                    DataRow(
                      cells: [
                        DataCell(Text("Branch")),
                        DataCell(
                            Text(widget.data['item']['Branch'].toString())),
                      ],
                    ),
                    DataRow(
                      cells: [
                        DataCell(Text("Price")),
                        DataCell(Text(widget.data['item']['S1'].toString())),
                      ],
                    ),
                    DataRow(
                      cells: [
                        DataCell(Text("Quantity")),
                        DataCell(
                            Text(widget.data['item']['quantity'].toString())),
                      ],
                    ),
                  ],
                ),

                // Add any additional widgets or styling as needed
              ],
            ),
          ),
        ),
      ),
    );
  }
}
