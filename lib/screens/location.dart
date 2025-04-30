import 'dart:convert';

import 'package:cureeit_user_app/current_address/google_maps_screen.dart';
import 'package:cureeit_user_app/selected_Address/currentAddress.dart';
import 'package:cureeit_user_app/utils/theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

class LocationScreen extends StatefulWidget {
  const LocationScreen({super.key});

  @override
  State<LocationScreen> createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  List<dynamic> addresses = [];
 
  @override
  void initState() {
    fetchAddresses();
    // TODO: implement initState
    super.initState();
  }

  Future<void> fetchAddresses() async {
   
    var url = Uri.parse(
      'http://ec2-13-60-8-94.eu-north-1.compute.amazonaws.com:3000/address/savedAddress',
    );

    // Create the GET request with the userId as query parameter
    var request = http.Request('GET', url)
      ..headers.addAll({
        'Content-Type': 'application/json',
      })
      ..body = jsonEncode({'userId': "68fa72cbdc5f0a68"});

    var response = await http.Client().send(request);

    if (response.statusCode == 200) {
      final data = json.decode(await response.stream.bytesToString());
      final fetchAddress = data["data"]["address"];
      if (fetchAddress != null || fetchAddress.isNotEmpty) {
        addresses = data['data']['address'];
        setState(() {});
        print(addresses);
      }
    } else {
      print('Failed to load addresses');
    }
  }

  void UpdateAddress(Map<String, dynamic> address) {
    Address.CurrentAddress = address;

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: ligtBlackColor,
          title: Text(
            "Select a Location",
            style: GoogleFonts.mulish(
                fontWeight: FontWeight.w300, fontSize: 24, color: whiteColor),
          ),
          leading: Padding(
            padding: const EdgeInsets.only(left: 24.0),
            child: GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: Padding(
                padding: const EdgeInsets.only(left: 4.0),
                child: Row(
                  spacing: 4,
                  children: [Image.asset("lib/images/Vector 9.png")],
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
                height: 35,
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
                    children: [
                      // Circle Avatar Placeholder\
                      const SizedBox(width: 16),
                      Icon(
                        Icons.search_rounded,
                        color: whiteColor,
                      ),
                      //Image.asset("lib/images/Search_light.png",scale: 0.8,),
                      const SizedBox(width: 16),

                      // Name & Phone
                      SizedBox(height: 2),
                      Container(
                        height: 30,
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
                height: 24,
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
                    children: [
                      // Circle Avatar Placeholder\
                      const SizedBox(width: 16),
                      Icon(
                        Icons.add_circle_outline,
                        color: whiteColor,
                      ),
                      //Image.asset("lib/images/Search_light.png",scale: 0.8,),
                      const SizedBox(width: 16),

                      // Name & Phone
                      SizedBox(height: 2),
                      Container(
                        height: 30,
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
                height: 24,
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
              SingleChildScrollView(
                child: Container(
                  height: 470,
                  child: addresses.isEmpty
                      ? Center(
                          child: Text(
                          "No saved addresses",
                          style: GoogleFonts.mulish(color: whiteColor),
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
                              },
                              child: Column(
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      color: ligtBlackColor,
                                    ),
                                    margin: EdgeInsets.only(bottom: 10),
                                    child: ListTile(
                                      contentPadding: EdgeInsets.symmetric(
                                          horizontal: 16, vertical: 3),
                                      leading: Container(
                                        decoration: BoxDecoration(
                                          color:
                                              ligtBlackColor, // Soft blue background
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: Icon(
                                          Icons
                                              .location_on, // More modern home icon
                                          color:
                                              whiteColor, // Matching blue icon
                                          size: 22,
                                        ),
                                      ),
                                      title: Text(
                                        address['address'] ?? '',
                                        style: GoogleFonts.mulish(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w500,
                                          color:
                                              whiteColor, // Darker text for better readability
                                        ),
                                      ),
                                      subtitle: Text(
                                        address['landmark'] ?? '',
                                        style: GoogleFonts.mulish(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w300,
                                          color:
                                              whiteColor, // Slightly lighter than title
                                        ),
                                      ),
                                      trailing: Container(
                                        width: 16,
                                        height: 16,
                                        
                                        decoration:  BoxDecoration(
                                          
                                          color:isSelected ?greenColor :Colors.black,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                    ),
                                  ),
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
