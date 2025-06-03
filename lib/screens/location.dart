import 'dart:convert';
import 'package:cureeit_user_app/BaseUrl.dart';
import 'package:cureeit_user_app/current_address/google_maps_screen.dart';
import 'package:cureeit_user_app/selected_Address/currentAddress.dart';
import 'package:cureeit_user_app/user/user.dart';
import 'package:cureeit_user_app/utils/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

class LocationScreen extends StatefulWidget {
  const LocationScreen({super.key});

  @override
  State<LocationScreen> createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  List<dynamic> addresses = [];
  bool fetchingAddress=false;

  @override
  void initState() {
    fetchAddresses();
    // TODO: implement initState
    super.initState();
  }

  Future<void> fetchAddresses() async {
    setState(() {
      fetchingAddress=true;
    });
    var url = Uri.parse(
      '$baseUrl/address/savedAddress',
    );

    // Create the GET request with the userId as query parameter
    var request = http.Request('GET', url)
      ..headers.addAll({
        'Content-Type': 'application/json',
      })
      ..body = jsonEncode({'userId': User.userId});

    var response = await http.Client().send(request);

    if (response.statusCode == 200) {
      final data = json.decode(await response.stream.bytesToString());
      final fetchAddress = data["data"]["address"];
      setState(() {
        fetchingAddress=false;
      });
      if (fetchAddress != null || fetchAddress.isNotEmpty) {
        addresses = data['data']['address'];
        setState(() {});
        print(addresses);
      }
    } else {
       setState(() {
        fetchingAddress=false;
      });
      print('Failed to load addresses');
    }
     setState(() {
        fetchingAddress=false;
      });
  }

  void UpdateAddress(Map<String, dynamic> address) {
    Address.CurrentAddress = address;

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: ligtBlackColor,
        appBar: AppBar(
          scrolledUnderElevation: 0,
            elevation: 0,
          centerTitle: true,
          backgroundColor: ligtBlackColor,
          shape: ContinuousRectangleBorder(
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(10),
              bottomRight: Radius.circular(10),
            ),
          ),
          title: Text(
            "Address",
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
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          color: scaffoldBlackColor,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 28,
              ),
              GestureDetector(
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => GoogleMapsScreen()));
                },
                child: Container(
                  padding: const EdgeInsets.only(top: 8, bottom: 8, left: 8),
                  decoration: BoxDecoration(
                    color: ligtBlackColor, // dark background
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Circle Avatar Placeholder\
                      const SizedBox(width: 16),
                      Container(
                        height: 16,
                        width: 16,
                        child: Image.asset("lib/images/Search_light.png"),
                      ),
                      //Image.asset("lib/images/Search_light.png",scale: 0.8,),
                      const SizedBox(width: 16),

                      Container(
                        child: Text(
                          "Search for your location",
                          style: GoogleFonts.mulish(
                            color: whiteColor,
                            fontWeight: FontWeight.w300,
                            fontSize: 17,
                          ),
                        ),
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
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => GoogleMapsScreen()));
                },
                child: Container(
                  padding: const EdgeInsets.only(top: 8, bottom: 8, left: 8),
                  decoration: BoxDecoration(
                    color: ligtBlackColor, // dark background
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Circle Avatar Placeholder\
                      const SizedBox(width: 16),
                      Container(
                        height: 16,
                        width: 16,
                        child: Image.asset("lib/images/Add_ring_light.png"),
                      ),
                      //Image.asset("lib/images/Search_light.png",scale: 0.8,),
                      const SizedBox(width: 16),

                      // Name & Phone

                      Container(
                        child: Text(
                          "Type your address",
                          style: GoogleFonts.mulish(
                            color: whiteColor,
                            fontWeight: FontWeight.w300,
                            fontSize: 17,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: 16,
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.0),
                child: Text(
                  "Saved address",
                  style: GoogleFonts.mulish(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: whiteColor,
                  ),
                ),
              ),
              SizedBox(
                height: 24,
              ),
              Expanded(
                child: Container(
                  
                  child:fetchingAddress?Center(
                    child: CircularProgressIndicator(
                      color: whiteColor,
                    ),
                  ): addresses.isEmpty
                      ? Center(
                          child: Text(
                          "No saved addresses",
                           style: GoogleFonts.mulish(
                            fontWeight: FontWeight.w500,
                            fontSize: 20,
                            color: greyColor,
                          ),
                        ))
                      : ListView.builder(
                          shrinkWrap: true,
                          itemCount: addresses.length,
                          itemBuilder: (context, index) {
                            var address = addresses[index];
                            bool isSelected = Address.selectedIndex == index;
                            return GestureDetector(
                              onTap: () {
                                print(address);
                                UpdateAddress(address);
                
                                setState(() {
                                  Address.selectedIndex = index;
                                });
                                Navigator.pop(context);
                              },
                              child: Column(
                                children: [
                                  Container(
                                      padding: EdgeInsets.only(
                                        left: 25,
                                        right: 16,
                                      ),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(8),
                                        color: ligtBlackColor,
                                      ),
                                      margin: EdgeInsets.only(bottom: 16),
                                      child: Container(
                                        height: 75,
                                        padding: EdgeInsets.symmetric(
                                            vertical:
                                                8), // Match ListTile's vertical padding
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            // Leading icon (16x16 with 8px right margin)
                                            Container(
                                              // Space between icon and text
                                              decoration: BoxDecoration(
                                                color: ligtBlackColor,
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              child: Container(
                                                height: 16,
                                                width: 16,
                                                child: Image.asset(
                                                    "lib/images/hugeicons_location.png"),
                                              ),
                                            ),
                                            SizedBox(width: 16,),
                                      
                                            Expanded(
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    address['address'] ?? '',
                                                    style: GoogleFonts.mulish(
                                                      fontSize: 15,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      color: whiteColor,
                                                    ),
                                                  ),
                                                  SizedBox(
                                                      height:
                                                          2), // Space between title and subtitle
                                                  Text(
                                                    address['landmark'] ?? '',
                                                    style: GoogleFonts.mulish(
                                                      fontSize: 13,
                                                      fontWeight:
                                                          FontWeight.w300,
                                                      color: whiteColor,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                
                                            // Trailing radio button
                                            Container(
                                              width: 16,
                                              height: 16,
                                              margin: EdgeInsets.only(
                                                  left:
                                                      8), // Space before trailing widget
                                              decoration: BoxDecoration(
                                                color: isSelected
                                                    ? greenColor
                                                    : scaffoldBlackColor,
                                                shape: BoxShape.circle,
                                              ),
                                            ),
                                          ],
                                        ),
                                      )),
                                ],
                              ),
                            );
                          },
                        ),
                ),
              )
            ],
          ),
        ));
  }
}
