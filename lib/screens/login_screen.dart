import 'dart:convert';
import 'package:cureeit_user_app/BaseUrl.dart';
import 'package:cureeit_user_app/firebase_notifications.dart';
import 'package:cureeit_user_app/screens/policies_screen.dart';
import 'package:cureeit_user_app/screens/terms_of_service_screen.dart';
import 'package:flutter/gestures.dart';
import 'package:location/location.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io'; // For exiting the app
import 'package:location/location.dart' as loc;
import 'package:permission_handler/permission_handler.dart' as perm;

import 'package:cureeit_user_app/screens/otp_screen.dart';
import 'package:cureeit_user_app/screens/register_screen.dart';
import 'package:cureeit_user_app/utils/theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _controller = TextEditingController();
  bool userLoggingIN = false;
  bool isButtonEnabled = false;

  void userLogin() async {
    setState(() {
      userLoggingIN = true;
    });

    try {
      final response = await http.post(
        Uri.parse(
            '$baseUrl/auth/user/verify'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          "mobileNumber": _controller.text.trim(),
          "fcmToken":fcmToken.fcmtoken
        }),
      );
    
     
      final Map<String, dynamic> responseBody = json.decode(response.body);
     

      if (response.statusCode == 200) {
        setState(() {
          userLoggingIN = false;
        });
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => OtpScreen(
                    phoneNumber: _controller.text.trim(),
                    purpose: "login",
                    name: "",
                  )),
        );
      }
      if (response.statusCode == 400) {
        setState(() {
          userLoggingIN = false;
        });
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  RegisterScreen(phoneNumber: _controller.text.trim()),
            ));
      }
    } catch (e) {
      setState(() {
        userLoggingIN = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Network error: $e')),
      );
    }
    setState(() {
          userLoggingIN = false;
        });
  }

  void _validateAndProceed() async {
    String phoneNumber = _controller.text.trim();

    if (phoneNumber.length != 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Phone number must be 10 digit ",
            style: GoogleFonts.mulish(),
          ),
          backgroundColor: greenColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    } else {
      userLogin();
    }
  }

  Future<void> _checkLocationStatus() async {
   
    loc.Location location = loc.Location();

    bool serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
    
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        _showLocationDeniedDialog();
        return;
      }
    }

    loc.PermissionStatus permissionGranted = await location.hasPermission();
    if (permissionGranted == loc.PermissionStatus.denied) {
     
      permissionGranted = await location.requestPermission();
      if (permissionGranted != loc.PermissionStatus.granted) {
        _showLocationDeniedDialog();
      }
    }
  }

  void _showLocationDeniedDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: ligtBlackColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        title: Text(
          "Location Required",
          style: GoogleFonts.mulish(color: whiteColor),
        ),
        content: Text(
          "Please enable location to use this app.",
          style: GoogleFonts.mulish(color: whiteColor),
        ),
        actions: [
          TextButton(
            style: TextButton.styleFrom(
                backgroundColor: Color(0xFFBE404F),
                foregroundColor: whiteColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                )),
            onPressed: () {
              exit(0); // Exit the app
            },
            child: Text(
              "Exit",
              style: GoogleFonts.mulish(color: whiteColor),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    _controller.addListener(_checkButton);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkLocationStatus();
    });

    super.initState();
  }

  void _checkButton() {
    setState(() {
      isButtonEnabled = _controller.text.trim().length == 10;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      resizeToAvoidBottomInset:
          false, // This makes the scaffold adjust when keyboard appears
      body: SingleChildScrollView(
        // <-- Wrap with scroll view
        child: Container(
          color: scaffoldBlackColor,
          width: screenWidth,
          height: screenHeight,
          child: Stack(
            children: [
              Padding(
                padding: EdgeInsets.only(
                  top: screenHeight * 0.17,
                  left: screenWidth * 0.1,
                  right: screenWidth * 0.1,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Image.asset(
                      "lib/images/MEDKARO.png",
                      height: screenHeight * 0.06,
                      width: screenWidth * 0.5,
                    ),
                    Text(
                      "10-minute medicine delivery",
                      style: GoogleFonts.mulish(
                        color: whiteColor,
                        fontSize: screenHeight * 0.022,
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.123),
                    Container(
                      width: screenWidth * 0.85,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A1A1A),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding:
                          EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
                      child: Row(
                        children: [
                          Text(
                            "+91 ",
                            style: GoogleFonts.mulish(
                                color: whiteColor, fontSize: 16),
                          ),
                          Expanded(
                            child: TextField(
                               cursorColor: greenColor,
                              controller:
                                  _controller, // <-- Attach controller here
                              style: GoogleFonts.mulish(color: whiteColor),
                              keyboardType: TextInputType.phone,
                              maxLength: 10,

                              decoration: InputDecoration(
                                counterText: "",
                                hintText: " Phone Number",
                                hintStyle: TextStyle(
                                    color: greyColor,
                                    fontWeight: FontWeight.w100),
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.02), // Added some spacing
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: () {
                              _validateAndProceed();
                            },
                            style: TextButton.styleFrom(
                              backgroundColor: isButtonEnabled
                                  ? greenColor
                                  : scaffoldBlackColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                                side: BorderSide(color: greenColor, width: 1),
                              ),
                            ),
                            child: userLoggingIN
                                ? Container(
                                    height: 10,
                                    width: 10,
                                    child: CircularProgressIndicator(
                                      color: whiteColor,
                                      strokeWidth: 2,
                                    ))
                                : Text(
                                    "Next",
                                    style: GoogleFonts.mulish(
                                      color: isButtonEnabled
                                          ? whiteColor
                                          : greenColor,
                                      fontSize: screenHeight * 0.018,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: screenHeight * 0.02,
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: RichText(
                            text: TextSpan(
                              style: TextStyle(color: whiteColor, fontSize: 12),
                              children: [
                                TextSpan(
                                    text: "By clicking next, I accept the ",
                                    style:
                                        GoogleFonts.mulish(color: greyColor)),
                                TextSpan(
                                  text: "terms of service",
                                  style: GoogleFonts.mulish(
                                    fontWeight: FontWeight.bold,
                                    color: greyColor,
                                    decoration: TextDecoration.underline,
                                  ),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = ()  {
                                    Navigator.of(context).push(MaterialPageRoute(builder: (context)=>TermsOfServiceScreen()));
                                    },
                                ),
                                TextSpan(
                                    text: " & ",
                                    style:
                                        GoogleFonts.mulish(color: greyColor)),
                                TextSpan(
                                  text: "policies.",
                                  style: GoogleFonts.mulish(
                                    fontWeight: FontWeight.bold,
                                    color: greyColor,
                                    decoration: TextDecoration.underline,
                                  ),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      Navigator.of(context).push(MaterialPageRoute(builder: (context)=>PoliciesScreen()));
                                    },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),

              /// 🚗 Positioned Gadi at bottom
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: SizedBox(
                  height: screenHeight * 0.36, // 40% of screen height
width: screenWidth * 0.9, 
                  child: Image.asset(
                    "lib/images/medkaroGadi.png",
                    width: 200,
                    fit: BoxFit.fill,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
