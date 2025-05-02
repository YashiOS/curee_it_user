import 'package:cureeit_user_app/screens/order_tracking_screen.dart';
import 'package:cureeit_user_app/screens/orderdetail_screen_new.dart';
import 'package:cureeit_user_app/utils/theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class OrderCard extends StatelessWidget {
  final dynamic orderData;
  const OrderCard({
    super.key,
    required this.orderData,
  });

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
  
void getOrderId(){
  List<dynamic> orderItems = orderData["orderItems"];
  List productIds=orderItems.map((item)=>item['productId'].toString()).toList();
  
  
}

  @override
  Widget build(BuildContext context) {
    String orderStatus = orderData['currentStatus'];
    String purchaseDate = orderData['purchaseDate'];
    double shippingCost = double.parse(orderData['totalAmount']);
    List orderItems = orderData['orderItems'];
    String orderId = orderData['orderId'];

   

    String allItems = formatOrderItems(orderItems);

    return Padding(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).size.height * 0.02,
      ),
      child: GestureDetector(
        onTap: () {
          if (orderStatus == "Order Placed" ||
              orderStatus == "Packing" ||
              orderStatus == "On the way") {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => OrderTrackingScreen(
                  NavigatingFrom: "Order History",
                  orderId: orderId,
                ),
              ),
            );
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    OrderdetailScreenNew(orderData: orderData),
              ),
            );
          }
        },
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
                    height: 24,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Address",
                            style: GoogleFonts.mulish(
                              fontWeight: FontWeight.w600,
                              fontSize: 17.02,
                              color: whiteColor,
                            ),
                          ),
                          SizedBox(
                            width: screenWidth * 0.4,
                            child: Text(
                              orderData['shippingAddress'],
                              style: GoogleFonts.mulish(
                                fontWeight: FontWeight.w300,
                                fontSize: 12,
                                color: whiteColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      GestureDetector(
                        onTap: (){
                           getOrderId();
                          if(orderStatus=="Delivered"||orderStatus==""){
                                
                          }
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 8,horizontal: 16),
                          decoration: BoxDecoration(
                              color: greenColor,
                              borderRadius: BorderRadius.circular(8)
                          ),
                          
                          child:orderStatus=="Delivered"||orderStatus==""?Text(
                            "Reorder",
                            style: GoogleFonts.mulish(
                              fontWeight: FontWeight.bold,
                              fontSize: screenheight * 0.014,
                             
                              color: whiteColor,
                            ),
                          ): Text(
                            orderStatus,
                            style: GoogleFonts.mulish(
                              fontWeight: FontWeight.bold,
                              fontSize: screenheight * 0.014,
                             
                              color: whiteColor,
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
