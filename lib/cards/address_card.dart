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
      child: Container(
          padding: EdgeInsets.only(
            left: 25,
            right: 16,
            
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: lightWhiteColor,
          ),
          margin: EdgeInsets.only(bottom: 16),
          child: Center(
            child: Container(
              height: 75,
             
              child: Row(
                
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Leading icon (16x16 with 8px right margin)
                  Container(
                    // Space between icon and text
                    decoration: BoxDecoration(
                      color: lightWhiteColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Container(
                      height: 16,
                      width: 16,
                      child: Image.asset("lib/images/hugeicons_location.png"),
                    ),
                  ),
                  SizedBox(
                    width: 16,
                  ),
                  
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          address['address'] ?? '',
                          style: GoogleFonts.mulish(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: blackColor,
                          ),
                        ),
                        SizedBox(height: 2), // Space between title and subtitle
                        Text(
                          address['type'] ?? '',
                          style: GoogleFonts.mulish(
                            fontSize: 13,
                            fontWeight: FontWeight.w300,
                            color: blackColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Trailing radio button
                  Container(
                    width: 16,
                    height: 16,
                    margin:
                        EdgeInsets.only(left: 8), // Space before trailing widget
                    decoration: BoxDecoration(
                      color: isSelected ? greenColor :  scaffoldWhiteColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ),
            ),
          )),
    );
    /*GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
          decoration: BoxDecoration(
            color: lightWhiteColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        address['type'],
                        style: GoogleFonts.mulish(
                          color: blackColor,
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.7,
                        child: Text(
                          address['address'],
                          style: GoogleFonts.mulish(
                            color: blackColor,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                ],
              ),
              Container(
                    width: 16,
                    height: 16,
                    margin: EdgeInsets.only(
                        left: 8), // Space before trailing widget
                    decoration: BoxDecoration(
                      color:isSelected? greenColor: scaffoldWhiteColor,
                      shape: BoxShape.circle,
                    ),
                  ),
            ],
          ),
        ),
      ),
    );*/
  }
}
