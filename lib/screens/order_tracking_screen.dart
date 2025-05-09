import 'dart:convert';
import 'dart:async';
import 'package:cureeit_user_app/screens/base_screen.dart';
import 'package:cureeit_user_app/user/user.dart';
import 'package:cureeit_user_app/utils/theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class OrderTrackingScreen extends StatefulWidget {
  OrderTrackingScreen(
      {super.key, required this.NavigatingFrom, required this.orderId});
  final String? userId = User.userId;
  late String orderId;
  final String NavigatingFrom;
  @override
  State<OrderTrackingScreen> createState() => _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends State<OrderTrackingScreen> {
  Map<String, dynamic> orderTrackingDetails = {};

  bool HittingApi = false;

  String formatDate(String isoDate) {
    // Parse the ISO 8601 string into a DateTime object
    DateTime dateTime = DateTime.parse(isoDate);

    // Format the date to the desired format without suffix for day
    String formattedDate = DateFormat("d MMMM yyyy, h:mm a").format(dateTime);

    return formattedDate;
  }

  Future<void> fetchOrderTracking() async {
    var url = Uri.parse(
      'http://ec2-13-60-8-94.eu-north-1.compute.amazonaws.com:3000/order/orderTracking',
    );
    var request = http.Request('GET', url)
      ..headers.addAll({
        'Content-Type': 'application/json',
      })
      ..body = jsonEncode({'userId': widget.userId, 'orderId': widget.orderId});

    var response = await http.Client().send(request);

    if (response.statusCode == 200) {
      final responseBody =
          await response.stream.bytesToString(); // 🔐 only once
      final data = json.decode(responseBody);

      setState(() {
        if (data["data"].isNotEmpty) {
          orderTrackingDetails = Map<String, dynamic>.from(data["data"][0]);
        }
      });
    } else {
      print('Failed to load tracking details');
    }
    if (HittingApi == false) {
      _hittingApi();
    }
  }

  @override
  void initState() {
    super.initState();
    fetchOrderTracking();
  }

  void _stopTimer() {
    print("✅ Stopping API hit timer");
    _timerStart?.cancel();
    _timerStart = null;
    HittingApi = false;
  }

  Timer? _timerStart;

  @override
  void dispose() {
    _stopTimer(); // ✅ Cancel timer when screen is destroyed
    super.dispose();
  }

  void _hittingApi() {
    HittingApi = true;
    _timerStart = Timer.periodic(Duration(seconds: 10), (timer) {
      fetchOrderTracking();
      print("Hitting api every 10 sec");
    });

    if (orderTrackingDetails["currentStatus"] == "Delivered") {
      _timerStart?.cancel();
    }
  }

  void showOrderSummaryBottomSheet() {
    final List<dynamic> items = orderTrackingDetails['orderItems'] ?? [];
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: scaffoldBlackColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: width * 0.04,
            right: width * 0.04,
            top: height * 0.015,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: width * 0.15,
                height: height * 0.006,
                decoration: BoxDecoration(
                  color: whiteColor,
                  borderRadius: BorderRadius.circular(width * 0.02),
                ),
              ),
              SizedBox(height: height * 0.015),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Order ${orderTrackingDetails["orderId"] ?? ""}",
                    style: GoogleFonts.mulish(
                        fontWeight: FontWeight.bold,
                        fontSize: width * 0.045,
                        color: whiteColor),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.close,
                      size: width * 0.06,
                      color: whiteColor,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              SizedBox(height: height * 0.005),
              Row(
                children: [
                  Text(
                    formatDate(orderTrackingDetails['createdAt'] ?? ""),
                    style: GoogleFonts.mulish(
                        fontSize: width * 0.035, color: whiteColor),
                  ),
                ],
              ),
              Divider(
                color: greyColor,
                thickness: 1,
                height: height * 0.035,
              ),
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: height * 0.33,
                  minHeight: 0,
                ),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return MedicineCard(
                      Imgurl: item['productImageURL'] ?? "", // or item['image']
                      MedicineName: item['productName'].toString(),
                      price: item['productPrice'].toString(),
                      quantities: item['quantity'].toString(),
                    );
                  },
                ),
              ),
              SizedBox(height: height * 0.015),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Bill Details",
                  style: GoogleFonts.mulish(
                      fontWeight: FontWeight.bold,
                      fontSize: width * 0.045,
                      color: whiteColor),
                ),
              ),
              Divider(
                color: greyColor,
                thickness: 1,
                height: height * 0.035,
              ),
              SizedBox(height: height * 0.01),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Icon(
                            Icons.currency_rupee,
                            color: greyColor,
                          ),
                          Text(
                            " Item total",
                            style: GoogleFonts.mulish(
                                fontSize: width * 0.04,
                                fontWeight: FontWeight.normal,
                                color: greyColor),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      "₹ ${orderTrackingDetails["itemTotal"]}",
                      style: GoogleFonts.mulish(
                          fontSize: width * 0.04,
                          fontWeight: FontWeight.bold,
                          color: greyColor),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Icon(
                            Icons.shopping_bag_outlined,
                            color: greyColor,
                          ),
                          Text(
                            " GST and Platform Fees ",
                            style: GoogleFonts.mulish(
                                fontSize: width * 0.04,
                                fontWeight: FontWeight.normal,
                                color: greyColor),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      "₹${orderTrackingDetails["gstServiceCharge"]}",
                      style: GoogleFonts.mulish(
                          fontSize: width * 0.04, color: greyColor),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Icon(
                            Icons.shopping_cart_outlined,
                            color: greyColor,
                          ),
                          Text(
                            " Delivery charge (Inc taxes)",
                            style: GoogleFonts.mulish(
                                fontSize: width * 0.04,
                                fontWeight: FontWeight.normal,
                                color: greyColor),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      "₹ ${orderTrackingDetails["shippingCost"]}",
                      style: GoogleFonts.mulish(
                        color: greyColor,
                        fontSize: width * 0.04,
                      ),
                    ),
                  ],
                ),
              ),
              Divider(
                color: greyColor,
                thickness: 1,
                height: height * 0.035,
              ),
              SizedBox(height: height * 0.01),
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 2, 8, 40),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Grand total",
                      style: GoogleFonts.mulish(
                        fontWeight: FontWeight.bold,
                        fontSize: width * 0.050,
                        color: whiteColor,
                      ),
                    ),
                    Row(
                      children: [
                        Icon(
                          Icons.currency_rupee,
                          color: whiteColor,
                        ),
                        Text(
                          "${orderTrackingDetails["totalAmount"]}",
                          style: GoogleFonts.mulish(
                              fontWeight: FontWeight.bold,
                              fontSize: width * 0.050,
                              color: whiteColor),
                        ),
                      ],
                    ),
                  ],
                ),
              )
            ],
          ),
        );
      },
    );
  }

  Widget OrderDetail({
    required IconData icon,
    required String title,
    required String subtitle,
    required double width,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.all(width * 0.025),
          decoration: BoxDecoration(
            color: ligtBlackColor,
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            size: width * 0.06,
            color: whiteColor,
          ),
        ),
        SizedBox(width: width * 0.04),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.mulish(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: whiteColor,
                ),
              ),
              Text(
                subtitle,
                maxLines: 1,
                style: GoogleFonts.mulish(
                  fontSize: width * 0.035,
                  fontWeight: FontWeight.w500,
                  color: greyColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget DeliveryStatus({
    required IconData icon,
    required String label,
    required Color color,
    required double size,
    bool isInactive = false,
  }) {
    final iconColor = isInactive
        ? greyColor
        : (color is MaterialColor ? color.shade800 : color);
    final bgColor = isInactive
        ? ligtBlackColor
        : (color is MaterialColor ? color.shade100 : color.withOpacity(0.2));

    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: bgColor,
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: iconColor,
            size: size * 0.07,
          ),
        ),
        SizedBox(height: size * 0.015),
        Text(
          label,
          style: GoogleFonts.mulish(
            fontWeight: FontWeight.w600,
            color: iconColor,
           
            fontSize: size * 0.03,
          ),
        ),
      ],
    );
  }

  Widget MedicineCard(
      {required String Imgurl,
      required String MedicineName,
      required String quantities,
      required String price}) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;
    int quantity = int.parse(quantities);
    double Price = double.parse(price);
    var total = quantity * Price;
    final hasUrl = Imgurl != null && Imgurl.trim().isNotEmpty;
    return Container(
      margin: EdgeInsets.symmetric(vertical: height * 0.01),
      padding: EdgeInsets.all(width * 0.03),
      decoration: BoxDecoration(
        color: ligtBlackColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(width * 0.02),
            child: hasUrl
                ? Image.network(
                    Imgurl,
                    width: width * 0.15,
                    height: width * 0.15,
                    fit: BoxFit.cover,
                  )
                : Image.asset(
                    "lib/images/capsule_image.png",
                    width: width * 0.15,
                    height: width * 0.15,
                  ),
          ),
          SizedBox(width: width * 0.04),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "$MedicineName",
                  style: GoogleFonts.mulish(
                      fontSize: width * 0.04,
                      fontWeight: FontWeight.w600,
                      color: whiteColor),
                ),
                SizedBox(height: height * 0.005),
                Text(
                  "$quantity x ₹$Price",
                  style: GoogleFonts.mulish(
                    fontSize: width * 0.035,
                    color: greyColor,
                  ),
                ),
              ],
            ),
          ),
          Text(
            "₹ ${total.toStringAsFixed(2)}",
            style: GoogleFonts.mulish(
              color: whiteColor,
              fontSize: width * 0.04,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  String getTrackingImage(String status) {
    switch (status) {
      case "Order Placed":
        return 'lib/images/ordered.png';
      case "Packing":
        return 'lib/images/packing.png';
      case "On the way":
        return 'lib/images/onTheWay.png';
      case "Delivered":
        return 'lib/images/delivered.png';
      case null:
        return 'lib/images/ordered.png';
      default:
        return 'lib/images/ordered.png'; // default image
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;

    return Scaffold(
      backgroundColor: scaffoldBlackColor,
      body: Column(
        children: [
          SizedBox(height: height * 0.02),
          Container(
            margin: EdgeInsets.all(width * 0.04),
            padding: EdgeInsets.all(width * 0.03),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: GestureDetector(
                    onTap: () {
                      _stopTimer();
                      if (widget.NavigatingFrom == "Order History") {
                        Navigator.of(context).pop();
                      }
                      if (widget.NavigatingFrom == "Order_SuccessScreen") {
                        Navigator.of(context).pushReplacement(MaterialPageRoute(
                            builder: (context) => BaseScreen(Navigatedfrom: "orderTrackingScreen",)));
                      }

                      //Navigator.pop(context);
                    },
                    child: Icon(
                      Icons.close,
                      color: whiteColor,
                      size: width * 0.06,
                    ),
                  ),
                ),
                SizedBox(height: height * 0.01),
                Container(
                  height: height * 0.35,
                  child: ClipRRect(
                    child: Image.asset(
                      orderTrackingDetails["currentStatus"] == "Order Placed"
                          ? 'lib/images/ordered.png'
                          : orderTrackingDetails["currentStatus"] == "Packing"
                              ? 'lib/images/packing.png'
                              : orderTrackingDetails["currentStatus"] ==
                                      "On the way"
                                  ? 'lib/images/onTheWay.png'
                                  : orderTrackingDetails["currentStatus"] ==
                                          "Delivered"
                                      ? 'lib/images/DELIVERED.png'
                                      : 'lib/images/ordered.png', // Default image

                      width: orderTrackingDetails["currentStatus"] ==
                              "Order Placed"
                          ? width*0.5
                          : orderTrackingDetails["currentStatus"] == "Packing"
                              ?  width*0.5
                              : orderTrackingDetails["currentStatus"] ==
                                      "On the way"
                                  ?  width*0.5
                                  : orderTrackingDetails["currentStatus"] ==
                                          "Delivered"
                                      ?  width*0.5
                                      :  width*0.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              padding: EdgeInsets.all(width * 0.04),
              decoration: BoxDecoration(
                color: ligtBlackColor,
                borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: width * 0.02,
                    offset: Offset(0, width * 0.01),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Order is being packed",
                    style: GoogleFonts.mulish(
                      fontSize: width * 0.045,
                      fontWeight: FontWeight.bold,
                      color: whiteColor,
                    ),
                  ),
                  SizedBox(height: height * 0.02),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      DeliveryStatus(
                        icon: Icons.check_circle,
                        label: "Ordered",
                        color: greenColor,
                        size: width,
                        isInactive: orderTrackingDetails["currentStatus"] ==
                                    "Order Placed" ||
                                orderTrackingDetails["currentStatus"] ==
                                    "Packing" ||
                                orderTrackingDetails["currentStatus"] ==
                                    "On the way" ||
                                orderTrackingDetails["currentStatus"] ==
                                    "Delivered"
                            ? false
                            : true,
                      ),
                      Expanded(
                        child: Container(
                          margin: EdgeInsets.only(top: 7),
                          child: Divider(
                            thickness: 2,
                            color: Colors.grey.shade300,
                          ),
                        ),
                      ),
                      DeliveryStatus(
                        icon: Icons.inventory_2,
                        label: "Packing",
                        color: greenColor,
                        size: width,
                        isInactive: orderTrackingDetails["currentStatus"] ==
                                    "Packing" ||
                                orderTrackingDetails["currentStatus"] ==
                                    "On the way" ||
                                orderTrackingDetails["currentStatus"] ==
                                    "Delivered"
                            ? false
                            : true,
                      ),
                      Expanded(
                        child: Container(
                          margin: EdgeInsets.only(top: 7),
                          child: Divider(
                            thickness: 2,
                            color: Colors.grey.shade300,
                          ),
                        ),
                      ),
                      DeliveryStatus(
                        icon: Icons.local_shipping,
                        label: "Enroute",
                        color: greenColor,
                        size: width,
                        isInactive: orderTrackingDetails["currentStatus"] ==
                                    "On the way" ||
                                orderTrackingDetails["currentStatus"] ==
                                    "Delivered"
                            ? false
                            : true,
                      ),
                      Expanded(
                        child: Container(
                          margin: EdgeInsets.only(top: 7),
                          child: Divider(
                            thickness: 2,
                            color: Colors.grey.shade300,
                          ),
                        ),
                      ),
                      DeliveryStatus(
                        icon: Icons.check_circle,
                        label: "Delivered",
                        color: greenColor,
                        size: width,
                        isInactive:
                            orderTrackingDetails["currentStatus"] == "Delivered"
                                ? false
                                : true,
                      ),
                    ],
                  ),
                  SizedBox(height: height * 0.015),
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.all(width * 0.04),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          OrderDetail(
                            icon: Icons.home_outlined,
                            title: "Delivery at:",
                            subtitle: orderTrackingDetails['shippingAddress'] ??
                                "Unknown",
                            width: width,
                          ),
                          OrderDetail(
                            icon: Icons.help_outline,
                            title: "Need help ?",
                            subtitle:
                                "Chat with us about any issue with your order",
                            width: width,
                          ),
                          GestureDetector(
                            onTap: () {
                              showOrderSummaryBottomSheet();
                            },
                            child: OrderDetail(
                              icon: Icons.receipt_outlined,
                              title: "Bill Details",
                              subtitle:
                                  "₹${orderTrackingDetails["totalAmount"]}",
                              width: width,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
