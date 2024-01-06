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

      try {
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
                content: Text('The scanned item barcode was not found.'),
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
        }
      } catch (e) {
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

  Color getAppBarBackgroundColor() {
    SharedPreferences prefs;
    bool? isOnline;

    Future<void> fetchData() async {
      prefs = await SharedPreferences.getInstance();
      isOnline = prefs.getBool('isOnline');
    }

    fetchData(); // Call the function to fetch data

    return isOnline == true ? Colors.deepPurple : Colors.grey;
  }

  @override
  Widget build(BuildContext context) {
    final itemQuantities =
        List<Map<String, dynamic>>.from(widget.data['itemQB']);

    final mediaQueryData = MediaQuery.of(context);
    final screenHeight = mediaQueryData.size.height;
    final screenWidth = mediaQueryData.size.width;
    print(widget.data['item']['Disc1']);
    print(widget.data['item']['Disc2']);

    print(widget.data['item']['Disc3']);
    print(widget.data['item']['Qunit']);

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
                // Wrap the image with InkWell to make it tappable
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          Text(
                            "Total Branches :",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          Text(
                            widget.data['branches_number'].toString(),
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 20),
                          ),
                        ],
                      ),
                    ),
                    widget.data['item']['image'] != ''
                        ? Center(
                            child: InkWell(
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
                                  errorBuilder: (context, error, stackTrace) {
                                    // Handle the image loading error here
                                    return Icon(Icons
                                        .error); // Display an error icon or placeholder
                                  },
                                  width: screenWidth *
                                      0.16, // Adjust the width as needed
                                  height: screenHeight *
                                      0.08, // Adjust the height as needed
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          )
                        : Expanded(child: Center()),
                    Expanded(
                      child: Column(
                        children: [
                          Text(
                            "Total Qty :",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          Text(
                            widget.data['totalQuantity'].toString(),
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 20),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    widget.data['item']['sp'] != "" &&
                            widget.data['item']['sp'] != null
                        ? Row(
                            children: [
                              // Text(
                              //   "TTC :",
                              //   style: TextStyle(
                              //       fontWeight: FontWeight.bold, fontSize: 16),
                              // ),
                              Text(
                                widget.data['item']['sp'].toString(),
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16),
                              )
                            ],
                          )
                        : Container(),
                    Row(
                      children: [
                        Text(
                          "VAT :",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        widget.data['item']['sp'] == "" ||
                                widget.data['item']['sp'] == null
                            ? Text(
                                "-",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16),
                              )
                            : Text(
                                widget.data['item']['vat'].toString(),
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16),
                              )
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          "QUnit:",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        SizedBox(
                          width: screenWidth * 0.025,
                        ),
                        Text(
                          widget.data['item']['Qunit'] == null
                              ? "-"
                              : widget.data['item']['Qunit'].toStringAsFixed(2),
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 20),
                        ),
                      ],
                    ),
                  ],
                ),
                // Display the data in a DataTable

                Container(
                  height: screenHeight * 0.625,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: Column(
                      children: [
                        DataTable(
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
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
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
                                                    widget.data['item']
                                                        ['itemNumber']
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
                                        widget.data['item']['itemName']
                                            .toString(),
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
                                // widget.data['item']['sp'] == 'None'
                                //     ? widget.data['item']['vat'] == 0
                                //         ? DataCell(Center(
                                //             child: Text(
                                //               "SPrice",
                                //               style: TextStyle(
                                //                   fontWeight: FontWeight.bold,
                                //                   fontSize: 16),
                                //             ),
                                //           ))
                                //         : DataCell(Center(
                                //             child: Text(
                                //               "SPrice *",
                                //               style: TextStyle(
                                //                   fontWeight: FontWeight.bold,
                                //                   fontSize: 16),
                                //             ),
                                //           ))
                                //     : widget.data['item']['vat'] == 0
                                //         ? DataCell(Center(
                                //             child: Text(
                                //               "SPrice" +
                                //                   '\n' +
                                //                   widget.data['item']['sp']
                                //                       .toString(),
                                //               style: TextStyle(
                                //                   fontWeight: FontWeight.bold,
                                //                   fontSize: 16),
                                //             ),
                                //           ))
                                //         : DataCell(
                                //             Center(
                                //               child: Text(
                                //                 "SPrice *" +
                                //                     '\n' +
                                //                     widget.data['item']['sp']
                                //                         .toString(),
                                //                 style: TextStyle(
                                //                     fontWeight: FontWeight.bold,
                                //                     fontSize: 16),
                                //               ),
                                //             ),
                                //           ),

                                DataCell(
                                  SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Row(
                                      children: [
                                        Column(children: [
                                          Container(
                                            height: screenHeight * 0.04,
                                            child: Row(
                                              children: [
                                                Container(
                                                  child: Text(
                                                    "1-",
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 20),
                                                  ),
                                                ),
                                                SizedBox(
                                                  width: screenWidth * 0.025,
                                                ),
                                                Container(
                                                  child: Text(
                                                    widget.data['item']['S1']
                                                        .toString(),
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 20),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Container(
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
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
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontSize: 20),
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        width:
                                                            screenWidth * 0.025,
                                                      ),
                                                      Container(
                                                        child: Text(
                                                          widget.data['item']
                                                                  ['S2']
                                                              .toString(),
                                                          style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
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
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 20),
                                                  ),
                                                ),
                                                SizedBox(
                                                  width: screenWidth * 0.025,
                                                ),
                                                Container(
                                                  child: Text(
                                                    widget.data['item']['S3']
                                                        .toString(),
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 20),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ]),
                                      ],
                                    ),
                                  ),
                                ),
                                DataCell(
                                  SingleChildScrollView(
                                    scrollDirection: Axis.vertical,
                                    child:
                                        widget.data['item']['Disc1'] > 0 ||
                                                widget.data['item']['Disc2'] >
                                                    0 ||
                                                widget.data['item']['Disc3'] > 0
                                            ? Column(
                                                children: [
                                                  Container(
                                                    height: screenHeight * 0.04,
                                                    child: Row(
                                                      children: [
                                                        Container(
                                                          child: Text(
                                                            "1-",
                                                            style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontSize: MediaQuery.of(context).textScaleFactor >
                                                                            1.75 ||
                                                                        MediaQuery.of(context).size.height <
                                                                            650
                                                                    ? 14
                                                                    : 18),
                                                          ),
                                                        ),
                                                        SizedBox(
                                                          width: screenWidth *
                                                              0.025,
                                                        ),
                                                        // Container(
                                                        //   child: Text(
                                                        //     widget.data['item']['S1']
                                                        //         .toString(),
                                                        //     style: TextStyle(
                                                        //         fontWeight: FontWeight.bold,
                                                        //         fontSize: MediaQuery.of(context)
                                                        //                         .textScaleFactor >
                                                        //                     1.75 ||
                                                        //                 MediaQuery.of(context)
                                                        //                         .size
                                                        //                         .height <
                                                        //                     650
                                                        //             ? 14
                                                        //             : 18),
                                                        //   ),
                                                        // ),
                                                        widget.data['item']
                                                                    ['Disc1'] >
                                                                0
                                                            ? Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .center,
                                                                children: [
                                                                  // SizedBox(
                                                                  //   width: screenWidth * 0.0125,
                                                                  // ),
                                                                  // Text(
                                                                  //   '|',
                                                                  //   style: TextStyle(
                                                                  //       fontWeight:
                                                                  //           FontWeight.bold,
                                                                  //       fontSize: MediaQuery.of(
                                                                  //                           context)
                                                                  //                       .textScaleFactor >
                                                                  //                   1.75 ||
                                                                  //               MediaQuery.of(
                                                                  //                           context)
                                                                  //                       .size
                                                                  //                       .height <
                                                                  //                   650
                                                                  //           ? 14
                                                                  //           : 18),
                                                                  //   textAlign: TextAlign.center,
                                                                  // ),
                                                                  // SizedBox(
                                                                  //   width: screenWidth * 0.0125,
                                                                  // ),
                                                                  Container(
                                                                    child: Text(
                                                                      "${widget.data['item']['Disc1']} %"
                                                                          .toString(),
                                                                      style: TextStyle(
                                                                          fontWeight: FontWeight
                                                                              .bold,
                                                                          fontSize: MediaQuery.of(context).textScaleFactor > 1.75 || MediaQuery.of(context).size.height < 650
                                                                              ? 14
                                                                              : 18),
                                                                    ),
                                                                  ),
                                                                ],
                                                              )
                                                            : Container(),
                                                      ],
                                                    ),
                                                  ),
                                                  Container(
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      children: [
                                                        Container(
                                                          height: screenHeight *
                                                              0.04,
                                                          child: Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Container(
                                                                child: Text(
                                                                    "2-",
                                                                    style: TextStyle(
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .bold,
                                                                        fontSize: MediaQuery.of(context).textScaleFactor > 1.75 ||
                                                                                MediaQuery.of(context).size.height < 650
                                                                            ? 14
                                                                            : 18)),
                                                              ),
                                                              SizedBox(
                                                                width:
                                                                    screenWidth *
                                                                        0.025,
                                                              ),
                                                              // Container(
                                                              //   child: Text(
                                                              //       widget.data['item']['S2']
                                                              //           .toString(),
                                                              //       style: TextStyle(
                                                              //           fontWeight:
                                                              //               FontWeight.bold,
                                                              //           fontSize: MediaQuery.of(
                                                              //                               context)
                                                              //                           .textScaleFactor >
                                                              //                       1.75 ||
                                                              //                   MediaQuery.of(
                                                              //                               context)
                                                              //                           .size
                                                              //                           .height <
                                                              //                       650
                                                              //               ? 14
                                                              //               : 18)),
                                                              // ),
                                                              widget.data['item']
                                                                          [
                                                                          'Disc2'] >
                                                                      0
                                                                  ? Row(
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .center,
                                                                      children: [
                                                                        // SizedBox(
                                                                        //   width: screenWidth *
                                                                        //       0.0125,
                                                                        // ),
                                                                        // Text(
                                                                        //   '|',
                                                                        //   style: TextStyle(
                                                                        //       fontWeight:
                                                                        //           FontWeight
                                                                        //               .bold,
                                                                        //       fontSize: MediaQuery.of(context)
                                                                        //                       .textScaleFactor >
                                                                        //                   1.75 ||
                                                                        //               MediaQuery.of(context)
                                                                        //                       .size
                                                                        //                       .height <
                                                                        //                   650
                                                                        //           ? 14
                                                                        //           : 18),
                                                                        //   textAlign:
                                                                        //       TextAlign.center,
                                                                        // ),
                                                                        // SizedBox(
                                                                        //   width: screenWidth *
                                                                        //       0.0125,
                                                                        // ),
                                                                        Container(
                                                                          child:
                                                                              Text(
                                                                            "${widget.data['item']['Disc2']} %".toString(),
                                                                            style:
                                                                                TextStyle(fontWeight: FontWeight.bold, fontSize: MediaQuery.of(context).textScaleFactor > 1.75 || MediaQuery.of(context).size.height < 650 ? 14 : 18),
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    )
                                                                  : Container(),
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
                                                          CrossAxisAlignment
                                                              .center,
                                                      children: [
                                                        Container(
                                                          child: Text(
                                                            "3-",
                                                            style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontSize: MediaQuery.of(context).textScaleFactor >
                                                                            1.75 ||
                                                                        MediaQuery.of(context).size.height <
                                                                            650
                                                                    ? 14
                                                                    : 18),
                                                          ),
                                                        ),
                                                        SizedBox(
                                                          width: screenWidth *
                                                              0.025,
                                                        ),
                                                        // Container(
                                                        //   child: Text(
                                                        //     widget.data['item']['S3']
                                                        //         .toString(),
                                                        //     style: TextStyle(
                                                        //         fontWeight: FontWeight.bold,
                                                        //         fontSize: MediaQuery.of(context)
                                                        //                         .textScaleFactor >
                                                        //                     1.75 ||
                                                        //                 MediaQuery.of(context)
                                                        //                         .size
                                                        //                         .height <
                                                        //                     650
                                                        //             ? 14
                                                        //             : 18),
                                                        //   ),
                                                        // ),
                                                        widget.data['item']
                                                                    ['Disc3'] >
                                                                0
                                                            ? Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .center,
                                                                children: [
                                                                  // SizedBox(
                                                                  //   width: screenWidth * 0.0125,
                                                                  // ),
                                                                  // Text(
                                                                  //   '|',
                                                                  //   style: TextStyle(
                                                                  //       fontWeight:
                                                                  //           FontWeight.bold,
                                                                  //       fontSize: MediaQuery.of(
                                                                  //                           context)
                                                                  //                       .textScaleFactor >
                                                                  //                   1.75 ||
                                                                  //               MediaQuery.of(
                                                                  //                           context)
                                                                  //                       .size
                                                                  //                       .height <
                                                                  //                   650
                                                                  //           ? 14
                                                                  //           : 18),
                                                                  //   textAlign: TextAlign.center,
                                                                  // ),
                                                                  // SizedBox(
                                                                  //   width: screenWidth * 0.0125,
                                                                  // ),
                                                                  Container(
                                                                    child: Text(
                                                                      "${widget.data['item']['Disc3']} %"
                                                                          .toString(),
                                                                      style: TextStyle(
                                                                          fontWeight: FontWeight
                                                                              .bold,
                                                                          fontSize: MediaQuery.of(context).textScaleFactor > 1.75 || MediaQuery.of(context).size.height < 650
                                                                              ? 14
                                                                              : 18),
                                                                    ),
                                                                  ),
                                                                ],
                                                              )
                                                            : Container(),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              )
                                            : Column(),
                                  ),
                                ),
                              ],
                            ),
                            ...itemQuantities.map<DataRow>((item) {
                              return DataRow(
                                cells: [
                                  DataCell(
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
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
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Text(
                                          "Qty In Stock :",
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16),
                                        ),
                                        SizedBox(
                                          width: screenWidth * 0.025,
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
                            // DataRow(cells: [
                            //   DataCell(
                            //     Row(
                            //       mainAxisAlignment: MainAxisAlignment.center,
                            //       crossAxisAlignment: CrossAxisAlignment.center,
                            //       children: [
                            //         Text(
                            //           "Total Qty :",
                            //           style: TextStyle(
                            //               fontWeight: FontWeight.bold,
                            //               fontSize: 16),
                            //         ),
                            //         SizedBox(
                            //           width: screenWidth * 0.05,
                            //         ),
                            //         Text(
                            //           widget.data['totalQuantity'].toString(),
                            //           style: TextStyle(
                            //               fontWeight: FontWeight.bold,
                            //               fontSize: 20),
                            //         ),
                            //       ],
                            //     ),
                            //   ),
                            //   DataCell(Container()),
                            // ])
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // Sign in button
                MyButton(
                  onTap: () {
                    // Validation passed, make the update call
                    Navigator.of(context).pop();

                    //ScanAgain();
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
