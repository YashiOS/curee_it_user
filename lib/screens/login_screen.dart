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
  bool isButtonEnabled=false;

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
  void initState() {
    _controller.addListener(_checkButton);
    super.initState();
  }

  void _checkButton(){
       setState(() {
         isButtonEnabled=_controller.text.trim().length==10;
       });
  }

@override
Widget build(BuildContext context) {
  final screenWidth = MediaQuery.of(context).size.width;
  final screenHeight = MediaQuery.of(context).size.height;

  return Scaffold(
    resizeToAvoidBottomInset: true, // This makes the scaffold adjust when keyboard appears
    body: SingleChildScrollView(  // <-- Wrap with scroll view
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
                    "lib/images/medkaroLogo.png",
                    height: screenHeight * 0.06,
                    width: screenWidth * 0.55,
                  ),
                  Text(
                    "10-minute medicine delivery",
                    style: GoogleFonts.mulish(
                      color: whiteColor,
                      fontSize: screenHeight * 0.022,
                    ),
                  ),
                  SizedBox(height: screenHeight * (60 / 812)),
                  Container(
                    width: screenWidth * 0.85,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A1A1A),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
                    child: TextField(
                      style: GoogleFonts.mulish(color: whiteColor),
                      decoration: InputDecoration(
                        hintText: "Name",
                        hintStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.w100),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.022),
                  Container(
                    width: screenWidth * 0.85,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A1A1A),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
                    child: TextField(
                      controller: _controller, // <-- Attach controller here
                      style: GoogleFonts.mulish(color: whiteColor),
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        hintText: "Phone Number",
                        hintStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.w100),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.05), // Added some spacing
                  SizedBox(
                    width: screenWidth * 0.23,
                    height: screenHeight * 0.055,
                    child: TextButton(
                      onPressed: () {
                        _validateAndProceed();
                      },
                      style: TextButton.styleFrom(
                        backgroundColor:isButtonEnabled?greenColor: scaffoldBlackColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: BorderSide(color: greenColor, width: 1),
                        ),
                      ),
                      child: Text(
                        "Next",
                        style: GoogleFonts.mulish(
                          color:isButtonEnabled?whiteColor: greenColor,
                          fontSize: screenHeight * 0.018,
                          fontWeight: FontWeight.bold,
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
              child: SizedBox(
                height: 332,
                width: 743,
                child: Image.asset(
                  "lib/images/medkaroGadi.png",
                  width: 200,
                  fit: BoxFit.cover,
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