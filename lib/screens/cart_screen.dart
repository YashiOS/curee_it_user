import 'package:cureeit_user_app/cards/cart_card.dart';
import 'package:cureeit_user_app/screens/Order_SuccessScreen.dart';
import 'package:cureeit_user_app/screens/addresses_screen.dart';
import 'package:cureeit_user_app/utils/razor_pay.dart';
import 'package:cureeit_user_app/utils/theme.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:razorpay_flutter/razorpay_flutter.dart';

class CartScreen extends StatefulWidget {
  final isNavigated;
  const CartScreen({super.key, required this.isNavigated});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  List<Map<String, dynamic>> cartItems = [];
  List<dynamic> addresses = [];
  Map<String, dynamic>? selectedAddress;
  bool isLoading = true;
  double totalAmount = 0.00;
  double taxServices = 0.0;
  double deliveryServiceFees = 0;
  double totalWholeAmount = 0;
  @override
  void initState() {
    super.initState();
    fetchCartDetails();
    fetchAddresses();
  }


  Future<void> _removeAllFromCart() async {
    final String userId = "68fa72cbdc5f0a68"; // Example userId

    final Map<String, dynamic> requestData = {
      "userId": userId,
    };

    final url =
        'http://ec2-13-60-8-94.eu-north-1.compute.amazonaws.com:3000/cart/removeAllFromCart';
    try {
      final response = await http.delete(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(requestData),
      );

      if (response.statusCode == 200) {
        fetchCartDetails(); // Re-fetch cart details to update the UI
      } else {}
    } catch (error) {}
  }

