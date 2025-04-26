import 'package:cureeit_user_app/utils/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class OtpForm extends StatefulWidget {
  final Function(bool) onOtpEntered; // Callback for otpEntered
  final Function(String) onOtpChanged; // Callback for the OTP string

  const OtpForm(
      {super.key, required this.onOtpEntered, required this.onOtpChanged});

  @override
  _OtpFormState createState() => _OtpFormState();
}

class _OtpFormState extends State<OtpForm> {
  List<TextEditingController> controllers =
      List.generate(4, (index) => TextEditingController());

  void checkOtp() {
    bool allFilled =
        controllers.every((controller) => controller.text.length == 1);
    widget.onOtpEntered(allFilled); // Notify parent with the result

    if (allFilled) {
      // Combine OTP values and send it to the parent
      String otp = controllers.map((controller) => controller.text).join();
      widget.onOtpChanged(otp);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
        child: Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: List.generate(4, (index) {
        return Container(
          margin: EdgeInsets.only(right: 4),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: ligtBlackColor,
          ),
          height: 40,
          width: 41,
          child: TextFormField(
            controller: controllers[index],
            onChanged: (value) {
              setState(() {
                checkOtp(); // Check OTP status after each change
              });
              if (value.length == 1 && index < 5) {
                FocusScope.of(context).nextFocus();
              } else if (value.isEmpty && index > 0) {
                FocusScope.of(context).previousFocus();
              }
            },
            style: GoogleFonts.mulish(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: whiteColor,
            ),
            decoration: InputDecoration(
              border: InputBorder.none,
            ),
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            inputFormatters: [
              LengthLimitingTextInputFormatter(1),
              FilteringTextInputFormatter.digitsOnly
            ],
          ),
        );
      }),
    ));
  }
}
