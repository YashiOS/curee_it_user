import 'package:cureeit_user_app/screens/base_screen.dart';
import 'package:cureeit_user_app/screens/home_screen.dart';
import 'package:cureeit_user_app/utils/otp_form.dart';
import 'package:cureeit_user_app/utils/theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class OtpScreen extends StatefulWidget {
  final String phoneNumber;
  const OtpScreen({super.key, required this.phoneNumber});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  bool otpEntered = false; // Track OTP completion
  String otp = ""; // Store the combined OTP

  void handleOtpEntered(bool entered) {
    setState(() {
      otpEntered = entered;
    });
  }

  void handleOtpChanged(String newOtp) {
    setState(() {
      otp = newOtp;
    });
  }

  void submitOtp() {
    if (otpEntered) {
      print('OTP entered: $otp');
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen()),
      );
    } else {
      print('OTP not fully entered');
    }
  }

 @override
Widget build(BuildContext context) {
  final screenWidth = MediaQuery.of(context).size.width;
  final screenHeight = MediaQuery.of(context).size.height;

  return Scaffold(
    resizeToAvoidBottomInset: true, // Important!
    body: SingleChildScrollView( // Wrap the whole body!
      child: Container(
        width: screenWidth,
        height: screenHeight,
        color: scaffoldBlackColor,
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
                    "lib/images/medkaroLogo.png",
                    height: screenHeight * 0.06,
                    width: screenWidth * 0.55,
                  ),
                  Text(
                    "10-minute medicine delivery",
                    style: GoogleFonts.mulish(
                      color: whiteColor,
                      fontSize: screenHeight * 0.022,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.12),
                  OtpForm(
                    onOtpEntered: handleOtpEntered,
                    onOtpChanged: handleOtpChanged,
                  ),
                  SizedBox(height: screenHeight * 0.05),
                  GestureDetector(
                    onTap: () {
                      submitOtp();
                      print(otp);
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (context) => BaseScreen()),
                      );
                    },
                    child: Container(
                      width: screenWidth * 0.23,
                      height: screenHeight * 0.055,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: greenColor,
                          width: 1,
                        ),
                        color: scaffoldBlackColor,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        "Next",
                        style: GoogleFonts.mulish(
                          color: greenColor,
                          fontSize: screenHeight * 0.018,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            /// 🚚 Medkaro Gadi
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Image.asset(
                "lib/images/medkaroGadi.png",
                fit: BoxFit.cover,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

}