import 'package:flutter/material.dart';
import 'components/my_button.dart';
import 'components/my_textfield.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class DisplayScreen extends StatefulWidget {
  final Map<String, dynamic> data;

  DisplayScreen({required this.data});

  @override
  _DisplayScreenState createState() => _DisplayScreenState();
}

class _DisplayScreenState extends State<DisplayScreen> {
  TextEditingController _inputController = TextEditingController();
  Future<void> update_hande_quantity(
      String itemNumber, String handQuantity, String branch) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String? dbName = prefs.getString('dbName');
    String? ip = prefs.getString('ip');

    int? branchAsInt = int.tryParse(branch);
    final url = Uri.parse(
        'http://$ip/handeQuantity_update/?itemNumber=$itemNumber&handQuantity=$handQuantity&branch=$branchAsInt&dbName=$dbName'); // Replace with your FastAPI login endpoint

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
      );
      print(response);

      if (response.statusCode == 200) {
        // Successful login, handle the response as needed
        Navigator.pop(context);
      } else {
        // Handle login failure (e.g., incorrect credentials)
        print("Failure");
      }
    } catch (e) {
      print("Error: $e");
    }

    /*final response2 = await get(Uri.parse('http://10.0.2.2:8000/getuser/'));
    final jsonData = jsonDecode(response2.body);

    print("hgffffffffffffffffffffffffr");
    print(jsonData);*/
  }

  // Declare a GlobalKey<FormState> in your _DisplayScreenState class
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();

// ...

  @override
  Widget build(BuildContext context) {
    final mediaQueryData = MediaQuery.of(context);
    final screenHeight = mediaQueryData.size.height;
    print(screenHeight);

    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: Text('Quantity'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Form(
            key: _formKey, // Set the form key
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
                // Input field for user input
                SizedBox(height: screenHeight * 0.05),
                MyTextField(
                  controller: _inputController,
                  hintText: 'Hand Quantity Collected',
                  obscureText: false,
                  validator: (value) {
                    if (value == null ||
                        value.isEmpty ||
                        !RegExp(r'^[0-9]+$').hasMatch(value)) {
                      return 'Please enter a valid hand quantity';
                    }
                    return null;
                  },
                ),
                SizedBox(height: screenHeight * 0.05),

                // Sign in button
                MyButton(
                  onTap: () {
                    if (_formKey.currentState!.validate()) {
                      // Validation passed, make the update call
                      update_hande_quantity(
                          widget.data['item']['itemNumber'].toString(),
                          _inputController.text,
                          widget.data['item']['Branch'].toString());
                    }
                  },
                  buttonName: "Update",
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
