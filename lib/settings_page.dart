import 'dart:convert';
//import 'dart:ffi';

import 'package:flutter/material.dart';

import 'components/MyDropdownButtonFormField.dart';
import 'components/my_button.dart';
//import 'components/my_textfield.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import 'components/switch.dart';

class SettingsScreen extends StatefulWidget {
  final bool isOnline;
  const SettingsScreen({super.key, required this.isOnline});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final branchController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String errorMessage = '';
  List<String> branches = []; // List to store fetched branches

  @override
  void initState() {
    super.initState();
    errorMessage = '';
    fetchBranches(); // Fetch branches when the screen initializes
  }

  // Future<bool> isOnlineStatus() async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   bool? isOnline = prefs.getBool('isOnline');
  //   return isOnline ?? false;
  // }

  Future<void> fetchBranches() async {
    // Fetch the list of branches from your backend API
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? ip = prefs.getString('ip');
    String? dbName = prefs.getString('dbName');

    final url = Uri.parse(
        'http://$ip/getBranches/?dbName=$dbName'); // Replace with your API endpoint

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          branches = List<String>.from(data['branches']);
        });
      }
    } catch (e) {
      print("Error fetching branches: $e");
    }
  }

  Future<void> updateBranch(String branchUpdated, BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    //String? username = prefs.getString('username');
    //String? password = prefs.getString('password');
    String? branch = prefs.getString('branch');
    String? dbName = prefs.getString('dbName');
    print(dbName);
    //String? ip = prefs.getString('ip');

    if (branch == branchUpdated) {
      setState(() {
        errorMessage = "You are already in this branch";
      });
    } else {
      setState(() {
        prefs.setString('branch', branchUpdated);
        errorMessage = "Your branch has been updated";
      });

      // final url = Uri.parse(
      //     'http://$ip/updateBranch/?username=$username&newbranch=$branchUpdated&dbName=$dbName');
      try {
        // final response = await http.post(
        //   url,
        //   headers: {
        //     'Content-Type': 'application/json',
        //   },
        // );
        // print(response);

        // if (response.statusCode == 201) {
        //   final data = jsonDecode(response.body);
        //   print(data['status']);
        //   if (data['status'] == "True") {
        //     setState(() {
        //       prefs.setString('branch', branchUpdated);
        //       errorMessage = "Your branch has been updated";
        //     });
        //   } else if (data['status'] == "noBranchFound") {
        //     setState(() {
        //       errorMessage = "This branch does not exsist";
        //     });
        //   }
        // }
      } catch (e) {
        print("Error: $e");
      }
    }
  }

  Future<void> logout(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt('flag', 0);
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    // Replace '/login' with your actual login route
  }

  @override
  Widget build(BuildContext context) {
    final mediaQueryData = MediaQuery.of(context);
    final screenHeight = mediaQueryData.size.height;
    print(screenHeight);

    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: Text('Settings'),
        backgroundColor: Colors.deepPurple,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  SizedBox(height: screenHeight * 0.05),
                  // Branch dropdown using MyDropdownButtonFormField
                  MyDropdownButtonFormField(
                      items: branches,
                      value: null,
                      hintText: 'Select Branch',
                      onChanged: (dynamic selectedBranch) {
                        branchController.text = selectedBranch;
                      },
                      validator: (dynamic value) {
                        if (value == null) {
                          return 'Please select a branch';
                        }
                        return null;
                      },
                      flag: 0,
                      username: ''),
                  /* MyTextField(
                    controller: branchController,
                    hintText: 'New Branch',
                    obscureText: false,
                    validator: (value) {
                      if (value == null ||
                          value.isEmpty ||
                          !RegExp(r'^[0-9]+$').hasMatch(value)) {
                        return 'Please enter a valid branch';
                      }
                      return null;
                    },
                  ),*/
                  Text(
                    errorMessage,
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 14,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.05),
                  MyButton(
                    onTap: () {
                      if (_formKey.currentState!.validate()) {
                        updateBranch(branchController.text, context);
                      }
                    },
                    buttonName: "Update",
                  ),
                  SizedBox(height: screenHeight * 0.05),
                  MyButton(
                    onTap: () {
                      logout(context);
                    },
                    buttonName: "Logout",
                  ),
                  SizedBox(height: screenHeight * 0.05),
                  Row(
                    children: [
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 25),
                        child: Text(
                          "Switch Mode :",
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                      SwitchExample(isOnline: widget.isOnline),
                    ],
                  ),
                ],
              ),
            ),
          ), // Customize the settings page content
        ),
      ),
    );
  }
}
