import 'package:cureeit_user_app/cards/address_card.dart';
import 'package:cureeit_user_app/current_address/google_maps_screen.dart';
import 'package:cureeit_user_app/utils/theme.dart';
import 'package:flutter/material.dart';
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
      'http://ec2-13-60-8-94.eu-north-1.compute.amazonaws.com:3000/address/savedAddress',
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

  void selectAddress(Map<String, dynamic> address) {
    setState(() {
      selectedAddress = address;
    });

    Navigator.pop(context, address);
  }

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
                    style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 24,
                        fontFamily: "JosefinSans",
                        color: primaryColor),
                  ),
                  Column(
                      children: addresses
                          .map(
                            (address) => AddressCard(
                                isSelected: true,
                                address: address,
                                onTap: () => selectAddress(address)),
                          )
                          .toList()),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12.0),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => GoogleMapsScreen()
                              // builder: (context) => AddAddressScreen(
                              //   userId: "eb7b25bc9d58880c",
                              // ),
                              ),
                        );
                      },
                      child: Container(
                        padding:
                            EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Text(
                          "+ Add new address",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: Color.fromARGB(255, 10, 21, 81),
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
