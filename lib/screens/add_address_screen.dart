import 'package:cureeit_user_app/screens/home_screen.dart';
import 'package:cureeit_user_app/selected_Address/currentAddress.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';




class AddAddressScreen extends StatefulWidget {
  final String userId;
  final double userLat;
  final double userLong;

  const AddAddressScreen({
    super.key,
    required this.userId,
    required this.userLat,
    required this.userLong,
  });

  @override
  _AddAddressScreenState createState() => _AddAddressScreenState();
}

class _AddAddressScreenState extends State<AddAddressScreen> {
  final _line1Controller = TextEditingController();
  final _line2Controller = TextEditingController();
  final _landmarkController = TextEditingController();
  final _floorController = TextEditingController();
  final _typeController = TextEditingController();
  bool isButtonEnabled=false;


  

  Future<void> addAddress() async {
    const String url =
        'http://ec2-13-60-8-94.eu-north-1.compute.amazonaws.com:3000/address/addAddress';

    Map<String, dynamic> addressData = {
      'userId': widget.userId,
      'address': "${_line1Controller.text}, ${_line2Controller.text}".trim(),
      'landmark': _landmarkController.text.trim(),
      'floor': _floorController.text.trim(),
      'userLat': widget.userLat.toString(),
      'userLong': widget.userLong.toString(),
      'type': _typeController.text.trim(),
    };

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(addressData),
      );

      if (response.statusCode == 200) {
        Fluttertoast.showToast(msg: "Address Added");
        Address.CurrentAddress = {
          "address":
              "${_line1Controller.text}, ${_line2Controller.text}".trim(),
          "landmark": _landmarkController.text.trim(),
          "floor": _floorController.text.trim(),
          "userLat": widget.userLat.toString(),
          "userLong": widget.userLong.toString(),
          "type": _typeController.text.trim(),
          "_id": widget.userId,
        };
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => HomeScreen()));
      } else {
        Fluttertoast.showToast(msg: "Failed to add address");
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  InputDecoration _inputDecoration(String hint) {
  return InputDecoration(
    hintText: hint,
    hintStyle: const TextStyle(color: Colors.black54),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: Colors.grey),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: Color(0xFF0A9682), width: 2),
    ),
  );
}
 @override
  void initState() {
    _line1Controller.addListener(_checkFields);
    _line2Controller.addListener(_checkFields);
    // TODO: implement initState
    super.initState();
  }

  void _checkFields() {
  setState(() {
    isButtonEnabled = _line1Controller.text.trim().isNotEmpty &&
                      _line2Controller.text.trim().isNotEmpty;
  });
}


  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.085, vertical: MediaQuery.of(context).size.height * 0.03),
        decoration: const BoxDecoration(
          color: Color(0xFFF9FCFB),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Close Button
            Align(
              alignment: Alignment.topRight,
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Icon(Icons.close, size: 30, color: Color.fromARGB(255, 121, 159, 138)),
              ),
            ),
             Text(
              "Add Your Address",
              style: TextStyle(
                fontSize: MediaQuery.of(context).size.width * 0.055,
                fontFamily: "Urbanist",
                fontWeight: FontWeight.bold,
                color: Color(0xFF0A9682),
              ),
            ),
            Text(
              "For a seamless delivery experience, help us locate you perfectly",
              style: TextStyle(
                fontSize: MediaQuery.of(context).size.width * 0.03,
                fontFamily: "Urbanist",
                fontWeight: FontWeight.bold,
                color: Color(0xFF0A9682),
              ),
            ),

            const SizedBox(height: 20),
            TextField(
              cursorColor:Color(0xFF0A9682) ,
              controller: _line1Controller,
              decoration: _inputDecoration("Flat/House No., Street, Area"),
            ),
            const SizedBox(height: 12),
            TextField(
              cursorColor:Color(0xFF0A9682) ,
              controller: _line2Controller,
              decoration: _inputDecoration("City, State, Pincode"),
            ),
            const SizedBox(height: 12),
            TextField(
              cursorColor:Color(0xFF0A9682) ,
              controller: _landmarkController,
              decoration: _inputDecoration("Landmark (Optional)"),
            ),
            const SizedBox(height: 12),
            TextField(
              cursorColor:Color(0xFF0A9682) ,
              controller: _floorController,
              decoration: _inputDecoration("Floor (Optional)"),
            ),
            const SizedBox(height: 12),
            TextField(
              cursorColor:Color(0xFF0A9682) ,
              controller: _typeController,
              decoration: _inputDecoration("Type (e.g., Home, Office)"),
            ),

            GestureDetector(
              onTap:(){
                if(isButtonEnabled){
                    addAddress();
                }
                
              } ,
              child: Container(
                  alignment: Alignment.bottomCenter,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      isButtonEnabled? Image.asset(
                        "lib/images/saveButton.png",
                        height: 100,
                        width: 350,
                        fit: BoxFit.contain,
                      ):Image.asset(
                        "lib/images/unablesaveButton.png",
                        height: 100,
                        width: 350,
                        fit: BoxFit.contain,
                      ),
                      Text(
                        "Save",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: MediaQuery.of(context).size.width*0.04,
                          fontFamily: "Urbanist",
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),),
            ),
          ],
        ),
      ),
    );
  }
}
