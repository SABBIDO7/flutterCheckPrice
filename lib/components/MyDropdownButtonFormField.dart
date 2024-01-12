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
    bool flagContainsOff = false;
    if (underscoreIndex != -1 &&
        underscoreIndex + startPosition + length <= input.length) {
      String prefix = input.substring(0, underscoreIndex + startPosition);
      String suffix = input.substring(underscoreIndex + startPosition + length);
      // Erase the last two digits
      String result = '$prefix$suffix';
      if (result.contains("_off")) {
        result = result.replaceAll("_off", "");
        flagContainsOff = true;
      }

      input = result.substring(0, result.length - 2);

      if (flagContainsOff == true) {
        input += "_off";
      }
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
                offset: const Offset(0, 3),
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
                style:
                    const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
              ),
              items: items.map((dynamic branch) {
                // ignore: prefer_typing_uninitialized_variables
                var displayedText;
                if (flag == 1 && username != '') {
                  String? usernameLower = username?.toLowerCase();
                  displayedText = branch['table_name']
                      .toString()
                      .replaceFirst('dc_${usernameLower}_', '');
                  displayedText = replaceAfterUnderscore(displayedText, 3, 4);
                  /*displayedText = displayedText.replaceRange(
                      2, 7, ''); */ // Replace at the 3rd position

                  displayedText += ' (${branch['row_count']})';
                  if (branch['update_time'] != null) {
                    displayedText += ' ${branch['update_time']}';
                  }

                  //replace from the 3rd and 7th character
                } else {
                  displayedText = branch;
                }

                return DropdownMenuItem<dynamic>(
                  value: flag == 1 ? branch['table_name'] : branch,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.8,
                        //height: MediaQuery.of(context).size.height * 0.5,
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width * 0.8,
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Text(
                              '$displayedText',
                              style: TextStyle(
                                  fontSize: MediaQuery.of(context)
                                              .textScaleFactor >
                                          1
                                      ? MediaQuery.of(context)
                                                  .textScaleFactor >=
                                              1.5
                                          ? MediaQuery.of(context)
                                                      .textScaleFactor >=
                                                  2.25
                                              ? 7
                                              : MediaQuery.of(context)
                                                          .textScaleFactor >=
                                                      1.75
                                                  ? 10 //1.75 2
                                                  : 12 //1.5

                                          : 15 //kenit 12 //1.25
                                      : 17, //1
                                  fontWeight: FontWeight.bold),
                              softWrap: true,
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
              onChanged: onChanged,
              validator: validator,
              decoration: const InputDecoration(
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
