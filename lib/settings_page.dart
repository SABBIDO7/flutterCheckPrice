import 'dart:convert';

import 'package:flutter/material.dart';

import 'components/my_button.dart';
import 'components/my_textfield.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final branchController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    errorMessage = '';
  }

  Future<void> updateBranch(String branchUpdated, BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? username = prefs.getString('username');
    String? password = prefs.getString('password');
    int? branch = prefs.getInt('branch');
    String? dbName = prefs.getString('dbName');
    print(dbName);
    int? branchAsInt = int.tryParse(branchUpdated);
    String? ip = prefs.getString('ip');

    if (branch == branchAsInt) {
      setState(() {
        errorMessage = "You are already in this branch";
      });
    } else {
      final url = Uri.parse(
          'http://$ip/updateBranch/?username=$username&password=$password&newbranch=$branchAsInt&dbName=$dbName');
      try {
        final response = await http.post(
          url,
          headers: {
            'Content-Type': 'application/json',
          },
        );
        print(response);

        if (response.statusCode == 201) {
          final data = jsonDecode(response.body);
          print(data['status']);
          if (data['status'] == "True") {
            setState(() {
              prefs.setInt('branch', branchAsInt ?? 0);
              errorMessage = "Your branch has been updated";
            });
          } else if (data['status'] == "noBranchFound") {
            setState(() {
              errorMessage = "This branch does not exsist";
            });
          }
        }
      } catch (e) {
        print("Error: $e");
      }
    }
  }

  Future<void> logout(BuildContext context) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.clear();
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    // Replace '/login' with your actual login route
  }

  @override
  Widget build(BuildContext context) {
    final mediaQueryData = MediaQuery.of(context);
    final screenHeight = mediaQueryData.size.height;
    print(screenHeight);

    return Scaffold(
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

                  // username textfield
                  // username textfield
                  MyTextField(
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
                  ),
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
                ],
              ),
            ),
          ), // Customize the settings page content
        ),
      ),
    );
  }
}
