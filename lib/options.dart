import 'package:checkprice/settings_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:checkprice/DisplayScreen.dart';
import 'package:checkprice/CheckpriceScreen.dart';

import 'package:shared_preferences/shared_preferences.dart';

import 'components/my_button.dart';

class Option extends StatelessWidget {
  const Option({super.key});

  // Function to handle scanning and data retrieval
  Future<void> scanAndRetrieveData(BuildContext context) async {
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

      int? branch = prefs.getInt('branch');
      // Make an API call with the scanned barcode
      final apiUrl = 'http://$ip/getItem/'; // Replace with your API endpoint
      final response = await http.get(Uri.parse(
          '$apiUrl?itemNumber=$barcodeScanRes&branch=$branch&dbName=$dbName'));

      if (response.statusCode == 200) {
        // Data was found in the database
        final data = jsonDecode(response.body);
        if (data['item'] != "empty") {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => DisplayScreen(data: data),
          ));
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

  // Function to handle scanning and data retrieval
  Future<void> scanAndRetrieveDataPrice(BuildContext context) async {
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

      int? branch = prefs.getInt('branch');
      // Make an API call with the scanned barcode
      final apiUrl = 'http://$ip/getItem/'; // Replace with your API endpoint
      final response = await http.get(Uri.parse(
          '$apiUrl?itemNumber=$barcodeScanRes&branch=$branch&dbName=$dbName'));

      if (response.statusCode == 200) {
        // Data was found in the database
        final data = jsonDecode(response.body);
        if (data['item'] != "empty") {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => CheckpriceScreen(data: data),
          ));
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

  // Function to navigate to the settings page
  void navigateToSettings(BuildContext context) {
    // Navigate to the settings page
    // Replace 'SettingsScreen' with the actual screen you want to navigate to
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => SettingsScreen(),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final mediaQueryData = MediaQuery.of(context);

    final screenHeight = mediaQueryData.size.height;
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
                scanAndRetrieveData(context);
              },
              buttonName: "hand Collected",
            ),
            SizedBox(height: screenHeight * 0.05),
            MyButton(
              onTap: () {
                scanAndRetrieveDataPrice(context);
              },
              buttonName: "checkPrice",
            ),
          ],
        ),
      ),
    );
  }
}
