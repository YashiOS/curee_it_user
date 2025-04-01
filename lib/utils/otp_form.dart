import 'package:cureeit_user_app/utils/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
      List.generate(6, (index) => TextEditingController());

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
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(6, (index) {
        return Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Color.fromARGB(255, 196, 220, 238),
                blurRadius: 1,
                spreadRadius: 1,
              ),
            ],
            borderRadius: BorderRadius.circular(12),
            color: Colors.white,
          ),
          height: 50,
          width: 42,
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
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: secondaryColor,
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
