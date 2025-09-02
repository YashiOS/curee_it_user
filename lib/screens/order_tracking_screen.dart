import 'dart:convert';
import 'dart:async';
import 'dart:ui';

import 'package:cureeit_user_app/BaseUrl.dart';
import 'package:cureeit_user_app/cards/cart_card.dart';
import 'package:cureeit_user_app/cards/order_accepted_card.dart';
import 'package:cureeit_user_app/cartManager/cartManager.dart';
import 'package:cureeit_user_app/current_address/map_style.dart';
import 'package:cureeit_user_app/current_address/tracking_map_style.dart';
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
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

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
  late GoogleMapController _mapController;
  bool paymentStart = false;
  var orderTrackingDetails;
  final String apiKey = 'AIzaSyANsLBcGOUyOEFZpqpoLFOqc4MRNSDpng8';
  var paymentOrderData;
  List acceptedProducts = [];
  bool webSockteConnected = false;
  String orderId = "";
  bool HittingApi = false;
  bool _isInitLoading = true;
  Set<Polyline> polylines = {};
  late BitmapDescriptor bikeIcon = BitmapDescriptor.defaultMarker;
  late BitmapDescriptor homeIcon = BitmapDescriptor.defaultMarker;
  late BitmapDescriptor shopIcon = BitmapDescriptor.defaultMarker;

  WebSocketChannel? _channel;
  double? vendorLat;
  double? vendorLng;
  double? dropLat;
  double? dropLng;
  double? partnerLat;
  double? partnerLng;
  List<String> messages = [];
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

  Future<void> fetchOrderTracking() async {
    print("**************FETCH ORDER TRACKING****************************");
    String avildId = widget.orderId;
    var url = Uri.parse(
      '$baseUrl/order/orderTracking',
    );
    var response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'availableId': avildId}),
    );

    if (response.statusCode == 200) {
      final responseBody = jsonDecode(response.body);
      // 🔐 only once
      final data = responseBody;

      setState(() {
        if (data["data"].isNotEmpty) {
          _isInitLoading = false;
          orderTrackingDetails = Map<String, dynamic>.from(data["data"][0]);
          if (orderTrackingDetails["status"] == "Available") {
            acceptedProducts = orderTrackingDetails["acceptedProducts"];
          }
        }
      });
      orderId = orderTrackingDetails["orderId"];
      if (orderTrackingDetails["status"] == "On the way" ||
          orderTrackingDetails["status"] == "Order Placed" ||
          orderTrackingDetails["status"] == "Packing" ||
          orderTrackingDetails["status"] == "Delivery Accepted" ||
          orderTrackingDetails["status"] ==
              "Delivery Partner arrived at darkstore") {
        vendorLat =
            double.parse(orderTrackingDetails['vendorPickupDetails']?['lat']);

        vendorLng =
            double.parse(orderTrackingDetails['vendorPickupDetails']?['long']);

        dropLat = orderTrackingDetails['dropDetails']?['address']?['lat'];

        dropLng = orderTrackingDetails['dropDetails']?['address']?['lng'];

        // partnerLat = orderTrackingDetails['porterAPIResponse']?['partner_info']
        //         ?['location']?['lat'] ??
        //     vendorLat;
        // partnerLng = orderTrackingDetails['porterAPIResponse']?['partner_info']
        //         ?['location']?['long'] ??

        await loadCustomIcon();
        if (webSockteConnected == false) {
          webSockteConnected = true;
          connectWebSocket();
        }

        if (orderTrackingDetails["status"] == "On the way") {
          await getDirections(dropLat!, dropLng!, partnerLat!, partnerLng!);
        }

        setState(() {
          _isInitLoading = false;
        });
      }
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

  Future<void> connectWebSocket() async {
    _channel = await IOWebSocketChannel.connect("ws://api.medkaro.in");
    print("connecting to webSocket");

    _channel!.stream.listen(
      (message) {
        setState(() {
          final data = jsonDecode(message); // 🔹 decode JSON string into Map

          if (data['type'] == 'locationUpdated') {
            setState(() {
              partnerLat = (data['lat'] as num?)?.toDouble() ?? 0.0;
              partnerLng = (data['long'] as num?)?.toDouble() ?? 0.0;
            });

            print("📍 Updated location: $partnerLat , $partnerLng");
          }

          print("✅ Partner Location: $partnerLat, $partnerLng");

          ;
        });
        print("📩 Message from server: $partnerLat");
      },
      onError: (error) {
        print("❌ WebSocket error: $error");
      },
      onDone: () {
        print("🔌 WebSocket connection closed");
      },
    );

    // 🔹 Send your join message after connecting
    print(widget.orderId);
    _channel!.sink.add('{"type":"joinOrderRoom","orderId":"${orderId}"}');
  }

  void _hittingApi() {
    HittingApi = true;
    _timerStart = Timer.periodic(Duration(seconds: 5), (timer) async {
      fetchOrderTracking();
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
                  fontSize: MediaQuery.of(context).size.width *
                      0.04, // ~17 on 375px width

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

  Future<void> loadCustomIcon() async {
    homeIcon = await BitmapDescriptor.asset(
        const ImageConfiguration(size: Size(30, 30)),
        'lib/images/map_home.png');

    bikeIcon = await BitmapDescriptor.asset(
      const ImageConfiguration(size: Size(88, 38)),
      'lib/images/onTheWay.png',
    );
    shopIcon = await BitmapDescriptor.asset(
        const ImageConfiguration(size: Size(30, 30)),
        'lib/images/map_shop.png');
  }

  Future<void> getDirections(double originLat, double originLng, double destLat,
      double destLng) async {
    print(
        'Getting directions from ($originLat,$originLng) to ($destLat,$destLng)');

    try {
      final String url = 'https://maps.googleapis.com/maps/api/directions/json?'
          'origin=$originLat,$originLng&'
          'destination=$destLat,$destLng&'
          'key=$apiKey';

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        print('Directions API response: $jsonData');

        if (jsonData['routes'] != null && jsonData['routes'].isNotEmpty) {
          final points = jsonData['routes'][0]['overview_polyline']['points'];
          final List<LatLng> polylineCoordinates = _decodePoly(points);

          print('Decoded ${polylineCoordinates.length} points for polyline');

          setState(() {
            polylines = {
              Polyline(
                polylineId: PolylineId('route'),
                points: polylineCoordinates,
                width: 3,
                color: greenColor,
                geodesic: true,
              ),
            };
          });
        } else {
          print('No routes found in response');
        }
      } else {
        print('Directions API error: ${response.statusCode}');
      }
    } catch (e) {
      print('Error getting directions: $e');
    }
  }

  List<LatLng> _decodePoly(String encoded) {
    List<LatLng> poly = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0) ? ~(result >> 1) : (result >> 1);
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0) ? ~(result >> 1) : (result >> 1);
      lng += dlng;

      poly.add(
        LatLng(lat / 1E5, lng / 1E5),
      );
    }
    return poly;
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

    final dynamic vendorLat =
        orderTrackingDetails['vendorPickupDetails']?['lat'] ?? 22.54056;
    final dynamic vendorLng =
        orderTrackingDetails['vendorPickupDetails']?['long'] ?? 88.39583;
    final dynamic dropLat =
        orderTrackingDetails['dropDetails']?['address']?['lat'] ?? 0.0;
    final dynamic dropLng =
        orderTrackingDetails['dropDetails']?['address']?['lng'] ?? 0.0;

    print(vendorLat);
    print(vendorLng);
    print(partnerLat);
    print(partnerLng);
    print(widget.orderId);
    double lat = (vendorLat is String)
        ? double.tryParse(vendorLat) ?? 0.0
        : (vendorLat ?? 0.0).toDouble();
    double lng = (vendorLng is String)
        ? double.tryParse(vendorLng) ?? 0.0
        : (vendorLng ?? 0.0).toDouble();

    return Scaffold(
      backgroundColor: scaffoldBlackColor,
      body: _isInitLoading
          ? Center(
              child: CircularProgressIndicator(
                color: whiteColor,
              ),
            )
          : Stack(
              children: [
                Column(
                  children: [
                    Container(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Container(
                            height: height * 0.71,
                            child: GoogleMap(
                              onMapCreated: (controller) {
                                _mapController = controller;
                              },
                              // Update on pan/zoom

                              style: TrackingMapStyle,
                              initialCameraPosition: CameraPosition(
                                target: LatLng(dropLat, dropLng),
                                zoom: 16,
                              ),
                              zoomControlsEnabled: false,
                              polylines: polylines,
                              markers: {
                                Marker(
                                    markerId: MarkerId('Home'),
                                    icon: homeIcon,
                                    position: LatLng(dropLat, dropLng),
                                    infoWindow:
                                        InfoWindow(title: '', onTap: () {})),
                                Marker(
                                    markerId: MarkerId('DarkStore'),
                                    icon: shopIcon,
                                    position: LatLng(lat, lng),
                                    infoWindow:
                                        InfoWindow(title: '', onTap: () {})),
                                if (orderTrackingDetails["status"] ==
                                    "Delivery Accepted")
                                  Marker(
                                      markerId: MarkerId('Delivery Partner'),
                                      icon: bikeIcon,
                                      position: LatLng(
                                        double.tryParse(
                                                partnerLat.toString()) ??
                                            0.0,
                                        double.tryParse(
                                                partnerLng.toString()) ??
                                            0.0,
                                      ),
                                      infoWindow:
                                          InfoWindow(title: '', onTap: () {})),
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                /*Positioned(
                  top: 60,
                  right: 40,
                  child: GestureDetector(
                    onTap: () {
                      _stopTimer();
                      if (widget.NavigatingFrom == "order_place") {
                        Navigator.of(context).pushReplacement(MaterialPageRoute(
                            builder: (context) => BaseScreen(
                                  Navigatedfrom: "",
                                )));
                      }
                      if (widget.NavigatingFrom == "Order History") {
                        Navigator.of(context).pop();
                      }
                      if (widget.NavigatingFrom == "Order_SuccessScreen") {
                        Navigator.of(context).pushReplacement(MaterialPageRoute(
                            builder: (context) => BaseScreen(
                                  Navigatedfrom: "orderTrackingScreen",
                                )));
                      }
                      if (widget.NavigatingFrom == "home") {
                        Navigator.of(context).pop();
                      }
                    },
                    child: Icon(
                      Icons.close,
                      color: scaffoldBlackColor,
                      size: width * 0.06,
                    ),
                  ),
                ),*/

                if (orderTrackingDetails["status"] != "In Review")
                  Positioned(
                    bottom: height * 0.33,
                    right: width * 0.33,
                    child: Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: greenColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        "Arriving in 7 min",
                        style: GoogleFonts.mulish(
                            color: whiteColor, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                if (orderTrackingDetails["status"] != "In Review")
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: height * 0.3, // Adjust this value as needed
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
                                              "Delivered" ||
                                          orderTrackingDetails["status"] ==
                                              "Delivery Accepted"
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
                                              "Delivered" ||
                                          orderTrackingDetails["status"] ==
                                              "Delivery Accepted"
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
                                    if (orderTrackingDetails["status"] !=
                                        "Delivered")
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
                                              if (await canLaunchUrl(
                                                  launchUri)) {
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
                                            "₹${orderTrackingDetails["finalTotal"] ?? 0.0}",
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

class CustomInfoWindow extends StatelessWidget {
  final String title;
  final String address;
  final String? phoneNumber;
  final VoidCallback? onCallPressed;

  const CustomInfoWindow({
    Key? key,
    required this.title,
    required this.address,
    this.phoneNumber,
    this.onCallPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;

    return Container(
      width: width * 0.8,
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: ligtBlackColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
        border: Border.all(color: greenColor, width: 1),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: GoogleFonts.mulish(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: whiteColor,
                ),
              ),
              if (onCallPressed != null && phoneNumber != null)
                IconButton(
                  icon: Icon(Icons.call, color: greenColor, size: 20),
                  onPressed: onCallPressed,
                ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            address,
            style: GoogleFonts.mulish(
              fontSize: 14,
              color: greyColor,
            ),
          ),
          if (phoneNumber != null) ...[
            SizedBox(height: 8),
            Text(
              "Contact: $phoneNumber",
              style: GoogleFonts.mulish(
                fontSize: 14,
                color: whiteColor,
              ),
            ),
          ],
        ],
      ),
    );
  }
}