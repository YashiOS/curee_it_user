import 'package:flutter/material.dart';

// Define theme colors
const Color primaryColor = Color(0xFF0A9682);
const Color secondaryColor = Color(0xFF13B8A7);
const Color ligtBlackColor=Color(0xFF1A1A1A);
const Color scaffoldBlackColor=Color(0xFF101010);
const Color whiteColor=Colors.white;
const Color greenColor=Color(0xFF00B852);
const Color greyColor=Color(0xFF727E78);

final ThemeData appTheme = ThemeData(
  primaryColor: primaryColor,
  scaffoldBackgroundColor: Colors.black,
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: secondaryColor, // Button color
    ),
  ),
  colorScheme: ColorScheme.light(
    primary: greenColor,
    secondary: secondaryColor,
  ),
);
