import 'package:cureeit_user_app/utils/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class OrderdetailScreenNew extends StatelessWidget {
  final dynamic orderData;
  String prescriptionURL;
   OrderdetailScreenNew({super.key, required this.orderData,this.prescriptionURL="",});

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
    String orderStatus = orderData['status'];
   
    return Scaffold(
        appBar: AppBar(
          scrolledUnderElevation: 0,
            elevation: 0,
          backgroundColor:ligtBlackColor,
         centerTitle: true,
          leading: GestureDetector(
            onTap: (){
              Navigator.of(context).pop();
            },
            child: Padding(
              padding: const EdgeInsets.only(left: 12.0),
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
          title: Text(
            "Order Details",
            style: GoogleFonts.mulish(
                color: whiteColor,
               
                fontSize: 22.69,
                fontWeight: FontWeight.w400),
          ),
        ),
        body: Container(
            color: scaffoldBlackColor,
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
                         
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                             color: ligtBlackColor,
                          ),
                          child: Column(
                            spacing: 12,
                            children: [
                              Icon(
                                orderStatus == "Delivered"
                                    ? Icons.check_circle
                                    : Icons.delivery_dining,
                                size: 40,
                                color: greenColor,
                              ),
                              Column(
                                children: [
                                  Text(
                                    "Order " + orderData['status'],
                                    style: GoogleFonts.mulish(
                                        color: whiteColor,
                                       
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    "You can count on us",
                                    style: TextStyle(
                                        color:greyColor,
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
                          
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                             color: ligtBlackColor,
                          ),
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
                                          color: greenColor,
                                          borderRadius:
                                              BorderRadius.circular(8)),
                                      child: Text(
                                        orderData['status'],
                                        style: GoogleFonts.mulish(
                                            color: Colors.white,
                                            
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ),
                                  Text(
                                    orderData['status'] == "Pending"
                                        ? "Delivering in"
                                        : "Delivered in",
                                    style: GoogleFonts.mulish(
                                        color: whiteColor,
                                       
                                        fontSize: 13,
                                        fontWeight: FontWeight.normal),
                                  ),
                                  Text(
                                    "16 mins",
                                    style: GoogleFonts.mulish(
                                        color: whiteColor,
                                       
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
                                      color: greenColor,
                                    ),
                                    Container(
                                      width: 70,
                                      height: 2,
                                      color: whiteColor,
                                    ),
                                    Icon(
                                      Icons.check_circle,
                                      size: 24,
                                      color: greenColor,
                                    ),
                                    Container(
                                      width: 70,
                                      height: 2,
                                      color: whiteColor,
                                    ),
                                    Icon(
                                      Icons.check_circle,
                                      size: 24,
                                      color: greenColor,
                                    ),
                                    Container(
                                      width: 70,
                                      height: 2,
                                      color: orderData['status'] ==
                                              "Pending"
                                          ? Colors.grey
                                          : greenColor,
                                    ),
                                    Icon(
                                      Icons.check_circle,
                                      size: 24,
                                      color: orderData['status'] ==
                                              "Pending"
                                          ? Colors.grey
                                          : greenColor,
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
                                    style: GoogleFonts.mulish(
                                        color: whiteColor,
                                        
                                        fontSize: 13,
                                        fontWeight: FontWeight.normal),
                                  ),
                                  Text(
                                    "Validated",
                                    style: GoogleFonts.mulish(
                                        color: whiteColor,
                                       
                                        fontSize: 13,
                                        fontWeight: FontWeight.normal),
                                  ),
                                  Text(
                                    "Shipped",
                                    style: GoogleFonts.mulish(
                                        color: whiteColor,
                                       
                                        fontSize: 13,
                                        fontWeight: FontWeight.normal),
                                  ),
                                  Text(
                                    "Delivered",
                                    style:GoogleFonts.mulish(
                                        color: whiteColor,
                                        
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
                                          color: greenColor,
                                          fontFamily: "Urbanist",
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      "View Invoice",
                                      style: TextStyle(
                                          decoration: TextDecoration.underline,
                                          color: greenColor,
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
                                    color: whiteColor,
                                    fontFamily: "Urbanist",
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600),
                              ),
                              Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 8),
                                
                                decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                             color: ligtBlackColor,
                          ),
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
                                              style: GoogleFonts.mulish(
                                                  color: whiteColor,
                                                 
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
                                                  style: GoogleFonts.mulish(
                                                      color: greyColor,
                                                     
                                                      fontSize: 13,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                                Text(
                                                  "₹ ${double.tryParse(product['productPrice'].toString())?.toStringAsFixed(2) ?? "0.00"}",
                                                  style: GoogleFonts.mulish(
                                                      color: whiteColor,
                                                      
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
                                style: GoogleFonts.mulish(
                                    color: whiteColor,
                                   
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600),
                              ),
                              Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 8),
                                color: ligtBlackColor,
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
                                          style: GoogleFonts.mulish(
                                              color:
                                                  greyColor,
                                              
                                              fontSize: 13,
                                              fontWeight: FontWeight.normal),
                                        ),
                                        Text(
                                          "₹ ${orderData["itemTotal"]}",
                                          style: GoogleFonts.mulish(
                                              color:
                                                  greyColor,
                                              
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
                                          style: GoogleFonts.mulish(
                                              color:
                                                  greyColor,
                                              
                                              fontSize: 13,
                                              fontWeight: FontWeight.normal),
                                        ),
                                        Text(
                                          "₹ ${orderData['shippingCost']}" ??
                                              "0",
                                          style: GoogleFonts.mulish(
                                              color:
                                                  greyColor,
                                              
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
                                          style: GoogleFonts.mulish(
                                              color:
                                                  greyColor,
                                              
                                              fontSize: 13,
                                              fontWeight: FontWeight.normal),
                                        ),
                                        Text(
                                          "₹ ${orderData["gstServiceCharge"]}",
                                          style: GoogleFonts.mulish(
                                              color:
                                                  greyColor,
                                              
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
                                          style: GoogleFonts.mulish(
                                              color:
                                                  greyColor,
                                              
                                              fontSize: 13,
                                              fontWeight: FontWeight.normal),
                                        ),
                                        Text(
                                          "₹ 10",
                                          style: GoogleFonts.mulish(
                                              color:
                                                  greyColor,
                                             
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
                                          style: GoogleFonts.mulish(
                                              color:
                                                  whiteColor,
                                             
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        Text(
                                          "₹ " + orderData['totalAmount'] ??
                                              "0",
                                          style: GoogleFonts.mulish(
                                              color:
                                                  whiteColor,
                                             
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
                                style: GoogleFonts.mulish(
                                    color: whiteColor,
                                    
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600),
                              ),
                              Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 8),
                                    decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                             color: ligtBlackColor,
                          ),
                                
                                width: MediaQuery.of(context).size.width,
                                child: Column(
                                  spacing: 12,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                   prescriptionURL==""?Text("No prescription uploaded") :Image.network(
                                      prescriptionURL,
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
                                style: GoogleFonts.mulish(
                                    color: whiteColor,
                                    
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600),
                              ),
                              Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 8),
                                    decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                             color: ligtBlackColor,
                          ),
                                
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
                                          style: GoogleFonts.mulish(
                                              color: greyColor,
                                              
                                              fontSize: 13,
                                              fontWeight: FontWeight.normal),
                                        ),
                                        Text(
                                          orderData['orderId'] ?? "N/A",
                                          style: GoogleFonts.mulish(
                                              color: whiteColor,
                                              
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
                                          style: GoogleFonts.mulish(
                                              color: greyColor,
                                              
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
                                            style: GoogleFonts.mulish(
                                                color: whiteColor,
                                              
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
                                          style: GoogleFonts.mulish(
                                              color: greyColor,
                                              
                                              fontSize: 13,
                                              fontWeight: FontWeight.normal),
                                        ),
                                        Text(
                                          formatDate(orderData['createdAt']) ??
                                              "N/A",
                                          style: GoogleFonts.mulish(
                                              color: whiteColor,
                                              
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
                                        color: greenColor,
                                          border:
                                              Border.all(color: greenColor),
                                          borderRadius:
                                              BorderRadius.circular(8)),
                                      child: Text(
                                        "Return Items",
                                        style: GoogleFonts.mulish(
                                            color: whiteColor,
                                            
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold),
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
