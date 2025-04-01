import 'package:cureeit_user_app/utils/theme.dart';
import 'package:flutter/material.dart';

class OrderdetailScreenNew extends StatelessWidget {
  final dynamic orderData;
  const OrderdetailScreenNew({super.key, required this.orderData});

  @override
  Widget build(BuildContext context) {
    String orderStatus = orderData['currentStatus'];
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
                    Image.asset(
                      'lib/images/back_arrow.png',
                      width: 20,
                      height: 16,
                    ),
                  ],
                ),
              ),
            ),
          ),
          title: Text(
            "Order Details",
            style: TextStyle(
                color: Colors.black.withOpacity(0.7),
                fontFamily: "JosefinSans",
                fontSize: 18,
                fontWeight: FontWeight.w700),
          ),
        ),
        body: Container(
            color: Colors.grey.shade100.withOpacity(0.5),
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8),
                child: ListView(
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 8,
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(vertical: 14),
                          width: MediaQuery.of(context).size.width,
                          color: secondaryColor.withOpacity(0.2),
                          child: Column(
                            spacing: 12,
                            children: [
                              Icon(
                                orderStatus == "Delivered"
                                    ? Icons.check_circle
                                    : Icons.delivery_dining,
                                size: 40,
                                color: primaryColor,
                              ),
                              Column(
                                children: [
                                  Text(
                                    "Order " + orderData['currentStatus'],
                                    style: TextStyle(
                                        color: Colors.black.withOpacity(0.6),
                                        fontFamily: "Urbanist",
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    "You can count on us",
                                    style: TextStyle(
                                        color: Colors.black.withOpacity(0.6),
                                        fontFamily: "Urbanist",
                                        fontSize: 11,
                                        fontWeight: FontWeight.w400),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.all(6),
                          color: Colors.white,
                          child: Column(
                            spacing: 12,
                            children: [
                              Row(
                                spacing: 6,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8.0),
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                          color: secondaryColor,
                                          borderRadius:
                                              BorderRadius.circular(20)),
                                      child: Text(
                                        orderData['currentStatus'],
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontFamily: "Urbanist",
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ),
                                  Text(
                                    orderData['currentStatus'] == "Pending"
                                        ? "Delivering in"
                                        : "Delivered in",
                                    style: TextStyle(
                                        color: Colors.black.withOpacity(0.6),
                                        fontFamily: "Urbanist",
                                        fontSize: 13,
                                        fontWeight: FontWeight.normal),
                                  ),
                                  Text(
                                    "16 mins",
                                    style: TextStyle(
                                        color: secondaryColor,
                                        fontFamily: "Urbanist",
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                    left: 8.0, right: 8, top: 10),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    Icon(
                                      Icons.check_circle,
                                      size: 24,
                                      color: primaryColor,
                                    ),
                                    Container(
                                      width: 70,
                                      height: 2,
                                      color: primaryColor,
                                    ),
                                    Icon(
                                      Icons.check_circle,
                                      size: 24,
                                      color: primaryColor,
                                    ),
                                    Container(
                                      width: 70,
                                      height: 2,
                                      color: primaryColor,
                                    ),
                                    Icon(
                                      Icons.check_circle,
                                      size: 24,
                                      color: primaryColor,
                                    ),
                                    Container(
                                      width: 70,
                                      height: 2,
                                      color: orderData['currentStatus'] ==
                                              "Pending"
                                          ? Colors.grey
                                          : primaryColor,
                                    ),
                                    Icon(
                                      Icons.check_circle,
                                      size: 24,
                                      color: orderData['currentStatus'] ==
                                              "Pending"
                                          ? Colors.grey
                                          : primaryColor,
                                    ),
                                  ],
                                ),
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                spacing: 36,
                                children: [
                                  Text(
                                    "Placed",
                                    style: TextStyle(
                                        color: Colors.black.withOpacity(0.6),
                                        fontFamily: "Urbanist",
                                        fontSize: 13,
                                        fontWeight: FontWeight.normal),
                                  ),
                                  Text(
                                    "Validated",
                                    style: TextStyle(
                                        color: Colors.black.withOpacity(0.6),
                                        fontFamily: "Urbanist",
                                        fontSize: 13,
                                        fontWeight: FontWeight.normal),
                                  ),
                                  Text(
                                    "Shipped",
                                    style: TextStyle(
                                        color: Colors.black.withOpacity(0.6),
                                        fontFamily: "Urbanist",
                                        fontSize: 13,
                                        fontWeight: FontWeight.normal),
                                  ),
                                  Text(
                                    "Delivered",
                                    style: TextStyle(
                                        color: Colors.black.withOpacity(0.6),
                                        fontFamily: "Urbanist",
                                        fontSize: 13,
                                        fontWeight: FontWeight.normal),
                                  ),
                                ],
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "Reorder",
                                      style: TextStyle(
                                          decoration: TextDecoration.underline,
                                          color: primaryColor,
                                          fontFamily: "Urbanist",
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      "View Invoice",
                                      style: TextStyle(
                                          decoration: TextDecoration.underline,
                                          color: primaryColor,
                                          fontFamily: "Urbanist",
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.only(top: 8, left: 4),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            spacing: 8,
                            children: [
                              Text(
                                "Items Ordered",
                                style: TextStyle(
                                    color: Colors.black,
                                    fontFamily: "Urbanist",
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600),
                              ),
                              Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 8),
                                color: Colors.white,
                                child: Column(
                                    spacing: 12,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: (orderData['orderItems'] as List)
                                        .map<Widget>((product) {
                                      return Container(
                                        //  height: 42,
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              product['productName'] ?? "",
                                              style: TextStyle(
                                                  color: Colors.black,
                                                  fontFamily: "Urbanist",
                                                  fontSize: 16,
                                                  fontWeight:
                                                      FontWeight.normal),
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(
                                                  "Qty : ${product['quantity']}" ??
                                                      "1",
                                                  style: TextStyle(
                                                      color: primaryColor,
                                                      fontFamily: "Urbanist",
                                                      fontSize: 13,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                                Text(
                                                  "₹ ${double.tryParse(product['productPrice'].toString())?.toStringAsFixed(2) ?? "0.00"}",
                                                  style: TextStyle(
                                                      color: primaryColor,
                                                      fontFamily: "Urbanist",
                                                      fontSize: 13,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              ],
                                            )
                                          ],
                                        ),
                                      );
                                    }).toList()),
                              )
                            ],
                          ),
                        ),
//Bill Summary
                        Container(
                          padding: EdgeInsets.only(top: 8, left: 4),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            spacing: 8,
                            children: [
                              Text(
                                "Bill Summary",
                                style: TextStyle(
                                    color: Colors.black,
                                    fontFamily: "Urbanist",
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600),
                              ),
                              Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 8),
                                color: Colors.white,
                                child: Column(
                                  spacing: 12,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          "Items total",
                                          style: TextStyle(
                                              color:
                                                  Colors.black.withOpacity(0.6),
                                              fontFamily: "Urbanist",
                                              fontSize: 13,
                                              fontWeight: FontWeight.normal),
                                        ),
                                        Text(
                                          "₹ 200",
                                          style: TextStyle(
                                              color:
                                                  Colors.black.withOpacity(0.6),
                                              fontFamily: "Urbanist",
                                              fontSize: 13,
                                              fontWeight: FontWeight.normal),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          "Shipping",
                                          style: TextStyle(
                                              color:
                                                  Colors.black.withOpacity(0.6),
                                              fontFamily: "Urbanist",
                                              fontSize: 13,
                                              fontWeight: FontWeight.normal),
                                        ),
                                        Text(
                                          "₹ ${orderData['shippingCost']}" ??
                                              "0",
                                          style: TextStyle(
                                              color:
                                                  Colors.black.withOpacity(0.6),
                                              fontFamily: "Urbanist",
                                              fontSize: 13,
                                              fontWeight: FontWeight.normal),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          "Tax and services",
                                          style: TextStyle(
                                              color:
                                                  Colors.black.withOpacity(0.6),
                                              fontFamily: "Urbanist",
                                              fontSize: 13,
                                              fontWeight: FontWeight.normal),
                                        ),
                                        Text(
                                          "₹ 10",
                                          style: TextStyle(
                                              color:
                                                  Colors.black.withOpacity(0.6),
                                              fontFamily: "Urbanist",
                                              fontSize: 13,
                                              fontWeight: FontWeight.normal),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          "Total discount",
                                          style: TextStyle(
                                              color:
                                                  Colors.black.withOpacity(0.6),
                                              fontFamily: "Urbanist",
                                              fontSize: 13,
                                              fontWeight: FontWeight.normal),
                                        ),
                                        Text(
                                          "₹ 10",
                                          style: TextStyle(
                                              color:
                                                  Colors.black.withOpacity(0.6),
                                              fontFamily: "Urbanist",
                                              fontSize: 13,
                                              fontWeight: FontWeight.normal),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          "Bill total",
                                          style: TextStyle(
                                              color:
                                                  Colors.black.withOpacity(0.6),
                                              fontFamily: "Urbanist",
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        Text(
                                          "₹ " + orderData['totalAmount'] ??
                                              "0",
                                          style: TextStyle(
                                              color:
                                                  Colors.black.withOpacity(0.6),
                                              fontFamily: "Urbanist",
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),

//Prescription Attached
                        Container(
                          padding: EdgeInsets.only(top: 8, left: 4),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            spacing: 8,
                            children: [
                              Text(
                                "Prescription Attached",
                                style: TextStyle(
                                    color: Colors.black,
                                    fontFamily: "Urbanist",
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600),
                              ),
                              Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 8),
                                color: Colors.white,
                                width: MediaQuery.of(context).size.width,
                                child: Column(
                                  spacing: 12,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Image.asset(
                                      "lib/images/prescription.png",
                                      height: 160,
                                    )
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
//Order Info
                        Container(
                          padding: EdgeInsets.only(top: 8, left: 4),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            spacing: 8,
                            children: [
                              Text(
                                "Order Info",
                                style: TextStyle(
                                    color: Colors.black,
                                    fontFamily: "Urbanist",
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600),
                              ),
                              Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 8),
                                color: Colors.white,
                                width: MediaQuery.of(context).size.width,
                                child: Column(
                                  spacing: 12,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Order ID",
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontFamily: "Urbanist",
                                              fontSize: 13,
                                              fontWeight: FontWeight.normal),
                                        ),
                                        Text(
                                          orderData['orderId'] ?? "N/A",
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontFamily: "Urbanist",
                                              fontSize: 12,
                                              fontWeight: FontWeight.w700),
                                        ),
                                      ],
                                    ),
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Address",
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontFamily: "Urbanist",
                                              fontSize: 13,
                                              fontWeight: FontWeight.normal),
                                        ),
                                        SizedBox(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width /
                                              1.3,
                                          child: Text(
                                            orderData['shippingAddress'] ??
                                                "N/A",
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontFamily: "Urbanist",
                                                fontSize: 12,
                                                fontWeight: FontWeight.w700),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Date and Time",
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontFamily: "Urbanist",
                                              fontSize: 13,
                                              fontWeight: FontWeight.normal),
                                        ),
                                        Text(
                                          //"18 March 2025, 4:11 P.M.",
                                          orderData['createdAt'] ?? "N/A",
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontFamily: "Urbanist",
                                              fontSize: 12,
                                              fontWeight: FontWeight.w700),
                                        ),
                                      ],
                                    ),
                                    Container(
                                      alignment: Alignment.center,
                                      width: MediaQuery.of(context).size.width,
                                      padding:
                                          EdgeInsets.symmetric(vertical: 6),
                                      decoration: BoxDecoration(
                                          border:
                                              Border.all(color: secondaryColor),
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                      child: Text(
                                        "Return Items",
                                        style: TextStyle(
                                            color: primaryColor,
                                            fontFamily: "Urbanist",
                                            fontSize: 12,
                                            fontWeight: FontWeight.normal),
                                      ),
                                    )
                                  ],
                                ),
                              )
                            ],
                          ),
                        )
                      ],
                    )
                  ],
                ))));
  }
}
