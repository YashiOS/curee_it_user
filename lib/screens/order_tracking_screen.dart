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
  bool _isInitLoading=true;

  String formatDate(String isoDate) {
    // Parse the ISO 8601 string into a DateTime object
    DateTime dateTime = DateTime.parse(isoDate);

    // Format the date to the desired format without suffix for day
    String formattedDate = DateFormat("d MMMM yyyy, h:mm a").format(dateTime);

    return formattedDate;
  }

  Future<void> fetchOrderTracking() async {
    String orderId=widget.orderId;
    var url = Uri.parse(
      'https://api.medkaro.in/order/orderTracking',
    );
     var response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'orderId': orderId}),
    );

    
    print("RESPONSE");
   print(response.statusCode);
  print(response.body);
    if (response.statusCode == 200) {
       setState(() {
        _isInitLoading=false;
      });
      final responseBody =jsonDecode(response.body);
           // 🔐 only once
      final data =responseBody;
      

      setState(() {
        if (data["data"].isNotEmpty) {
          _isInitLoading=false;
          orderTrackingDetails = Map<String, dynamic>.from(data["data"][0]);
          print("address");
          print(orderTrackingDetails['shippingAddress']);
          
          
        }
      });
    } else {
      setState(() {
        _isInitLoading=false;
      });
      
      print('Failed to load tracking details');
    }
    if (HittingApi == false) {
      _hittingApi();
    }
    setState(() {
        _isInitLoading=false;
      });
      
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
    final List<dynamic> items = orderTrackingDetails['products'] ?? [];
    final double totalSellingPrice = items.fold(0.0, (sum, item) {
  final price = double.tryParse(item['sellingPrice'].toString()) ?? 0.0;
  final quantity = int.tryParse(item['quantity'].toString()) ?? 1;
  return sum + (price * quantity);
});

