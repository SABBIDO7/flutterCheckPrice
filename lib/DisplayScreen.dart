import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'components/image_dialog.dart';
import 'components/my_button.dart';
import 'components/my_textfield.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

// ignore: must_be_immutable
class DisplayScreen extends StatefulWidget {
  Map<String, dynamic> data;
  final String inventory;
  DisplayScreen({required this.data, required this.inventory});

  @override
  _DisplayScreenState createState() => _DisplayScreenState();
}

class _DisplayScreenState extends State<DisplayScreen> {
  TextEditingController _inputController = TextEditingController(text: '1');

  Future<void> scanAnotherTimeFail(String inventory) async {
    String barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
      '#ff6666', // Scanner overlay color
      'Cancel', // Cancel button text
      true, // Show flash icon
      ScanMode.BARCODE, // Scan mode
    );

    // Check if a barcode was successfully scanned
    if (barcodeScanRes != '-1') {
      print(barcodeScanRes);
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? dbName = prefs.getString('dbName');
      String? ip = prefs.getString('ip');
      String? username = prefs.getString('username');
      String? branch = prefs.getString('branch');
      // Make an API call with the scanned barcode
      final apiUrl =
          'http://$ip/getInventoryItem/'; // Replace with your API endpoint
      final response = await http.get(Uri.parse(
          '$apiUrl?itemNumber=$barcodeScanRes&branch=$branch&dbName=$dbName&username=$username&inventory=$inventory'));

      if (response.statusCode == 200) {
        // Data was found in the database
        //final data = jsonDecode(response.body);
        // final encoding = Encoding.getByName('utf-8'); // Use UTF-8 encoding
        final data =
            jsonDecode(utf8.decode(response.bodyBytes, allowMalformed: true));
        if (data['item'] != "empty") {
          Navigator.of(context).pop();
          print("bingooooo");
          setState(() {
            widget.data = data;
          });
        } else {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => AlertDialog(
              title: Text('Data Not Found'),
              content: Text(
                  'The scanned item barcode was not found in this branch.'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    scanAnotherTimeFail(inventory);
                    //blaaaaaaaaaaaaaaaaaaaa
                  },
                  child: Text('Scan Again'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      '/options', // Replace with the route name of OptionsScreen
                      (route) =>
                          false, // This predicate will remove all routes from the stack
                    );
                    //blaaaaaaaaaaaaaaaaaaaa
                  },
                  child: Text('Exit'),
                ),
              ],
            ),
          );
        }
        // Navigate to a new screen to display the data
      } else {
        // Data not found in the database
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Data Not Found'),
            content: Text('Request error.'),
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

  Future<void> update_hande_quantity(String itemNumber, String handQuantity,
      String branch, String inventory, double oldHandQuantity) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String? dbName = prefs.getString('dbName');
    String? ip = prefs.getString('ip');

    final url = Uri.parse(
        'http://$ip/handeQuantity_update/?itemNumber=$itemNumber&handQuantity=$handQuantity&branch=$branch&dbName=$dbName&inventory=$inventory&oldHandQuantity=$oldHandQuantity'); // Replace with your FastAPI login endpoint

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
        ////////////////////////////////////////////////////
        // Function to handle scanning and data retrieval

        String barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
          '#ff6666', // Scanner overlay color
          'Cancel', // Cancel button text
          true, // Show flash icon
          ScanMode.BARCODE, // Scan mode
        );

        // Check if a barcode was successfully scanned
        if (barcodeScanRes != '-1') {
          print(barcodeScanRes);
          SharedPreferences prefs = await SharedPreferences.getInstance();
          String? dbName = prefs.getString('dbName');
          String? ip = prefs.getString('ip');
          String? username = prefs.getString('username');
          String? branch = prefs.getString('branch');
          // Make an API call with the scanned barcode
          final apiUrl =
              'http://$ip/getInventoryItem/'; // Replace with your API endpoint
          final response = await http.get(Uri.parse(
              '$apiUrl?itemNumber=$barcodeScanRes&branch=$branch&dbName=$dbName&username=$username&inventory=$inventory'));

          if (response.statusCode == 200) {
            // Data was found in the database
            //final data = jsonDecode(response.body);
            // final encoding = Encoding.getByName('utf-8'); // Use UTF-8 encoding
            final newdata = jsonDecode(
                utf8.decode(response.bodyBytes, allowMalformed: true));
            if (newdata['item'] != "empty") {
              setState(() {
                widget.data = newdata;
              });
            } else {
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => AlertDialog(
                  title: Text('Data Not Found'),
                  content: Text(
                      'The scanned item barcode was not found in this branch.'),
                  actions: [
                    TextButton(
                      onPressed: () {
                        scanAnotherTimeFail(inventory);
                        //blaaaaaaaaaaaaaaaaaaaa
                      },
                      child: Text('Scan Again'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          '/options', // Replace with the route name of OptionsScreen
                          (route) =>
                              false, // This predicate will remove all routes from the stack
                        );
                        //blaaaaaaaaaaaaaaaaaaaa
                      },
                      child: Text('Exit'),
                    ),
                  ],
                ),
              );
            }
            // Navigate to a new screen to display the data
          } else {
            // Data not found in the database
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: Text('Data Not Found'),
                content: Text('Request error.'),
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
    final screenWidth = mediaQueryData.size.width;

    print(screenHeight);

    // return WillPopScope(
    //   onWillPop: () async {
    //     Navigator.pushNamedAndRemoveUntil(
    //       context,
    //       '/options', // Replace with the route name of OptionsScreen
    //       (route) =>
    //           false, // This predicate will remove all routes from the stack
    //     );
    //     return false;
    //   },
    //   child:

    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: Text('${widget.inventory}'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Form(
            key: _formKey, // Set the form key
            child: Column(
              //mainAxisAlignment: MainAxisAlignment.center,
              //crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                widget.data['item']['image'] == ''
                    ? Container()
                    : InkWell(
                        onTap: () {
                          // Open a dialog with a larger version of the image
                          showDialog(
                            context: context,
                            builder: (context) => ImageDialog(
                              imageUrl: widget.data['item']['image'],
                            ),
                          );
                        },
                        child: ClipOval(
                          child: Image.memory(
                            base64Decode(widget.data['item']['image']),
                            errorBuilder: (context, error, stackTrace) {
                              // Handle the image loading error here
                              return Icon(Icons
                                  .error); // Display an error icon or placeholder
                            },
                            width:
                                screenWidth * 0.2, // Adjust the width as needed
                            height: screenHeight *
                                0.1, // Adjust the height as needed
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                // Display the data in a DataTable
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    dataRowMaxHeight: screenHeight * 0.12,
                    columns: [
                      DataColumn(label: Text('')),
                      DataColumn(label: Text('')),
                    ],
                    rows: [
                      DataRow(
                        cells: [
                          DataCell(
                            Container(
                              width: screenWidth * 0.45,
                              child: SingleChildScrollView(
                                scrollDirection: Axis.vertical,
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      "Item Name",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16),
                                    ),
                                    Text(
                                      widget.data['item']['itemNumber'],
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16),
                                    ),
                                    Text(
                                      widget.data['item']['GOID'] ==
                                              widget.data['item']['itemNumber']
                                          ? ""
                                          : widget.data['item']['GOID'],
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                          DataCell(
                            SingleChildScrollView(
                              scrollDirection: Axis.vertical,
                              child: Container(
                                alignment: Alignment.center,
                                width: screenWidth *
                                    0.45, // Set the width to fill the available space

                                child: Text(
                                  widget.data['item']['itemName'].toString(),
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16),
                                  //
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      DataRow(
                        cells: [
                          DataCell(
                            Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "Branch :",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16),
                                  ),
                                  SizedBox(
                                    width: screenWidth * 0.025,
                                  ),
                                  Text(
                                    widget.data['item']['Branch'],
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20),
                                  ),
                                ]),
                          ),
                          DataCell(
                            Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    "Cost Price :",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16),
                                  ),
                                  SizedBox(
                                    width: screenWidth * 0.025,
                                  ),
                                  Text(
                                    widget.data['item']['costPrice'] == 0
                                        ? '-'
                                        : widget.data['item']['costPrice']
                                            .toString(),
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20),
                                  ),
                                ]),
                          ),
                        ],
                      ),
                      DataRow(
                        cells: [
                          widget.data['item']['sp'] == null
                              ? widget.data['item']['vat'] == 0
                                  ? DataCell(Center(
                                      child: Text(
                                        "SPrice",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16),
                                      ),
                                    ))
                                  : DataCell(Center(
                                      child: Text(
                                        "SPrice *",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16),
                                      ),
                                    ))
                              : widget.data['item']['vat'] == 0
                                  ? DataCell(Center(
                                      child: Text(
                                        "SPrice" +
                                            '\n' +
                                            widget.data['item']['sp']
                                                .toString(),
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16),
                                      ),
                                    ))
                                  : DataCell(Center(
                                      child: Text(
                                        "SPrice *" +
                                            '\n' +
                                            widget.data['item']['sp']
                                                .toString(),
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16),
                                      ),
                                    )),
                          DataCell(
                            SingleChildScrollView(
                              scrollDirection: Axis.vertical,
                              child: Column(children: [
                                Container(
                                  height: screenHeight * 0.04,
                                  child: Row(
                                    children: [
                                      Container(
                                        child: Text(
                                          "1-",
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 20),
                                        ),
                                      ),
                                      SizedBox(
                                        width: screenWidth * 0.025,
                                      ),
                                      Container(
                                        child: Text(
                                          widget.data['item']['S1'].toString(),
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 20),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Container(
                                        height: screenHeight * 0.04,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            Container(
                                              child: const Text(
                                                "2-",
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 20),
                                              ),
                                            ),
                                            SizedBox(
                                              width: screenWidth * 0.025,
                                            ),
                                            Container(
                                              child: Text(
                                                widget.data['item']['S2']
                                                    .toString(),
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 20),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  height: screenHeight * 0.04,
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Container(
                                        child: Text(
                                          "3-",
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 20),
                                        ),
                                      ),
                                      SizedBox(
                                        width: screenWidth * 0.025,
                                      ),
                                      Container(
                                        child: Text(
                                          widget.data['item']['S3'].toString(),
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 20),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ]),
                            ),
                          ),
                        ],
                      ),
                      DataRow(
                        cells: [
                          DataCell(
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Qty :",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16),
                                ),
                                SizedBox(
                                  width: screenWidth * 0.025,
                                ),
                                Text(
                                  widget.data['item']['quantity'].toString(),
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20),
                                ),
                              ],
                            ),
                          ),
                          DataCell(
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Hand Qty :",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16),
                                ),
                                SizedBox(
                                  width: screenWidth * 0.025,
                                ),
                                Text(
                                  widget.data['item']['handQuantity'] == null
                                      ? "-"
                                      : widget.data['item']['handQuantity']
                                          .toStringAsFixed(2),
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Input field for user input
                SizedBox(height: screenHeight * 0.01),
                MyTextField(
                    controller: _inputController,
                    hintText: 'Hand Quantity Collected',
                    obscureText: false,
                    validator: (value) {
                      if (value == null ||
                          value.isEmpty ||
                          !RegExp(r'^-?\d+(\.\d+)?$').hasMatch(value)) {
                        return 'Please enter a valid hand quantity';
                      }
                      return null;
                    },
                    flag: 1),
                SizedBox(height: screenHeight * 0.05),

                // Sign in button
                MyButton(
                  onTap: () {
                    if (_formKey.currentState!.validate()) {
                      // Validation passed, make the update call
                      update_hande_quantity(
                          widget.data['item']['itemNumber'].toString(),
                          _inputController.text,
                          widget.data['item']['Branch'].toString(),
                          widget.inventory,
                          widget.data['item']['handQuantity']);
                    }
                  },
                  buttonName: "Update",
                ),
                SizedBox(height: screenHeight * 0.01),

                // Add any additional widgets or styling as needed
              ],
            ),
          ),
        ),
      ),
    );
    //);
  }
}
