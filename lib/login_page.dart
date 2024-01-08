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
  late Future<dynamic> savedCreds;
  String errorMessage = '';
  final dBController = TextEditingController();
  final ipController = TextEditingController();

  @override
  void initState() {
    super.initState();
    response = checkSavedCredentials();

    savedCreds = getSavedCredentials();

    errorMessage = '';
    print('inital $response');
  }

  // Save user credentials to shared preferences
  Future<void> saveUserCredentials(
      String username,
      /*String password,*/
      String branch,
      String ip,
      String dbName,
      int flag) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    prefs.setString('username', username.toLowerCase());
    //prefs.setString('password', password);
    prefs.setString('branch', branch);
    prefs.setString('dbName', dbName);
    prefs.setString('ip', ip);
    prefs.setInt('flag', 1);
    prefs.setBool('isOnline', true);
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
      ).timeout(Duration(seconds: 5));
      print(response);

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        if (data['status'] == true) {
          // Successful login, handle the response as needed
          if (flag == -1) {
            saveUserCredentials(username, /* password,*/ branch, ip, dB, 1);
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
    String savedUsername = prefs.getString('username') ?? "";

    String savedBranch = prefs.getString('branch') ?? "";
    String savedIp = prefs.getString('ip') ?? "";

    String savedDb = prefs.getString('dbName') ?? "";
    int savedFlag = prefs.getInt('flag') ?? -1;
    print(savedFlag);
    print("opaa");
    if (savedFlag != -1) {
      print("adim");
      //eendo prob
      if (savedFlag == 1) {
        // Credentials are found, attempt to sign in //dayman ha tsahyik she mayfout aal app eza sah bet fawto aal app else bterjaa btekhdi aa login page maa l error li sar
        return await signUserIn(
            savedUsername, savedBranch, 1, savedDb, savedIp, context);
      }
      //eemil logout bi ido
      return false;
    } else {
      print("jdid");

      return false;
    }
  }

  Future<dynamic> getSavedCredentials() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String savedUsername = prefs.getString('username') ?? "";

    String savedBranch = prefs.getString('branch') ?? "";
    String savedIp = prefs.getString('ip') ?? "";

    String savedDb = prefs.getString('dbName') ?? "";
    int savedFlag = prefs.getInt('flag') ?? -1;
    print(savedFlag);
    print("opa");
    if (savedFlag == 0 || savedFlag == 1) {
      setState(() {
        usernameController.text = savedUsername;
        print("ppppppppppppppppppp");
        print(usernameController.text);
        branchController.text = savedBranch;
        dBController.text = savedDb;
        ipController.text = savedIp;
      });
      return {
        "username": savedUsername,
        "branch": savedBranch,
        "ip": savedIp,
        "db": savedDb
      };
    } else {
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
          return FutureBuilder<dynamic>(
              future: savedCreds,
              builder: (context, snapshotCredentials) {
                // Check if the data is still loading

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
                              // Icon(
                              //   Icons.lock,
                              //   size: screenHeight * 0.1,
                              // ),

                              Container(
                                child: ClipOval(
                                  child: Image(
                                    image: AssetImage('assets/paradoxlogo.jpg'),
                                    height: 90,
                                    width: 90,
                                    fit:
                                        BoxFit.fill, // Adjust the fit as needed
                                  ),
                                ),
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
                                  if (value.contains(' ')) {
                                    return 'Username cannot contain spaces';
                                  }
                                  if (value.length > 10) {
                                    return 'Username cannot acceed\n10 characters';
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
                                      !RegExp(r'^[a-zA-Z0-9]+$')
                                          .hasMatch(value)) {
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
                                          -1,
                                          dBController.text,
                                          ipController.text,
                                          context);
                                    }
                                  },
                                  buttonName: "Login",
                                  isOnline: true),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              });
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
