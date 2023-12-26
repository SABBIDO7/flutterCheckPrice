import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'components/my_button.dart';
import 'components/my_textfield.dart';
import 'package:checkprice/options.dart';

class LoginPage extends StatefulWidget {
  LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // text editing controllers
  final usernameController = TextEditingController();
  //final passwordController = TextEditingController();
  final branchController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late Future<bool> response;
  String errorMessage = '';
  final dBController = TextEditingController();
  final ipController = TextEditingController();

  @override
  void initState() {
    super.initState();
    response = checkSavedCredentials();
    errorMessage = '';
    print('inital $response');
  }

  // Save user credentials to shared preferences
  Future<void> saveUserCredentials(
      String username,
      /*String password,*/
      String branch,
      String ip,
      String dbName) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('username', username);
    //prefs.setString('password', password);
    prefs.setString('branch', branch);
    prefs.setString('dbName', dbName);
    prefs.setString('ip', ip);
  }

  // sign user in method
  Future<bool> signUserIn(String username, /*String password,*/ String branch,
      int flag, String dB, String ip, BuildContext context) async {
    final url = Uri.parse(
        'http://$ip/Checkuser/?username=$username&branch=$branch&dbName=$dB');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
      ).timeout(Duration(seconds: 10));
      print(response);

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        if (data['status'] == true) {
          // Successful login, handle the response as needed
          if (flag != 1) {
            saveUserCredentials(username, /* password,*/ branch, ip, dB);
          }
          // Successful login, navigate to the HomeScreen
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => Option(),
            ),
          );
          return true;
        } else {
          //print("habpouvvv");
          // Handle login failure (e.g., incorrect credentials)
          // Set error message here
          if (flag == 1) {
            errorMessage =
                'Your credentials have been changed. Enter the new ones.';
          } else {
            setState(() {
              errorMessage = 'Invalid credentials. Please try again.';
            });
          }
          print("Failure");
          return false;
        }
      } else {
        setState(() {
          errorMessage = 'Database does not exist or connection failed';
        });
        return false;
      }
    } catch (e) {
      print("Error: $e");
      setState(() {
        errorMessage = 'wrong ip or server down\nCheck your WIFI';
      });
      return false;
    }
  }

  Future<bool> checkSavedCredentials() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedUsername = prefs.getString('username');

    String? savedBranch = prefs.getString('branch');
    String? savedIp = prefs.getString('ip');

    String? savedDb = prefs.getString('dbName');

    if (savedUsername != null &&
        savedBranch != null &&
        savedDb != null &&
        savedIp != null) {
      print("adim");

      // Credentials are found, attempt to sign in
      return await signUserIn(
          savedUsername, savedBranch, 1, savedDb, savedIp, context);
    } else {
      print("jdid");

      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaQueryData = MediaQuery.of(context);
    final screenHeight = mediaQueryData.size.height;
    return FutureBuilder<bool>(
      future: response,
      builder: (context, snapshot) {
        if (snapshot.data == false) {
          return Scaffold(
            backgroundColor: Colors.grey[200],
            body: SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // logo
                        Icon(
                          Icons.lock,
                          size: screenHeight * 0.1,
                        ),

                        SizedBox(height: screenHeight * 0.015),

                        // welcome back, you've been missed!
                        Text(
                          'Paradox Welcome back',
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        SizedBox(height: screenHeight * 0.04),

                        // username textfield
                        // username textfield
                        MyTextField(
                          controller: usernameController,
                          hintText: 'Username',
                          obscureText: false,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a valid username';
                            }
                            return null;
                          },
                          flag: 0,
                        ),

                        // SizedBox(height: screenHeight * 0.015),

                        // // password textfield
                        // // username textfield
                        // MyTextField(
                        //   controller: passwordController,
                        //   hintText: 'Password',
                        //   obscureText: true,
                        //   validator: (value) {
                        //     if (value == null || value.isEmpty) {
                        //       return 'Please enter a valid password';
                        //     }
                        //     return null;
                        //   },
                        //   flag: 0,
                        // ),

                        SizedBox(height: screenHeight * 0.015),

                        MyTextField(
                          controller: branchController,
                          hintText: 'Branch Number',
                          obscureText: false,
                          validator: (value) {
                            if (value == null ||
                                value.isEmpty ||
                                !RegExp(r'^[a-zA-Z0-9]+$').hasMatch(value)) {
                              return 'Please enter a valid Branch Number (letters and numbers only)';
                            }
                            return null;
                          },
                          flag: 0,
                        ),
                        SizedBox(height: screenHeight * 0.015),

                        MyTextField(
                          controller: dBController,
                          hintText: 'DB Name',
                          obscureText: false,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a valid username';
                            }
                            return null;
                          },
                          flag: 0,
                        ),
                        SizedBox(height: screenHeight * 0.015),

                        MyTextField(
                          controller: ipController,
                          hintText: 'Server ip',
                          obscureText: false,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a valid ip';
                            }
                            return null;
                          },
                          flag: 0,
                        ),
                        // Display error message
                        SizedBox(height: screenHeight * 0.015),

                        Text(
                          errorMessage,
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 14,
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.005),

                        // sign in button
                        MyButton(
                          onTap: () {
                            if (_formKey.currentState!.validate()) {
                              signUserIn(
                                  usernameController.text,
                                  //passwordController.text,
                                  branchController.text,
                                  0,
                                  dBController.text,
                                  ipController.text,
                                  context);
                            }
                          },
                          buttonName: "Login",
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        } else {
          return Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
      },
    );
  }
}
