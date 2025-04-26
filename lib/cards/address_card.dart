import 'package:cureeit_user_app/utils/theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AddressCard extends StatelessWidget {
  final bool isSelected;
  final Map<String, dynamic> address;
  final VoidCallback onTap;
  const AddressCard(
      {super.key,
      required this.isSelected,
      required this.address,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 18, horizontal: 10),
          decoration: BoxDecoration(
            color: ligtBlackColor,
            borderRadius: BorderRadius.circular(14),
            border: isSelected
                ? Border.all(
                    color: greenColor, width: 2) // Highlight selection
                : Border.all(color: Colors.transparent),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Image.asset(
                    isSelected
                        ? "lib/images/selected_button.png"
                        : "lib/images/nonselected_button.png",
                    height: 24,
                    width: 24,
                    fit: BoxFit.contain,
                  ),
                  SizedBox(width: 12), // Spacing between image and text
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        address['type'],
                        style: GoogleFonts.mulish(
                          color: whiteColor,
                          fontSize: 20,
                         
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.7,
                        child: Text(
                          address['address'],
                          style: GoogleFonts.mulish(
                            color:whiteColor,
                            fontSize: 14,
                            
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
