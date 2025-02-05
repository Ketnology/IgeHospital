import 'package:flutter/material.dart';
import 'package:ige_hospital/provider/colors_provider.dart';
import 'package:ige_hospital/static_data/static_data.dart';
import 'package:provider/provider.dart';

class BottomBar extends StatefulWidget {
  const BottomBar({super.key});

  @override
  State<BottomBar> createState() => _BottomBarState();
}

class _BottomBarState extends State<BottomBar> {
  @override
  Widget build(BuildContext context) {
    return Consumer<ColourNotifier>(
      builder: (BuildContext context, value, Widget? child) {
        return Container(
          height: 50,
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
              boxShadow: boxShadow, color: notifier!.getPrimaryColor),
          child: Center(
              child: Text(
            "Copyright 2025 © IGE Hospital.",
            style: TextStyle(color: notifier!.getMainText),
          )),
        );
      },
    );
  }
}
