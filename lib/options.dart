import 'package:checkprice/settings_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:checkprice/DisplayScreen.dart';
import 'package:checkprice/CheckpriceScreen.dart';

import 'package:shared_preferences/shared_preferences.dart';

import 'components/MyDropdownButtonFormField.dart';
import 'components/my_button.dart';
import 'components/my_textfield.dart';

class Option extends StatefulWidget {
  final String? param;
  const Option({super.key, this.param});
  @override
  State<Option> createState() => _OptionState();
}

class _OptionState extends State<Option> {
  void showCartDialog(BuildContext context, String? savedInventory) async {
    final inventoryController = TextEditingController();
    final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

    String errorMessage = '';
    List<dynamic> inventories = [];

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? dbName = prefs.getString('dbName');
    String? ip = prefs.getString('ip');
    String? username = prefs.getString('username');

    // Make an API call with the scanned barcode
    final apiUrl =
        'http://$ip/getInventories/'; // Replace with your API endpoint
    final response =
        await http.get(Uri.parse('$apiUrl?username=$username&dbName=$dbName'));

    if (response.statusCode == 200) {
      // Data was found in the database
      final data =
          jsonDecode(utf8.decode(response.bodyBytes, allowMalformed: true));
      if (data['status'] != false) {
        print(data['result']);
        print(data['status']);
        print(inventories);
        inventories = data['result'];
      }
    } else {}
    //final mediaQueryData = MediaQuery.of(context);

    //final screenHeight = mediaQueryData.size.height;
    //final screenWidth = mediaQueryData.size.width;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.grey[200],
          child: Container(
            padding: EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Add your ComboBox and other widgets here
                    // ...
                    Text(
                      "Select Inventory",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                    ),
                    MyDropdownButtonFormField(
                      items: inventories,
                      value: savedInventory,
                      hintText: MediaQuery.of(context).textScaleFactor > 1.5
                          ? "Select"
                          : "Select Inventory",
                      onChanged: (dynamic selectedInventory) {
                        inventoryController.text =
                            selectedInventory?.toString() ?? '';
                      },
                      validator: (dynamic value) {
                        if (value == null) {
                          return 'Please select an inventory';
                        }
                        return null;
                      },
                    ),
                    Text(
                      errorMessage,
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 14,
                      ),
                    ),
                    // Example buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Container(
                            child: MyButton(
                              onTap: () {
                                //Navigator.of(context).pop();
                                showcartCreate(
                                    context, username!, dbName!, ip!);
                              },
                              buttonName: "create",
                            ),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            child: MyButton(
                              onTap: () async {
                                if (_formKey.currentState!.validate()) {
                                  SharedPreferences prefs =
                                      await SharedPreferences.getInstance();

                                  prefs.setString(
                                      'inventory', inventoryController.text);
                                  scanAndRetrieveData(
                                      context, inventoryController.text, 0);
                                }
                              },
                              buttonName: "Scan",
                            ),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<String> saveDb(
      String username, String dbName, String inventoryName, String ip) async {
    print(username);

    final apiUrl =
        'http://$ip/createInventory/'; // Replace with your API endpoint

    final response = await http.post(
      Uri.parse(
          '$apiUrl?dbName=$dbName&username=$username&inventory=$inventoryName'),
      headers: {
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      // Data was found in the database
      final data =
          jsonDecode(utf8.decode(response.bodyBytes, allowMalformed: true));
      if (data['status'] == true) {
        return "True";
      } else {
        return "False";
      }
    } else {
      return "No connection or Server Down";
    }
  }

  void showcartCreate(
      BuildContext context, String username, String db, String ip) async {
    final nameController = TextEditingController();
    final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
    String errorMessage = '';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.grey[200],
          child: Container(
            padding: EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Create New Inventory",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                    ),
                    // Add your ComboBox and other widgets here
                    // ...
                    MyTextField(
                      controller: nameController,
                      hintText: 'Inventory Name',
                      obscureText: false,
                      validator: (value) {
                        if (value == null ||
                            value.isEmpty ||
                            !RegExp(r'^[a-zA-Z0-9]+$').hasMatch(value)) {
                          return 'Please enter a valid name.\nNo Special characters.';
                        }
                        return null;
                      },
                      flag: 0,
                    ),
                    Text(
                      errorMessage,
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 14,
                      ),
                    ),
                    // Example buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Container(
                            child: MyButton(
                              onTap: () async {
                                if (_formKey.currentState!.validate()) {
                                  if (await saveDb(username, db,
                                          nameController.text, ip) ==
                                      "True") {
                                    scanAndRetrieveData(
                                        context, nameController.text, 1);
                                  } else {
                                    showDialog(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: Text('Inventory Already Exsist'),
                                        content: Text(
                                            'The name of the Inventory already exists.\n' +
                                                'Please Choose another Name'),
                                        actions: [
                                          TextButton(
                                            onPressed: () {
                                              Navigator.of(context)
                                                  .pop(); // Close the AlertDialog
                                            },
                                            child: Text('OK'),
                                          ),
                                        ],
                                      ),
                                    );
                                  }
                                }
                              },
                              buttonName: "create",
                            ),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // Function to handle scanning and data retrieval
  Future<void> scanAndRetrieveData(
      BuildContext context, String inventory, int flag) async {
    String barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
      '#ff6666', // Scanner overlay color
      'Cancel', // Cancel button text
      true, // Show flash icon
      ScanMode.BARCODE, // Scan mode
    );

    // Check if a barcode was successfully scanned
    if (barcodeScanRes != '-1') {
      print(barcodeScanRes);
      print("hohoho");
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? dbName = prefs.getString('dbName');
      String? ip = prefs.getString('ip');
      String? username = prefs.getString('username');
      if (flag == 1) {
        inventory = '$username' + '_$inventory';
        inventory = inventory.replaceAll(RegExp(r"\s+"), "");
        //inventory = combined;
      }
      String? branch = prefs.getString('branch');
      // Make an API call with the scanned barcode
      final apiUrl =
          'http://$ip/getInventoryItem/'; // Replace with your API endpoint
      final response = await http.get(Uri.parse(
          '$apiUrl?itemNumber=$barcodeScanRes&branch=$branch&dbName=$dbName&username=$username&inventory=$inventory'));
      print("hon");
      if (response.statusCode == 200) {
        print("heyyyyyy");
        // Data was found in the database
        final data =
            jsonDecode(utf8.decode(response.bodyBytes, allowMalformed: true));
        print("broooooooooooooooooooo");
        print(data['item']);
        print("rawaaa");

        if (data['item'] != "empty") {
          if (flag == 2) {
            print("hey niga");
            Navigator.of(context).pop();
          }

          print("jjjjjjjjjjjjjj");
          Navigator.of(context)
              .push(MaterialPageRoute(
            builder: (context) =>
                DisplayScreen(data: data, inventory: inventory),
          ))
              .then((value) {
            // Callback function to be executed after the route is popped

            // If value is true, call the showCartDialog function
            showCartDialog(context, null);
          });
        } else {
          Navigator.of(context).pop();

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
                    print("vvvvvvvvvvvvvvvvvvvvvvvvv");
                    scanAndRetrieveData(context, inventory, 2);
                    //blaaaaaaaaaaaaaaaaaaaa
                  },
                  child: Text('Scan Again'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    //blaaaaaaaaaaaaaaaaaaaa
                  },
                  child: Text('Cancel'),
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

  // Function to handle scanning and data retrieval
  Future<void> scanAndRetrieveDataPrice(BuildContext context, int flag) async {
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
        final data =
            jsonDecode(utf8.decode(response.bodyBytes, allowMalformed: true));
        if (data['item'] != "empty") {
          if (flag == 1) {
            Navigator.of(context).pop();
          }
          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => CheckpriceScreen(data: data),
          ));
        } else {
          if (flag == 1) {
            Navigator.of(context).pop();
          }

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
                    print("vvvvvvvvvvvvvvvvvvvvvvvvv");
                    scanAndRetrieveDataPrice(context, 1);
                    //blaaaaaaaaaaaaaaaaaaaa
                  },
                  child: Text('Scan Again'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    //blaaaaaaaaaaaaaaaaaaaa
                  },
                  child: Text('Cancel'),
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

  // Function to navigate to the settings page
  void navigateToSettings(BuildContext context) {
    // Navigate to the settings page
    // Replace 'SettingsScreen' with the actual screen you want to navigate to
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => SettingsScreen(),
    ));
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    print("shou l wade3");
    // Use Future.delayed to schedule the execution after initState has completed
    Future.delayed(Duration.zero, () async {
      // Retrieve the arguments

      // Check if arguments are not null and of the expected type
      if (widget.param != null) {
        print("dddddddd");
        // Call your function with the passed value
        SharedPreferences prefs = await SharedPreferences.getInstance();
        String? savedInventory = prefs.getString('inventory');
        print("------------------------------");
        print(savedInventory);
        showCartDialog(context, savedInventory);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final mediaQueryData = MediaQuery.of(context);

    final screenHeight = mediaQueryData.size.height;
    //final screenWidth = mediaQueryData.size.width;

    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        title: Text('Options'),
        actions: [
          // Add the settings icon to the AppBar
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              // Call the function to navigate to the settings page
              navigateToSettings(context);
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min, // Set mainAxisSize to min

          children: [
            MyButton(
              onTap: () {
                //here i want to add a cart that opens contains a comboBox getting data from api and two buttons
                showCartDialog(context, null);
              },
              buttonName: "hand Collected",
            ),
            SizedBox(height: screenHeight * 0.05),
            MyButton(
              onTap: () {
                scanAndRetrieveDataPrice(context, 0);
              },
              buttonName: "checkPrice",
            ),
          ],
        ),
      ),
    );
  }
}
