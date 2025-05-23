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
                "1. Service Scope",
                style: GoogleFonts.mulish(
                    color: greenColor, fontSize: 18, fontWeight: FontWeight.w700),
              ),
              Text(
                "Medkaro facilitates the delivery of medicines and healthcare products in partnership with licensed pharmacies. We do not sell medicines directly.",
                style: GoogleFonts.mulish(
                    color: whiteColor, fontSize: 15, fontWeight: FontWeight.w300),
              ),
              Text(
                "2. Prescription Policy",
                style: GoogleFonts.mulish(
                    color: greenColor, fontSize: 18, fontWeight: FontWeight.w700),
              ),
              Text(
                '''Over-the-counter (OTC) medicines are available without a prescription as per Indian drug laws.
        
Scheduled medicines (e.g., Schedule H, H1, X) will only be delivered against a valid prescription issued by a registered medical practitioner.''',
                style: GoogleFonts.mulish(
                    color: whiteColor, fontSize: 15, fontWeight: FontWeight.w300),
              ),
              Text(
                "3. Customer Responsibility",
                style: GoogleFonts.mulish(
                    color: greenColor, fontSize: 18, fontWeight: FontWeight.w700),
              ),
              Text(
                '''Customers must ensure the accuracy of their prescriptions and order details.
        
For prescription medicines, you may be required to upload a clear and valid prescription for verification.''',
                style: GoogleFonts.mulish(
                    color: whiteColor, fontSize: 15, fontWeight: FontWeight.w300),
              ),
                 Text(
                "4. Order Acceptance and Fulfillment",
                style: GoogleFonts.mulish(
                    color: greenColor, fontSize: 18, fontWeight: FontWeight.w700),
              ),
              Text(
                '''Orders are confirmed subject to availability and verification of prescriptions where applicable.
        
Medkaro reserves the right to cancel any order if it does not comply with these terms.''',
                style: GoogleFonts.mulish(
                    color: whiteColor, fontSize: 15, fontWeight: FontWeight.w300),
              ),
              Text(
                "5. Limitation of Liability",
                style: GoogleFonts.mulish(
                    color: greenColor, fontSize: 18, fontWeight: FontWeight.w700),
              ),
               Text(
                "Medkaro acts as an intermediary between customers and pharmacies. We are not liable for any issues related to the quality, efficacy, or adverse reactions of the medicines delivered.",
                style: GoogleFonts.mulish(
                    color: whiteColor, fontSize: 15, fontWeight: FontWeight.w300),
              ),
              Text(
                "6. Compliance with Laws",
                style: GoogleFonts.mulish(
                    color: greenColor, fontSize: 18, fontWeight: FontWeight.w700),
              ),
              Text(
                '''All transactions comply with the Drugs and Cosmetics Act, 1940, and other applicable laws in India.

For any clarifications, feel free to reach out to our customer support team at medkaro.in@gmail.com.''',
                style: GoogleFonts.mulish(
                    color: whiteColor, fontSize: 15, fontWeight: FontWeight.w300),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
