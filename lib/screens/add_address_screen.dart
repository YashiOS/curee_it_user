import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AddAddressScreen extends StatefulWidget {
  final String userId;
  final double userLat;
  final double userLong;
  const AddAddressScreen(
      {super.key,
      required this.userId,
      required this.userLat,
      required this.userLong});

  @override
  _AddAddressScreenState createState() => _AddAddressScreenState();
}

class _AddAddressScreenState extends State<AddAddressScreen> {
  final _line1Controller = TextEditingController();
  final _line2Controller = TextEditingController();
  final _landmarkController = TextEditingController();
  final _floorController = TextEditingController();
  final _typeController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _line1Controller.clear();
    _line2Controller.clear();
    _landmarkController.clear();
    _floorController.clear();
    _typeController.clear();
    super.dispose();
  }

  Future<void> addAddress() async {
    final String url =
        'http://ec2-13-60-8-94.eu-north-1.compute.amazonaws.com:3000/address/addAddress';

    Map<String, dynamic> addressData = {
      'userId': widget.userId.toString(),
      'address':
          "${_line1Controller.text ?? ''}, ${_line2Controller.text ?? ''}"
              .trim(),
      'landmark': _landmarkController.text.trim() ?? "",
      'floor': _floorController.text.trim() ?? "",
      'userLat': widget.userLat.toString(),
      'userLong': widget.userLong.toString(),
      'type': _typeController.text.trim() ?? "",
    };

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(addressData),
      );

      if (response.statusCode == 200) {
        Fluttertoast.showToast(msg: "Address Added");
        Navigator.pop(context);
      } else {
        print('Failed response: ${response.body}');
        Fluttertoast.showToast(msg: "Failed to add address");
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // Close button (cross)
              Align(
                alignment: Alignment.topRight,
                child: GestureDetector(
                  onTap: () {
                    Navigator.pop(context); // Close bottom sheet
                  },
                  child: Icon(
                    Icons.close,
                    color: Colors.black,
                    size: 30,
                  ),
                ),
              ),

              // Title Text
              SizedBox(height: 10),
              Text(
                "Add Address",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  fontFamily: "Urbanist", // optional if you're using this font
                  color: Colors.black, // or any color you prefer
                ),
              ),

              // Address Line 1
              SizedBox(height: 20),
              TextField(
                controller: _line1Controller,
                decoration: InputDecoration(
                  labelText: "Address Line 1",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),

              // Address Line 2
              SizedBox(height: 10),
              TextField(
                controller: _line2Controller,
                decoration: InputDecoration(
                  labelText: "Address Line 2",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),

              // Landmark
              SizedBox(height: 10),
              TextField(
                controller: _landmarkController,
                decoration: InputDecoration(
                  labelText: "Landmark (Optional)",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),

              // Floor
              SizedBox(height: 10),
              TextField(
                controller: _floorController,
                decoration: InputDecoration(
                  labelText: "Floor (Optional)",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),

              // Type (Home, Office)
              SizedBox(height: 10),
              TextField(
                controller: _typeController,
                decoration: InputDecoration(
                  labelText: "Type (e.g., Home, Office)",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),

              // Add Address Button
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: addAddress,
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      const Color(0xFF2E7D32), // Material Design Green 800
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(vertical: 18, horizontal: 32),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 1,
                  shadowColor: Colors.black.withOpacity(0.25),
                  minimumSize: const Size(200, 50),
                  animationDuration: const Duration(milliseconds: 200),
                  enableFeedback: true,
                ).copyWith(
                  overlayColor: MaterialStateProperty.resolveWith<Color>(
                    (states) {
                      if (states.contains(MaterialState.pressed)) {
                        return Colors.white.withOpacity(0.2);
                      }
                      return Colors.transparent;
                    },
                  ),
                ),
                child: const Text(
                  "Add Address",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
