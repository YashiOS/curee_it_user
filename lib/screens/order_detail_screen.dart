import 'package:cureeit_user_app/utils/theme.dart';
import 'package:flutter/material.dart';

class OrderDetailScreen extends StatelessWidget {
  final dynamic orderData;
  const OrderDetailScreen({super.key, required this.orderData});

  @override
  Widget build(BuildContext context) {
    String orderNumber = orderData['_id'];
    String purchaseDate = orderData['purchaseDate'];
    List orderItems = orderData['orderItems'];
    String shippingAddress = orderData['shippingAddress'];
    double shippingCost = orderData['shippingCost'];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey.shade100.withOpacity(0.5),
        leadingWidth: 100,
        leading: Padding(
          padding: const EdgeInsets.only(left: 12.0),
          child: GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: Padding(
              padding: const EdgeInsets.only(left: 4.0),
              child: Row(
                spacing: 4,
                children: [
                  Icon(Icons.arrow_back, color: primaryColor),
                  Text(
                    "Back",
                    style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        fontFamily: "Urbanist",
                        color: primaryColor),
                  )
                ],
              ),
            ),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 18.0),
            child: Text(
              "HELP",
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 14,
                fontFamily: "Urbanist",
                color: primaryColor,
              ),
            ),
          ),
        ],
      ),
      body: Container(
        color: Colors.grey.shade100.withOpacity(0.5),
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 18),
          child: ListView(
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Order: ",
                    style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 24,
                        fontFamily: "JosefinSans",
                        color: primaryColor),
                  ),
                  Text(
                    orderNumber.toUpperCase(),
                    style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 18,
                        fontFamily: "JosefinSans",
                        color: primaryColor),
                  ),
                ],
              ),
              Column(
                spacing: 14,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 18.0),
                    child: Text(
                      "DELIVERY DETAILS",
                      style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 10,
                          fontFamily: "Urbanist",
                          color: Colors.black.withOpacity(0.6)),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.white,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 14,
                      children: [
                        Row(
                          spacing: 12,
                          children: [
                            Icon(
                              Icons.location_pin,
                              color: Color(0xFF1F1970),
                            ),
                            Column(
                              spacing: 4,
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Office",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w900,
                                    fontSize: 14,
                                    fontFamily: "JosefinSans",
                                    color: Color(0xFF1F1970),
                                  ),
                                ),
                                SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width / 1.34,
                                  child: Text(
                                    shippingAddress,
                                    style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 12,
                                        fontFamily: "Urbanist",
                                        color: Colors.black.withOpacity(0.5)),
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                        Row(
                          spacing: 12,
                          children: [
                            Icon(
                              Icons.check,
                              color: Colors.green,
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              spacing: 6,
                              children: [
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 2.0),
                                  child: Image.asset(
                                    "lib/images/dotted_divider.png",
                                    width: MediaQuery.of(context).size.width /
                                        1.34,
                                  ),
                                ),
                                Text(
                                  "DELIVERED on ${purchaseDate.substring(0, 10)} at ${purchaseDate.substring(11, 16)}",
                                  style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12,
                                      fontFamily: "JosefinSans",
                                      color: Colors.black),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 18.0),
                    child: Text(
                      "ORDER DETAILS",
                      style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 10,
                          fontFamily: "Urbanist",
                          color: Colors.black.withOpacity(0.6)),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.white,
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SizedBox(
                              width: MediaQuery.of(context).size.width / 2,
                              child: Text(
                                "Fenak Plus x 4",
                                style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                    fontFamily: "Urbanist",
                                    color: Colors.black.withOpacity(0.6)),
                              ),
                            ),
                            Text(
                              "₹100",
                              style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                  fontFamily: "Urbanist",
                                  color: Colors.black.withOpacity(0.8)),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SizedBox(
                              width: MediaQuery.of(context).size.width / 2,
                              child: Text(
                                "Neurobion Forte x 3",
                                style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                    fontFamily: "Urbanist",
                                    color: Colors.black.withOpacity(0.6)),
                              ),
                            ),
                            Text(
                              "₹230",
                              style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                  fontFamily: "Urbanist",
                                  color: Colors.black.withOpacity(0.8)),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SizedBox(
                              width: MediaQuery.of(context).size.width / 2,
                              child: Text(
                                "Metrogyl x 1",
                                style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                    fontFamily: "Urbanist",
                                    color: Colors.black.withOpacity(0.6)),
                              ),
                            ),
                            Text(
                              "₹23",
                              style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                  fontFamily: "Urbanist",
                                  color: Colors.black.withOpacity(0.8)),
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          child: Image.asset("lib/images/dotted_divider.png"),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SizedBox(
                              width: MediaQuery.of(context).size.width / 2,
                              child: Text(
                                "Item Total",
                                style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                    fontFamily: "Urbanist",
                                    color: Colors.black.withOpacity(0.6)),
                              ),
                            ),
                            Text(
                              "₹ 380.00",
                              style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                  fontFamily: "Urbanist",
                                  color: Colors.black.withOpacity(0.6)),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SizedBox(
                              width: MediaQuery.of(context).size.width / 2,
                              child: Text(
                                "Shipping Charges",
                                style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                    fontFamily: "Urbanist",
                                    color: Colors.black.withOpacity(0.6)),
                              ),
                            ),
                            Text(
                              "₹ 60.00",
                              style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                  fontFamily: "Urbanist",
                                  color: Colors.black.withOpacity(0.6)),
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Container(
                            height: 0.5,
                            color: Colors.grey.withOpacity(0.2),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SizedBox(
                              width: MediaQuery.of(context).size.width / 2,
                              child: Text(
                                "Total",
                                style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                    fontFamily: "Urbanist",
                                    color: Colors.black),
                              ),
                            ),
                            Text(
                              "₹ 440.00",
                              style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                  fontFamily: "Urbanist",
                                  color: Colors.black),
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Text(
                            "Paid By : ${orderData['paymentDetails']['gateway']}",
                            style: TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 14,
                                fontFamily: "Urbanist",
                                color: Colors.black.withOpacity(0.5)),
                          ),
                        ),
                      ],
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
}
