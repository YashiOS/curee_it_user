import 'package:cureeit_user_app/BaseUrl.dart';
import 'package:cureeit_user_app/cards/address_card.dart';
import 'package:cureeit_user_app/current_address/google_maps_screen.dart';
import 'package:cureeit_user_app/selected_Address/currentAddress.dart';
import 'package:cureeit_user_app/utils/theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class AddressesScreen extends StatefulWidget {
  final String userId;
  const AddressesScreen({super.key, required this.userId});

  @override
  State<AddressesScreen> createState() => _AddressesScreenState();
}

class _AddressesScreenState extends State<AddressesScreen> {
  List<dynamic> addresses = []; // List to store addresses
  Map<String, dynamic>? selectedAddress;

  @override
  void initState() {
    super.initState();
    fetchAddresses(); // Fetch addresses when screen is loaded
  }

  // Function to fetch addresses from the API
  Future<void> fetchAddresses() async {
    var url = Uri.parse(
      '$baseUrl/address/savedAddress',
    );

    // Create the GET request with the userId as query parameter
    var request = http.Request('GET', url)
      ..headers.addAll({
        'Content-Type': 'application/json',
      })
      ..body = jsonEncode({'userId': widget.userId});

    var response = await http.Client().send(request);

    if (response.statusCode == 200) {
      final data = json.decode(await response.stream.bytesToString());
      setState(() {
        addresses = data['data']['address'];
      });
    } else {
      print('Failed to load addresses');
    }
  }

  void selectAddress(Map<String, dynamic> address,int index) {
    setState(() {
      Address.CurrentAddress = address;
      Address.selectedIndex=index;
      selectedAddress = address;

    });

    Navigator.pop(context, address);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: scaffoldBlackColor,
      appBar: AppBar(
        backgroundColor: scaffoldBlackColor,
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
                  Icon(Icons.arrow_back, color: whiteColor),
                  Text(
                    "Back",
                    style: GoogleFonts.mulish(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: whiteColor),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          SizedBox(
        
            width:
                MediaQuery.of(context).size.width, // Set width to screen width
            height: MediaQuery.of(context).size.height,
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 8.0, horizontal: 18),
              child: (ListView(
                children: [
                  Text(
                    "Addresses",
                    style: GoogleFonts.mulish(
                        fontWeight: FontWeight.w600,
                        fontSize: 24,
                      
                        color: whiteColor),
                  ),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: addresses.length,
                    
                    itemBuilder: (context, index) {
                      bool isSelected= Address.selectedIndex==index;
                      final address = addresses[index];
                      return AddressCard(
                        isSelected: isSelected,
                        address: address,
                        onTap: () => selectAddress(address,index),
                      );
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12.0),
                    child: GestureDetector(
                      onTap: () async{
                       await Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => GoogleMapsScreen()
                              // builder: (context) => AddAddressScreen(
                              //   userId: "eb7b25bc9d58880c",
                              // ),
                              ),
                        );
                        setState(() {
                          
                        });
                      },
                      child: Container(
                        padding:
                            EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                        decoration: BoxDecoration(
                          color:ligtBlackColor,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Text(
                          "+ Add new address",
                          style: GoogleFonts.mulish(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: whiteColor,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              )),
            ),
          ),
        ],
      ),
    );
  }
}
