import 'package:flutter/material.dart';

import '../static_data/color_theme.dart';

class ColourNotifier with ChangeNotifier {
  bool _isDark = false;

  bool get isDark => _isDark;

  void isavalable(bool value) {
    _isDark = value;
    notifyListeners();
  }

  get getIsDark => isDark;

  get getPrimaryColor => isDark ? darkPrimeryColor : primeryColor;

  get getBgColor => isDark ? darkbgcolor : bgcolor;

  get getBgColor100 => isDark ? darkbgcolor : Colors.white;

  get badges  => isDark ? darkbgcolor : Colors.black;

  get getBorderColor => isDark ? darkbordercolor : bordercolor;
  get spinners => isDark ? const Color(0xffbfbfbf) : const Color(0xff3f4b64);
  get getIconColor => isDark ? darkiconcolor : iconcolor;

  get getContainer => isDark ? darkcontinercolor : continercolor;

  get getcontinershadow => isDark ? darkcontinercolo1r : continercolo1r;

  get getTextColor1 => isDark ? textwhite : textdark;

  get getMainText => isDark ? themgrey : themblack;

  get progress => isDark ? const Color(0xff1d2630) : const Color(0xffEEEEEE);

  get getMaingey => isDark ? themblackgrey : themlitegrey;

  get getbacknoticolor => isDark ? darkbackcolor : notibackcolor;

  get getsubcolors => isDark ? darksubcolor : notisubcolor;

  get getbacktextcolors => isDark ? darktextcolor : backtextcolor;

  get getfiltextcolors => isDark ? darkfilcolor : filtexcolor;

  get getdolorcolors => isDark ? darkdolorcolor : dolorcolor;

  get getmaintext => isDark ? themblack1 : themgrey1;
}
