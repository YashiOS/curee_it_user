import 'package:flutter/material.dart';

// Define theme colors
const Color primaryColor = Color(0xFF0A9682);
const Color secondaryColor = Color(0xFF13B8A7);

final ThemeData appTheme = ThemeData(
  primaryColor: primaryColor,
  scaffoldBackgroundColor: Colors.white,
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: secondaryColor, // Button color
    ),
  ),
  colorScheme: ColorScheme.light(
    primary: primaryColor,
    secondary: secondaryColor,
  ),
);
