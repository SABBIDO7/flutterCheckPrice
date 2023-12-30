//import 'package:checkprice/components/customTable.dart';
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
  void showCartDialog(String? savedInventory) async {
    final inventoryController = TextEditingController(text: savedInventory);
    final barcodeController = TextEditingController();
    final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

    String errorMessage = '';
    List<dynamic> inventories = [];

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? dbName = prefs.getString('dbName');
    String? ip = prefs.getString('ip');
    String? username = prefs.getString('username');
    String? branch = prefs.getString('branch');

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
        return AlertDialog(
          backgroundColor: Colors.grey[200],
          content: Container(
            width: MediaQuery.of(context).size.width,
            padding: EdgeInsets.all(2),
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Add your ComboBox and other widgets here
                    // ...
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Select Inventory",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        Text(
                          "Branch: $branch",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        Text(
                          "$username",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ],
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
                      flag: 1,
                      username: username,
                    ),
                    Text(
                      errorMessage,
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 14,
                      ),
                    ),
                    MyTextField(
                      controller: barcodeController,
                      hintText: 'Barcode Number',
                      obscureText: false,
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
                              onTap: () {
                                Navigator.of(context).pop();
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
                                print("shoubek");
                                print(inventoryController.text);
                                if (_formKey.currentState!.validate()) {
                                  SharedPreferences prefs =
                                      await SharedPreferences.getInstance();

                                  prefs.setString(
                                      'inventory', inventoryController.text);
                                  scanAndRetrieveData(
                                      context,
                                      inventoryController.text,
                                      0,
                                      barcodeController.text);
                                }
                              },
                              buttonName: "Scan",
                            ),
                          ),
                        ),
                      ],
                    ),
                    // SizedBox(
                    //   height: MediaQuery.of(context).size.height * 0.01,
                    // ),
                    // Row(
                    //   mainAxisAlignment: MainAxisAlignment.center,
                    //   children: [
                    //     Expanded(
                    //       child: Container(
                    //         child: MyButton(
                    //           onTap: () async {
                    //             if (_formKey.currentState!.validate()) {
                    //               SharedPreferences prefs =
                    //                   await SharedPreferences.getInstance();

                    //               prefs.setString(
                    //                   'inventory', inventoryController.text);
                    //               scanAndRetrieveData(
                    //                   context,
                    //                   inventoryController.text,
                    //                   0,
                    //                   barcodeController.text);
                    //             }
                    //           },
                    //           buttonName: "Barcode Input",
                    //         ),
                    //       ),
                    //     ),
                    //   ],
                    // )
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
        print(data['result'][0]);
        String name = data['result'][0];
        print(name);
        return name;
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
            width: (MediaQuery.of(context).size.width),
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
                                  String inventory_name = await saveDb(
                                      username, db, nameController.text, ip);
                                  if (inventory_name != "False") {
                                    /* scanAndRetrieveData(
                                        context, inventory_name, 1, "");*/
                                    Navigator.of(context).pop();
                                    SharedPreferences prefs =
                                        await SharedPreferences.getInstance();

                                    prefs.setString(
                                        'inventory', inventory_name);
                                    String? savedInventory =
                                        prefs.getString('inventory');
                                    showCartDialog(savedInventory);
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

  void showCartDialogCheckPrice() async {
    final barcodeController = TextEditingController();
    final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

    String errorMessage = '';

    SharedPreferences prefs = await SharedPreferences.getInstance();

    String? username = prefs.getString('username');
    String? branch = prefs.getString('branch');

    // Make an API call with the scanned barcode

    //final mediaQueryData = MediaQuery.of(context);

    //final screenHeight = mediaQueryData.size.height;
    //final screenWidth = mediaQueryData.size.width;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.grey[200],
          content: Container(
            width: MediaQuery.of(context).size.width,
            padding: EdgeInsets.all(2),
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Add your ComboBox and other widgets here
                    // ...
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Branch: $branch",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        Text(
                          "$username",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ],
                    ),

                    MyTextField(
                      controller: barcodeController,
                      hintText: 'Barcode Number',
                      obscureText: false,
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
                                scanAndRetrieveDataPrice(
                                    context, 1, barcodeController.text);
                              },
                              buttonName: "Scan",
                            ),
                          ),
                        ),
                      ],
                    ),
                    // SizedBox(
                    //   height: MediaQuery.of(context).size.height * 0.01,
                    // ),
                    // Row(
                    //   mainAxisAlignment: MainAxisAlignment.center,
                    //   children: [
                    //     Expanded(
                    //       child: Container(
                    //         child: MyButton(
                    //           onTap: () async {
                    //             if (_formKey.currentState!.validate()) {
                    //               SharedPreferences prefs =
                    //                   await SharedPreferences.getInstance();

                    //               prefs.setString(
                    //                   'inventory', inventoryController.text);
                    //               scanAndRetrieveData(
                    //                   context,
                    //                   inventoryController.text,
                    //                   0,
                    //                   barcodeController.text);
                    //             }
                    //           },
                    //           buttonName: "Barcode Input",
                    //         ),
                    //       ),
                    //     ),
                    //   ],
                    // )
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
      BuildContext context, String inventory, int flag, String input) async {
    String barcodeScanRes = input;
    if (input == "") {
      barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
        '#ff6666', // Scanner overlay color
        'Cancel', // Cancel button text
        true, // Show flash icon
        ScanMode.BARCODE, // Scan mode
      );
    }

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? dbName = prefs.getString('dbName');
    String? ip = prefs.getString('ip');
    String? username = prefs.getString('username');
    String? inventorytst = prefs.getString('inventory');
    print(inventory);
    print("sakados");
    // if (flag == 1) {
    //   inventory = 'dc_' + '$username' + '_$inventory';
    //   inventory = inventory.replaceAll(RegExp(r"\s+"), "");
    //   //inventory = combined;
    // }
    print("lkooooo");
    prefs.setString('inventory', inventory);
    // Check if a barcode was successfully scanned
    if (barcodeScanRes != '-1') {
      print(barcodeScanRes);
      print("hohoho");

      String? branch = prefs.getString('branch');
      print("///////////////////////////////");
      print(inventorytst);

      print("///////////////////////////////");

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
            //Navigator.of(context).pop();
          }

          print("jjjjjjjjjjjjjj");
          Navigator.of(context).pop();

          Navigator.of(context)
              .push(MaterialPageRoute(
            builder: (context) => DisplayScreen(
                data: data, inventory: inventory, username: username),
            //CustomTable(),
          ))
              .then((value) async {
            // Callback function to be executed after the route is popped
            print("dxxxxxxx");
            // Call your function with the passed value
            SharedPreferences prefs = await SharedPreferences.getInstance();
            String? savedInventory = prefs.getString('inventory');
            print("------------------------------");
            print(savedInventory);
            showCartDialog(savedInventory);
            // If value is true, call the showCartDialog function
          });
        } else {
          Navigator.of(context).pop();

          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => AlertDialog(
              title: Text('Data Not Found'),
              content: input != ""
                  ? Text(
                      'The scanned item barcode was not found in this branch.\nThe scanned Item Number: $input')
                  : Text(
                      'The scanned item barcode was not found in this branch.'),
              actions: [
                TextButton(
                  onPressed: () {
                    print("vvvvvvvvvvvvvvvvvvvvvvvvv");
                    //scanAndRetrieveData(context, inventory, 2, input);
                    Navigator.of(context).pop();
                    showCartDialog(inventory);
                    //blaaaaaaaaaaaaaaaaaaaa
                  },
                  child: Text('Scan Again'),
                ),
                // TextButton(
                //   onPressed: () {
                //     Navigator.of(context).pop();
                //     //blaaaaaaaaaaaaaaaaaaaa
                //   },
                //   child: Text('Cancel'),
                // ),
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
    } else if (barcodeScanRes == '-1') {
      print("fetttttttOpP");

      Navigator.of(context).pop();
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? savedInventory = prefs.getString('inventory');
      print("------------------------------");
      print(savedInventory);
      showCartDialog(savedInventory);
    }
  }

  // Function to handle scanning and data retrieval
  Future<void> scanAndRetrieveDataPrice(
      BuildContext context, int flag, String input) async {
    String barcodeScanRes = input;
    if (input == "") {
      barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
        '#ff6666', // Scanner overlay color
        'Cancel', // Cancel button text
        true, // Show flash icon
        ScanMode.BARCODE, // Scan mode
      );
    }

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
          } else {
            Navigator.of(context).pop();
          }

          Navigator.of(context)
              .push(MaterialPageRoute(
            builder: (context) => CheckpriceScreen(data: data),
            //CustomTable(),
          ))
              .then((value) async {
            // Callback function to be executed after the route is popped
            print("dxxxxxxx");
            // Call your function with the passed value

            showCartDialogCheckPrice();
            // If value is true, call the showCartDialog function
          });
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
                    Navigator.of(context).pop();
                    showCartDialogCheckPrice();
                    //blaaaaaaaaaaaaaaaaaaaa
                  },
                  child: Text('Scan Again'),
                ),
                // TextButton(
                //   onPressed: () {
                //     Navigator.of(context).pop();
                //     //blaaaaaaaaaaaaaaaaaaaa
                //   },
                //   child: Text('Cancel'),
                // ),
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

      var arguments = ModalRoute.of(context)?.settings.arguments;

      print("thissssss");
      print(arguments);
      print("shish");
      // Check if arguments are not null and of the expected type
      if (arguments == 2) {
        print("dddddddd");
        // Call your function with the passed value
        SharedPreferences prefs = await SharedPreferences.getInstance();
        String? savedInventory = prefs.getString('inventory');
        print("------------------------------");
        print(savedInventory);
        showCartDialog(savedInventory);
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
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              child: Image(
                image: AssetImage('assets/paradoxlogo.jpg'),
                height: 350,
                width: 350,
                // Adjust the width as needed
              ),
            ),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min, // Set mainAxisSize to min

                children: [
                  MyButton(
                    onTap: () {
                      //here i want to add a cart that opens contains a comboBox getting data from api and two buttons
                      showCartDialog(null);
                    },
                    buttonName: "hand Collected",
                  ),
                  SizedBox(height: screenHeight * 0.05),
                  MyButton(
                    onTap: () {
                      showCartDialogCheckPrice();
                    },
                    buttonName: "checkPrice",
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
