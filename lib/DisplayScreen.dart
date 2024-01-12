import 'dart:convert';

import 'package:checkprice/offline/sqllite.dart';
import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'components/image_dialog.dart';
import 'components/my_button.dart';
import 'components/my_textfield.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

//import 'options.dart';

// ignore: must_be_immutable
class DisplayScreen extends StatefulWidget {
  Map<String, dynamic> data;
  final String inventory;
  final String? username;
  bool isOnline;
  DisplayScreen(
      {super.key, required this.data,
      required this.inventory,
      required this.username,
      required this.isOnline});

  @override
  _DisplayScreenState createState() => _DisplayScreenState();
}

class _DisplayScreenState extends State<DisplayScreen> {
  final TextEditingController _inputController = TextEditingController(text: '1');

  Future<void> scanRetreiveData(String inventory) async {
    String barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
      '#ff6666', // Scanner overlay color
      'Cancel', // Cancel button text
      true, // Show flash icon
      ScanMode.BARCODE, // Scan mode
    );
    if (barcodeScanRes == '-1') {
      print("fettttttttttttttttttttttnew");
      Navigator.of(context).pop();
    }

    // Check if a barcode was successfully scanned
    if (barcodeScanRes != '-1') {
      print(barcodeScanRes);
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? dbName = prefs.getString('dbName');
      String? ip = prefs.getString('ip');
      String? username = prefs.getString('username');
      String? branch = prefs.getString('branch');
      try {
        // Make an API call with the scanned barcode
        final apiUrl =
            'http://$ip/getInventoryItem/'; // Replace with your API endpoint
        final response = await http.get(Uri.parse(
            '$apiUrl?itemNumber=$barcodeScanRes&branch=$branch&dbName=$dbName&username=$username&inventory=$inventory'));

        if (response.statusCode == 200) {
          // Data was found in the database
          //final data = jsonDecode(response.body);
          // final encoding = Encoding.getByName('utf-8'); // Use UTF-8 encoding
          final newdata =
              jsonDecode(utf8.decode(response.bodyBytes, allowMalformed: true));
          if (newdata['item'] != "empty") {
            setState(() {
              widget.data = newdata;
            });
          } else {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) => AlertDialog(
                title: const Text('Data Not Found'),
                content: const Text('The scanned item barcode was not found.'),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();

                      scanRetreiveData(inventory);
                      //blaaaaaaaaaaaaaaaaaaaa
                    },
                    child: const Text('Scan Again'),
                  ),
                  // TextButton(
                  //   onPressed: () {
                  //     Navigator.pushNamedAndRemoveUntil(
                  //       context,
                  //       '/options', // Replace with the route name of OptionsScreen
                  //       (route) =>
                  //           false, // This predicate will remove all routes from the stack
                  //     );
                  //     //blaaaaaaaaaaaaaaaaaaaa
                  //   },
                  //   child: Text('Exit'),
                  // ),
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
            title: const Text('Data Not Found'),
            content: const Text('Request error.\nCheck your WIFI.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    }
  }

  Future<void> scanAnotherTimeFail(String inventory) async {
    String barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
      '#ff6666', // Scanner overlay color
      'Cancel', // Cancel button text
      true, // Show flash icon
      ScanMode.BARCODE, // Scan mode
    );
    if (barcodeScanRes == '-1') {
      Navigator.of(context).pop(1);
      // Navigator.of(context).push(MaterialPageRoute(
      //   builder: (context) => Option(param: '1'),
      // ));
    }

    // Check if a barcode was successfully scanned
    if (barcodeScanRes != '-1') {
      print(barcodeScanRes);
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? dbName = prefs.getString('dbName');
      String? ip = prefs.getString('ip');
      String? username = prefs.getString('username');
      String? branch = prefs.getString('branch');
      try {
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
                title: const Text('Data Not Found'),
                content: const Text('The scanned item barcode was not found.'),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      scanAnotherTimeFail(inventory);
                      //blaaaaaaaaaaaaaaaaaaaa
                    },
                    child: const Text('Scan Again'),
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
                    child: const Text('Exit'),
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
            title: const Text('Data Not Found'),
            content: const Text('Request error.\nCheck your WIFI.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
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
      if (widget.isOnline) {
        final response = await http.post(
          url,
          headers: {
            'Content-Type': 'application/json',
          },
        );
        print(response);

        if (response.statusCode == 200) {
          Navigator.of(context).pop();
        } else {
          // Handle login failure (e.g., incorrect credentials)
          print("Failure");
        }
      } else {
        Map<String, dynamic> data = await YourDatabaseHelper()
            .updateHandQuantity(itemNumber, double.parse(handQuantity), branch,
                inventory, oldHandQuantity);
        if (data["status"] == true) {
          Navigator.of(context).pop();
        } else {
          print("Failure");
        }
      }
    } catch (e) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Data Not Found'),
          content: const Text('Request error.\nCheck your WIFI.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }

    /*final response2 = await get(Uri.parse('http://10.0.2.2:8000/getuser/'));
    final jsonData = jsonDecode(response2.body);

    print("hgffffffffffffffffffffffffr");
    print(jsonData);*/
  }

  // Declare a GlobalKey<FormState> in your _DisplayScreenState class
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

// ...

  String replaceAfterUnderscore(String input, int startPosition, int length) {
    int underscoreIndex = input.indexOf('_');
    bool flagContainsOff = false;
    if (underscoreIndex != -1 &&
        underscoreIndex + startPosition + length <= input.length) {
      String prefix = input.substring(0, underscoreIndex + startPosition);
      String suffix = input.substring(underscoreIndex + startPosition + length);
      // Erase the last two digits
      String result = '$prefix$suffix';
      if (result.contains("_off")) {
        result = result.replaceAll("_off", "");
        flagContainsOff = true;
      }

      input = result.substring(0, result.length - 2);

      print(result);
      print("displayedddd");
      print(input);
      if (flagContainsOff == true) {
        input += "_off";
      }
      return input; // Replace with 'XXXX' or any desired characters
    }

    return input; // Return the original string if the replacement is not possible
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
    final mediaQueryData = MediaQuery.of(context);
    final screenHeight = mediaQueryData.size.height;
    final screenWidth = mediaQueryData.size.width;
    String? usernameLower = widget.username?.toLowerCase();
    final displayedText =
        widget.inventory.toString().replaceFirst('dc_${usernameLower}_', '');
    print(screenHeight);

    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context).pop();

        // Navigator.of(context).push(MaterialPageRoute(
        //   builder: (context) => Option(param: '1'),
        // ));
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.grey[200],
        appBar: AppBar(
          title: Text(replaceAfterUnderscore(displayedText, 3, 4),
              style: const TextStyle(fontSize: 18)),
          backgroundColor:
              widget.isOnline == true ? Colors.deepPurple : Colors.grey,
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
                                return const Icon(Icons
                                    .error); // Display an error icon or placeholder
                              },
                              width: screenWidth *
                                  0.2, // Adjust the width as needed
                              height: screenHeight *
                                  0.1, // Adjust the height as needed
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      widget.data['item']['sp'] != "" &&
                              widget.data['item']['sp'] != null
                          ? Row(
                              children: [
                                const Text(
                                  "TTC :",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16),
                                ),
                                Text(
                                  widget.data['item']['sp'].toString(),
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16),
                                )
                              ],
                            )
                          : Container(),
                      Row(
                        children: [
                          const Text(
                            "VAT :",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          widget.data['item']['sp'] == "" ||
                                  widget.data['item']['sp'] == null
                              ? const Text(
                                  "-",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16),
                                )
                              : Text(
                                  widget.data['item']['vat'].toString(),
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16),
                                )
                        ],
                      ),
                    ],
                  ),
                  // Display the data in a DataTable
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      dataRowMaxHeight: screenHeight * 0.12,
                      //dataRowMinHeight: screenHeight * 0.08,
                      columns: const [
                        DataColumn(label: Text('')),
                        DataColumn(label: Text('')),
                      ],
                      rows: [
                        DataRow(
                          cells: [
                            DataCell(
                              SizedBox(
                                width: screenWidth * 0.45,
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.vertical,
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      const Text(
                                        "Item Name",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16),
                                      ),
                                      Text(
                                        widget.data['item']['itemNumber'],
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16),
                                      ),
                                      Text(
                                        widget.data['item']['GOID'] ==
                                                widget.data['item']
                                                    ['itemNumber']
                                            ? ""
                                            : widget.data['item']['GOID'],
                                        style: const TextStyle(
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
                                    style: const TextStyle(
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
                            //         ? DataCell(
                            //             Center(
                            //               child: Text(
                            //                 "Sale Price",
                            //                 textAlign: TextAlign.center,
                            //                 style: TextStyle(
                            //                     fontWeight: FontWeight.bold,
                            //                     fontSize: 16),
                            //               ),
                            //             ),
                            //           )
                            //         : DataCell(Center(
                            //             child: Text(
                            //               "Sale Price *",
                            //               style: TextStyle(
                            //                   fontWeight: FontWeight.bold,
                            //                   fontSize: 16),
                            //             ),
                            //           ))
                            //     : widget.data['item']['vat'] == 0
                            //         ? DataCell(Center(
                            //             child: Text(
                            //               "Sale Price" +
                            //                   '\n' +
                            //                   widget.data['item']['sp']
                            //                       .toString(),
                            //               style: TextStyle(
                            //                   fontWeight: FontWeight.bold,
                            //                   fontSize: 16),
                            //             ),
                            //           ))
                            //         : DataCell(Center(
                            //             child: Text(
                            //               "Sale Price *" +
                            //                   '\n' +
                            //                   widget.data['item']['sp']
                            //                       .toString(),
                            //               style: TextStyle(
                            //                   fontWeight: FontWeight.bold,
                            //                   fontSize: 16),
                            //             ),
                            //           )),
                            DataCell(
                              SingleChildScrollView(
                                scrollDirection: Axis.vertical,
                                child: Column(children: [
                                  SizedBox(
                                    height: screenHeight * 0.04,
                                    child: Row(
                                      children: [
                                        Container(
                                          child: Text(
                                            "1-",
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: MediaQuery.of(context)
                                                                .textScaleFactor >
                                                            1.75 ||
                                                        MediaQuery.of(context)
                                                                .size
                                                                .height <
                                                            650
                                                    ? 14
                                                    : 18),
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
                                                fontWeight: FontWeight.bold,
                                                fontSize: MediaQuery.of(context)
                                                                .textScaleFactor >
                                                            1.75 ||
                                                        MediaQuery.of(context)
                                                                .size
                                                                .height <
                                                            650
                                                    ? 14
                                                    : 18),
                                          ),
                                        ),
                                        // widget.data['item']['Disc1'] > 0
                                        //     ? Row(
                                        //         mainAxisAlignment:
                                        //             MainAxisAlignment.center,
                                        //         children: [
                                        //           SizedBox(
                                        //             width: screenWidth * 0.0125,
                                        //           ),
                                        //           Text(
                                        //             '|',
                                        //             style: TextStyle(
                                        //                 fontWeight:
                                        //                     FontWeight.bold,
                                        //                 fontSize: MediaQuery.of(
                                        //                                     context)
                                        //                                 .textScaleFactor >
                                        //                             1.75 ||
                                        //                         MediaQuery.of(
                                        //                                     context)
                                        //                                 .size
                                        //                                 .height <
                                        //                             650
                                        //                     ? 14
                                        //                     : 18),
                                        //             textAlign: TextAlign.center,
                                        //           ),
                                        //           SizedBox(
                                        //             width: screenWidth * 0.0125,
                                        //           ),
                                        //           Container(
                                        //             child: Text(
                                        //               "${widget.data['item']['Disc1']}%"
                                        //                   .toString(),
                                        //               style: TextStyle(
                                        //                   fontWeight:
                                        //                       FontWeight.bold,
                                        //                   fontSize: MediaQuery.of(
                                        //                                       context)
                                        //                                   .textScaleFactor >
                                        //                               1.75 ||
                                        //                           MediaQuery.of(
                                        //                                       context)
                                        //                                   .size
                                        //                                   .height <
                                        //                               650
                                        //                       ? 14
                                        //                       : 18),
                                        //             ),
                                        //           ),
                                        //         ],
                                        //       )
                                        //     : Container(),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        SizedBox(
                                          height: screenHeight * 0.04,
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              Container(
                                                child: Text("2-",
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: MediaQuery.of(
                                                                            context)
                                                                        .textScaleFactor >
                                                                    1.75 ||
                                                                MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .height <
                                                                    650
                                                            ? 14
                                                            : 18)),
                                              ),
                                              SizedBox(
                                                width: screenWidth * 0.025,
                                              ),
                                              Container(
                                                child: Text(
                                                    widget.data['item']['S2']
                                                        .toString(),
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: MediaQuery.of(
                                                                            context)
                                                                        .textScaleFactor >
                                                                    1.75 ||
                                                                MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .height <
                                                                    650
                                                            ? 14
                                                            : 18)),
                                              ),
                                              // widget.data['item']['Disc2'] > 0
                                              //     ? Row(
                                              //         mainAxisAlignment:
                                              //             MainAxisAlignment
                                              //                 .center,
                                              //         children: [
                                              //           SizedBox(
                                              //             width: screenWidth *
                                              //                 0.0125,
                                              //           ),
                                              //           Text(
                                              //             '|',
                                              //             style: TextStyle(
                                              //                 fontWeight:
                                              //                     FontWeight
                                              //                         .bold,
                                              //                 fontSize: MediaQuery.of(context)
                                              //                                 .textScaleFactor >
                                              //                             1.75 ||
                                              //                         MediaQuery.of(context)
                                              //                                 .size
                                              //                                 .height <
                                              //                             650
                                              //                     ? 14
                                              //                     : 18),
                                              //             textAlign:
                                              //                 TextAlign.center,
                                              //           ),
                                              //           SizedBox(
                                              //             width: screenWidth *
                                              //                 0.0125,
                                              //           ),
                                              //           Container(
                                              //             child: Text(
                                              //               "${widget.data['item']['Disc2']}%"
                                              //                   .toString(),
                                              //               style: TextStyle(
                                              //                   fontWeight:
                                              //                       FontWeight
                                              //                           .bold,
                                              //                   fontSize: MediaQuery.of(context).textScaleFactor >
                                              //                               1.75 ||
                                              //                           MediaQuery.of(context).size.height <
                                              //                               650
                                              //                       ? 14
                                              //                       : 18),
                                              //             ),
                                              //           ),
                                              //         ],
                                              //       )
                                              //     : Container(),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(
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
                                                fontSize: MediaQuery.of(context)
                                                                .textScaleFactor >
                                                            1.75 ||
                                                        MediaQuery.of(context)
                                                                .size
                                                                .height <
                                                            650
                                                    ? 14
                                                    : 18),
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
                                                fontWeight: FontWeight.bold,
                                                fontSize: MediaQuery.of(context)
                                                                .textScaleFactor >
                                                            1.75 ||
                                                        MediaQuery.of(context)
                                                                .size
                                                                .height <
                                                            650
                                                    ? 14
                                                    : 18),
                                          ),
                                        ),
                                        // widget.data['item']['Disc3'] > 0
                                        //     ? Row(
                                        //         mainAxisAlignment:
                                        //             MainAxisAlignment.center,
                                        //         children: [
                                        //           SizedBox(
                                        //             width: screenWidth * 0.0125,
                                        //           ),
                                        //           Text(
                                        //             '|',
                                        //             style: TextStyle(
                                        //                 fontWeight:
                                        //                     FontWeight.bold,
                                        //                 fontSize: MediaQuery.of(
                                        //                                     context)
                                        //                                 .textScaleFactor >
                                        //                             1.75 ||
                                        //                         MediaQuery.of(
                                        //                                     context)
                                        //                                 .size
                                        //                                 .height <
                                        //                             650
                                        //                     ? 14
                                        //                     : 18),
                                        //             textAlign: TextAlign.center,
                                        //           ),
                                        //           SizedBox(
                                        //             width: screenWidth * 0.0125,
                                        //           ),
                                        //           Container(
                                        //             child: Text(
                                        //               "${widget.data['item']['Disc3']}%"
                                        //                   .toString(),
                                        //               style: TextStyle(
                                        //                   fontWeight:
                                        //                       FontWeight.bold,
                                        //                   fontSize: MediaQuery.of(
                                        //                                       context)
                                        //                                   .textScaleFactor >
                                        //                               1.75 ||
                                        //                           MediaQuery.of(
                                        //                                       context)
                                        //                                   .size
                                        //                                   .height <
                                        //                               650
                                        //                       ? 14
                                        //                       : 18),
                                        //             ),
                                        //           ),
                                        //         ],
                                        //       )
                                        //     : Container(),
                                      ],
                                    ),
                                  ),
                                ]),
                              ),
                            ),
                            DataCell(
                              SingleChildScrollView(
                                scrollDirection: Axis.vertical,
                                child:
                                    widget.data['item']['Disc1'] > 0 ||
                                            widget.data['item']['Disc2'] > 0 ||
                                            widget.data['item']['Disc3'] > 0
                                        ? Column(
                                            children: [
                                              SizedBox(
                                                height: screenHeight * 0.04,
                                                child: Row(
                                                  children: [
                                                    Container(
                                                      child: Text(
                                                        "1-",
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: MediaQuery.of(context)
                                                                            .textScaleFactor >
                                                                        1.75 ||
                                                                    MediaQuery.of(context)
                                                                            .size
                                                                            .height <
                                                                        650
                                                                ? 14
                                                                : 18),
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      width:
                                                          screenWidth * 0.025,
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
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                      fontSize: MediaQuery.of(context).textScaleFactor > 1.75 ||
                                                                              MediaQuery.of(context).size.height < 650
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
                                                      MainAxisAlignment.start,
                                                  children: [
                                                    SizedBox(
                                                      height:
                                                          screenHeight * 0.04,
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .start,
                                                        children: [
                                                          Container(
                                                            child: Text("2-",
                                                                style: TextStyle(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    fontSize: MediaQuery.of(context).textScaleFactor >
                                                                                1.75 ||
                                                                            MediaQuery.of(context).size.height <
                                                                                650
                                                                        ? 14
                                                                        : 18)),
                                                          ),
                                                          SizedBox(
                                                            width: screenWidth *
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
                                                          widget.data['item'][
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
                                                                        "${widget.data['item']['Disc2']} %"
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
                                                ),
                                              ),
                                              SizedBox(
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
                                                            fontSize: MediaQuery.of(context)
                                                                            .textScaleFactor >
                                                                        1.75 ||
                                                                    MediaQuery.of(context)
                                                                            .size
                                                                            .height <
                                                                        650
                                                                ? 14
                                                                : 18),
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      width:
                                                          screenWidth * 0.025,
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
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                      fontSize: MediaQuery.of(context).textScaleFactor > 1.75 ||
                                                                              MediaQuery.of(context).size.height < 650
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
                                        : const Column(),
                              ),
                            ),
                          ],
                        ),
                        // DataRow(
                        //   cells: [
                        //     DataCell(
                        //       Center(
                        //         child: Text(
                        //           "Discount %",
                        //           style: TextStyle(
                        //               fontWeight: FontWeight.bold,
                        //               fontSize: 16),
                        //         ),
                        //       ),
                        //     ),
                        //     DataCell(
                        //       SingleChildScrollView(
                        //         scrollDirection: Axis.vertical,
                        //         child:
                        //             widget.data['item']['Disc1'] > 0 ||
                        //                     widget.data['item']['Disc2'] > 0 ||
                        //                     widget.data['item']['Disc3'] > 0
                        //                 ? Column(
                        //                     children: [
                        //                       Container(
                        //                         height: screenHeight * 0.04,
                        //                         child: Row(
                        //                           children: [
                        //                             Container(
                        //                               child: Text(
                        //                                 "1-",
                        //                                 style: TextStyle(
                        //                                     fontWeight:
                        //                                         FontWeight.bold,
                        //                                     fontSize: MediaQuery.of(context)
                        //                                                     .textScaleFactor >
                        //                                                 1.75 ||
                        //                                             MediaQuery.of(context)
                        //                                                     .size
                        //                                                     .height <
                        //                                                 650
                        //                                         ? 14
                        //                                         : 18),
                        //                               ),
                        //                             ),
                        //                             SizedBox(
                        //                               width:
                        //                                   screenWidth * 0.025,
                        //                             ),
                        //                             // Container(
                        //                             //   child: Text(
                        //                             //     widget.data['item']['S1']
                        //                             //         .toString(),
                        //                             //     style: TextStyle(
                        //                             //         fontWeight: FontWeight.bold,
                        //                             //         fontSize: MediaQuery.of(context)
                        //                             //                         .textScaleFactor >
                        //                             //                     1.75 ||
                        //                             //                 MediaQuery.of(context)
                        //                             //                         .size
                        //                             //                         .height <
                        //                             //                     650
                        //                             //             ? 14
                        //                             //             : 18),
                        //                             //   ),
                        //                             // ),
                        //                             widget.data['item']
                        //                                         ['Disc1'] >
                        //                                     0
                        //                                 ? Row(
                        //                                     mainAxisAlignment:
                        //                                         MainAxisAlignment
                        //                                             .center,
                        //                                     children: [
                        //                                       // SizedBox(
                        //                                       //   width: screenWidth * 0.0125,
                        //                                       // ),
                        //                                       // Text(
                        //                                       //   '|',
                        //                                       //   style: TextStyle(
                        //                                       //       fontWeight:
                        //                                       //           FontWeight.bold,
                        //                                       //       fontSize: MediaQuery.of(
                        //                                       //                           context)
                        //                                       //                       .textScaleFactor >
                        //                                       //                   1.75 ||
                        //                                       //               MediaQuery.of(
                        //                                       //                           context)
                        //                                       //                       .size
                        //                                       //                       .height <
                        //                                       //                   650
                        //                                       //           ? 14
                        //                                       //           : 18),
                        //                                       //   textAlign: TextAlign.center,
                        //                                       // ),
                        //                                       // SizedBox(
                        //                                       //   width: screenWidth * 0.0125,
                        //                                       // ),
                        //                                       Container(
                        //                                         child: Text(
                        //                                           "${widget.data['item']['Disc1']}"
                        //                                               .toString(),
                        //                                           style: TextStyle(
                        //                                               fontWeight:
                        //                                                   FontWeight
                        //                                                       .bold,
                        //                                               fontSize: MediaQuery.of(context).textScaleFactor > 1.75 ||
                        //                                                       MediaQuery.of(context).size.height < 650
                        //                                                   ? 14
                        //                                                   : 18),
                        //                                         ),
                        //                                       ),
                        //                                     ],
                        //                                   )
                        //                                 : Container(),
                        //                           ],
                        //                         ),
                        //                       ),
                        //                       Container(
                        //                         child: Row(
                        //                           mainAxisAlignment:
                        //                               MainAxisAlignment.start,
                        //                           children: [
                        //                             Container(
                        //                               height:
                        //                                   screenHeight * 0.04,
                        //                               child: Row(
                        //                                 mainAxisAlignment:
                        //                                     MainAxisAlignment
                        //                                         .start,
                        //                                 children: [
                        //                                   Container(
                        //                                     child: Text("2-",
                        //                                         style: TextStyle(
                        //                                             fontWeight:
                        //                                                 FontWeight
                        //                                                     .bold,
                        //                                             fontSize: MediaQuery.of(context).textScaleFactor >
                        //                                                         1.75 ||
                        //                                                     MediaQuery.of(context).size.height <
                        //                                                         650
                        //                                                 ? 14
                        //                                                 : 18)),
                        //                                   ),
                        //                                   SizedBox(
                        //                                     width: screenWidth *
                        //                                         0.025,
                        //                                   ),
                        //                                   // Container(
                        //                                   //   child: Text(
                        //                                   //       widget.data['item']['S2']
                        //                                   //           .toString(),
                        //                                   //       style: TextStyle(
                        //                                   //           fontWeight:
                        //                                   //               FontWeight.bold,
                        //                                   //           fontSize: MediaQuery.of(
                        //                                   //                               context)
                        //                                   //                           .textScaleFactor >
                        //                                   //                       1.75 ||
                        //                                   //                   MediaQuery.of(
                        //                                   //                               context)
                        //                                   //                           .size
                        //                                   //                           .height <
                        //                                   //                       650
                        //                                   //               ? 14
                        //                                   //               : 18)),
                        //                                   // ),
                        //                                   widget.data['item'][
                        //                                               'Disc2'] >
                        //                                           0
                        //                                       ? Row(
                        //                                           mainAxisAlignment:
                        //                                               MainAxisAlignment
                        //                                                   .center,
                        //                                           children: [
                        //                                             // SizedBox(
                        //                                             //   width: screenWidth *
                        //                                             //       0.0125,
                        //                                             // ),
                        //                                             // Text(
                        //                                             //   '|',
                        //                                             //   style: TextStyle(
                        //                                             //       fontWeight:
                        //                                             //           FontWeight
                        //                                             //               .bold,
                        //                                             //       fontSize: MediaQuery.of(context)
                        //                                             //                       .textScaleFactor >
                        //                                             //                   1.75 ||
                        //                                             //               MediaQuery.of(context)
                        //                                             //                       .size
                        //                                             //                       .height <
                        //                                             //                   650
                        //                                             //           ? 14
                        //                                             //           : 18),
                        //                                             //   textAlign:
                        //                                             //       TextAlign.center,
                        //                                             // ),
                        //                                             // SizedBox(
                        //                                             //   width: screenWidth *
                        //                                             //       0.0125,
                        //                                             // ),
                        //                                             Container(
                        //                                               child:
                        //                                                   Text(
                        //                                                 "${widget.data['item']['Disc2']}"
                        //                                                     .toString(),
                        //                                                 style: TextStyle(
                        //                                                     fontWeight: FontWeight
                        //                                                         .bold,
                        //                                                     fontSize: MediaQuery.of(context).textScaleFactor > 1.75 || MediaQuery.of(context).size.height < 650
                        //                                                         ? 14
                        //                                                         : 18),
                        //                                               ),
                        //                                             ),
                        //                                           ],
                        //                                         )
                        //                                       : Container(),
                        //                                 ],
                        //                               ),
                        //                             ),
                        //                           ],
                        //                         ),
                        //                       ),
                        //                       Container(
                        //                         height: screenHeight * 0.04,
                        //                         child: Row(
                        //                           crossAxisAlignment:
                        //                               CrossAxisAlignment.center,
                        //                           children: [
                        //                             Container(
                        //                               child: Text(
                        //                                 "3-",
                        //                                 style: TextStyle(
                        //                                     fontWeight:
                        //                                         FontWeight.bold,
                        //                                     fontSize: MediaQuery.of(context)
                        //                                                     .textScaleFactor >
                        //                                                 1.75 ||
                        //                                             MediaQuery.of(context)
                        //                                                     .size
                        //                                                     .height <
                        //                                                 650
                        //                                         ? 14
                        //                                         : 18),
                        //                               ),
                        //                             ),
                        //                             SizedBox(
                        //                               width:
                        //                                   screenWidth * 0.025,
                        //                             ),
                        //                             // Container(
                        //                             //   child: Text(
                        //                             //     widget.data['item']['S3']
                        //                             //         .toString(),
                        //                             //     style: TextStyle(
                        //                             //         fontWeight: FontWeight.bold,
                        //                             //         fontSize: MediaQuery.of(context)
                        //                             //                         .textScaleFactor >
                        //                             //                     1.75 ||
                        //                             //                 MediaQuery.of(context)
                        //                             //                         .size
                        //                             //                         .height <
                        //                             //                     650
                        //                             //             ? 14
                        //                             //             : 18),
                        //                             //   ),
                        //                             // ),
                        //                             widget.data['item']
                        //                                         ['Disc3'] >
                        //                                     0
                        //                                 ? Row(
                        //                                     mainAxisAlignment:
                        //                                         MainAxisAlignment
                        //                                             .center,
                        //                                     children: [
                        //                                       // SizedBox(
                        //                                       //   width: screenWidth * 0.0125,
                        //                                       // ),
                        //                                       // Text(
                        //                                       //   '|',
                        //                                       //   style: TextStyle(
                        //                                       //       fontWeight:
                        //                                       //           FontWeight.bold,
                        //                                       //       fontSize: MediaQuery.of(
                        //                                       //                           context)
                        //                                       //                       .textScaleFactor >
                        //                                       //                   1.75 ||
                        //                                       //               MediaQuery.of(
                        //                                       //                           context)
                        //                                       //                       .size
                        //                                       //                       .height <
                        //                                       //                   650
                        //                                       //           ? 14
                        //                                       //           : 18),
                        //                                       //   textAlign: TextAlign.center,
                        //                                       // ),
                        //                                       // SizedBox(
                        //                                       //   width: screenWidth * 0.0125,
                        //                                       // ),
                        //                                       Container(
                        //                                         child: Text(
                        //                                           "${widget.data['item']['Disc3']}"
                        //                                               .toString(),
                        //                                           style: TextStyle(
                        //                                               fontWeight:
                        //                                                   FontWeight
                        //                                                       .bold,
                        //                                               fontSize: MediaQuery.of(context).textScaleFactor > 1.75 ||
                        //                                                       MediaQuery.of(context).size.height < 650
                        //                                                   ? 14
                        //                                                   : 18),
                        //                                         ),
                        //                                       ),
                        //                                     ],
                        //                                   )
                        //                                 : Container(),
                        //                           ],
                        //                         ),
                        //                       ),
                        //                     ],
                        //                   )
                        //                 : Column(),
                        //       ),
                        //     ),
                        //   ],
                        // ),
                        DataRow(
                          cells: [
                            DataCell(
                              SingleChildScrollView(
                                scrollDirection: Axis.vertical,
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        const Text(
                                          "Qty In Stock :",
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16),
                                        ),
                                        SizedBox(
                                          width: screenWidth * 0.025,
                                        ),
                                        Text(
                                          widget.data['item']['quantity']
                                              .toString(),
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 20),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        const Text(
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
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 20),
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                              ),
                            ),
                            DataCell(
                              Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      const Text(
                                        "Qty Collected:",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16),
                                      ),
                                      SizedBox(
                                        width: screenWidth * 0.025,
                                      ),
                                      Text(
                                        widget.data['item']['handQuantity'] ==
                                                null
                                            ? "-"
                                            : widget.data['item']
                                                    ['handQuantity']
                                                .toStringAsFixed(2),
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      const Text(
                                        "QUnit:",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16),
                                      ),
                                      SizedBox(
                                        width: screenWidth * 0.025,
                                      ),
                                      Text(
                                        widget.data['item']['Qunit'] == null
                                            ? "-"
                                            : widget.data['item']['Qunit']
                                                .toStringAsFixed(2),
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20),
                                      ),
                                    ],
                                  )
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
                    isOnline: widget.isOnline,
                    padding: 20,
                  ),
                  SizedBox(height: screenHeight * 0.01),

                  // Add any additional widgets or styling as needed
                ],
              ),
            ),
          ),
        ),
      ),
    );
    //);
  }
}
