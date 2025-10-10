import 'package:cureeit_user_app/firebase_notifications.dart';
import 'package:cureeit_user_app/screens/otp/presentation/otp_screen.dart';
import 'package:cureeit_user_app/screens/register/domain/entities/registerEntity.dart';
import 'package:cureeit_user_app/screens/register/presentation/provider/registerProvider.dart';
import 'package:cureeit_user_app/utils/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  RegisterScreen({super.key, required this.phoneNumber});
  final String phoneNumber;

  @override
  ConsumerState<RegisterScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<RegisterScreen> {
  final TextEditingController _nameController = TextEditingController();
  bool isButtonEnabled = false;

  void _validateAndProceed() async {
    String name = _nameController.text.trim();

    if (name.length <= 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("name must be longer then 1 alphabet "),
          backgroundColor: greenColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }
    if (name == "" && name == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Name can not be empty "),
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
      await _registerUser();
    }
  }

  Future<void> _registerUser() async {
    final registerNotifier = ref.read(RegisterNotifierProvider.notifier);

    final registerEntity = RegisterEntity(
      phoneNumber: widget.phoneNumber,
      name: _nameController.text.trim(),
      fcmToken: fcmToken.fcmtoken,
    );

    await registerNotifier.registerUser(registerEntity);

    final state = ref.read(RegisterNotifierProvider);

    if (state.registered) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => OtpScreen(
            phoneNumber: widget.phoneNumber,
            purpose: "register",
            name: _nameController.text.trim(),
          ),
        ),
      );
    } else if (state.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${state.error}')),
      );
    }
  }

  @override
  void initState() {
    _nameController.addListener(_checkButton);
    super.initState();
  }

  void _checkButton() {
    setState(() {
      isButtonEnabled = _nameController.text.trim().length > 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    final registerState = ref.watch(RegisterNotifierProvider);
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      resizeToAvoidBottomInset: true,
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
                      padding:
                          EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              cursorColor: greenColor,
                              controller: _nameController,
                              style: GoogleFonts.mulish(color: whiteColor),
                              decoration: InputDecoration(
                                counterText: "",
                                hintText: "Name",
                                hintStyle: TextStyle(
                                    color: whiteColor,
                                    fontWeight: FontWeight.w100),
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
                            onPressed: registerState.isLoading
                                ? null
                                : _validateAndProceed,
                            style: TextButton.styleFrom(
                              backgroundColor:
                                  isButtonEnabled && !registerState.isLoading
                                      ? greenColor
                                      : scaffoldBlackColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                                side: BorderSide(color: greenColor, width: 1),
                              ),
                            ),
                            child: registerState.isLoading
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
                  ],
                ),
              ),

              /// 🚗 Positioned Gadi at bottom
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
