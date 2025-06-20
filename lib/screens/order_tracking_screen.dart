import 'dart:convert';
import 'dart:async';
import 'package:cureeit_user_app/BaseUrl.dart';
import 'package:cureeit_user_app/cards/cart_card.dart';
import 'package:cureeit_user_app/cards/order_accepted_card.dart';
import 'package:cureeit_user_app/cartManager/cartManager.dart';
import 'package:cureeit_user_app/screens/Order_SuccessScreen.dart';
import 'package:cureeit_user_app/screens/base_screen.dart';
import 'package:cureeit_user_app/screens/loading.dart';
import 'package:cureeit_user_app/selected_Address/currentAddress.dart';
import 'package:cureeit_user_app/user/user.dart';
import 'package:cureeit_user_app/utils/cashfree.dart';
import 'package:cureeit_user_app/utils/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cashfree_pg_sdk/utils/cfenums.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:url_launcher/url_launcher.dart';

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
  var orderTrackingDetails;
  var paymentOrderData;
  List acceptedProducts = [];
  bool HittingApi = false;
  bool _isInitLoading = true;

  Future<void> createCheckout(String total, double shippingCost,
      String shippingAddress, String transactionId, String avlId) async {
    ;

    try {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => LoadingScreen(),
          fullscreenDialog: true,
        ),
      );
      var url = Uri.parse('$baseUrl/order/createCheckout');
      var request = http.Request('POST', url)
        ..headers.addAll({
          'Content-Type': 'application/json',
        })
        ..body = jsonEncode({
          "userId": User.userId,
          "shippingAddress": shippingAddress,
          "availableId": avlId,
          "userLat": Address.CurrentAddress?["userLat"] ?? 0.0,
          "userLong": Address.CurrentAddress?["userLong"] ?? 0.0,
          "paymentDetails": {
            "gateway": "Paytm",
            "transactionId": transactionId,
            "status": "Paid"
          }
        });

      var response = await http.Client().send(request);

      if (response.statusCode == 200) {
        var responseBody = await response.stream.bytesToString();
        Map<String, dynamic> responseData = jsonDecode(responseBody);

        if (responseData['success'] == true) {
          CartManager.cartQuantities.clear();
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OrderSuccessScreen(
                orderId: responseData['data']['availableID'],
              ),
            ),
          );
        }
      } else {
        var responseBody = await response.stream.bytesToString();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Failed to Create Order",
              style: GoogleFonts.mulish(),
            ),
            backgroundColor: greenColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            duration: Duration(seconds: 2),
          ),
        );
        throw Exception('Failed to Create Order --> $responseBody');
      }
    } catch (error) {
      print('Error in Creating Order: $error');
    }
  }

  String formatDate(String isoDate) {
    // Parse the ISO 8601 string into a DateTime object
    DateTime dateTime = DateTime.parse(isoDate);

    // Format the date to the desired format without suffix for day
    String formattedDate = DateFormat("d MMMM yyyy, h:mm a").format(dateTime);

    return formattedDate;
  }

Future<void> startPayment(String orderId, String paymentSessionId) async {
    final cashFreePayment = CashfreePaymentService(
      environment: CFEnvironment.SANDBOX,
      orderId: orderId,
      paymentSessionId: paymentSessionId,
    );
    
    await cashFreePayment.initializeCashfree();
    await cashFreePayment.webCheckout();
  }


  Future<void> fetchOrderTracking() async {
    String orderId = widget.orderId;
    var url = Uri.parse(
      '$baseUrl/order/orderTracking',
    );
    var response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'availableId': orderId}),
    );
    print("BODY");
    print(response.body);
    if (response.statusCode == 200) {
      setState(() {
        _isInitLoading = false;
      });
      final responseBody = jsonDecode(response.body);
      // 🔐 only once
      final data = responseBody;

      setState(() {
        if (data["data"].isNotEmpty) {
          _isInitLoading = false;
          orderTrackingDetails = Map<String, dynamic>.from(data["data"][0]);
          print("ORDER STATUS");
          print(orderTrackingDetails["status"]);
          if (orderTrackingDetails["status"] == "Available") {
            acceptedProducts = orderTrackingDetails["acceptedProducts"];
          }
        }
      });
    } else {
      setState(() {
        _isInitLoading = false;
      });

      print('Failed to load tracking details');
    }
    if (HittingApi == false) {
      _hittingApi();
    }
    setState(() {
      _isInitLoading = false;
    });
  }
