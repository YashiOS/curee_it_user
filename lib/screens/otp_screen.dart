import 'dart:convert';

import 'package:cureeit_user_app/BaseUrl.dart';
import 'package:cureeit_user_app/LocalStorageCubit/store_user_cubit.dart';
import 'package:cureeit_user_app/screens/base_screen.dart';

import 'package:cureeit_user_app/selected_Address/otp_form.dart';
import 'package:cureeit_user_app/user/user.dart';

import 'package:cureeit_user_app/utils/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;


class OtpScreen extends StatefulWidget {
  final String phoneNumber;
  final String purpose;
  final String name;
  const OtpScreen(
      {super.key,
      required this.phoneNumber,
      required this.purpose,
      required this.name});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  bool verifyingOTP = false;
  bool otpEntered = false; // Track OTP completion
  String otp = "";
    //String? signature;
    //final TextEditingController _otpController = TextEditingController(); // Store the combined OTP

  @override
  void initState() {
    show();
    //listenOtp();
    // TODO: implement initState
    super.initState();
  }



  /*void listenOtp()async{
    try {
      // Get app signature (important for Android)
      signature = await SmsAutoFill().getAppSignature;
      print("App Signature: $signature");
      
      // Start listening for SMS
      await SmsAutoFill().listenForCode();
    } catch (e) {
      print("Error initializing SMS listener: $e");
    }
  }*/

  void handleOtpEntered(bool entered) {
    print(entered);
    setState(() {
      otpEntered = entered;
    });
  }

  void handleOtpChanged(String newOtp) {
    setState(() {
      otp = newOtp;
    });
  }

  void show() {
    Future.delayed(Duration(seconds: 2), () {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "OTP sent successfully ",
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
    });
  }

   


  Future<void> submitOtp() async {
   
    setState(() {
      verifyingOTP = true;
    });
    if (otp.length==4) {
      print('OTP entered: $otp');

      try {
        final response = await http.post(
          Uri.parse(
              '$baseUrl/auth/user/verifyOTP'),
          headers: {
            'Content-Type': 'application/json',
          },
          body: json.encode({
            "mobileNumber": widget.phoneNumber,
            "code": otp,
            "purpose": widget.purpose,
            "name": widget.name
          }),
        );
        final data = json.decode(response.body);
       
        if (response.statusCode == 200) {
          final id = data["user"]["_id"];
          final name = data["user"]["name"];
          final userid = data["user"]["userId"];
          final mobileNumber = data["user"]["mobileNumber"];
 
          User.id = id;
          User.name = name;
          User.phoneNumber = mobileNumber;
          User.userId = userid;
          context.read<StoreUserCubit>().saveUserData(
              id: id, userId: userid, name: name, phoneNumber: mobileNumber);
          setState(() {
            verifyingOTP = false;
          });
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => BaseScreen(
                      Navigatedfrom: "otpScreen",
                    )),
          );
        }
        if (response.statusCode != 200) {
          setState(() {
            verifyingOTP = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                "Wrong OTP",
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
        }
      } catch (e) {
        setState(() {
          verifyingOTP = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Failed to logged in error: $e",
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
      }
    } else {
      setState(() {
          verifyingOTP = false;
        });
      print('OTP not fully entered');
    }
  }

  

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      resizeToAvoidBottomInset: false, // Important!
      body: SingleChildScrollView(
        // Wrap the whole body!
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
                      "lib/images/MEDKARO.png",
                      height: screenHeight * 0.06,
                      width: screenWidth * 0.5,
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
                    SizedBox(height: screenHeight * 0.02),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: () {
                              submitOtp();
                            },
                            style: TextButton.styleFrom(
                              backgroundColor:
                                  otpEntered ? greenColor : scaffoldBlackColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                                side: BorderSide(color: greenColor, width: 1),
                              ),
                            ),
                            child: verifyingOTP
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
                                      color:
                                          otpEntered ? whiteColor : greenColor,
                                      fontSize: screenHeight * 0.018,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              /// 🚚 Medkaro Gadi
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
