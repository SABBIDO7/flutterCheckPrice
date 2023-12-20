import 'package:flutter/material.dart';

class MyDropdownButtonFormField extends StatelessWidget {
  final List<dynamic> items;
  final dynamic value;
  final void Function(dynamic)? onChanged;
  final String hintText;
  final String? Function(dynamic)? validator;

  const MyDropdownButtonFormField({
    Key? key,
    required this.items,
    required this.value,
    required this.onChanged,
    required this.hintText,
    this.validator,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: MediaQuery.of(context).textScaleFactor > 1.25
          ? const EdgeInsets.symmetric(horizontal: 0.0, vertical: 5.0)
          : const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Container(
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
                : const EdgeInsets.only(left: 15, right: 15),
            child: DropdownButtonFormField<dynamic>(
              isDense: true,
              itemHeight: null,
              value: value,
              hint: Text(hintText),
              items: items.map((dynamic branch) {
                return DropdownMenuItem<dynamic>(
                  value: branch,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '$branch',
                        style: TextStyle(
                            fontSize: MediaQuery.of(context).textScaleFactor > 1
                                ? MediaQuery.of(context).textScaleFactor > 1.75
                                    ? MediaQuery.of(context).textScaleFactor >
                                            2.25
                                        ? 7
                                        : 8
                                    : 10
                                : 16),
                        softWrap: true,
                      ),
                    ],
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
