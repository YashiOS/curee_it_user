import 'package:cureeit_user_app/firebase_notifications.dart';
import 'package:cureeit_user_app/screens/login/domain/entities/loginEntity.dart';
import 'package:cureeit_user_app/screens/login/presentation/providers/loginProvider.dart';
import 'package:cureeit_user_app/screens/otp/presentation/otp_screen.dart';
import 'package:cureeit_user_app/screens/policies_screen.dart';
import 'package:cureeit_user_app/screens/register/presentation/register_screen.dart';
import 'package:cureeit_user_app/screens/terms_of_service_screen.dart';
import 'package:cureeit_user_app/utils/theme.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final TextEditingController _controller = TextEditingController();
  bool _isButtonEnabled = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    _controller.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    setState(() {
      _isButtonEnabled = _controller.text.length == 10;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final loginState = ref.watch(LoginNotifierProvider);
    
    // Handle navigation based on state changes
    void _handleLoginStateChanges() {
      if (loginState.isLoggedIn) {
        // Navigate to OTP screen
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (context) => OtpScreen(
              phoneNumber: _controller.text.trim(),
              purpose: "login", 
              name: ""
            ),
          ));
        });
      } else if (loginState.newUser) {
        // Navigate to Register screen
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (context) => RegisterScreen(
              phoneNumber: _controller.text.trim()
            ),
          ));
        });
      } else if (loginState.error != null) {
        // Show error message
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                loginState.error!,
                style: GoogleFonts.mulish(),
              ),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              duration: Duration(seconds: 3),
            ),
          );
        });
      }
    }

    // Call the state handler when state changes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _handleLoginStateChanges();
    });

    void _validateAndProceed() async {
      String phoneNumber = _controller.text.trim();
      final fcmTOken = fcmToken.fcmtoken ?? "";

      // Clear previous errors
      ref.read(LoginNotifierProvider.notifier).clearError();

      if (phoneNumber.length != 10) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Phone number must be 10 digits",
              style: GoogleFonts.mulish(),
            ),
            backgroundColor: Colors.orange,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            duration: Duration(seconds: 2),
          ),
        );
        return;
      }

      final loginEntity = LoginEntity(
        mobileNumber: phoneNumber, 
        fcmToken: fcmTOken
      );
      print("clicked");
      await ref.read(LoginNotifierProvider.notifier)
          .verifyPhoneNumber(loginEntity);
    }

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SingleChildScrollView(
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
                      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
                      child: Row(
                        children: [
                          Text(
                            "+91 ",
                            style: GoogleFonts.mulish(
                              color: whiteColor, 
                              fontSize: 16
                            ),
                          ),
                          Expanded(
                            child: TextField(
                              cursorColor: greenColor,
                              controller: _controller,
                              style: GoogleFonts.mulish(color: whiteColor),
                              keyboardType: TextInputType.phone,
                              maxLength: 10,
                              decoration: InputDecoration(
                                counterText: "",
                                hintText: " Phone Number",
                                hintStyle: TextStyle(
                                  color: greyColor,
                                  fontWeight: FontWeight.w100
                                ),
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.02),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: _isButtonEnabled && !loginState.isLoading 
                                ? _validateAndProceed 
                                : null,
                            style: TextButton.styleFrom(
                              backgroundColor: _isButtonEnabled
                                  ? greenColor
                                  : scaffoldBlackColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                                side: BorderSide(
                                  color: greenColor, 
                                  width: 1
                                ),
                              ),
                            ),
                            child: loginState.isLoading
                                ? Container(
                                    height: 10,
                                    width: 10,
                                    child: CircularProgressIndicator(
                                      color: whiteColor,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Text(
                                    "Next",
                                    style: GoogleFonts.mulish(
                                      color: _isButtonEnabled
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
                    SizedBox(height: screenHeight * 0.02),
                    Row(
                      children: [
                        Expanded(
                          child: RichText(
                            text: TextSpan(
                              style: TextStyle(color: whiteColor, fontSize: 12),
                              children: [
                                TextSpan(
                                  text: "By clicking next, I accept the ",
                                  style: GoogleFonts.mulish(color: greyColor)
                                ),
                                TextSpan(
                                  text: "terms of service",
                                  style: GoogleFonts.mulish(
                                    fontWeight: FontWeight.bold,
                                    color: greyColor,
                                    decoration: TextDecoration.underline,
                                  ),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) => TermsOfServiceScreen()
                                        ),
                                      );
                                    },
                                ),
                                TextSpan(
                                  text: " & ",
                                  style: GoogleFonts.mulish(color: greyColor)
                                ),
                                TextSpan(
                                  text: "policies.",
                                  style: GoogleFonts.mulish(
                                    fontWeight: FontWeight.bold,
                                    color: greyColor,
                                    decoration: TextDecoration.underline,
                                  ),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) => PoliciesScreen()
                                        ),
                                      );
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
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: SizedBox(
                  height: screenHeight * 0.36,
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