import 'package:flutter/material.dart';

// Define theme colors
const Color primaryColor = Color(0xFF0A9682);
const Color secondaryColor = Color(0xFF13B8A7);


const Color lightBlackColor=Color(0xFF1A1A1A);
const Color  scaffoldBlackColor=Color(0xFF101010);
const Color homepageWhite = Color(0xFFFFFFFF);
const Color WhiteColor=Colors.white;
const Color greenColor=Color(0xFF00B852);
const Color lightGreenColor=Color.fromARGB(255, 222, 245, 232);
const Color greyColor=Color(0xFF727E78);

const Color lightWhiteColor= Colors.white;
const Color scaffoldWhiteColor = Color(0xFFF4F5F7);
const Color blackColor=Color(0xFF333333);

const Color textFieldFillColor=Color(0xFFF2F2F7);

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
