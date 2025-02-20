import 'package:flutter/material.dart';

class MyTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final bool obscureText;
  final String? Function(String?)? validator; // Validator function
  final int flag;
  final bool? readOnly;
  final bool? focusVar;
  final VoidCallback? onFieldSubmitted; // Callback for field submission

  const MyTextField(
      {Key? key,
      required this.controller,
      required this.hintText,
      required this.obscureText,
      this.validator,
      required this.flag, // Add validator parameter
      this.readOnly,
      this.focusVar,
      this.onFieldSubmitted})
      : super(key: key);

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
        child: Row(
          children: [
            flag == 1
                ? GestureDetector(
                    onTap: () {
                      int currentValue = int.parse(controller.text);

                      // Increment the value
                      currentValue--;

                      // Update the controller with the new value
                      controller.text = currentValue.toString();

                      // Handle the "-" button tap
                      // You may want to decrement the value in the controller here
                    },
                    child: const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Icon(
                        Icons.remove,
                        size: 30,
                      ),
                    ),
                  )
                : Container(),
            Expanded(
              child: readOnly != true && flag != 1
                  ? Padding(
                      padding: const EdgeInsets.only(left: 15),
                      child: TextFormField(
                        autofocus: focusVar == true ? true : false,
                        readOnly: readOnly == true ? true : false,
                        // Use TextFormField instead of TextField
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),

                        textAlign: TextAlign.start,
                        controller: controller,
                        obscureText: obscureText,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: hintText,
                          hintStyle: TextStyle(color: Colors.grey[500]),
                          errorStyle: const TextStyle(fontSize: 16),
                          // Set the font size for the error message
                          suffixIcon: IconButton(
                            icon: const Icon(
                              Icons.clear,
                              color: Colors.deepPurple,
                            ),
                            onPressed: () {
                              controller.clear();
                            },
                          ),
                        ),
                        validator: validator, // Attach the validator function
                        onFieldSubmitted: (_) => onFieldSubmitted?.call(),
                      ),
                    )
                  : Padding(
                      padding: const EdgeInsets.only(left: 15),
                      child: TextFormField(
                        autofocus: focusVar == true ? true : false,

                        readOnly: readOnly == true ? true : false,
                        // Use TextFormField instead of TextField
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),

                        textAlign:
                            flag == 1 ? TextAlign.center : TextAlign.start,
                        controller: controller,
                        obscureText: obscureText,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: hintText,
                          hintStyle: TextStyle(color: Colors.grey[500]),
                          errorStyle: const TextStyle(fontSize: 16),
                          // Set the font size for the error message
                        ),
                        validator: validator, // Attach the validator function
                        onFieldSubmitted: (_) => onFieldSubmitted?.call(),
                      ),
                    ),
            ),
            flag == 1
                ? GestureDetector(
                    onTap: () {
                      int currentValue = int.parse(controller.text);

                      // Increment the value
                      currentValue++;

                      // Update the controller with the new value
                      controller.text = currentValue.toString();
                      // Handle the "+" button tap
                      // You may want to increment the value in the controller here
                    },
                    child: const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Icon(
                        Icons.add,
                        size: 30,
                      ),
                    ),
                  )
                : Container(),
          ],
        ),
      ),
    );
  }
}
