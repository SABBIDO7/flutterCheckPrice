import 'package:flutter/material.dart';

class MyDropdownButtonFormField extends StatelessWidget {
  final List<dynamic> items;
  final dynamic value;
  final void Function(dynamic)? onChanged;
  final String hintText;
  final String? Function(dynamic)? validator;
  final int flag;
  final String? username;

  const MyDropdownButtonFormField({
    Key? key,
    required this.items,
    required this.value,
    required this.onChanged,
    required this.hintText,
    this.validator,
    required this.flag,
    required this.username,
  }) : super(key: key);

  String replaceAfterUnderscore(String input, int startPosition, int length) {
    int underscoreIndex = input.indexOf('_');

    if (underscoreIndex != -1 &&
        underscoreIndex + startPosition + length <= input.length) {
      String prefix = input.substring(0, underscoreIndex + startPosition);
      String suffix = input.substring(underscoreIndex + startPosition + length);
      // Erase the last two digits
      String result = '$prefix$suffix';
      result = result.replaceAll("_off", "");

      input = result.substring(0, result.length - 2);

      print(result);
      print("displayedddd");
      print(input);
      return input; // Replace with 'XXXX' or any desired characters
    }

    return input; // Return the original string if the replacement is not possible
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: MediaQuery.of(context).textScaleFactor > 1.25
          ? const EdgeInsets.symmetric(horizontal: 0.0, vertical: 5.0)
          : const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 1,
                blurRadius: 4,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Padding(
            padding: MediaQuery.of(context).textScaleFactor > 1
                ? const EdgeInsets.only(left: 1, right: 1)
                : const EdgeInsets.only(left: 0, right: 0),
            child: DropdownButtonFormField<dynamic>(
              isDense: true,
              itemHeight: null,
              isExpanded: true,
              value: value,
              hint: Text(
                hintText,
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
              ),
              items: items.map((dynamic branch) {
                var displayedText;
                if (flag == 1 && username != '') {
                  print("hougaAAAAAAA");
                  String? usernameLower = username?.toLowerCase();
                  print(usernameLower);
                  displayedText = branch
                      .toString()
                      .replaceFirst('dc_${usernameLower}_', '');
                  print(displayedText);
                  print(username);
                  displayedText = replaceAfterUnderscore(displayedText, 3, 4);
                  /*displayedText = displayedText.replaceRange(
                      2, 7, ''); */ // Replace at the 3rd position

                  print(
                      "displayeddddddd"); //replace from the 3rd and 7th character
                  print(displayedText);
                } else {
                  displayedText = branch;
                }

                return DropdownMenuItem<dynamic>(
                  value: branch,
                  child: Container(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.62,
                          //height: MediaQuery.of(context).size.height * 0.5,
                          child: SizedBox(
                            width: MediaQuery.of(context).size.width * 0.62,
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Text(
                                '$displayedText',
                                style: TextStyle(
                                    fontSize:
                                        MediaQuery.of(context).textScaleFactor >
                                                1
                                            ? MediaQuery.of(context)
                                                        .textScaleFactor >
                                                    1.75
                                                ? MediaQuery.of(context)
                                                            .textScaleFactor >
                                                        2.25
                                                    ? 7
                                                    : 8
                                                : 17 //kenit 10
                                            : 17,
                                    fontWeight: FontWeight.bold),
                                softWrap: true,
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
              onChanged: onChanged,
              validator: validator,
              decoration: InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 10),
                errorStyle: TextStyle(fontSize: 16),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
