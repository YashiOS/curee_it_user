import 'package:cureeit_user_app/utils/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class OtpForm extends StatefulWidget {
  final Function(bool) onOtpEntered;
  final Function(String) onOtpChanged;

  const OtpForm({
    super.key,
    required this.onOtpEntered,
    required this.onOtpChanged,
  });

  @override
  _OtpFormState createState() => _OtpFormState();
}

class _OtpFormState extends State<OtpForm> {
  List<TextEditingController> controllers = List.generate(4, (_) => TextEditingController());
  List<FocusNode> focusNodes = List.generate(4, (_) => FocusNode());

  @override
  void dispose() {
    for (var controller in controllers) {
      controller.dispose();
    }
    for (var focusNode in focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  void checkOtp() {
    bool allFilled = controllers.every((controller) => controller.text.length == 1);
    widget.onOtpEntered(allFilled);

    String otp = controllers.map((controller) => controller.text).join();
    widget.onOtpChanged(otp);
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: List.generate(4, (index) {
          return Container(
            margin: EdgeInsets.only(right: 8),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: textFieldFillColor,
            ),
            height: 50,
            width: 50,
            child: TextFormField(
               cursorColor: greenColor,
              controller: controllers[index],
              focusNode: focusNodes[index],
              onChanged: (value) {
                if (value.length == 1) {
                  if (index < 3) {
                    FocusScope.of(context).requestFocus(focusNodes[index + 1]);
                  } else {
                    focusNodes[index].unfocus(); // Close keyboard after last digit
                  }
                } else if (value.isEmpty && index > 0) {
                  FocusScope.of(context).requestFocus(focusNodes[index - 1]);
                }
                checkOtp();
              },
              style: GoogleFonts.mulish(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: blackColor,
              ),
              textAlign: TextAlign.center,
              textAlignVertical: TextAlignVertical.center,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                 border: InputBorder.none,
                 isCollapsed: true, 
    contentPadding: EdgeInsets.symmetric(vertical: 12), 
              ),
              inputFormatters: [
                LengthLimitingTextInputFormatter(1),
                FilteringTextInputFormatter.digitsOnly,
              ],
            ),
          );
        }),
      ),
    );
  }
}
