import 'package:flutter/material.dart';

import '../constants/color_theme.dart';

class ColourNotifier with ChangeNotifier {
  bool _isDark = false;

  bool get isDark => _isDark;

  void isAvaliable(bool value) {
    _isDark = value;
    notifyListeners();
  }

  get getIsDark => isDark;

  get getPrimaryColor => isDark ? darkPrimaryColor : primaryColor;

  get getBgColor => isDark ? darkBgColor : bgColor;

  get getBgColor100 => isDark ? darkBgColor : Colors.white;

  get badges  => isDark ? darkBgColor : Colors.black;

  get getBorderColor => isDark ? darkBorderColor : borderColor;
  get spinners => isDark ? const Color(0xffbfbfbf) : const Color(0xff3f4b64);
  get getIconColor => isDark ? darkIconColor : iconColor;

  get getContainer => isDark ? darkContainerColor : containerColor;

  get getcontinershadow => isDark ? darkContainerColorOne : containerColorOne;

  get getTextColor1 => isDark ? textWhite : textDark;

  get getMainText => isDark ? themeGrey : themeBlack;

  get progress => isDark ? const Color(0xff1d2630) : const Color(0xffEEEEEE);

  get getMaingey => isDark ? themeBlackGrey : themeLightGrey;

  get getbacknoticolor => isDark ? darkbackcolor : notibackcolor;

  get getsubcolors => isDark ? darksubcolor : notisubcolor;

  get getbacktextcolors => isDark ? darkTextColor : backTextColor;

  get getfiltextcolors => isDark ? darkfilcolor : filtexcolor;

  get getdolorcolors => isDark ? darkdolorcolor : dolorcolor;

  get getmaintext => isDark ? themeBlackOne : themeGreyOne;
}
