import 'package:cureeit_user_app/utils/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';

class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: scaffoldBlackColor,
      appBar: AppBar(
        scrolledUnderElevation: 0,
            elevation: 0,
        centerTitle: true,
        shape: ContinuousRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(10),
            bottomRight: Radius.circular(10),
          ),
        ),
        title: Text(
          "Terms of service",
          style: GoogleFonts.mulish(
              color: whiteColor, fontSize: 22.69, fontWeight: FontWeight.w400),
        ),
        backgroundColor: ligtBlackColor,
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: Padding(
            padding: const EdgeInsets.only(left: 24.0),
            child: Padding(
              padding: const EdgeInsets.only(left: 4.0),
              child: Row(
                spacing: 4,
                children: [
                 SvgPicture.asset(
                    colorFilter:
                        ColorFilter.mode(Colors.white, BlendMode.srcIn),
                    "lib/images/back.svg",
                    width: 24, // optional
                    height: 24, // optional
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(20),
          child: Column(
            spacing: 10,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Return Policy",
                style: GoogleFonts.mulish(
                    color: whiteColor, fontSize: 18, fontWeight: FontWeight.w700),
              ),
              Text(
                '''Returns are only accepted in the following cases:

Incorrect medicines delivered.

Medicines past their expiry date.

Products must be returned in their original, unopened packaging with the invoice.''',
                style: GoogleFonts.mulish(
                    color: whiteColor, fontSize: 15, fontWeight: FontWeight.w300),
              ),
              Text(
                "How to Return",
                style: GoogleFonts.mulish(
                    color: whiteColor, fontSize: 18, fontWeight: FontWeight.w700),
              ),
              Text(
                '''Customers can return the product by either:

Requesting a pickup (subject to availability).

Dropping it off at the partner pharmacy.''',
                style: GoogleFonts.mulish(
                    color: whiteColor, fontSize: 15, fontWeight: FontWeight.w300),
              ),
              Text(
                "Cancellation Policy",
                style: GoogleFonts.mulish(
                    color: whiteColor, fontSize: 18, fontWeight: FontWeight.w700),
              ),
              Text(
                '''Orders cannot be canceled once confirmed. We appreciate your understanding and cooperation. For any concerns, please contact our support team at''',
                style: GoogleFonts.mulish(
                    color: whiteColor, fontSize: 15, fontWeight: FontWeight.w300),
              ),
                 Text(
                "medkaro.in@gmail.com.",
                style: GoogleFonts.mulish(
                    color: greenColor, fontSize: 15, fontWeight: FontWeight.w500),
              ),
             
            ],
          ),
        ),
      ),
    );
  }
}
