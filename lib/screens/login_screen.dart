import 'package:cureeit_user_app/screens/otp_screen.dart';
import 'package:cureeit_user_app/utils/theme.dart';
import 'package:flutter/material.dart';

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
    return Scaffold(
        //appBar: AppBar(),
        body: Container(
      color: Colors.grey.shade100.withOpacity(0.5),
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      child: Padding(
        padding: const EdgeInsets.all(22.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 12,
          children: [
            Image.asset(
              "lib/images/capsule_image.png",
              height: 60,
              width: 60,
            ),
            Text(
              "Curee it",
              style: TextStyle(
                  color: primaryColor,
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -1),
            ),
            Text(
              "Ordering Medicines is made easy through three easy steps Browse, Select and Order. A good and exciting step, Curee it.",
              style: TextStyle(
                  color: Color(0xFF689AC0),
                  fontSize: 14,
                  fontWeight: FontWeight.w400),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 36.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 6, horizontal: 18),
                    decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: Color.fromARGB(255, 196, 220, 238),
                            blurRadius: 1,

                            /// Offset for the shadow (x, y)
                            spreadRadius: 1, // How much the shadow spreads
                          ),
                        ],
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.white),
                    child: Row(
                      spacing: 12,
                      children: [
                        Text(
                          "+91",
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              letterSpacing: -1),
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width / 2,
                          child: TextField(
                            controller: _controller,
                            keyboardType: TextInputType.number,
                            maxLength: 10,
                            style: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.w500),
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: 'Mobile Number',
                              hintStyle:
                                  TextStyle(color: Colors.blueGrey.shade300),
                              counterText: "",
                              labelStyle: TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _validateAndProceed,
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      padding: EdgeInsets.all(20),
                      backgroundColor: secondaryColor,
                    ),
                    child: Icon(
                      Icons.arrow_forward,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    ));
  }
}
