import 'package:cureeit_user_app/BaseUrl.dart';
import 'package:cureeit_user_app/cards/order_card.dart';
import 'package:cureeit_user_app/screens/base_screen.dart';
import 'package:cureeit_user_app/user/user.dart';
import 'package:cureeit_user_app/utils/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  List<dynamic> orders = [];
  bool isLoading = true;

  Future<void> fetchOrderHistory() async {
    print("fetching cart");
    var url = Uri.parse(
        '$baseUrl/order/orderHistory');
    var request =  http.Request('GET', url)
      ..headers.addAll({
        'Content-Type': 'application/json',
      })
      ..body = jsonEncode({'userId':User.userId});

    var response = await http.Client().send(request);
 
    if (response.statusCode == 200) {
      var responseBody = await response.stream.bytesToString();
      Map<String, dynamic> data = jsonDecode(responseBody);
      
      setState(() {
      
        orders = data['data'];
        print(orders);
         
        orders.sort((item1, item2) {
  final dateA = DateTime.parse(item1['purchaseDate']);
  final dateB = DateTime.parse(item2['purchaseDate']);
  return dateB.compareTo(dateA); // descending = most recent first
});

        isLoading = false;
      });
    } else {
      
      setState(() {
        isLoading=false;
      });
      throw Exception('Failed to load order history');
    }
   
  }

  @override
  void initState() {
    super.initState();
    print("intistate");
    fetchOrderHistory();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: scaffoldBlackColor,
      appBar:AppBar(
            centerTitle: true,
            backgroundColor: ligtBlackColor,
            shape: ContinuousRectangleBorder(
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(10),
                bottomRight: Radius.circular(10),
              ),
            ),
            title: Text(
              "Order Again",
              style: GoogleFonts.mulish(
                fontWeight: FontWeight.w400,
                fontSize: 22.69,
                color: whiteColor,
              ),
            ),
             leading: GestureDetector(
            onTap: () {
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>BaseScreen(Navigatedfrom: "")));
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
      body: isLoading
          ? Container(
            color:scaffoldBlackColor,
            child: Center(
                child: CircularProgressIndicator(
                color: whiteColor,
              )),
          ) // Show loader while data is loading
          : orders.length==0?Center(
            child: Text("No orders", style: GoogleFonts.mulish(
            fontWeight: FontWeight.w500,
            fontSize: 20,
            color: greyColor,
          ) ,),
          ) :Container(
            margin: EdgeInsets.only(bottom: MediaQuery.of(context).size.height*0.03),
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              color: scaffoldBlackColor,
              child: Padding(
                padding: const EdgeInsets.only(
                    top: 6.0, left: 18, right: 18, bottom: 60),
                child: ListView.builder(
                  itemCount:
                      orders.length, // Use the length of the orders array
                  itemBuilder: (context, index) {
                    return OrderCard(
                      prescriptionURL:orders[0]["prescription"]?["photoURL"] ??"",
                        orderData:
                            orders[index]); // Pass the order data to the card
                  },
                ),
              ),
            ),
    );
  }
}