Future<void> getPaymentSessionID() async {
  var url = Uri.parse('$baseUrl/cashfree/getPaymentSessionID');
  final totalAmount = orderTrackingDetails["finalTotal"];
  var response = await http.post(
    url,
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({'userId': User.userId, 'totalAmount': totalAmount}),
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);

    final paymentSessionId = data["payment_session_id"];
    final orderId = data["order_id"];

    setState(() {
      paymentOrderData = {
        "payment_session_id": paymentSessionId,
        "order_id": orderId,
      };
    });

    print(paymentSessionId);
    await startPayment(orderId, paymentSessionId);
  } else {
    print('Failed to load paymentOrderData details');
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

    if (orderTrackingDetails["status"] == "Delivered") {
      _timerStart?.cancel();
    }
  }

  void showOrderSummaryBottomSheet() {
    final List<dynamic> items = orderTrackingDetails['acceptedProducts'] ?? [];
    final double totalSellingPrice = items.fold(0.0, (sum, item) {
      final price = double.tryParse(item['sellingPrice'].toString()) ?? 0.0;
      final quantity = int.tryParse(item['quantity'].toString()) ?? 1;
      return sum + (price * quantity);
    });

    final double itemTotal =
        double.tryParse(orderTrackingDetails["itemTotal"].toString()) ?? 0.0;

    final grandTotal = totalSellingPrice +
        orderTrackingDetails["gstServiceCharge"] +
        orderTrackingDetails["shippingCost"];
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
                        
                        SizedBox(
                          width: 5,
                        ),
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
                          fontSize: 12,
                          color: greyColor,
                          fontWeight: FontWeight.w400),
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
                padding: EdgeInsets.only(left: 0, top: 5, bottom: 10),
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
                      "₹${grandTotal.toStringAsFixed(2)}",
                      style: GoogleFonts.mulish(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
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
                  fontSize: MediaQuery.of(context).size.width * 0.04, // ~17 on 375px width

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
        color: isInactive ? greyColor : whiteColor,
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
                      fontSize: 13,
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
      case "In Review":
        return 'lib/images/verifying.png';
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
    if (_isInitLoading) {
      return Center(
          child: CircularProgressIndicator(
        color: whiteColor,
      ));
    }
    if (orderTrackingDetails["status"] == "Available") {
      final finalTotal = double.parse(orderTrackingDetails["finalTotal"]);
      final shippingCostRaw = orderTrackingDetails["shippingCost"];
      final shippingCost = (shippingCostRaw is int)
          ? shippingCostRaw.toDouble()
          : double.tryParse(shippingCostRaw.toString()) ?? 0.0;

      final avlId = orderTrackingDetails["availableID"];
      return Scaffold(
        backgroundColor: scaffoldBlackColor,
        appBar: AppBar(
          scrolledUnderElevation: 0,
          elevation: 0,
          automaticallyImplyLeading: false,
          backgroundColor: ligtBlackColor,
          title: Text(
            'Order Accepted',
            style: GoogleFonts.mulish(color: Colors.white),
          ),
          centerTitle: true,
        ),
        body: Container(
            margin: EdgeInsets.all(16),
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              color: ligtBlackColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListView.builder(
                    physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: acceptedProducts.length,
                    itemBuilder: (context, index) {
                      final marketerName =
                          acceptedProducts[index]["productMarketer"];
                      final productid = acceptedProducts[index]["productId"];
                      final productname =
                          acceptedProducts[index]["productName"];

// productPrice might be a String, so convert safely:
                      final productStr =
                          acceptedProducts[index]["productPrice"].toString();
                      final productPrice = double.tryParse(productStr) ?? 0.0;

// quantity might be int or String, ensure int:
                      final quantityRaw = acceptedProducts[index]["quantity"];
                      final quent = quantityRaw is int
                          ? quantityRaw
                          : int.tryParse(quantityRaw.toString()) ?? 1;

// sellingPrice might be String or double, convert safely:
                      final sellingPriceStr =
                          acceptedProducts[index]["sellingPrice"].toString();
                      final sellingPrice =
                          double.tryParse(sellingPriceStr) ?? 0.0;

                      return OrderAcceptedCard(
                        marketeproductMarketer: marketerName,
                        productId: productid,
                        productName: productname,
                        productPrice: productPrice,
                        quantity: quent,
                        sellingPrice: sellingPrice,
                      );
                    }),
                Container(
                  padding: EdgeInsets.only(right: 25, left: 25, bottom: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Item Total",
                        style: GoogleFonts.mulish(
                          fontWeight: FontWeight.w300,
                          fontSize: 14,
                          color: whiteColor,
                        ),
                      ),
                      Text(
                        "₹${orderTrackingDetails["totalAmount"]}",
                        style: GoogleFonts.mulish(
                          fontWeight: FontWeight.w400,
                          fontSize: 14,
                          color: whiteColor,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.only(right: 25, left: 25, bottom: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Delivery Fee",
                        style: GoogleFonts.mulish(
                          fontWeight: FontWeight.w300,
                          fontSize: 12,
                          color: greyColor,
                        ),
                      ),
                      Text(
                        "₹${orderTrackingDetails["shippingCost"]}",
                        style: GoogleFonts.mulish(
                          fontWeight: FontWeight.w400,
                          fontSize: 12,
                          color: greyColor,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.only(right: 25, left: 25, bottom: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "GST and Platform Fees",
                        style: GoogleFonts.mulish(
                          fontWeight: FontWeight.w300,
                          fontSize: 12,
                          color: greyColor,
                        ),
                      ),
                      Text(
                        "₹${orderTrackingDetails["gstServiceCharge"]}",
                        style: GoogleFonts.mulish(
                          fontWeight: FontWeight.w400,
                          fontSize: 12,
                          color: greyColor,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.only(right: 25, left: 25, bottom: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "To Pay",
                        style: GoogleFonts.mulish(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: whiteColor),
                      ),
                      Text(
                        "₹${double.parse(orderTrackingDetails["finalTotal"]).toStringAsFixed(2)}",
                        style: GoogleFonts.mulish(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          color: whiteColor,
                        ),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () {
                getPaymentSessionID();
                  },
                  child: Container(
                    height: 36,
                    margin: EdgeInsets.all(25),
                    width: double.infinity,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: greenColor,
                      border: Border.all(
                        color: greenColor,
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        "Confirm and Pay",
                        style: GoogleFonts.mulish(
                          color: whiteColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            )),
      );
    }
    if (orderTrackingDetails["status"] == "Not Available" ||
        orderTrackingDetails["status"] == "Rejected") {
      return Scaffold(
        backgroundColor: scaffoldBlackColor,
        body: _isInitLoading
            ? Center(
                child: CircularProgressIndicator(
                  color: whiteColor,
                ),
              )
            : Container(
                width: double.infinity,
                margin: EdgeInsets.all(30),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                              height: 80,
                              child: Container(
                                height: 80,
                                width: 80,
                                decoration: BoxDecoration(
                                  color: const Color.fromARGB(255, 246, 80, 69),
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Icon(
                                    Icons.close,
                                    color: Colors.white,
                                    size: 30,
                                  ),
                                ),
                              )),
                          SizedBox(height: 20),
                          Container(
                            margin: EdgeInsets.all(5),
                            child: Text(
                              'Cancelled',
                              style: GoogleFonts.mulish(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                color: whiteColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
      );
    }

    if (orderTrackingDetails["status"] == "In Review") {
      return Scaffold(
        appBar: AppBar(
          elevation: 0,
          scrolledUnderElevation: 0,
          centerTitle: true,
          backgroundColor: ligtBlackColor,
          shape: ContinuousRectangleBorder(
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(10),
              bottomRight: Radius.circular(10),
            ),
          ),
          title: Text(
            "Status",
            style: GoogleFonts.mulish(
              fontWeight: FontWeight.w400,
              fontSize: 22.69,
              color: whiteColor,
            ),
          ),
          leading: GestureDetector(
            onTap: () {
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => BaseScreen(Navigatedfrom: "")));
            },
            child: Padding(
              padding: const EdgeInsets.only(left: 24.0),
              child: Padding(
                padding: const EdgeInsets.only(left: 4.0),
                child: Row(
                  spacing: 4,
                  children: [
                    SvgPicture.asset(
                      colorFilter:
                          ColorFilter.mode(Colors.white, BlendMode.srcIn),
                      "lib/images/back.svg",
                      width: 24, // optional
                      height: 24, // optional
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        backgroundColor: scaffoldBlackColor,
        body: _isInitLoading
            ? Center(
                child: CircularProgressIndicator(
                  color: whiteColor,
                ),
              )
            : Container(
                width: double.infinity,
                margin: EdgeInsets.all(30),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            height: 80,
                            child: SvgPicture.asset(
                              "lib/images/veryfing.svg",
                            ),
                          ),
                          SizedBox(height: 20),
                          Container(
                            margin: EdgeInsets.all(5),
                            child: Text(
                              'Verifying',
                              style: GoogleFonts.mulish(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                color: whiteColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Container(
                        height: 60,
                        width: 60,
                        child: LoadingIndicator(
                          indicatorType: Indicator.ballPulse, // Bottom loader
                          colors: [whiteColor],
                          strokeWidth: 2,
                          backgroundColor: scaffoldBlackColor,
                          pathBackgroundColor: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      );
    }

    return Scaffold(
      backgroundColor: scaffoldBlackColor,
      body: _isInitLoading
          ? Center(
              child: CircularProgressIndicator(
                color: whiteColor,
              ),
            )
          : Column(
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
                            if (widget.NavigatingFrom == "order_place") {
                              Navigator.of(context)
                                  .pushReplacement(MaterialPageRoute(
                                      builder: (context) => BaseScreen(
                                            Navigatedfrom: "",
                                          )));
                            }
                            if (widget.NavigatingFrom == "Order History") {
                              Navigator.of(context).pop();
                            }
                            if (widget.NavigatingFrom ==
                                "Order_SuccessScreen") {
                              Navigator.of(context)
                                  .pushReplacement(MaterialPageRoute(
                                      builder: (context) => BaseScreen(
                                            Navigatedfrom:
                                                "orderTrackingScreen",
                                          )));
                            }
                            if (widget.NavigatingFrom == "home") {
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
                        height: height * 0.39,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              height: 80,
                              child: ClipRRect(
                                child: Image.asset(
                                  orderTrackingDetails["status"] ==
                                          "Order Placed"
                                      ? 'lib/images/ordered.png'
                                      : orderTrackingDetails["status"] ==
                                              "Packing"
                                          ? 'lib/images/packing.png'
                                          : orderTrackingDetails["status"] ==
                                                  "On the way"
                                              ? 'lib/images/onTheWay.png'
                                              : orderTrackingDetails[
                                                          "status"] ==
                                                      "Delivered"
                                                  ? 'lib/images/DELIVERED.png'
                                                  : 'lib/images/ordered.png', // Default image

                                  height: 80,
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            Text(
                              orderTrackingDetails["status"] == "Order Placed"
                                  ? "Ordered"
                                  : orderTrackingDetails["status"] == "Packing"
                                      ? "Packing"
                                      : orderTrackingDetails["status"] ==
                                              "On the way"
                                          ? "Enroute"
                                          : orderTrackingDetails["status"] ==
                                                  "Delivered"
                                              ? "Delivered"
                                              : "Order status unavailable",
                              style: GoogleFonts.mulish(
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold,
                                  color: whiteColor),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                if (orderTrackingDetails["status"] != "In Review")
                  SizedBox(
                    height: 90,
                  ),
                if (orderTrackingDetails["status"] != "In Review")
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.all(width * 0.04),
                      decoration: BoxDecoration(
                        color: ligtBlackColor,
                        borderRadius:
                            BorderRadius.vertical(top: Radius.circular(8)),
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
                                        thickness: 1, color: ligtBlackColor),
                                  ),
                                ),
                                DeliveryStatus(
                                  icon: Icons.check_circle,
                                  label: "Delivered",
                                  color: greenColor,
                                  size: width,
                                  isInactive: orderTrackingDetails["status"] ==
                                          "Delivered"
                                      ? false
                                      : true,
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: SingleChildScrollView(
                              child: Container(
                                padding: EdgeInsets.all(width * 0.04),
                                child: Column(
                                  children: [
                                    GestureDetector(
                                      onTap: () async {
                                        if (orderTrackingDetails[
                                                        "porterAPIResponse"]
                                                    ["deliveryBoyNumber"] !=
                                                null &&
                                            orderTrackingDetails[
                                                        "porterAPIResponse"]
                                                    ["deliveryBoyNumber"] !=
                                                "") {
                                          final phone = orderTrackingDetails[
                                                  'porterAPIResponse']
                                              ?['deliveryBoyNumber'];
                                          if (phone != null &&
                                              phone.toString().isNotEmpty) {
                                            final Uri launchUri = Uri(
                                              scheme: 'tel',
                                              path: phone.toString(),
                                            );
                                            if (await canLaunchUrl(launchUri)) {
                                              await launchUrl(launchUri);
                                            } else {
                                              // handle error
                                              print(
                                                  'Could not launch $launchUri');
                                            }
                                          }
                                        }
                                      },
                                      child: OrderDetail(
                                        icon: Icons.phone,
                                        title:
                                            "${orderTrackingDetails['porterAPIResponse']?['partner_info']?["name"] ?? "Searching for delivery partner"}",
                                        subtitle: orderTrackingDetails[
                                                    'porterAPIResponse']
                                                ?['deliveryBoyNumber'] ??
                                            "+91 ",
                                        width: width,
                                      ),
                                    ),
                                    SizedBox(
                                      height: 16,
                                    ),
                                    OrderDetail(
                                      icon: Icons.home_outlined,
                                      title: "Delivery",
                                      subtitle:
                                          orderTrackingDetails['dropDetails']
                                                      ?['address']
                                                  ?['street_address1'] ??
                                              "Unknown",
                                      width: width,
                                    ),
                                    SizedBox(
                                      height: 16,
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        showOrderSummaryBottomSheet();
                                      },
                                      child: OrderDetail(
                                        icon: Icons.receipt_outlined,
                                        title: "Bill Details",
                                        subtitle:
                                            "₹${orderTrackingDetails["finalTotal"]??0.0}",
                                        width: width,
                                      ),
                                    ),
                                  ],
                                ),
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
