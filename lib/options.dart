//import 'package:checkprice/components/customTable.dart';

import 'package:checkprice/settings_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:checkprice/DisplayScreen.dart';
import 'package:checkprice/CheckpriceScreen.dart';

// ignore: depend_on_referenced_packages
import 'package:shared_preferences/shared_preferences.dart';

import 'components/MyDropdownButtonFormField.dart';
import 'components/my_button.dart';
import 'components/my_textfield.dart';
import 'offline/sqllite.dart';

class Option extends StatefulWidget {
  final String? param;

  const Option({super.key, this.param});
  @override
  State<Option> createState() => _OptionState();
}

class _OptionState extends State<Option> {
  late bool isOnlineFlag = false;
  String? checkPricePage;
  String? qtyToColPage;
  String? deleteInv;
  Future<bool> UploadData(String inventory) async {
    try {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
        barrierDismissible: false,
      );
      // Sync data
      Color backgroundColor = const Color.fromRGBO(103, 58, 183, 1);
      Widget content = const Text("");
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? username = prefs.getString('username');
      bool finalres;
      if (await YourDataSync().uploadData(username ?? "", inventory) == false) {
        backgroundColor = Colors.red;
        content = const Text("Error in Uploading Data");
        finalres = false;
      } else {
        backgroundColor = Colors.deepPurple;
        content = const Text("Data Uploaded Successfully");
        finalres = true;
      }
      final snackBar = SnackBar(
        content: content,
        duration: const Duration(seconds: 2),
        backgroundColor: backgroundColor,
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);

      Navigator.of(context).pop();
      return finalres;
    } catch (e) {
      return false;
    }
  }

  saveItemInDb(String itemNumber, String itemName, String inventory,
      String? dbName, String? branch, String handQuantity) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? dbName = prefs.getString('dbName');
    String? ip = prefs.getString('ip');
    String? inventory = prefs.getString('inventory');
    String? branch = prefs.getString('branch');

    try {
      if (isOnlineFlag == true) {
        // Make an API call with the scanned barcode
        final apiUrl =
            'http://$ip/createItem/'; // Replace with your API endpoint
        final response = await http.post(Uri.parse(
            '$apiUrl?itemNumber=$itemNumber&itemName=$itemName&inventory=$inventory&dbName=$dbName&branch=$branch&handQuantity=$handQuantity'));

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
          return "False";
        }
      } else {
        Map<dynamic, Object?> data = await YourDatabaseHelper().createItem(
            itemNumber,
            itemName,
            inventory ?? "",
            branch ?? "",
            double.parse(handQuantity));
        print(data);
        if (data["status"] == true) {
          return "True";
        } else {
          return "False";
        }
      }
    } catch (e) {
      // Handle the exception here
      print("Error: $e");
      return "False";
    }
  }

  showCartDialogCreateItem(String barcodeCode, String inventory, String? dbName,
      String? branch) async {
    TextEditingController inputController = TextEditingController(text: '1');
    final barcodeController = TextEditingController(text: barcodeCode);
    final itemNameController = TextEditingController();
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();
    String errorMessage = '';
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            "Create Item",
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: MediaQuery.of(context).size.width > 320 ? 18 : 14),
          ),
          backgroundColor: Colors.grey[200],
          content: Container(
            width: MediaQuery.of(context).size.width,
            padding: const EdgeInsets.all(2),
            child: SingleChildScrollView(
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    // Add your ComboBox and other widgets here
                    // ...

                    MyTextField(
                        controller: barcodeController,
                        hintText: 'Barcode Number',
                        obscureText: false,
                        flag: 0,
                        readOnly: true),
                    Text(
                      errorMessage,
                      style: const TextStyle(
                        color: Colors.red,
                        fontSize: 12,
                      ),
                    ),
                    MyTextField(
                      controller: itemNameController,
                      hintText: 'Item Name',
                      obscureText: false,
                      flag: 0,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a valid username';
                        }
                        if (value.length > 120) {
                          return 'Username cannot exceed\n120 characters';
                        }
                        return null;
                      },
                    ),
                    Text(
                      errorMessage,
                      style: const TextStyle(
                        color: Colors.red,
                        fontSize: 12,
                      ),
                    ),
                    MyTextField(
                        controller: inputController,
                        hintText: 'Hand Quantity Collected',
                        obscureText: false,
                        validator: (value) {
                          if (value == null ||
                              value.isEmpty ||
                              !RegExp(r'^-?\d+(\.\d+)?$').hasMatch(value)) {
                            return 'Please enter a\nvalid hand quantity';
                          }
                          return null;
                        },
                        flag: 1),
                    Text(
                      errorMessage,
                      style: const TextStyle(
                        color: Colors.red,
                        fontSize: 12,
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
                                if (formKey.currentState!.validate()) {
                                  // scanAndRetrieveData(
                                  //       context,
                                  //       inventory,
                                  //       0,
                                  //       barcodeController.text);
                                  if (await saveItemInDb(
                                          barcodeCode,
                                          itemNameController.text,
                                          inventory,
                                          dbName,
                                          branch,
                                          inputController.text) ==
                                      "True") {
                                    // Validation passed, make the update call

                                    Navigator.of(context).pop();
                                    showCartDialog(inventory, "");
                                  } else {
                                    showDialog(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: const Text('Insertion Failed'),
                                        content: const Text(
                                            'Server Request Error.\n'
                                            'Please Check your WIFI connection'),
                                        actions: [
                                          TextButton(
                                            onPressed: () {
                                              Navigator.of(context)
                                                  .pop(); // Close the AlertDialog
                                            },
                                            child: const Text('OK'),
                                          ),
                                        ],
                                      ),
                                    );
                                  }
                                }
                              },
                              buttonName: "create",
                              isOnline: isOnlineFlag,
                              padding: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          insetPadding: const EdgeInsets.all(10),
        );
      },
    );
  }

  void showCartDialog(String? savedInventory, String barcodeVariable) async {
    final inventoryController = TextEditingController(text: savedInventory);
    final barcodeController = barcodeVariable == ""
        ? TextEditingController()
        : TextEditingController(text: barcodeVariable);
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();

    String errorMessage = '';
    List<dynamic> inventories = [];

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? dbName = prefs.getString('dbName');
    String? ip = prefs.getString('ip');
    String? username = prefs.getString('username');
    String? branch = prefs.getString('branch');
    bool? isOnline = prefs.getBool('isOnline');

    try {
      if (isOnline == true) {
        // Make an API call with the scanned barcode
        final apiUrl =
            'http://$ip/getInventories/'; // Replace with your API endpoint
        final response = await http
            .get(Uri.parse('$apiUrl?username=$username&dbName=$dbName'));

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
        }
      }
      if (isOnline == false) {
        List<Map<String, dynamic>> tables =
            await YourDatabaseHelper().getInventories(username);
        inventories = tables;
        print("-------------------$inventories");
      }

      //final mediaQueryData = MediaQuery.of(context);

      //final screenHeight = mediaQueryData.size.height;
      //final screenWidth = mediaQueryData.size.width;
      showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Colors.grey[200],
            title: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Select Inventory",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize:
                          MediaQuery.of(context).size.width > 320 ? 18 : 16),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the dialog
                  },
                  child: Icon(
                    Icons.close,
                    color:
                        isOnlineFlag == true ? Colors.deepPurple : Colors.grey,
                  ), // "X" icon
                ),
              ],
            ),
            content: Container(
              width: MediaQuery.of(context).size.width,
              padding: const EdgeInsets.all(2),
              child: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      // Add your ComboBox and other widgets here
                      // ...

                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Center(
                              child: Text(
                                "Inventory",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize:
                                        MediaQuery.of(context).size.width > 320
                                            ? 16
                                            : 14),
                              ),
                            ),
                          ),
                          Flexible(
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Column(
                                children: [
                                  Text(
                                    "Branch: $branch",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize:
                                            MediaQuery.of(context).size.width >
                                                    320
                                                ? 16
                                                : 14),
                                  ),
                                  isOnlineFlag == true
                                      ? Container()
                                      : Center(
                                          child: Text(
                                            "OFFLINE",
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: MediaQuery.of(context)
                                                            .size
                                                            .width >
                                                        320
                                                    ? 16
                                                    : 14),
                                          ),
                                        ),
                                ],
                              ),
                            ),
                          ),
                          Flexible(
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Center(
                                child: Text(
                                  "$username",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize:
                                          MediaQuery.of(context).size.width >
                                                  320
                                              ? 16
                                              : 14),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 25,
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
                        style: const TextStyle(
                          color: Colors.red,
                          fontSize: 14,
                        ),
                      ),
                      MyTextField(
                        controller: barcodeController,
                        hintText: 'Barcode Number',
                        obscureText: false,
                        flag: 0,
                        focusVar: true,
                        onFieldSubmitted: () async {
                          if (formKey.currentState!.validate()) {
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
                      ),
                      Text(
                        errorMessage,
                        style: const TextStyle(
                          color: Colors.red,
                          fontSize: 14,
                        ),
                      ),
                      Container(
                        child: MyButton(
                          onTap: () async {
                            print("shoubek");
                            print(inventoryController.text);
                            if (formKey.currentState!.validate()) {
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
                          isOnline: isOnlineFlag,
                          padding: 30,
                        ),
                      ),
                      const SizedBox(
                        height: 15,
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
                                isOnline: isOnlineFlag,
                                padding: 20,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              child: MyButton(
                                onTap: () async {
                                  if (deleteInv == "Y") {
                                    if (formKey.currentState!.validate()) {
                                      if (isOnlineFlag == true) {
                                        bool deleteConfirm = await showDialog(
                                          context: context,
                                          barrierDismissible: false,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              title: const Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  // Add some spacing between icon and text
                                                  Text('Delete Table'),
                                                  Icon(Icons.warning,
                                                      color: Colors
                                                          .red), // Alert icon
                                                ],
                                              ),
                                              content: Text(
                                                  'Are you sure you want to delete?\nTable:${inventoryController.text}'),
                                              actions: <Widget>[
                                                TextButton(
                                                  onPressed: () {
                                                    Navigator.of(context)
                                                        .pop(); // Close the dialog
                                                  },
                                                  child: const Text('Cancel'),
                                                ),
                                                TextButton(
                                                  onPressed: () async {
                                                    // Call the delete function
                                                    if (await deleteInventory(
                                                            inventoryController
                                                                .text) ==
                                                        "True") {
                                                      SharedPreferences prefs =
                                                          await SharedPreferences
                                                              .getInstance();
                                                      String? inventory =
                                                          prefs.getString(
                                                              "inventory");
                                                      if (inventoryController
                                                              .text ==
                                                          inventory) {
                                                        prefs.setString(
                                                            'inventory', "");
                                                      }
                                                      Navigator.of(context).pop(
                                                          true); // Close the dialog
                                                    } else {
                                                      Navigator.of(context)
                                                          .pop(false);
                                                    }
                                                  },
                                                  child: const Text('Delete'),
                                                ),
                                              ],
                                              insetPadding:
                                                  const EdgeInsets.all(10),
                                            );
                                          },
                                        );
                                        if (deleteConfirm == true) {
                                          Navigator.of(context).pop();
                                          const snackBar = SnackBar(
                                            content: Text(
                                              'Table Deleted Successfully.',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 14),
                                            ),
                                            duration: Duration(seconds: 2),
                                            backgroundColor: Colors.deepPurple,
                                            padding: EdgeInsets.all(20),
                                          );

                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(snackBar);
                                        } else if (deleteConfirm == false) {
                                          const snackBar = SnackBar(
                                            content: Text(
                                              'Error while Deleting the Table.',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 14),
                                            ),
                                            duration: Duration(seconds: 2),
                                            backgroundColor: Colors.red,
                                            padding: EdgeInsets.all(20),
                                          );

                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(snackBar);
                                        }
                                      } else {
                                        const snackBar = SnackBar(
                                          content: Text(
                                            'Cannot Delete Table in Offline Mode.',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14),
                                          ),
                                          duration: Duration(seconds: 2),
                                          backgroundColor: Colors.red,
                                          padding: EdgeInsets.all(20),
                                        );

                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(snackBar);
                                      }
                                    }
                                  } else {}
                                },
                                buttonName: "Delete",
                                isOnline: isOnlineFlag,
                                padding: 20,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 5,
                      ),

                      isOnlineFlag == false
                          ? Column(
                              children: [
                                MyButton(
                                  onTap: () async {
                                    //bool isOnline = await isOnlineStatus();
                                    if (formKey.currentState!.validate()) {
                                      bool isConnected =
                                          await YourDataSync().isConnected();

                                      if (isConnected) {
                                        bool confirmUpload = await showDialog(
                                          barrierDismissible: false,
                                          context: context,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              title: const Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  // Add some spacing between icon and text
                                                  Text('Upload Data'),
                                                  Icon(Icons.warning,
                                                      color: Colors
                                                          .red), // Alert icon
                                                ],
                                              ),
                                              content: const Text(
                                                'Are you sure you want to upload data?',
                                                style: TextStyle(fontSize: 16),
                                              ),
                                              actions: <Widget>[
                                                TextButton(
                                                  onPressed: () {
                                                    Navigator.of(context)
                                                        .pop(false); // Cancel
                                                  },
                                                  child: const Text('Cancel'),
                                                ),
                                                TextButton(
                                                  onPressed: () {
                                                    Navigator.of(context)
                                                        .pop(true); // Confirm
                                                  },
                                                  child: const Text('Upload'),
                                                ),
                                              ],
                                              insetPadding:
                                                  const EdgeInsets.all(10),
                                            );
                                          },
                                        );

                                        // Check if the user confirmed the sync
                                        if (confirmUpload == true) {
                                          bool result = await UploadData(
                                              inventoryController.text);
                                          if (result == true) {
                                            bool confirmDelete =
                                                await showDialog(
                                              barrierDismissible: false,
                                              context: context,
                                              builder: (BuildContext context) {
                                                return AlertDialog(
                                                  title: const Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      // Add some spacing between icon and text
                                                      Text('Delete Data'),
                                                      Icon(Icons.warning,
                                                          color: Colors
                                                              .red), // Alert icon
                                                    ],
                                                  ),
                                                  content: const Text(
                                                    'Are you sure you want to DELETE OFFLNE DATA in this DEVICE?',
                                                    style:
                                                        TextStyle(fontSize: 16),
                                                  ),
                                                  actions: <Widget>[
                                                    TextButton(
                                                      onPressed: () {
                                                        Navigator.of(context)
                                                            .pop(
                                                                false); // Cancel
                                                      },
                                                      child:
                                                          const Text('Cancel'),
                                                    ),
                                                    TextButton(
                                                      onPressed: () {
                                                        Navigator.of(context)
                                                            .pop(
                                                                true); // Confirm
                                                      },
                                                      child:
                                                          const Text('Delete'),
                                                    ),
                                                  ],
                                                  insetPadding:
                                                      const EdgeInsets.all(10),
                                                );
                                              },
                                            );
                                            if (confirmDelete == true) {
                                              await YourDatabaseHelper()
                                                  .deleteTable(dbName ?? "",
                                                      "${inventoryController.text}");
                                              Navigator.of(context).pop();
                                            }
                                          }
                                        }
                                      } else {
                                        const snackBar = SnackBar(
                                          content: Text(
                                            'Cannot Upload Data without WIFI.',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14),
                                          ),
                                          duration: Duration(seconds: 2),
                                          backgroundColor: Colors.grey,
                                          padding: EdgeInsets.all(20),
                                        );

                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(snackBar);
                                      }
                                    }
                                  },
                                  buttonName: "Upload Data",
                                  isOnline: isOnlineFlag,
                                  padding: 15,
                                ),
                                const SizedBox(
                                  height: 15,
                                ),
                              ],
                            )
                          : Container(),

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
            insetPadding: const EdgeInsets.all(10),
          );
        },
      );
    } catch (e) {
      // Data not found in the database
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
          insetPadding: const EdgeInsets.all(10),
        ),
      );
    }
  }

  Future<String> saveDb(
      String username, String dbName, String inventoryName, String ip) async {
    print(username);

    try {
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
        return "False";
      }
    } catch (e) {
      // Data not found in the database
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
          insetPadding: const EdgeInsets.all(10),
        ),
      );
      return "False";
    }
  }

  Future<String> deleteInventory(String inventory) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? dbName = prefs.getString('dbName');
    String? ip = prefs.getString('ip');
    bool? isOnline = prefs.getBool('isOnline');
    if (isOnline == true) {
      try {
        final apiUrl =
            'http://$ip/deleteInventory/'; // Replace with your API endpoint

        final response = await http.post(
          Uri.parse('$apiUrl?dbName=$dbName&inventory=$inventory'),
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
          return "False";
        }
      } catch (e) {
        // Data not found in the database
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Inventory Not Deleted'),
            content: const Text('Request error.\nCheck your WIFI.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
              ),
            ],
            insetPadding: const EdgeInsets.all(10),
          ),
        );
        return "False";
      }
    }
    return "False";
  }

  void showcartCreate(
      BuildContext context, String username, String db, String ip) async {
    final nameController = TextEditingController();
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();
    String errorMessage = '';

    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.grey[200],
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Text(
                    "Create New Inventory",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                ],
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // Close the dialog
                    },
                    child: Icon(
                      Icons.close,
                      color: isOnlineFlag == true
                          ? Colors.deepPurple
                          : Colors.grey,
                    ), // "X" icon
                  ),
                ],
              ),
            ],
          ),
          content: Container(
            width: (MediaQuery.of(context).size.width),
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                        if (value.length > 10) {
                          return 'Inventory cannot acceed\n10 characters';
                        }
                        return null;
                      },
                      flag: 0,
                    ),
                    Text(
                      errorMessage,
                      style: const TextStyle(
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
                                if (formKey.currentState!.validate()) {
                                  SharedPreferences prefs =
                                      await SharedPreferences.getInstance();
                                  bool? isOnline = prefs.getBool('isOnline');
                                  if (isOnline == true) {
                                    String inventoryName = await saveDb(
                                        username, db, nameController.text, ip);
                                    if (inventoryName != "False") {
                                      /* scanAndRetrieveData(
                                        context, inventory_name, 1, "");*/
                                      Navigator.of(context).pop();

                                      prefs.setString(
                                          'inventory', inventoryName);
                                      String? savedInventory =
                                          prefs.getString('inventory');
                                      showCartDialog(savedInventory, "");
                                    } else {
                                      showDialog(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          title: const Text(
                                              'Inventory Already Exsist'),
                                          content: const Text(
                                              'The name of the Inventory already exists.\n'
                                              'Please Choose another Name'),
                                          actions: [
                                            TextButton(
                                              onPressed: () {
                                                Navigator.of(context)
                                                    .pop(); // Close the AlertDialog
                                              },
                                              child: const Text('OK'),
                                            ),
                                          ],
                                        ),
                                      );
                                    }
                                  }
                                  if (isOnline == false) {
                                    String inventoryName = await YourDataSync()
                                        .databaseHelper
                                        .createInventoryTable(
                                            username, db, nameController.text);
                                    if (inventoryName != "False") {
                                      /* scanAndRetrieveData(
                                        context, inventory_name, 1, "");*/
                                      Navigator.of(context).pop();

                                      prefs.setString(
                                          'inventory', inventoryName);
                                      String? savedInventory =
                                          prefs.getString('inventory');
                                      print("===============$savedInventory");
                                      showCartDialog(savedInventory, "");
                                    } else {
                                      showDialog(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          title: const Text(
                                              'Inventory Already Exsist'),
                                          content: const Text(
                                              'The name of the Inventory already exists.\n'
                                              'Please Choose another Name'),
                                          actions: [
                                            TextButton(
                                              onPressed: () {
                                                Navigator.of(context)
                                                    .pop(); // Close the AlertDialog
                                              },
                                              child: const Text('OK'),
                                            ),
                                          ],
                                        ),
                                      );
                                    }
                                  }
                                }
                              },
                              buttonName: "create",
                              isOnline: isOnlineFlag,
                              padding: 20,
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
          insetPadding: const EdgeInsets.all(10),
        );
      },
    );
  }

  void showCartDialogCheckPrice() async {
    final barcodeController = TextEditingController();
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();

    String errorMessage = '';

    SharedPreferences prefs = await SharedPreferences.getInstance();

    String? username = prefs.getString('username');
    String? branch = prefs.getString('branch');

    // Make an API call with the scanned barcode

    //final mediaQueryData = MediaQuery.of(context);

    //final screenHeight = mediaQueryData.size.height;
    //final screenWidth = mediaQueryData.size.width;
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.grey[200],
          title: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Check Price",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize:
                        MediaQuery.of(context).size.width > 320 ? 18 : 16),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                },
                child: Icon(
                  Icons.close,
                  color: isOnlineFlag == true ? Colors.deepPurple : Colors.grey,
                ), // "X" icon
              ),
            ],
          ),
          content: Container(
            width: MediaQuery.of(context).size.width,
            padding: const EdgeInsets.all(2),
            child: SingleChildScrollView(
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Add your ComboBox and other widgets here
                    // ...
                    // Row(
                    //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    //   children: [
                    //     Text(
                    //       "Branch: $branch",
                    //       style: TextStyle(
                    //           fontWeight: FontWeight.bold, fontSize: 16),
                    //     ),
                    //     Text(
                    //       "$username",
                    //       style: TextStyle(
                    //           fontWeight: FontWeight.bold, fontSize: 16),
                    //     ),
                    //   ],
                    // ),

                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Center(
                              child: Text(
                                "Branch: $branch",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize:
                                        MediaQuery.of(context).size.width > 320
                                            ? 16
                                            : 14),
                              ),
                            ),
                          ),
                        ),
                        isOnlineFlag == true
                            ? Container()
                            : Flexible(
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Center(
                                    child: Text(
                                      "OFFLINE",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: MediaQuery.of(context)
                                                      .size
                                                      .width >
                                                  320
                                              ? 16
                                              : 14),
                                    ),
                                  ),
                                ),
                              ),
                        Flexible(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Center(
                              child: Text(
                                "$username",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize:
                                        MediaQuery.of(context).size.width > 320
                                            ? 16
                                            : 14),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    MyTextField(
                        controller: barcodeController,
                        hintText: 'Barcode Number',
                        obscureText: false,
                        flag: 0,
                        focusVar: true,
                        onFieldSubmitted: () async {
                          scanAndRetrieveDataPrice(
                              context, 1, barcodeController.text);
                        }),
                    Text(
                      errorMessage,
                      style: const TextStyle(
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
                              isOnline: isOnlineFlag,
                              padding: 30,
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
          insetPadding: const EdgeInsets.all(10),
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
      try {
        if (isOnlineFlag == true) {
          // Make an API call with the scanned barcode
          final apiUrl =
              'http://$ip/getInventoryItem/'; // Replace with your API endpoint
          final response = await http.get(Uri.parse(
              '$apiUrl?itemNumber=$barcodeScanRes&branch=$branch&dbName=$dbName&username=$username&inventory=$inventory'));
          print("hon");
          if (response.statusCode == 200) {
            print("heyyyyyy");
            // Data was found in the database
            final data = jsonDecode(
                utf8.decode(response.bodyBytes, allowMalformed: true));
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
                  data: data,
                  inventory: inventory,
                  username: username,
                  isOnline: isOnlineFlag,
                ),
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
                showCartDialog(savedInventory, "");
                // If value is true, call the showCartDialog function
              });
            } else {
              Navigator.of(context).pop();

              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => AlertDialog(
                  title: const Text('Data Not Found'),
                  content: Text(
                      'The scanned item barcode was not found.\nThe scanned Item Number: $barcodeScanRes'),
                  actions: [
                    TextButton(
                      onPressed: () {
                        print("vvvvvvvvvvvvvvvvvvvvvvvvv");
                        //scanAndRetrieveData(context, inventory, 2, input);
                        Navigator.of(context).pop();
                        showCartDialog(inventory, "");
                        //blaaaaaaaaaaaaaaaaaaaa
                      },
                      child: const Text('Scan Again'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        showCartDialogCreateItem(
                            barcodeScanRes, inventory, dbName, branch);
                        //blaaaaaaaaaaaaaaaaaaaa
                      },
                      child: const Text('Create Item'),
                    ),
                  ],
                  insetPadding: const EdgeInsets.all(10),
                ),
              );
            }
            // Navigate to a new screen to display the data
          }
        } else {
          print("fetttttttttttttttt offlie inv");
          Map<String, dynamic> data = await YourDatabaseHelper()
              .getInventoryItem(barcodeScanRes, branch ?? "", inventory);
          print(data);
          print(data["item"]);
          print("dataaaa-----------------");
          if (data["item"] != "{}") {
            print(data["item"]);
            print("finally");
            Navigator.of(context).pop();

            Navigator.of(context)
                .push(MaterialPageRoute(
              builder: (context) => DisplayScreen(
                data: data,
                inventory: inventory,
                username: username,
                isOnline: isOnlineFlag,
              ),
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
              showCartDialog(savedInventory, "");
              // If value is true, call the showCartDialog function
            });
          } else {
            Navigator.of(context).pop();

            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) => AlertDialog(
                title: const Text('Data Not Found'),
                content: Text(
                    'The scanned item barcode was not found.\nThe scanned Item Number: $barcodeScanRes'),
                actions: [
                  TextButton(
                    onPressed: () {
                      print("vvvvvvvvvvvvvvvvvvvvvvvvv");
                      //scanAndRetrieveData(context, inventory, 2, input);
                      Navigator.of(context).pop();
                      showCartDialog(inventory, "");
                      //blaaaaaaaaaaaaaaaaaaaa
                    },
                    child: const Text('Scan Again'),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      showCartDialogCreateItem(
                          barcodeScanRes, inventory, dbName, branch);
                      //blaaaaaaaaaaaaaaaaaaaa
                    },
                    child: const Text('Create Item'),
                  ),
                ],
                insetPadding: const EdgeInsets.all(10),
              ),
            );
          }
        }
      } catch (e) {
        // Data not found in the database
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Data Not Found'),
            content: const Text('Request error.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
              ),
            ],
            insetPadding: const EdgeInsets.all(10),
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
      showCartDialog(savedInventory, "");
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
      bool? isOnline = prefs.getBool('isOnline');

      try {
        if (isOnline == true) {
          final apiUrl =
              'http://$ip/getItem/'; // Replace with your API endpoint
          final response = await http.get(Uri.parse(
              '$apiUrl?itemNumber=$barcodeScanRes&branch=$branch&dbName=$dbName'));

          if (response.statusCode == 200) {
            // Data was found in the database
            final data = jsonDecode(
                utf8.decode(response.bodyBytes, allowMalformed: true));
            if (data['item'] != "empty") {
              if (flag == 1) {
                Navigator.of(context).pop();
              } else {
                Navigator.of(context).pop();
              }

              Navigator.of(context)
                  .push(MaterialPageRoute(
                builder: (context) =>
                    CheckpriceScreen(data: data, isOnline: isOnlineFlag),
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
                  title: const Text('Data Not Found'),
                  content:
                      const Text('The scanned item barcode was not found.'),
                  actions: [
                    TextButton(
                      onPressed: () {
                        print("vvvvvvvvvvvvvvvvvvvvvvvvv");
                        Navigator.of(context).pop();
                        showCartDialogCheckPrice();
                        //blaaaaaaaaaaaaaaaaaaaa
                      },
                      child: const Text('Scan Again'),
                    ),
                  ],
                  insetPadding: const EdgeInsets.all(10),
                ),
              );
            }
            // Navigate to a new screen to display the data
          }
        }
        if (isOnline == false) {
          // Data was found in the database
          Map<String, dynamic> result =
              await YourDatabaseHelper().getItem(barcodeScanRes);
          print(result);
          if (result['item'] != "empty") {
            if (flag == 1) {
              Navigator.of(context).pop();
            } else {
              Navigator.of(context).pop();
            }
            print("henge ${result['itemQB']}");

            Navigator.of(context)
                .push(MaterialPageRoute(
              builder: (context) => CheckpriceScreen(
                data: result,
                isOnline: isOnlineFlag,
              ),
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
                title: const Text('Data Not Found'),
                content: const Text('The scanned item barcode was not found.'),
                actions: [
                  TextButton(
                    onPressed: () {
                      print("vvvvvvvvvvvvvvvvvvvvvvvvv");
                      Navigator.of(context).pop();
                      showCartDialogCheckPrice();
                      //blaaaaaaaaaaaaaaaaaaaa
                    },
                    child: const Text('Scan Again'),
                  ),
                ],
                insetPadding: const EdgeInsets.all(10),
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
            insetPadding: const EdgeInsets.all(10),
          ),
        );
      }
    }
  }

  // Function to navigate to the settings page
  void navigateToSettings(BuildContext context, bool isOnline) {
    // Navigate to the settings page
    // Replace 'SettingsScreen' with the actual screen you want to navigate to
    Navigator.of(context)
        .push(MaterialPageRoute(
      builder: (context) => SettingsScreen(isOnline: isOnline),
    ))
        .then((result) async {
      // Run your async function here
      await isOnlineStatus();
    });
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
      SharedPreferences prefs = await SharedPreferences.getInstance();
      checkPricePage = prefs.getString('checkPricePage');
      qtyToColPage = prefs.getString('qtyToColPage');
      deleteInv = prefs.getString('deleteInv');
      // Check if arguments are not null and of the expected type
      if (arguments == 2) {
        print("dddddddd");
        // Call your function with the passed value
        String? savedInventory = prefs.getString('inventory');

        print("------------------------------");
        print(savedInventory);
        showCartDialog(savedInventory, "");
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      isOnlineStatus();
    });
  }

  Future<bool> isOnlineStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? isOnline = prefs.getBool('isOnline');
    setState(() {
      isOnlineFlag = isOnline ?? true;
    });
    return isOnline ?? true;
  }

  @override
  Widget build(BuildContext context) {
    final mediaQueryData = MediaQuery.of(context);

    final screenHeight = mediaQueryData.size.height;
    //final screenWidth = mediaQueryData.size.width;

    return Scaffold(
      appBar: AppBar(
        title: isOnlineFlag == true
            ? const Text('Options')
            : const Text("Options-OFF"),
        backgroundColor: isOnlineFlag == true ? Colors.deepPurple : Colors.grey,
        actions: [
          // Add the settings icon to the AppBar
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () async {
              // Call the function to navigate to the settings page
              SharedPreferences prefs = await SharedPreferences.getInstance();
              bool? isOnline = prefs.getBool('isOnline');
              navigateToSettings(context, isOnline ?? false);
            },
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                child: Image(
                  image: const AssetImage('assets/paradoxlogo.jpg'),

                  width: MediaQuery.of(context).size.width * 0.8,
                  // Adjust the width as needed
                ),
              ),
              SizedBox(
                height: screenHeight * 0.1,
              ),
              SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min, // Set mainAxisSize to min

                    children: [
                      MyButton(
                        onTap: () {
                          if (qtyToColPage == "Y") {
                            //here i want to add a cart that opens contains a comboBox getting data from api and two buttons
                            showCartDialog(null, "");
                          } else {
                            print(qtyToColPage);
                            print("lll");
                          }
                        },
                        buttonName: "Quantity To Collect",
                        isOnline: isOnlineFlag,
                        padding: 20,
                      ),
                      SizedBox(height: screenHeight * 0.05),
                      MyButton(
                        onTap: () {
                          if (checkPricePage == "Y") {
                            showCartDialogCheckPrice();
                          }
                        },
                        buttonName: "Check Price",
                        isOnline: isOnlineFlag,
                        padding: 20,
                      ),
                      SizedBox(height: screenHeight * 0.05),
                      MyButton(
                        onTap: () {
                          navigateToSettings(context, isOnlineFlag);
                        },
                        buttonName: "Settings",
                        isOnline: isOnlineFlag,
                        padding: 20,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