  void _navigateToAddressScreen() async {
    final address = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddressesScreen(userId: "68fa72cbdc5f0a68"),
      ),
    );

    if (address != null) {
      setState(() {
        selectedAddress = address;
      });
    }
  }

  Future<void> fetchCartDetails() async {
    var cartApiUrl = Uri.parse(
        "http://ec2-13-60-8-94.eu-north-1.compute.amazonaws.com:3000/cart/cartDetails");
    final String userId = "68fa72cbdc5f0a68"; // Replace with the actual userId

    try {
      var request = http.Request('GET', cartApiUrl)
        ..headers.addAll({
          'Content-Type': 'application/json',
        })
        ..body = jsonEncode({"userId": userId});

      var response = await http.Client().send(request);

      if (response.statusCode == 200) {
        final responseData = jsonDecode(await response.stream.bytesToString());

        if (responseData['status'] == 200 && responseData['data'] != null) {
          List<dynamic> cartData = responseData['data'];
          List<Map<String, dynamic>> tempCart = [];
          double totalFromApi = double.tryParse(responseData['totalAmount'].toString()) ?? 0.0;
double taxFees = double.tryParse(responseData['taxServicesFees'].toString()) ?? 0.0;
double deliveryFees = double.tryParse(responseData['deliveryFees'].toString()) ?? 0.0;

          for (var cartItem in cartData) {
            print(
                "🔵 Fetching product details for Product ID: ${cartItem['productId']}");

            Map<String, dynamic>? productDetails =
                await fetchProductDetails(cartItem['productId']);

            if (productDetails != null) {
              print("🟢 Product Details Retrieved: $productDetails");
              tempCart.add({
                "productId": cartItem['productId'],
                "quantity": cartItem['quantity'],
                "name": productDetails['name'],
                "sellingPrice": (productDetails['sellingPrice'] is int)
                    ? productDetails['sellingPrice'].toDouble()
                    : double.tryParse(
                            productDetails['sellingPrice'].toString()) ??
                        0.0,
                "packagingDetail": productDetails['packagingDetail'],
                "imageUrls": productDetails['imageUrls']
              });
            } else {
              print(
                  "❌ Failed to fetch details for Product ID: ${cartItem['productId']}");
            }
          }

          setState(() {
            cartItems = tempCart;
            isLoading = false;
            totalAmount = totalFromApi;
  taxServices = taxFees;
  deliveryServiceFees = deliveryFees;
  totalWholeAmount = taxServices + totalAmount + deliveryServiceFees;
          });
      
        } else {
          print("❌ Response did not contain valid cart data");
        }
      } else {
        final responseBody = await response.stream.bytesToString();
        print("❌ Failed to fetch cart details. Response: $responseBody");
        if (responseBody.contains("No products available")) {
          setState(() {
            isLoading = false; // Stop loading and show "No Items in Cart"
          });
          return;
        }
      }
    } catch (error) {
      print("❌ Error fetching cart details: $error");
    }
  }

  Future<Map<String, dynamic>?> fetchProductDetails(String productId) async {
    var productApiUrl = Uri.parse(
        "http://ec2-13-60-8-94.eu-north-1.compute.amazonaws.com:3000/product/productDetail");

    try {
      var request = http.Request('GET', productApiUrl)
        ..headers.addAll({
          'Content-Type': 'application/json',
        })
        ..body = jsonEncode(
            {"productId": productId}); // Send body with the productId

      var response = await http.Client().send(request);

      if (response.statusCode == 200) {
        final responseBody = await response.stream.bytesToString();
        final responseData = jsonDecode(responseBody);

        if (responseData['status'] == 200 && responseData['data'] != null) {
          return responseData['data']; // Return the data part of the response
        } else {
          print("❌ Product API did not return valid data.");
        }
      }
    } catch (error) {
      print("❌ Error fetching product details: $error");
    }

    return null;
  }

  Future<void> fetchAddresses() async {
    var url = Uri.parse(
      'http://ec2-13-60-8-94.eu-north-1.compute.amazonaws.com:3000/address/savedAddress',
    );

    var request = http.Request('GET', url)
      ..headers.addAll({
        'Content-Type': 'application/json',
      })
      ..body = jsonEncode(
          {'userId': "68fa72cbdc5f0a68"});

    var response = await http.Client().send(request);

    if (response.statusCode == 200) {
      final data = json.decode(await response.stream.bytesToString());
      setState(() {
        selectedAddress = data['data']['address'][0];
      });
    } else {
      print('Failed to load addresses');
    }
  }

  Future<void> createCheckout(
      String total, double shippingCost, String shippingAddress) async {
    try {
      var url = Uri.parse(
          'http://ec2-13-60-8-94.eu-north-1.compute.amazonaws.com:3000/order/createCheckout');
      var request = http.Request('POST', url)
        ..headers.addAll({
          'Content-Type': 'application/json',
        })
        ..body = jsonEncode({
          "userId": "68fa72cbdc5f0a68",
          "purchaseDate": "2025-03-19T10:30:00Z",
          "currentStatus": "Pending",
          "totalAmount": total,
          "shippingAddress": shippingAddress,
          "shippingCost": shippingCost,
          "userLat": selectedAddress!['userLat'],
          "userLong": selectedAddress!['userLong'],
          "paymentDetails": {
            "gateway": "Paytm",
            "transactionId": "txn_123456789",
            "status": "Paid"
          }
        });

      var response = await http.Client().send(request);

      if (response.statusCode == 200) {
        var responseBody = await response.stream.bytesToString();
        Map<String, dynamic> responseData = jsonDecode(responseBody);

        if (responseData['message'] == 'Order created successfully') {

  //            Navigator.push(
  // context,
  // MaterialPageRoute(
  //   builder: (context) => OrderSuccessScreen(),
  // ),
  // );
  final shouldRefresh = await Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => OrderSuccessScreen(),
  ),
);

if (shouldRefresh == true) {
  await fetchCartDetails();
}
        }
      } else {
        var responseBody = await response.stream.bytesToString();
        throw Exception('Failed to Create Order --> $responseBody');
      }
    } catch (error) {
      print('Error in Creating Order: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: widget.isNavigated ? 48 : 0,
        backgroundColor: Colors.grey[100],
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
      ),
      body: Container(
        color: Colors.grey.shade100.withOpacity(0.5),
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 18),
          child: Stack(
            children: [
              ListView(
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 16,
                    children: [
                      Row(children: [
                        Text(
                          "Cart",
                          style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 24,
                              fontFamily: "JosefinSans",
                              color: primaryColor),
                        )
                      ]),
                      Container(
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10)),
                        padding: EdgeInsets.only(
                            top: 14, bottom: 14, right: 18, left: 28),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              spacing: 12,
                              children: [
                                Icon(
                                  Icons.discount,
                                  color: secondaryColor,
                                ),
                                Text(
                                  "Apply Coupon",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w400,
                                    fontSize: 12,
                                    fontFamily: "Urbanist",
                                    color: Color(0xFF1F1970),
                                  ),
                                ),
                              ],
                            ),
                            Icon(Icons.arrow_forward, color: Color(0xFF1F1970))
                          ],
                        ),
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10)),
                        child: Stack(
                          children: [
                            isLoading
                                ? Center(
                                    child: Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: CircularProgressIndicator(
                                      color: secondaryColor,
                                    ),
                                  ))
                                : cartItems.isEmpty
                                    ? SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width,
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 16.0),
                                              child: Text(
                                                "No Items in Cart",
                                                style: TextStyle(
                                                    fontSize: 28,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.grey
                                                        .withOpacity(0.5)),
                                              ),
                                            ),
                                          ],
                                        ),
                                      )
                                    : Column(
                                        children: [
                                          Column(
                                            children: [
                                              Column(
                                                children: cartItems
                                                    .map((item) => CartCard(
                                                        productName:
                                                            item['name'],
                                                        packLabel: item[
                                                                'packagingDetail'] ??
                                                            " ",
                                                        quantity:
                                                            item['quantity'] ??
                                                                1,
                                                        productId:
                                                            item['productId'],
                                                        sellingPrice: item[
                                                                'sellingPrice'] ??
                                                            0.0,
                                                        onUpdate:
                                                            fetchCartDetails,
                                                        onRemove:
                                                            fetchCartDetails,
                                                        productImages:
                                                            item['imageUrls'] ??
                                                                ''))
                                                    .toList(),
                                              ),
                                            ],
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                left: 30.0,
                                                right: 22,
                                                top: 28,
                                                bottom: 14),
                                            child: Column(
                                              spacing: 18,
                                              children: [
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Text(
                                                      "Item Total",
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.w400,
                                                        fontSize: 12,
                                                        fontFamily: "Urbanist",
                                                        color:
                                                            Color(0xFF1F1970),
                                                      ),
                                                    ),
                                                    Text(
                                                      "₹${(totalAmount)}",
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.w400,
                                                        fontSize: 12,
                                                        fontFamily: "Urbanist",
                                                        color:
                                                            Color(0xFF1F1970),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Row(
                                                      spacing: 18,
                                                      children: [
                                                        Text(
                                                          "Delivery Fee",
                                                          style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.w400,
                                                            fontSize: 12,
                                                            fontFamily:
                                                                "Urbanist",
                                                            color: Color(
                                                                0xFF1F1970),
                                                          ),
                                                        ),
                                                        Image.asset(
                                                          "lib/images/cart_i_button.png",
                                                          height: 10,
                                                          width: 10,
                                                          fit: BoxFit.contain,
                                                        )
                                                      ],
                                                    ),
                                                    Text(
                                                      "₹${deliveryServiceFees}",
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.w400,
                                                        fontSize: 12,
                                                        fontFamily: "Urbanist",
                                                        color:
                                                            Color(0xFF1F1970),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Row(
                                                      spacing: 18,
                                                      children: [
                                                        Text(
                                                          "Tax and Charges",
                                                          style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.w400,
                                                            fontSize: 12,
                                                            fontFamily:
                                                                "Urbanist",
                                                            color: Color(
                                                                0xFF1F1970),
                                                          ),
                                                        ),
                                                        Image.asset(
                                                          "lib/images/cart_i_button.png",
                                                          height: 10,
                                                          width: 10,
                                                          fit: BoxFit.contain,
                                                        )
                                                      ],
                                                    ),
                                                    Text(
                                                      "₹${taxServices}",
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.w400,
                                                        fontSize: 12,
                                                        fontFamily: "Urbanist",
                                                        color:
                                                            Color(0xFF1F1970),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          top: 18.0),
                                                  child: Image.asset(
                                                    "lib/images/dotted_divider.png",
                                                  ),
                                                ),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Container(
                                                      height: 50,
                                                      width: 80,
                                                      alignment:
                                                          Alignment.center,
                                                      decoration: BoxDecoration(
                                                        color:
                                                            primaryColor, // Setting the background color to primary color
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                                10), // Setting the border radius to 10
                                                      ),
                                                      child: GestureDetector(
                                                        onTap: () {
                                                          RazorpayPayment
                                                              razorpayPayment =
                                                              RazorpayPayment(
                                                            onSuccess:
                                                                (PaymentSuccessResponse
                                                                    response) {
                                                                      print("Total Amount is ${totalAmount.toStringAsFixed(2)}");
                                                                createCheckout(
                                                            totalWholeAmount.toStringAsFixed(2),
                                                            deliveryServiceFees,
                                                            "${selectedAddress!['address']}, ${selectedAddress!['landmark']}, ${selectedAddress!['floor']}, ${selectedAddress!['userLat']}, ${selectedAddress!['userLong']}",
                                                          );
                                                            },
                                                            onFailure:
                                                                (PaymentFailureResponse
                                                                    response) {
                                                              // Handle payment failure
                                                              print(
                                                                  'Payment Failed: ${response.message}');
                                                              ScaffoldMessenger
                                                                      .of(
                                                                          context)
                                                                  .showSnackBar(
                                                                      SnackBar(
                                                                content: Text(
                                                                    'Payment Failed'),
                                                              ));
                                                            },
                                                          );

                                                          razorpayPayment
                                                              .initiatePayment(
                                                            totalWholeAmount, // Amount in paise (e.g., 50000 = 500 INR)
                                                            'Cure it', // Product Name
                                                            'Please do the payment', // Description
                                                            '8890170172',
                                                            'yash123@gmail.com',
                                                          );
                                                        },
                                                        child: Center(
                                                          child: Text(
                                                            "Pay Now",
                                                            style: TextStyle(
                                                              color:
                                                                  Colors.white,
                                                              fontSize: 16,
                                                              fontFamily:
                                                                  "Urbanist",
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    Column(children: [
                                                      Text(
                                                        "To Pay",
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            fontSize: 16,
                                                            fontFamily:
                                                                "Urbanist",
                                                            color:
                                                                primaryColor),
                                                      ),
                                                      Text(
                                                        "₹${totalWholeAmount.toStringAsFixed(2)}",
                                                        style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.w700,
                                                          fontSize: 20,
                                                          fontFamily:
                                                              "Urbanist",
                                                          color:
                                                              Color(0xFF1F1970),
                                                        ),
                                                      ),
                                                    ])
                                                  ],
                                                ),
                                              ],
                                            ),
                                          )
                                        ],
                                      ),
                            Transform.translate(
                              offset: Offset(-10, 8),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [],
                              ),
                            )
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 0.0),
                        child: Container(
                          padding: EdgeInsets.only(
                              right: 14, left: 20, top: 20, bottom: 20),
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10)),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            spacing: 16,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Delivery Address",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14,
                                      fontFamily: "JosefinSans",
                                      color: Color(0xFF1F1970),
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: _navigateToAddressScreen,
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 14, vertical: 6),
                                      decoration: BoxDecoration(
                                          color:
                                              secondaryColor.withOpacity(0.16),
                                          borderRadius:
                                              BorderRadius.circular(30)),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            selectedAddress != null
                                                ? selectedAddress!['type']
                                                : "",
                                            // addresses.isNotEmpty ? addresses[0]['type'] ?? 'N/A' : 'Others',
                                            style: TextStyle(
                                              fontWeight: FontWeight.w400,
                                              fontSize: 12,
                                              fontFamily: "Urbanist",
                                              color: secondaryColor,
                                            ),
                                          ),
                                          Icon(
                                            Icons.play_arrow,
                                            color: secondaryColor,
                                            size: 18,
                                          )
                                        ],
                                      ),
                                    ),
                                  )
                                ],
                              ),
                              Text(
                                selectedAddress != null
                                    ? "${selectedAddress!['address']}, \nLandmark:${selectedAddress!['landmark']}, \nFloor:${selectedAddress!['floor']}"
                                    : "N/A",
                                style: TextStyle(
                                  fontWeight: FontWeight.w400,
                                  fontSize: 12,
                                  fontFamily: "Urbanist",
                                  color: Color(0xFF1F1970).withOpacity(0.6),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                  SizedBox(
                    height: 40,
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
