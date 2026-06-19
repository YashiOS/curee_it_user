import 'package:cureeit_user_app/screens/base_screen.dart';
import 'package:cureeit_user_app/screens/otp/domain/entities/otpEntity.dart';
import 'package:cureeit_user_app/screens/otp/domain/entities/userEntity.dart';
import 'package:cureeit_user_app/screens/otp/presentation/provider/otpProvider.dart';
import 'package:cureeit_user_app/selected_Address/otp_form.dart';
import 'package:cureeit_user_app/utils/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'
    show ConsumerWidget, WidgetRef, ConsumerStatefulWidget, ConsumerState;
import 'package:google_fonts/google_fonts.dart';

class OtpScreen extends ConsumerWidget {
  final String phoneNumber;
  final String purpose;
  final String name;

  const OtpScreen({
    super.key,
    required this.phoneNumber,
    required this.purpose,
    required this.name,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: _OtpScreenContent(
        phoneNumber: phoneNumber,
        purpose: purpose,
        name: name,
      ),
    );
  }
}

class _OtpScreenContent extends ConsumerStatefulWidget {
  final String phoneNumber;
  final String purpose;
  final String name;

  const _OtpScreenContent({
    required this.phoneNumber,
    required this.purpose,
    required this.name,
  });

  @override
  ConsumerState<_OtpScreenContent> createState() => _OtpScreenContentState();
}

class _OtpScreenContentState extends ConsumerState<_OtpScreenContent> {
  String otp = "";
  bool otpEntered = false;

  @override
  void initState() {
    super.initState();
    _showOtpSentSnackbar();
  }

  void _showOtpSentSnackbar() {
    Future.delayed(const Duration(seconds: 2), () {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "OTP sent successfully",
            style: GoogleFonts.mulish(),
          ),
          backgroundColor: greenColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    });
  }

  void _handleOtpEntered(bool entered) {
    setState(() {
      otpEntered = entered;
    });
  }

  void _handleOtpChanged(String newOtp) {
    setState(() {
      otp = newOtp;
    });
    // Clear any previous errors when user starts typing
    if (newOtp.isNotEmpty) {
      ref.read(OtpNotifierProvider.notifier).clearError();
    }
  }

  Future<void> _submitOtp() async {
    if (otp.length != 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Please enter a valid 4-digit OTP",
            style: GoogleFonts.mulish(),
          ),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    final otpModel = OtpModel(
      mobileNumber: widget.phoneNumber,
      code: otp,
      purpose: widget.purpose,
      name: widget.name,
    );

    final user =
        await ref.read(OtpNotifierProvider.notifier).verifyOtp(otpModel);
    _handleOtpVerificationResult(user);
  }

  void _handleOtpVerificationResult(User? user) {
    final state = ref.watch(OtpNotifierProvider);

    if (state.verifyed) {
      ref.read(OtpNotifierProvider.notifier).saveUserData(user ??
          User(id: "", name: "", userId: "", mobileNumber: ""));
        
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => BaseScreen(Navigatedfrom: "otpScreen"),
        ),
      );
    } else if (state.error != null) {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            state.error!,
            style: GoogleFonts.mulish(),
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(OtpNotifierProvider);
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Handle state changes
    WidgetsBinding.instance.addPostFrameCallback((_) {});

    return Container(
      width: screenWidth,
      height: screenHeight,
      color:  Colors.black,
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
                  "lib/images/siccLog.png",
                  height: screenHeight * 0.25,
                  width: screenWidth,
                  alignment: Alignment.centerLeft,
                  fit: BoxFit.contain,
                ),
                OtpForm(
                  onOtpEntered: _handleOtpEntered,
                  onOtpChanged: _handleOtpChanged,
                ),
                SizedBox(height: screenHeight * 0.02),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: state.isLoading ? null : _submitOtp,
                        style: TextButton.styleFrom(
                          backgroundColor: otpEntered
                              ? greenColor
                              :  WhiteColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            side: BorderSide(
                              color: greenColor,
                              width: 1,
                            ),
                          ),
                        ),
                        child: state.isLoading
                            ? Container(
                                height: 10,
                                width: 10,
                                child: const CircularProgressIndicator(
                                  color: lightWhiteColor,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                "Next",
                                style: GoogleFonts.mulish(
                                  color: otpEntered ?lightWhiteColor : greenColor,
                                  fontSize: screenHeight * 0.018,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),

                // Error message display
                if (state.error != null) ...[
                  SizedBox(height: screenHeight * 0.02),
                  Text(
                    state.error!,
                    style: GoogleFonts.mulish(
                      color: Colors.red,
                      fontSize: screenHeight * 0.016,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
          ),

          /// 🚚 Medkaro Gadi
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
    );
  }
}
