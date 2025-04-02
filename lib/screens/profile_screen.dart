import 'package:cureeit_user_app/utils/theme.dart';
import 'package:flutter/material.dart';

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
        backgroundColor: Colors.grey.shade100.withOpacity(0.5),
        leadingWidth: 100,
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
                  Icon(Icons.arrow_back, color: primaryColor),
                  Text(
                    "Back",
                    style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        fontFamily: "Urbanist",
                        color: primaryColor),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
      body: Container(
        color: Colors.grey.shade100.withOpacity(0.5),
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 18),
          child: Stack(
            children: [
              ListView(
                children: [
                  Text(
                    "My Profile",
                    style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 24,
                        fontFamily: "JosefinSans",
                        color: primaryColor),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 18.0),
                    child: Column(
                      spacing: 8,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Padding(
                            padding: const EdgeInsets.only(left: 6.0),
                            child: Text(
                              "Name",
                              style: TextStyle(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 10,
                                  fontFamily: "Urbanist",
                                  color: Colors.black.withOpacity(0.6)),
                            ),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: TextField(
                            controller: _fullName,
                            decoration: InputDecoration(
                              //labelText: "Full Name",
                              hintText: "Gagan Pareek",
                              hintStyle: TextStyle(
                                  color: Color(0xFF689AC0),
                                  fontSize: 18,
                                  fontWeight: FontWeight.w400,
                                  fontFamily: "Urbanist"),
                              labelStyle: TextStyle(
                                  color: Color(0xFF689AC0),
                                  fontSize: 18,
                                  fontWeight: FontWeight.w400,
                                  fontFamily: "Urbanist"),
                              border: InputBorder.none, // Removes the underline
                            ),
                          ),
                        ),
                        //Mobile Number
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Padding(
                            padding: const EdgeInsets.only(left: 6.0),
                            child: Text(
                              "Mobile Number",
                              style: TextStyle(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 10,
                                  fontFamily: "Urbanist",
                                  color: Colors.black.withOpacity(0.6)),
                            ),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: TextField(
                            controller: _mobileNumber,
                            decoration: InputDecoration(
                              hintText: "+91-87284767998",
                              hintStyle: TextStyle(
                                  color: Color(0xFF689AC0),
                                  fontSize: 18,
                                  fontWeight: FontWeight.w400,
                                  fontFamily: "Urbanist"),
                              //labelText: "Full Name",
                              labelStyle: TextStyle(
                                  color: Color(0xFF689AC0),
                                  fontSize: 18,
                                  fontWeight: FontWeight.w400,
                                  fontFamily: "Urbanist"),
                              border: InputBorder.none, // Removes the underline
                            ),
                          ),
                        ),
                        //email
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Padding(
                            padding: const EdgeInsets.only(left: 6.0),
                            child: Text(
                              "Email",
                              style: TextStyle(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 10,
                                  fontFamily: "Urbanist",
                                  color: Colors.black.withOpacity(0.6)),
                            ),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: TextField(
                            controller: _emailAddress,
                            decoration: InputDecoration(
                              //labelText: "Full Name",
                              hintText: "gaganpareek@gmail.com",
                              hintStyle: TextStyle(
                                  color: Color(0xFF689AC0),
                                  fontSize: 18,
                                  fontWeight: FontWeight.w400,
                                  fontFamily: "Urbanist"),
                              labelStyle: TextStyle(
                                  color: Color(0xFF689AC0),
                                  fontSize: 18,
                                  fontWeight: FontWeight.w400,
                                  fontFamily: "Urbanist"),
                              border: InputBorder.none, // Removes the underline
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Container(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 18.0),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Image.asset(
                        "lib/images/bottom_button.png",
                        height: 58,
                        width: 120,
                        fit: BoxFit.contain,
                      ),
                      Text(
                        "Save",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontFamily: "Urbanist",
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
