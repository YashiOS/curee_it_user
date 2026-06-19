import 'dart:convert';
import 'package:cureeit_user_app/BaseUrl.dart';
import 'package:cureeit_user_app/LocalStorageCubit/store_user_cubit.dart';
import 'package:cureeit_user_app/screens/location.dart';
import 'package:cureeit_user_app/screens/login/presentation/login_screen.dart';
import 'package:cureeit_user_app/user/user.dart';
import 'package:cureeit_user_app/utils/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String? name;
  String? phoneNumber;

  @override
  void initState() {
    super.initState();
    fetchUserProfile();
  }

  void showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: lightWhiteColor, // Dark background
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Are you sure you want to\nlogout?",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 17.02,
                  fontFamily: 'Mulish',
                  color: blackColor,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context); // Close the dialog
                    },
                    child: const Text(
                      "Cancel",
                      style: TextStyle(
                        color: blackColor,
                        fontSize: 17.13,
                        fontFamily: 'Mulish',
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      context.read<StoreUserCubit>().clearUserData();
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => LoginScreen()));
                      // Perform logout logic here
                    },
                    child: const Text(
                      "Logout",
                      style: TextStyle(
                        color: Color(0xFFBE404F), // reddish color
                        fontSize: 17.13,
                        fontFamily: 'Mulish',
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> fetchUserProfile() async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/profile/user/profileDetails'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({"userId": User.userId}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        setState(() {
          name = data["data"]["name"];
          phoneNumber = data["data"]["mobileNumber"];
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('failed to load user profile  error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          scrolledUnderElevation: 0,
          elevation: 0,
          centerTitle: true,
          shape: ContinuousRectangleBorder(
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(0),
              bottomRight: Radius.circular(0),
            ),
          ),
          backgroundColor: blackColor,
          leadingWidth: 100,
          title: Text(
            "Settings",
            style: GoogleFonts.mulish(
                fontWeight: FontWeight.w400,
                fontSize: 22.69,
                color: WhiteColor),
          ),
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
                          ColorFilter.mode(WhiteColor, BlendMode.srcIn),
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
        body: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
          ),
          color: Colors.black,
          child: Column(
            children: [
              SizedBox(
                height: 28,
              ),
              Container(
                padding: const EdgeInsets.only(top: 24, bottom: 24, left: 16),
                decoration: BoxDecoration(
                  color: blackColor, // dark background
                  borderRadius: BorderRadius.circular(8),
                  // border: Border.all(
                  //   color: Colors.grey.shade300, // light grey border
                  //   width: 1,
                  // ),
                ),
                child: Row(
                  children: [
                    // Circle Avatar Placeholder
                    Container(
                      width: 36,
                      height: 36,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                      ),
                      child: Image.asset("lib/images/profileIcon.png"),
                    ),
                    const SizedBox(width: 16),

                    // Name & Phone
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${name ?? User.name}",
                          style: GoogleFonts.mulish(
                            color: WhiteColor,
                            fontSize: 18,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          "${phoneNumber ?? User.phoneNumber}",
                          style: GoogleFonts.mulish(
                            color: WhiteColor,
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
                height: 16,
              ),
              GestureDetector(
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => LocationScreen()));
                },
                child: Container(
                  padding: const EdgeInsets.only(top: 16, bottom: 16, left: 16),
                  decoration: BoxDecoration(
                    color: blackColor, // dark background
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        child: const Center(
                          child: Icon(
                            Icons.location_on, // Location icon
                            color: WhiteColor,
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
                              color: WhiteColor,
                              fontSize: 18,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            "Edit and add new addresses",
                            style: GoogleFonts.mulish(
                              color: WhiteColor,
                              fontWeight: FontWeight.w300,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: 16,
              ),
              GestureDetector(
                onTap: () async {
                  showModalBottomSheet(
                    context: context,
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(20)),
                    ),
                    backgroundColor: blackColor,
                    builder: (context) {
                      return Padding(
                        padding: const EdgeInsets.only(
                            left: 16, right: 16, top: 16, bottom: 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 40,
                              height: 4,
                              decoration: BoxDecoration(
                                color: greyColor,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                GestureDetector(
                                  onTap: () async {
                                    Navigator.pop(context);
                                    final uri = Uri.parse("tel:+91 8910115375");
                                    if (await canLaunchUrl(uri)) {
                                      await launchUrl(uri);
                                    }
                                  },
                                  child: Container(
                                    height: 40,
                                    width: 90,
                                    decoration: BoxDecoration(
                                      color:
                                          greenColor, // Optional: change or remove for transparent
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.phone,
                                          color: homepageWhite,
                                          size: 16,
                                        ),
                                        SizedBox(width: 10),
                                        Text(
                                          "Call",
                                          style: GoogleFonts.mulish(
                                            color: homepageWhite,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () async {
                                    Navigator.pop(context);
                                    final uri =
                                        Uri.parse("mailto:accounts@medkaro.in");
                                    if (await canLaunchUrl(uri)) {
                                      await launchUrl(uri);
                                    }
                                  },
                                  child: Container(
                                    height: 40,
                                    width: 90,
                                    decoration: BoxDecoration(
                                      color: greenColor, // Optional background
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.email,
                                          color: homepageWhite,
                                          size: 16,
                                        ),
                                        SizedBox(width: 12),
                                        Text(
                                          "Email",
                                          style: GoogleFonts.mulish(
                                            color: homepageWhite,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              ],
                            )
                          ],
                        ),
                      );
                    },
                  );
                  //final phoneNumber="+91 8910115375";
                  //final Uri launchUri=Uri(
                  //scheme: 'tel',
                  //path: phoneNumber
                  //);
                  //if(await canLaunchUrl(launchUri)){
                  //await launchUrl(launchUri);
                  //}else{
                  //print("faild to launch ");
                  //}
                },
                child: Container(
                  padding: const EdgeInsets.only(top: 16, bottom: 16, left: 16),
                  decoration: BoxDecoration(
                    color: blackColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        child: const Center(
                          child: Icon(
                            Icons
                                .headphones_outlined, // Updated icon for support
                            color: WhiteColor,
                            size: 28,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),

                      // Title & Subtitle
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Help", // Updated title
                            style: GoogleFonts.mulish(
                              color: WhiteColor,
                              fontSize: 18,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          SizedBox(height: 2),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: 16,
              ),
              GestureDetector(
                onTap: () {
                  showLogoutDialog(context);
                },
                child: Container(
                  padding: const EdgeInsets.only(top: 16, bottom: 16, left: 16),
                  decoration: BoxDecoration(
                    color: blackColor, // dark background
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      // Circle Avatar Placeholder
                      Container(
                        width: 36,
                        height: 36,
                        child: const Center(
                          child: Icon(
                            Icons.logout, // Location icon
                            color: WhiteColor,
                            size: 28,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),

                      // Name & Phone
                      Text(
                        "Logout",
                        style: GoogleFonts.mulish(
                          color: Colors.red,
                          fontSize: 18,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ));
  }
}