final double itemTotal = double.tryParse(orderTrackingDetails["itemTotal"].toString()) ?? 0.0;
final double difference = itemTotal - totalSellingPrice;
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
            left: width * 0.08,
            right: width * 0.08,
            top: height * 0.015,
          ),
          child: Column(
            spacing: 10,
            crossAxisAlignment: CrossAxisAlignment.center,
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
              Container(
                width: double.infinity,
                child: Text(
                  "${orderTrackingDetails["orderId"] ?? ""}",
                  style: GoogleFonts.mulish(
                    fontSize: 13.78,
                    color: whiteColor,
                  ),
                  textAlign: TextAlign.start,
                ),
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
                      // or item['image']
                      MedicineName: item['productName'].toString(),
                      price: item['sellingPrice'].toString(),
                      quantities: item['quantity'].toString(),
                    );
                  },
                ),
              ),
              SizedBox(height: height * 0.015),
             
              Padding(
                padding: const EdgeInsets.only(top: 0, bottom: 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Item Total",
                            style: GoogleFonts.mulish(
                                fontSize: 14,
                                fontWeight: FontWeight.w300,
                                color: whiteColor),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                          "₹${orderTrackingDetails["itemTotal"]}",
                          style: GoogleFonts.mulish(
                              fontSize: 12,
                              fontWeight: FontWeight.w300,
                              decoration: TextDecoration.lineThrough,
                              decorationColor: greyColor,
                              color: greyColor),
                        ),
                        SizedBox(width: 5,),
                        Text(
                          "₹${totalSellingPrice.toStringAsFixed(2)}",
                          style: GoogleFonts.mulish(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                             
                              color: whiteColor),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.only(top: 0, bottom: 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        "GST and Platform Fees ",
                        style: GoogleFonts.mulish(
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: greyColor),
                      ),
                    ),
                    Text(
                      "₹${orderTrackingDetails["gstServiceCharge"]}",
                      style: GoogleFonts.mulish(
                          fontSize: 12, color: greyColor,fontWeight: FontWeight.w400 ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 0, bottom: 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Text(
                            "Delivery Fee",
                            style: GoogleFonts.mulish(
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                                color: greyColor),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      "₹${orderTrackingDetails["shippingCost"]}",
                      style: GoogleFonts.mulish(
                        color: greyColor,
                        fontWeight: FontWeight.w400,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              
              Padding(
                padding:  EdgeInsets.only(  left: 0,top: 5,bottom: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Grand Total",
                      style: GoogleFonts.mulish(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: whiteColor,
                      ),
                    ),
                    Text(
                      "₹${orderTrackingDetails["totalAmount"]}",
                      style: GoogleFonts.mulish(
                          fontWeight: FontWeight.bold,
                          fontSize:15,
                          color: whiteColor),
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
          child: title == "Delivery"
              ? Container(
                  height: 24,
                  width: 24,
                  child: Image.asset("lib/images/Home.png", color: whiteColor))
              : Icon(
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
    

    return Text(
      label,
      style: GoogleFonts.mulish(
        fontWeight: FontWeight.w600,
        color: isInactive?greyColor:whiteColor,
        fontSize: size * 0.03,
      ),
    );
  }

  Widget MedicineCard(
      {required String MedicineName,
      required String quantities,
      required String price}) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;
    int quantity = int.parse(quantities);
    double Price = double.parse(price);
    var total = quantity * Price;

    return Container(
      margin: EdgeInsets.symmetric(vertical: height * 0.01),
      padding: EdgeInsets.only(top: width * 0.03, bottom: width * 0.03),
      decoration: BoxDecoration(
        color: scaffoldBlackColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "$MedicineName",
                  style: GoogleFonts.mulish(
                      fontSize:13,
                      fontWeight: FontWeight.w700,
                      color: whiteColor),
                ),
                SizedBox(height: height * 0.005),
                Text(
                  "$quantity x ₹$Price",
                  style: GoogleFonts.mulish(
                    fontWeight: FontWeight.w400,
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
      body:_isInitLoading?Center(
        child: CircularProgressIndicator(
          color: whiteColor,
        ),
      ) :Column(
        children: [
          SizedBox(height: height * 0.03),
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
                            builder: (context) => BaseScreen(
                                  Navigatedfrom: "orderTrackingScreen",
                                )));
                      }
                      if(widget.NavigatingFrom=="home"){
                        Navigator.of(context).pop();
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
                SizedBox(height: 70),
                Container(
                  height: height * 0.45,
                  child: ClipRRect(
                    child: Image.asset(
                      orderTrackingDetails["status"] == "Order Placed"
                          ? 'lib/images/ordered.png'
                          : orderTrackingDetails["status"] == "Packing"
                              ? 'lib/images/packing.png'
                              : orderTrackingDetails["status"] ==
                                      "On the way"
                                  ? 'lib/images/onTheWay.png'
                                  : orderTrackingDetails["status"] ==
                                          "Delivered"
                                      ? 'lib/images/DELIVERED.png'
                                      : 'lib/images/ordered.png', // Default image

                      height: 80,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 90,
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
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                 
                  Container(
                    width: 320,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        DeliveryStatus(
                          icon: Icons.check_circle,
                          label: "Ordered",
                          color: greenColor,
                          size: width,
                          isInactive: orderTrackingDetails["status"] ==
                                      "Order Placed" ||
                                  orderTrackingDetails["status"] ==
                                      "Packing" ||
                                  orderTrackingDetails["status"] ==
                                      "On the way" ||
                                  orderTrackingDetails["status"] ==
                                      "Delivered"
                              ? false
                              : true,
                        ),
                        Expanded(
                          child: Container(
                            margin: EdgeInsets.only(top: 7),
                            child: Divider(
                              thickness: 1,
                              color: ligtBlackColor,
                            ),
                          ),
                        ),
                        DeliveryStatus(
                          icon: Icons.inventory_2,
                          label: "Packing",
                          color: greenColor,
                          size: width,
                          isInactive: orderTrackingDetails["status"] ==
                                      "Packing" ||
                                  orderTrackingDetails["status"] ==
                                      "On the way" ||
                                  orderTrackingDetails["status"] ==
                                      "Delivered"
                              ? false
                              : true,
                        ),
                        Expanded(
                          child: Container(
                            margin: EdgeInsets.only(top: 7),
                            child: Divider(
                              thickness: 1,
                              color: ligtBlackColor,
                            ),
                          ),
                        ),
                        DeliveryStatus(
                          icon: Icons.local_shipping,
                          label: "Enroute",
                          color: greenColor,
                          size: width,
                          isInactive: orderTrackingDetails["status"] ==
                                      "On the way" ||
                                  orderTrackingDetails["status"] ==
                                      "Delivered"
                              ? false
                              : true,
                        ),
                        Expanded(
                          child: Container(
                            margin: EdgeInsets.only(top: 7),
                            child: Divider(
                              thickness: 1,
                              color: ligtBlackColor
                            ),
                          ),
                        ),
                        DeliveryStatus(
                          icon: Icons.check_circle,
                          label: "Delivered",
                          color: greenColor,
                          size: width,
                          isInactive:
                              orderTrackingDetails["status"] == "Delivered"
                                  ? false
                                  : true,
                        ),
                      ],
                    ),
                  ),
                
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.all(width * 0.04),
                      child: Column(
                       
                        children: [
                          OrderDetail(
                            icon: Icons.home_outlined,
                            title: "Delivery",
                            subtitle:orderTrackingDetails['dropDetails']?['address']?['street_address1'] ?? "Unknown",
                            width: width,
                          ),
                          SizedBox(height: 24,),
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
