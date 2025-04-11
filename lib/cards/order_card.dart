import 'package:cureeit_user_app/screens/order_tracking_screen.dart';
import 'package:cureeit_user_app/screens/orderdetail_screen_new.dart';
import 'package:cureeit_user_app/utils/theme.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class OrderCard extends StatelessWidget {
  final int index;
  final dynamic orderData;
  const OrderCard({super.key, required this.orderData,required this.index});

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

  @override
  Widget build(BuildContext context) {
    String orderStatus = orderData['currentStatus'];
    String purchaseDate = orderData['createdAt'];
    double shippingCost = double.parse(orderData['totalAmount']);
    List orderItems = orderData['orderItems'];
    String orderId = orderData['orderId'];
    print("Order details $index");
    print(purchaseDate);
    print(orderData["createdAt"]);
    print(orderData["updatedAt"]);

    String allItems = formatOrderItems(orderItems);

    return Padding(
  padding: EdgeInsets.only(
    top: MediaQuery.of(context).size.height * 0.02,
  ),
  child: GestureDetector(
    onTap: () {
      if (orderStatus == "Order Placed" || orderStatus == "Packing" || orderStatus == "On the way") {
           Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OrderTrackingScreen(NavigatingFrom: "Order History", orderId: orderId,),
      ),
    );
   } else {
     Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => OrderdetailScreenNew(orderData: orderData),
        ),
      );
    }
    },
    child: LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = MediaQuery.of(context).size.width;

        return Container(
          padding: EdgeInsets.symmetric(
            vertical: screenWidth * 0.025,
            horizontal: screenWidth * 0.035,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.white,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Index : ${index}"),
                      Text(
                        "Order ID: ${orderData['orderId'] ?? '?'}",
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: screenWidth * 0.035,
                          fontFamily: "Urbanist",
                          color: primaryColor,
                        ),
                      ),
                      Text(
                        "Date: ${formatDate(purchaseDate) ?? "N/A"}",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: screenWidth * 0.03,
                          fontFamily: "Urbanist",
                          color: Colors.black.withOpacity(0.6),
                        ),
                      ),
                      SizedBox(
                        width: screenWidth * 0.6,
                        child: Text(
                          orderData['shippingAddress'],
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: screenWidth * 0.03,
                            fontFamily: "Urbanist",
                            color: Colors.black.withOpacity(0.6),
                          ),
                        ),
                      ),
                      Text(
                        "₹ ${shippingCost.toStringAsFixed(2)}",
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: screenWidth * 0.035,
                          fontFamily: "JosefinSans",
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    orderStatus.toUpperCase(),
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: screenWidth * 0.03,
                      fontFamily: "Urbanist",
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
              Padding(
                padding: EdgeInsets.symmetric(
                  vertical: screenWidth * 0.02,
                ),
                child: Image.asset("lib/images/dotted_divider.png"),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    width: screenWidth * 0.7,
                    child: Text(
                      allItems,
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: screenWidth * 0.03,
                        fontFamily: "Urbanist",
                        color: Colors.black.withOpacity(0.5),
                      ),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: secondaryColor.withOpacity(0.2),
                    ),
                    child: Icon(
                      Icons.chevron_right,
                      color: secondaryColor,
                      size: screenWidth * 0.07,
                    ),
                  )
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
