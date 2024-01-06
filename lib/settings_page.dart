// ignore_for_file: depend_on_referenced_packages

import 'dart:convert';
//import 'dart:ffi';

import 'package:flutter/material.dart';

import 'components/MyDropdownButtonFormField.dart';
import 'components/my_button.dart';
//import 'components/my_textfield.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import 'components/switch.dart';
import 'offline/sqllite.dart';

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
  void refreshState() {
    // Call setState to trigger a rebuild of the widget
    setState(() {
      print("hiiiiiiiii rafrashit");
      fetchBranches();
      // Your refresh logic here
    });
  }

  @override
  void initState() {
    super.initState();
    errorMessage = '';
    fetchBranches(); // Fetch branches when the screen initializes
  }

  Future<bool> isOnlineStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? isOnline = prefs.getBool('isOnline');
    return isOnline ?? false;
  }

  Future<void> fetchBranches() async {
    print("fettt");
    // Fetch the list of branches from your backend API
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? ip = prefs.getString('ip');
    String? dbName = prefs.getString('dbName');
    bool? isOnline = prefs.getBool('isOnline');
    if (isOnline == true) {
      print("onlinps");
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
    } else {
      print("oflineeee modeeee");
      try {
        List<dynamic> branchesQuery =
            await YourDataSync().databaseHelper.getBranches();
        setState(() {
          branches = List<String>.from(branchesQuery);
          print("----------");
          print(branches);
        });
      } catch (e) {
        print('Error fetching branches: $e');
      }
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

  Future<void> SyncData() async {
    try {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return Center(
            child: CircularProgressIndicator(),
          );
        },
        barrierDismissible: false,
      );
      // Sync data
      Color backgroundColor = const Color.fromRGBO(103, 58, 183, 1);
      Widget content = Text("");
      if (await YourDataSync().syncData() == false) {
        backgroundColor = Colors.grey;
        content = Text("Error in syncing Data");
      } else {
        backgroundColor = Colors.deepPurple;
        content = Text("Data Synced Successfully");
      }
      final snackBar = SnackBar(
        content: content,
        duration: Duration(seconds: 2),
        backgroundColor: backgroundColor,
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);

      Navigator.of(context).pop();
    } catch (e) {}
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
                      Row(
                        children: [
                          SwitchExample(
                              isOnline: widget.isOnline,
                              onRefresh: refreshState),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: screenHeight * 0.05),

                  Row(
                    children: [
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 25),
                        child: Text(
                          "Sync Data :",
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                      MyButton(
                        onTap: () async {
                          bool isOnline = await isOnlineStatus();
                          if (isOnline) {
                            SyncData();
                          } else {
                            final snackBar = SnackBar(
                              content:
                                  Text('Cannot Async Data in Offline Mode.'),
                              duration: Duration(seconds: 2),
                              backgroundColor: Colors.grey,
                            );

                            ScaffoldMessenger.of(context)
                                .showSnackBar(snackBar);
                          }
                        },
                        buttonName: "Sync Data",
                      ),
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
