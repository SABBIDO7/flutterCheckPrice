import 'package:flutter/material.dart';

class MyTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final bool obscureText;
  final String? Function(String?)? validator; // Validator function

  const MyTextField({
    Key? key,
    required this.controller,
    required this.hintText,
    required this.obscureText,
    this.validator, // Add validator parameter
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.white),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Padding(
          padding: const EdgeInsets.only(left: 15),
          child: TextFormField(
            // Use TextFormField instead of TextField
            controller: controller,
            obscureText: obscureText,
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: hintText,
              hintStyle: TextStyle(color: Colors.grey[500]),
              errorStyle: TextStyle(
                  fontSize: 16), // Set the font size for the error message
            ),
            validator: validator, // Attach the validator function
          ),
        ),
      ),
    );
  }
}
