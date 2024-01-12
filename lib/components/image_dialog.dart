import 'dart:convert';

import 'package:flutter/material.dart';

class ImageDialog extends StatelessWidget {
  final String imageUrl;

  const ImageDialog({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    final widthS = MediaQuery.of(context).size.width;
    final heightS = MediaQuery.of(context).size.height;

    return Dialog(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(
                Icons.arrow_back,
                color: Colors.black,
              ),
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
            ),
            actions: const [], // Clear any actions from the AppBar
          ),
          Center(
            child: Image.memory(
              base64Decode(imageUrl),

              width: widthS * 0.75, // Adjust the width as needed
              height: heightS * 0.5, // Adjust the height as needed
              fit: BoxFit.cover,
            ),
          ),
        ],
      ),
    );
  }
}
