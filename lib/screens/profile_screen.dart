import 'package:cureeit_user_app/utils/theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _fullName = TextEditingController();
  final _mobileNumber = TextEditingController();
  final _emailAddress = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: ligtBlackColor,
          leadingWidth: 100,
          title: Text(
            "Profile",
            style: GoogleFonts.mulish(
                fontWeight: FontWeight.w300, fontSize: 24, color: whiteColor),
          ),
          leading: Padding(
            padding: const EdgeInsets.only(left: 12.0),
            child: GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: Padding(
                padding: const EdgeInsets.only(left: 4.0),
                child: Row(
                  spacing: 4,
                  children: [
                    Icon(
                      Icons.arrow_back,
                      color: whiteColor,
                      weight: 10,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        body: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          color: scaffoldBlackColor,
          child: Column(
            children: [
              SizedBox(
                height: 35,
              ),
              Container(
                padding: const EdgeInsets.only(top: 24, bottom: 24, left: 16),
                decoration: BoxDecoration(
                  color: ligtBlackColor, // dark background
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    // Circle Avatar Placeholder
                    Container(
                      width: 46,
                      height: 46,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: whiteColor,
                      ),
                    ),
                    const SizedBox(width: 16),

                    // Name & Phone
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Saksham",
                          style: GoogleFonts.mulish(
                            color: whiteColor,
                            fontSize: 18,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          "8910115375",
                          style: GoogleFonts.mulish(
                            color: whiteColor,
                            fontWeight: FontWeight.w300,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 24,
              ),
              
              Container(
                padding: const EdgeInsets.only(top: 16, bottom: 16, left: 16),
                decoration: BoxDecoration(
                  color: ligtBlackColor, // dark background
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    // Circle Avatar Placeholder
                    Container(
                      width: 46,
                      height: 46,
                      
                      child: const Center(
                        child: Icon(
                          Icons.location_on, // Location icon
                          color: whiteColor,
                          size: 28,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),

                    // Name & Phone
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Address",
                          style: GoogleFonts.mulish(
                            color: whiteColor,
                            fontSize: 18,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          "Edit and add new addresses",
                          style: GoogleFonts.mulish(
                            color: whiteColor,
                            fontWeight: FontWeight.w300,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
                SizedBox(
                height: 24,
              ),
              
              Container(
                padding: const EdgeInsets.only(top: 16, bottom: 16, left: 16),
                decoration: BoxDecoration(
                  color: ligtBlackColor, // dark background
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    // Circle Avatar Placeholder
                    Container(
                      width: 46,
                      height: 46,
                      
                      child: const Center(
                        child: Icon(
                          Icons.logout, // Location icon
                          color: whiteColor,
                          size: 28,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),

                    // Name & Phone
                    Text(
                      "Logout",
                      style: GoogleFonts.mulish(
                        color: Colors.redAccent,
                        fontSize: 18,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              )
             
             
            ],
          ),
        ));
  }
}
