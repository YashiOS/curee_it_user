import 'package:cureeit_user_app/screens/orderdetail_screen_new.dart';
import 'package:cureeit_user_app/utils/theme.dart';
import 'package:flutter/material.dart';

class OrderCard extends StatelessWidget {
  final dynamic orderData;
  const OrderCard({super.key, required this.orderData});

  @override
  Widget build(BuildContext context) {
    String orderStatus = orderData['currentStatus'];
    String purchaseDate = orderData['purchaseDate'];
    double shippingCost = double.parse(orderData['totalAmount']);
    List orderItems = orderData['orderItems'];

    String allItems = formatOrderItems(orderItems);

    return Padding(
      padding: const EdgeInsets.only(top: 16.0),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => OrderdetailScreenNew(
                        orderData: orderData,
                      )));
        },
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.white,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Column(
                    spacing: 1,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Order ID: " + orderData['orderId'] ?? "?",
                        style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                            fontFamily: "Urbanist",
                            color: primaryColor),
                      ),
                      Text(
                        "Date: ${purchaseDate.substring(0, 10)}",
                        style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                            fontFamily: "Urbanist",
                            color: Colors.black.withOpacity(0.6)),
                      ),
                      Text(
                        orderData['shippingAddress'],
                        style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                            fontFamily: "Urbanist",
                            color: Colors.black.withOpacity(0.6)),
                      ),
                      Text(
                        "₹ $shippingCost",
                        style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                            fontFamily: "JosefinSans",
                            color: Colors.black),
                      ),
                    ],
                  ),
                  Row(
                    spacing: 4,
                    children: [
                      Text(
                        orderStatus.toUpperCase(),
                        style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                            fontFamily: "Urbanist",
                            color: Colors.black),
                      ),
                    ],
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Image.asset("lib/images/dotted_divider.png"),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width / 1.4,
                    child: Text(
                      allItems, // Display the formatted order items
                      style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 12,
                          fontFamily: "Urbanist",
                          color: Colors.black.withOpacity(0.5)),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: secondaryColor.withOpacity(0.2)),
                    child: Icon(
                      Icons.chevron_right,
                      color: secondaryColor,
                      size: 28,
                    ),
                  )
                ],
              )
            ],
          ),
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
