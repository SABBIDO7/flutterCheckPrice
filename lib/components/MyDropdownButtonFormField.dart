import 'package:flutter/material.dart';

class MyDropdownButtonFormField extends StatelessWidget {
  final List<int> items;
  final int? value;
  final void Function(int?)? onChanged;
  final String hintText;
  final String? Function(int?)? validator;

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
      padding: const EdgeInsets.symmetric(horizontal: 25.0),
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
            padding: MediaQuery.of(context).textScaleFactor > 2.5
                ? const EdgeInsets.only(left: 1, right: 1)
                : const EdgeInsets.only(left: 15, right: 15),
            child: DropdownButtonFormField<int>(
              value: value,
              hint: Text(hintText),
              items: items.map((int branch) {
                return DropdownMenuItem<int>(
                  value: branch,
                  child: Column(
                    children: [
                      Text(
                        '$branch',
                        style: TextStyle(
                            fontSize:
                                MediaQuery.of(context).textScaleFactor > 1.25
                                    ? 13
                                    : 16),
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
