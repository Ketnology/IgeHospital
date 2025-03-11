import 'package:flutter/material.dart';
import 'package:ige_hospital/provider/colors_provider.dart';
import 'package:ige_hospital/static_data/static_data.dart';
import 'package:provider/provider.dart';

class MyTextField extends StatefulWidget {
  final String title;
  final String hinttext;
  final TextEditingController controller;
  final String? img;
  final Widget? prefix;

  const MyTextField(
      {super.key,
      required this.title,
      required this.hinttext,
      required this.controller,
      this.img,
      this.prefix});

  @override
  State<MyTextField> createState() => _MyTextFieldState();
}

class _MyTextFieldState extends State<MyTextField> {
  @override
  Widget build(BuildContext context) {
    return Consumer<ColourNotifier>(
      builder: (BuildContext context, value, Widget? child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.title,
              style:
                  mediumBlackTextStyle.copyWith(color: notifier!.getMainText),
            ),
            const SizedBox(
              height: 10,
            ),
            SizedBox(
              child: TextFormField(
                style: TextStyle(color: notifier!.getMainText),
                enabled: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter some text';
                  }
                  return null;
                },
                decoration: InputDecoration(
                  hintStyle: mediumGreyTextStyle.copyWith(fontSize: 13),
                  hintText: widget.hinttext,
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
                    borderRadius: const BorderRadius.all(Radius.circular(10)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: notifier!.getIconColor,
                      width: 1.5,
                    ),
                  ),
                ),
                controller: widget.controller,
              ),
            ),
          ],
        );
      },
    );
  }
}
