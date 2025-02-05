import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MySizeBox extends StatefulWidget {
  const MySizeBox({super.key});

  @override
  State<MySizeBox> createState() => _MySizeBoxState();
}

class _MySizeBoxState extends State<MySizeBox> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: Get.height / 25,
    );
  }
}
