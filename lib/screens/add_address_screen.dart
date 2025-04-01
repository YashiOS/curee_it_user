import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AddAddressScreen extends StatefulWidget {
  final String userId;
  final double userLat;
  final double userLong;
  const AddAddressScreen({super.key, required this.userId, required this.userLat, required this.userLong});

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

  Future<void> addAddress() async {
    final String url =
        'http://ec2-13-60-8-94.eu-north-1.compute.amazonaws.com:3000/address/addAddress';

    Map<String, dynamic> addressData = {
    'userId': widget.userId.toString(),
    'address': "${_line1Controller.text ?? ''}, ${_line2Controller.text ?? ''}".trim(),
    'landmark': _landmarkController.text?.trim() ?? "",
    'floor': _floorController.text?.trim() ?? "",
    'userLat': widget.userLat.toString(),
    'userLong': widget.userLong.toString(),
    'type': _typeController.text?.trim() ?? "",
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
      } else  {
         print('Failed response: ${response.body}');
        Fluttertoast.showToast(msg: "Failed to add address");
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: Icon(Icons.close)),
        title: Text(
          "Add Address",
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
        ),
      ),
      body: Container(
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              TextField(
                controller: _line1Controller,
                decoration: InputDecoration(
                  labelText: "Address Line 1",
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 10),
              TextField(
                controller: _line2Controller,
                decoration: InputDecoration(
                  labelText: "Address Line 2",
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 10),
              TextField(
                controller: _landmarkController,
                decoration: InputDecoration(
                  labelText: "Landmark (Optional)" ,
                  border: OutlineInputBorder()
                ),
              ),
              SizedBox(height: 10),
              TextField(
                controller: _floorController,
                decoration: InputDecoration(
                  labelText: "Floor (Optional)" ,
                  border: OutlineInputBorder()
                ),
              ),
              SizedBox(height: 10),
              TextField(
                controller: _typeController,
                decoration: InputDecoration(
                  labelText: "Type (e.g., Home, Office)",
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: addAddress,
                style: ElevatedButton.styleFrom(
                  iconColor: const Color.fromARGB(255, 10, 21, 81),
                  backgroundColor: const Color.fromARGB(255, 10, 21, 81),
                  padding: EdgeInsets.all(15),
                  textStyle: TextStyle(fontSize: 18),
                ),
                child: Text(
                  "Add Address",
                  style: TextStyle(
                      fontWeight: FontWeight.w700, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
