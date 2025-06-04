import 'dart:convert';

import 'package:cureeit_user_app/BaseUrl.dart';
import 'package:cureeit_user_app/LocalStorageCubit/store_user_cubit.dart';
import 'package:cureeit_user_app/screens/location.dart';
import 'package:cureeit_user_app/screens/login_screen.dart';
import 'package:cureeit_user_app/user/user.dart';
import 'package:cureeit_user_app/utils/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

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
        backgroundColor: ligtBlackColor, // Dark background
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
                  color: Colors.white,
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
                        color: Colors.white,
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
    print("fetchUserProfile...");
    try {
      final response = await http.post(
        Uri.parse(
            '$baseUrl/profile/user/profileDetails'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({"userId": User.userId}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print(data);
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
          backgroundColor: ligtBlackColor,
          leadingWidth: 100,
          title: Text(
            "Profile",
            style: GoogleFonts.mulish(
                fontWeight: FontWeight.w400,
                fontSize: 22.69,
                color: whiteColor),
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
                  children: [SvgPicture.asset(
                    colorFilter:
                        ColorFilter.mode(Colors.white, BlendMode.srcIn),
                    "lib/images/back.svg",
                    width: 24, // optional
                    height: 24, // optional
                  ),],
                ),
              ),
            ),
          ),
        ),
        body: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20,),
          color: scaffoldBlackColor,
          child: Column(
            children: [
              SizedBox(
                height: 28,
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
                            color: whiteColor,
                            fontSize: 18,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          "${phoneNumber ?? User.phoneNumber}",
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
                    color: ligtBlackColor, // dark background
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
                    color: ligtBlackColor, // dark background
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
                          color: Color(0xFFBE404F),
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
