import 'dart:convert';

import 'package:cureeit_user_app/BaseUrl.dart';
import 'package:cureeit_user_app/screens/cart_screen.dart';
import 'package:cureeit_user_app/screens/order_tracking_screen.dart';
import 'package:cureeit_user_app/screens/orderdetail_screen_new.dart';
import 'package:cureeit_user_app/user/user.dart';
import 'package:cureeit_user_app/utils/theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class OrderCard extends StatefulWidget {
  final dynamic orderData;
  String prescriptionURL;
  OrderCard({
    super.key,
    required this.orderData,
    this.prescriptionURL = "",
  });

  @override
  State<OrderCard> createState() => _OrderCardState();
}

class _OrderCardState extends State<OrderCard> {
  bool reOrdering=false;

  String formatDate(String isoDate) {
    // Parse the ISO 8601 string into a DateTime object
    DateTime dateTime = DateTime.parse(isoDate);

    // Format the date to the desired format without suffix for day
    String formattedDate = DateFormat("d MMMM yyyy, h:mm a").format(dateTime);

    return formattedDate;
  }

  String getDayWithSuffix(int day) {
    if (day >= 11 && day <= 13) {
      return '${day}th'; // Special case for 11th, 12th, and 13th
    }
    switch (day % 10) {
      case 1:
        return '${day}st';
      case 2:
        return '${day}nd';
      case 3:
        return '${day}rd';
      default:
        return '${day}th';
    }
  }

  void addMultipleTocart(context) async {
    setState(() {
      reOrdering=true;
    });
    List<dynamic> orderItems = widget.orderData["products"];
    print(orderItems);
    List productIds =
        orderItems.map((item) => item['productId'].toString()).toList();
    try {
      final response = await http.post(
        Uri.parse(
            '$baseUrl/cart/addMultipleToCart'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'userId': User.userId,
          'productIds': productIds,
          'quantity': 1,
        }),
      );

      if (response.statusCode == 200) {
        setState(() {
      reOrdering=false;
    });
        Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => CartScreen(isNavigated: true)));
      }
    } catch (e) {}
    setState(() {
      reOrdering=false;
    });
  }

  @override
  Widget build(BuildContext context) {
    String orderStatus = widget.orderData['status'];
    String purchaseDate = widget.orderData['createdAt'];
    double shippingCost = double.parse(widget.orderData['totalAmount']??"0.0");
    List orderItems = widget.orderData['products'];
    final total=orderItems.fold(0.0,(sum,item)=>sum+double.parse(item["productPrice"]));
    
    String orderId = widget.orderData['_id'];
    print("THIS IS ORDER ID");
    print(orderId);

    String allItems = formatOrderItems(orderItems);

    return Padding(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).size.height * 0.02,
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final screenWidth = MediaQuery.of(context).size.width;
          final screenheight = MediaQuery.of(context).size.height;
      
          return Container(
            padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: ligtBlackColor,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 165,
                          child: Text(
                            maxLines: 1,
                            allItems,
                            style: GoogleFonts.mulish(
                              fontSize: 17.02,
                              fontWeight: FontWeight.w500,
                              color: whiteColor,
                            ),
                          ),
                        ),
                        Text(
                          "${formatDate(purchaseDate) ?? "N/A"}",
                          style: GoogleFonts.mulish(
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                            color: greyColor,
                          ),
                        ),
                      ],
                    ),
                    if(orderStatus!="In Review")
                    Text(
                      "₹ ${shippingCost.toStringAsFixed(2)}",
                      style: GoogleFonts.mulish(
                        fontWeight: FontWeight.w500,
                        fontSize: 17,
                        color: whiteColor,
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    
                    GestureDetector(
                      onTap: () {
                        if (orderStatus == "Delivered" || orderStatus == "") {
                          addMultipleTocart(context);
                        }
                      },
                      child: Container(
                        padding:
                            EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                        decoration: BoxDecoration(
                            color:orderStatus=="Delivered"||orderStatus==""? greenColor:ligtBlackColor,
                            border:orderStatus!="Delivered" ?Border.all(color: greenColor,width: 1):Border.all(color: Colors.transparent,width: 0),
                            borderRadius: BorderRadius.circular(8)),
                        child: orderStatus == "Delivered" || orderStatus == ""
                            ? Text(
                                "Reorder",
                                style: GoogleFonts.mulish(
                                  fontWeight: FontWeight.bold,
                                  fontSize: screenheight * 0.014,
                                  color: whiteColor,
                                ),
                              )
                            :orderStatus=="Available"?Text(
                                    "Available",
                                    style: GoogleFonts.mulish(
                                      fontWeight: FontWeight.bold,
                                      fontSize: screenheight * 0.014,
                                      color: greenColor,
                                    ),
                                  ) :orderStatus=="In Review"?Text(
                                    "Verifying",
                                    style: GoogleFonts.mulish(
                                      fontWeight: FontWeight.bold,
                                      fontSize: screenheight * 0.014,
                                      color: greenColor,
                                    ),
                                  ) :orderStatus == "Order Placed"
                                ? Text(
                                    "Ordered",
                                    style: GoogleFonts.mulish(
                                      fontWeight: FontWeight.bold,
                                      fontSize: screenheight * 0.014,
                                      color: greenColor,
                                    ),
                                  )
                                :orderStatus=="On the way"?Text("Enroute",style:GoogleFonts.mulish(
                                      fontWeight: FontWeight.bold,
                                      fontSize: screenheight * 0.014,
                                      color: greenColor,
                                    ) ,) :Text(
                                    orderStatus,
                                    style: GoogleFonts.mulish(
                                      fontWeight: FontWeight.bold,
                                      fontSize: screenheight * 0.014,
                                      color: greenColor,
                                    ),
                                  ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // Helper function to format the orderItems list into a string
  String formatOrderItems(List orderItems) {
    String allItems = "";

    for (int i = 0; i < orderItems.length; i++) {
      var item = orderItems[i];
      String productId = item['productName'];
      int quantity = item['quantity'];

      if (i > 0) {
        allItems += ", ";
      }
      allItems += "$productId ($quantity)";
    }

    return allItems;
  }
}
