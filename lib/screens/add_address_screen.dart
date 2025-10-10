import 'package:cureeit_user_app/BaseUrl.dart';
import 'package:cureeit_user_app/LocalStorageCubit/store_user_cubit.dart';
import 'package:cureeit_user_app/screens/base_screen.dart';
import 'package:cureeit_user_app/screens/home/presentation/home_screen.dart';
import 'package:cureeit_user_app/selected_Address/currentAddress.dart';
import 'package:cureeit_user_app/utils/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
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
  bool isButtonEnabled = false;
  bool addingAddress = false;

  Future<void> addAddress() async {
    setState(() {
      addingAddress = true;
    });
    const String url = '$baseUrl/address/addAddress';

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
        context.read<StoreUserCubit>().saveUserAddress(
          index: null,
              address:
                  "${_line1Controller.text}, ${_line2Controller.text}".trim(),
              floor: _floorController.text.trim(),
              landmark: _landmarkController.text.trim(),
              type: _typeController.text.trim(),
              userId: widget.userId,
              userLat: widget.userLat.toString(),
              userlong: widget.userLong.toString(),
            );
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
        setState(() {
          addingAddress = false;
        });
        Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (context) => BaseScreen(
                  Navigatedfrom: "add_address_screen",
                )));
      } else {
        setState(() {
          addingAddress = false;
        });
        Fluttertoast.showToast(msg: "Failed to add address");
      }
    } catch (e) {
      setState(() {
        addingAddress = false;
      });
      print('Error: $e');
    }
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.mulish(color: whiteColor),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: InputBorder.none);
  }

  @override
  void initState() {
    _line1Controller.addListener(_checkFields);
    _line2Controller.addListener(_checkFields);
    _typeController.addListener(_checkFields);
    // TODO: implement initState
    super.initState();
  }

  void _checkFields() {
    setState(() {
      isButtonEnabled = _line1Controller.text.trim().isNotEmpty &&
          _line2Controller.text.trim().isNotEmpty &&
          _typeController.text.trim().isNotEmpty;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.symmetric(
            horizontal: MediaQuery.of(context).size.width * 0.085,
            vertical: MediaQuery.of(context).size.height * 0.03),
        decoration: const BoxDecoration(
          color: scaffoldBlackColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Close Button
            Align(
              alignment: Alignment.topRight,
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Icon(Icons.close, size: 30, color: whiteColor),
              ),
            ),
            Text(
              "Add Your Address",
              style: GoogleFonts.mulish(
                fontSize: MediaQuery.of(context).size.width * 0.055,
                fontWeight: FontWeight.bold,
                color: whiteColor,
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Text(
              "For a seamless delivery experience, help us locate you perfectly",
              style: GoogleFonts.mulish(
                fontSize: MediaQuery.of(context).size.width * 0.03,
                fontWeight: FontWeight.bold,
                color: greyColor,
              ),
            ),

            const SizedBox(height: 20),
            Container(
              margin: EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: ligtBlackColor,
              ),
              child: TextField(
                style: GoogleFonts.mulish(color: whiteColor),
                cursorColor: greenColor,
                controller: _line1Controller,
                decoration: _inputDecoration("Flat/House No., Street, Area"),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              margin: EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: ligtBlackColor,
              ),
              child: TextField(
                style: GoogleFonts.mulish(color: whiteColor),
                cursorColor: greenColor,
                controller: _line2Controller,
                decoration: _inputDecoration("City, State, Pincode"),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              margin: EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: ligtBlackColor,
              ),
              child: TextField(
                style: GoogleFonts.mulish(color: whiteColor),
                cursorColor: greenColor,
                controller: _typeController,
                decoration: _inputDecoration("Type (e.g., Home, Office)"),
              ),
            ),
            const SizedBox(height: 12),

            Container(
              margin: EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: ligtBlackColor,
              ),
              child: TextField(
                style: GoogleFonts.mulish(color: whiteColor),
                cursorColor: greenColor,
                controller: _landmarkController,
                decoration: _inputDecoration("Landmark (Optional)"),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              margin: EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: ligtBlackColor,
              ),
              child: TextField(
                style: GoogleFonts.mulish(color: whiteColor),
                cursorColor: greenColor,
                controller: _floorController,
                decoration: _inputDecoration("Floor (Optional)"),
              ),
            ),
            const SizedBox(height: 12),

            GestureDetector(
              onTap: () {
                if (isButtonEnabled) {
                  addAddress();
                }
              },
              child: Container(
                width: double.infinity,
                height: 36,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: greenColor, width: 1),
                    color: isButtonEnabled ? greenColor : scaffoldBlackColor),
                child: Center(
                  child: addingAddress
                      ? Container(
                          height: 10,
                          width: 10,
                          child: CircularProgressIndicator(
                            color: whiteColor,
                            strokeWidth: 2,
                          ))
                      : Text(
                          "Save Address",
                          style: GoogleFonts.mulish(
                            color: isButtonEnabled ? Colors.white : greenColor,
                            fontSize: MediaQuery.of(context).size.width * 0.04,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}
