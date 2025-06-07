import 'dart:io';

import 'package:cureeit_user_app/screens/order_tracking_screen.dart';
import 'package:cureeit_user_app/utils/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:cureeit_user_app/BaseUrl.dart';
import 'package:cureeit_user_app/user/user.dart';
import 'package:cureeit_user_app/selected_Address/currentAddress.dart';
import 'package:cureeit_user_app/utils/widgets/LoadingIndicater.dart';
import 'package:loading_indicator/loading_indicator.dart';

class MedicineAvailabilityScreen extends StatefulWidget {
  final File? prescriptionImage;

  const MedicineAvailabilityScreen({super.key, this.prescriptionImage});

  @override
  State<MedicineAvailabilityScreen> createState() =>
      _MedicineAvailabilityScreenState();
}

class _MedicineAvailabilityScreenState extends State<MedicineAvailabilityScreen>
    with TickerProviderStateMixin {
  List<dynamic> medicines = [];
  bool isLoading = true;
  bool allAvailable = true;
 
  bool started=false;
 

  @override
  void initState() {
    super.initState();
   

    checkAvailability();
  }

  @override
  void dispose() {
    
    super.dispose();
  }

 

  Future<void> checkAvailability() async {
     setState(() {
      started=true;
    });
    
    try {
      String base64Image = "";
      if (widget.prescriptionImage != null) {
        List<int> imageBytes = await widget.prescriptionImage!.readAsBytes();
        base64Image = base64Encode(imageBytes);
      }

      final response = await http.post(
        Uri.parse('$baseUrl/order/itemAvailability'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "userId": User.userId,
          "prescriptionPhoto": base64Image,
          "userLat": Address.CurrentAddress?["userLat"]?.toString() ?? "0.0",
          "userLong": Address.CurrentAddress?["userLong"]?.toString() ?? "0.0",
        }),
      );
      print(response.statusCode);
 print(response.body);
      if (response.statusCode == 200) {
        setState(() {
      started=false;
    });
        final data = json.decode(response.body);
        print(data);
        if (data['success'] == true) {
        final AvilableId=data["data"]['availableID'];
       
          Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context)=>OrderTrackingScreen(NavigatingFrom: "order_place", orderId:AvilableId )));
        } else {
        
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                "Failed to sent order to pharmacy! please try again",
                style: GoogleFonts.mulish(),
              ),
              backgroundColor: greenColor,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              duration: Duration(seconds: 2),
            ),
          );
           setState(() {
      started=false;
    });
    Future.delayed(Duration(seconds: 2),()=>Navigator.pop(context));
          // Handle API error
        }
      } else {
        
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                "Failed to sent order to pharmacy! please try again",
                style: GoogleFonts.mulish(),
              ),
              backgroundColor: greenColor,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              duration: Duration(seconds: 2),
            ),
          );
         setState(() {
      started=false;
    });
     Future.delayed(Duration(seconds: 2),()=>Navigator.pop(context));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                "Failed to sent order to pharmacy! please try again",
                style: GoogleFonts.mulish(),
              ),
              backgroundColor: greenColor,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              duration: Duration(seconds: 2),
            ),
          );
       setState(() {
      started=false;
    });
    Future.delayed(Duration(seconds: 2),()=>Navigator.pop(context));
    }
     
  
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: scaffoldBlackColor,
        
        appBar: AppBar(
          scrolledUnderElevation: 0,
            elevation: 0,
          automaticallyImplyLeading: false,
          backgroundColor: ligtBlackColor,
          centerTitle: true,
          title: Text(
            "Order Placing",
            style: GoogleFonts.mulish(
              fontWeight: FontWeight.w400,
              fontSize: 22.69,
              color: whiteColor,
            ),
          ),
          
        ),
        body:started? Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Center(
                child: Container(
                  height: 200,
                  width: 100,
                  child: LoadingIndicator(
                    indicatorType: Indicator.ballPulse, // Example
                    colors: [whiteColor],
                    strokeWidth: 2,
                    backgroundColor: scaffoldBlackColor,
                    pathBackgroundColor: Colors.black,
                  ),
                ),
              ),
              
            ],
          ),
        ):SizedBox());
  }
}
