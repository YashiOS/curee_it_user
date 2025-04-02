import 'package:cureeit_user_app/screens/home_screen.dart';
import 'package:cureeit_user_app/utils/otp_form.dart';
import 'package:cureeit_user_app/utils/theme.dart';
import 'package:flutter/material.dart';

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
    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.all(16.0),
          child: GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: Image.asset(
                'lib/images/back_arrow.png',
                fit: BoxFit.contain, // or BoxFit.contain, BoxFit.fill, etc.
              )),
        ),
      ),
      body: SizedBox(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 22),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 8,
                children: [
                  Text(
                    "Enter OTP",
                    style: TextStyle(
                      color: primaryColor,
                      fontSize: 24,
                      fontFamily: "JosefinSans",
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Please check your message box.",
                        style: TextStyle(
                          color: Color(0xFF689AC0),
                          fontSize: 14,
                          fontFamily: "Urbanist",
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      Text(
                        "01:59",
                        style: TextStyle(
                          color: primaryColor,
                          fontSize: 14,
                          fontFamily: "Urbanist",
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 18.0),
                    child: OtpForm(
                      onOtpEntered:
                          handleOtpEntered, // Pass callback for OTP entry status
                      onOtpChanged:
                          handleOtpChanged, // Pass callback for OTP value
                    ),
                  )
                ],
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 36.0),
                child: Column(
                  spacing: 36,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      spacing: 8,
                      children: [
                        Text(
                          "If you don't receive a code !",
                          style: TextStyle(
                            color: Color(0xFF689AC0).withOpacity(0.5),
                            fontSize: 14,
                            fontFamily: "Urbanist",
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        Text(
                          "Resend",
                          style: TextStyle(
                            color: primaryColor,
                            fontSize: 14,
                            fontFamily: "Urbanist",
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                    GestureDetector(
                      onTap: () {
                        submitOtp();
                        print(otp);
                      },
                      child: Container(
                        width: 275,
                        height: 60,
                        decoration: BoxDecoration(
                            color: secondaryColor
                                .withOpacity(otpEntered ? 1 : 0.3),
                            borderRadius: BorderRadius.circular(10)),
                        alignment: Alignment.center,
                        child: Text(
                          "Confirm OTP",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
