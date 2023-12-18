import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import 'components/image_dialog.dart';
import 'components/my_button.dart';

// ignore: must_be_immutable
class CheckpriceScreen extends StatefulWidget {
  Map<String, dynamic> data;

  CheckpriceScreen({required this.data});

  @override
  _CheckpriceScreenState createState() => _CheckpriceScreenState();
}

class _CheckpriceScreenState extends State<CheckpriceScreen> {
  // Declare a GlobalKey<FormState> in your _DisplayScreenState class

// ...

  Future<void> ScanAgain() async {
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

      String? branch = prefs.getString('branch');
      // Make an API call with the scanned barcode
      final apiUrl = 'http://$ip/getItem/'; // Replace with your API endpoint
      final response = await http.get(Uri.parse(
          '$apiUrl?itemNumber=$barcodeScanRes&branch=$branch&dbName=$dbName'));

      if (response.statusCode == 200) {
        // Data was found in the database
        final newdata =
            jsonDecode(utf8.decode(response.bodyBytes, allowMalformed: true));
        print(newdata['item']);
        if (newdata['item'] != "empty") {
          print("mmmihn");
          setState(() {
            widget.data = newdata;
          });
        } else {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text('Data Not Found'),
              content: Text(
                  'The scanned item barcode was not found in this branch.'),
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

  @override
  Widget build(BuildContext context) {
    final itemQuantities =
        List<Map<String, dynamic>>.from(widget.data['itemQB']);

    final mediaQueryData = MediaQuery.of(context);
    final screenHeight = mediaQueryData.size.height;
    final screenWidth = mediaQueryData.size.width;
    print(screenWidth);

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
              // mainAxisAlignment: MainAxisAlignment.spaceBetween,
              // crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                widget.data['item']['image'] == ''
                    ? Container()
                    : // Wrap the image with InkWell to make it tappable
                    InkWell(
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
                            base64Decode(widget.data['item'][
                                'image']), // Replace with the actual URL from your database
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
                    dataRowMaxHeight: screenHeight * 0.11,
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
                                  mainAxisAlignment: MainAxisAlignment.center,
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
                                width: screenWidth * 0.45,
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
                              scrollDirection: Axis.horizontal,
                              child: Container(
                                alignment: Alignment.center,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Container(
                                      child: Text(
                                        widget.data['item']['S1'].toString(),
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20),
                                      ),
                                    ),
                                    SizedBox(
                                      width: screenWidth * 0.01,
                                    ),
                                    Text("|"),
                                    // Add some spacing between the prices
                                    SizedBox(
                                      width: screenWidth * 0.01,
                                    ),

                                    Container(
                                      child: Text(
                                        widget.data['item']['S2'].toString(),
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20),
                                      ),
                                    ),
                                    SizedBox(
                                      width: screenWidth * 0.01,
                                    ),

                                    Text("|"),
                                    SizedBox(
                                      width: screenWidth * 0.01,
                                    ),

                                    // Add some spacing between the prices
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
                            ),
                          ),
                        ],
                      ),
                      ...itemQuantities.map<DataRow>((item) {
                        return DataRow(
                          cells: [
                            DataCell(
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    "Branch :",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16),
                                  ),
                                  SizedBox(
                                    width: screenWidth * 0.05,
                                  ),
                                  Text(
                                    item['branch'],
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
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    "Quantity :",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16),
                                  ),
                                  SizedBox(
                                    width: screenWidth * 0.05,
                                  ),
                                  Text(
                                    item['quantity'].toString(),
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                      DataRow(cells: [
                        DataCell(
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                "Total Quantity :",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              SizedBox(
                                width: screenWidth * 0.05,
                              ),
                              Text(
                                widget.data['totalQuantity'].toString(),
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 20),
                              ),
                            ],
                          ),
                        ),
                        DataCell(Container()),
                      ])
                    ],
                  ),
                ),

                // Sign in button
                MyButton(
                  onTap: () {
                    // Validation passed, make the update call
                    ScanAgain();
                  },
                  buttonName: "Scan Again",
                ),
                SizedBox(height: screenHeight * 0.01),

                // Add any additional widgets or styling as needed
              ],
            ),
          ),
        ),
      ),
    );
  }
}
