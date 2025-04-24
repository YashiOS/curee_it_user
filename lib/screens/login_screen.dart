import 'package:cureeit_user_app/screens/otp_screen.dart';
import 'package:cureeit_user_app/utils/theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _controller = TextEditingController();

  void _validateAndProceed() {
    String phoneNumber = _controller.text.trim();

    if (phoneNumber.length != 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Mobile number must be 10 digits')),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => OtpScreen(phoneNumber: phoneNumber)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Container(
        color: scaffoldBlackColor,
        width: screenWidth,
        height: screenHeight,
        child: Stack(
          children: [
            Padding(
              padding: EdgeInsets.only(
                top: screenHeight * 0.17,
                left: screenWidth * 0.1,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image.asset(
                    "lib/images/medkaroLogo.png",
                    height:
                        screenHeight * 0.06, // approx 47 if screen height ~780
                    width:
                        screenWidth * 0.55, // approx 210 if screen width ~390
                  ),
                  SizedBox(height: screenHeight * 0.01),
                  Text(
                    "10-minute medicine delivery",
                    style: GoogleFonts.mulish(
                      color: whiteColor,
                      fontSize: screenHeight * 0.022, // ~17.2
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.09), // ~70
                  Container(
                    width: screenWidth * 0.85, // ~311 if screen width ~366
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A1A1A),
                      borderRadius: BorderRadius.circular(screenWidth * 0.02),
                    ),
                    padding:
                        EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
                    child: TextField(
                      style: GoogleFonts.mulish(color: whiteColor),
                      decoration: InputDecoration(
                        hintText: "Name",
                        hintStyle: TextStyle(color: Colors.white),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.025),
                  Container(
                    width: screenWidth * 0.85,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A1A1A),
                      borderRadius: BorderRadius.circular(screenWidth * 0.02),
                    ),
                    padding:
                        EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
                    child: TextField(
                      style: GoogleFonts.mulish(color: whiteColor),
                      decoration: InputDecoration(
                        hintText: "Phone Number",
                        hintStyle: TextStyle(color: Colors.white),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.05),
                  SizedBox(
                    width: screenWidth * 0.23, // ~83 if screen width ~360
                    height: screenHeight * 0.055, // ~40
                    child: TextButton(
                      onPressed:(){
                           _validateAndProceed();
                           Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context)=>OtpScreen(phoneNumber: "1234567891")));
                      } ,
                      style: TextButton.styleFrom(
                        backgroundColor: scaffoldBlackColor,
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(screenWidth * 0.02),
                          side: BorderSide(color: greenColor, width: 1),
                        ),
                      ),
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

            /// 🚗 Positioned Gadi at bottom
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Image.asset(
                "lib/images/medkaroGadi.png",
                width: screenWidth,
                fit: BoxFit.cover,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
