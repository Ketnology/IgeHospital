import 'package:flutter/material.dart';
import 'package:ige_hospital/provider/colors_provider.dart';

//..............Colors....................
const Color appMainColor = Color(0xFFF44C46);
const Color appWhiteColor = Color(0xffffffff);
const Color appGreyColor = Color(0xffa1a1ae);

//..............TextStyle....................
TextStyle mainTextStyle = const TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w800,
    color: Colors.black,
    fontFamily: "Gilroy");
TextStyle mediumGreyTextStyle =
    const TextStyle(fontSize: 14, color: appGreyColor, fontFamily: "Gilroy");
TextStyle mediumBlackTextStyle =
    const TextStyle(fontSize: 14, color: Colors.black, fontFamily: "Gilroy");

//..............BoxShadow....................
List<BoxShadow>? boxShadow =  [

];

Decoration boxDecoration = BoxDecoration(
  borderRadius: const BorderRadius.all(Radius.circular(12)),
  color: notifier!.getContainer,
  boxShadow: boxShadow,
);

//const value

const double padding = 15;

// *****************************************
ColourNotifier? notifier;
