import 'package:flutter/material.dart';

abstract class AppColors {
  static bool isLightTheme = true;

  static const Color primaryBlue1 = Color(0xFF254D99);
  static const Color primaryBlue2 = Color(0xFF549DD6);
  static const Color primaryBlue3 = Color(0xFFF1F5FF);
  static const Color secondaryYellow = Color(0xFFFFE9AD);
  static const Color secondaryBlue1 = Color(0xFFE9EDF5);
  static const Color secondaryBlue2 = Color(0xFFF8FAFC);
  static const Color secondaryGrey3 = Color(0xFF656565);
  static const Color secondaryGrey2 = Color(0xFFCCCCCC);
  static const Color secondaryGrey1 = Color(0xFFD3D3D3);
  static const Color white = Color(0xFFFFFFFF);

  static const Color cyan = Color(0xFF2196F3);
  static const Color red = Color(0xFFFF0000);
  static const Color green = Color(0xFF178E1E);
  static const Color purple = Color(0xFF82399A);
  static const Color lightCyan = Color(0xFFCBE2F5);
  static const Color lightRed = Color(0xFFF8B8B8);
  static const Color lightGreen = Color(0xFFBEDBBF);
  static const Color lightPurple = Color(0xFFD5C6F8);

  static const boxShadowColor = Color(0x14000000);
  static const Color hintTextColor = Color(0xFF656565);
  static const Color dividerColor = Color(0xFFD6D6D6);
  static const Color checkBoxColor = Color(0xFF1C1C1C);
  static const Color borderColor = Color(0xFFCCCCCC);
  static const Color appBarColor = Color(0xFFFFFFFF);
  static const black = Color(0xFF000000);
  static const transparent = Colors.transparent;

  static Color get backgroundColor => isLightTheme ? AppColors.white : const Color(0xFF0F0F0F);

  static Color get regularTextColor => isLightTheme ? const Color(0xFF1C1C1C) : const Color(0xFFEEEEEE);

  static Color get textFieldColor => isLightTheme ? const Color(0xFFCCCCCC) : const Color(0xFF343434);
}
