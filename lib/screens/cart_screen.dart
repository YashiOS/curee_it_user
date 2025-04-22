import 'dart:io';

import 'package:cureeit_user_app/cards/cart_card.dart';
import 'package:cureeit_user_app/current_address/google_maps_screen.dart';
import 'package:cureeit_user_app/screens/Order_SuccessScreen.dart';
import 'package:cureeit_user_app/screens/addresses_screen.dart';
import 'package:cureeit_user_app/selected_Address/currentAddress.dart';
import 'package:cureeit_user_app/utils/razor_pay.dart';
import 'package:cureeit_user_app/utils/theme.dart';
import 'package:cureeit_user_app/widgets/LoadingIndicater.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'dart:convert';

import 'package:razorpay_flutter/razorpay_flutter.dart';

class CartScreen extends StatefulWidget {
  final isNavigated;
  const CartScreen({super.key, required this.isNavigated});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  bool isDeleting = false;
  List<Map<String, dynamic>> cartItems = [];
  List<dynamic> addresses = [];
  Map<String, dynamic>? selectedAddress;
  bool isLoading = true;
  double totalAmount = 0.00;
  double taxServices = 0.0;
  double deliveryServiceFees = 0;
  double totalWholeAmount = 0;
  bool requiresPrescription = false;
  final ImagePicker _picker = ImagePicker();
  bool payNow = true;
  bool imagePicked = false;
  File? _imageFile;

  @override
  void initState() {
    super.initState();
    fetchCartDetails();
    fetchAddresses();
  }

  void reBuild() {
    setState(() {});
    print("ruBuild done");
  }

  void ItemDeleting(bool value) {
    print("is deleting $value");
    if (value) {
      setState(() {
        isDeleting = true;
      });
    } else {
      setState(() {
        isDeleting = false;
      });
    }
  }

  void removeItemFromCart(String productId) {
    setState(() {
      cartItems.removeWhere((item) => item['productId'] == productId);

      if (cartItems.isEmpty) {
        totalAmount = 0.0;
        taxServices = 0.0;
        deliveryServiceFees = 0.0;
        totalWholeAmount = 0.0;
      }
    });
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
    } catch (error) {
      print("item did not got removed $error");
    }
  }

  void _navigateToAddressScreen() async {
    final address = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddressesScreen(userId: "68fa72cbdc5f0a68"),
      ),
    );
    setState(() {});
    if (address != null) {
      setState(() {
        selectedAddress = address;
      });
    }
  }

  Future<void> fetchCartDetails() async {
    print("****fetching cart******");
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
          double totalFromApi =
              double.tryParse(responseData['totalAmount'].toString()) ?? 0.0;
          double taxFees =
              double.tryParse(responseData['taxServicesFees'].toString()) ??
                  0.0;
          double deliveryFees =
              double.tryParse(responseData['deliveryFees'].toString()) ?? 0.0;

          for (var cartItem in cartData) {
            Map<String, dynamic>? productDetails =
                await fetchProductDetails(cartItem['productId']);

            if (productDetails != null) {
              print("${cartItem["prescription_required"]}");
             
              if (cartItem["prescription_required"]=="true") {
                payNow = false;
                requiresPrescription = true;
                print("in if block");
              }
              //print("🟢 Product Details Retrieved: $productDetails");
              tempCart.add({
                "productId": cartItem['productId'],
                "quantity": cartItem['quantity'],
                "name": productDetails['name'],
                "sellingPrice": cartItem["sellingPrice"] ?? '0',
                "packagingDetail": productDetails['packagingDetail'],
                "imageUrls": productDetails['imageUrls'],
                "productPrice": cartItem["productPrice"],
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
    print(cartItems);
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
      ..body = jsonEncode({'userId': "68fa72cbdc5f0a68"});

    var response = await http.Client().send(request);

    if (response.statusCode == 200) {
      final data = json.decode(await response.stream.bytesToString());
      addresses = data['data']['address'];

      selectedAddress = data['data']['address'][0];
    } else {
      print('Failed to load addresses');
    }
  }

  Future<void> createCheckout(String total, double shippingCost,
      String shippingAddress, String transactionId) async {
    print("***SHIPPING ADDRESS****");
    print(shippingAddress);
    int Total = double.parse(total).toInt();
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
          "totalAmount": Total,
          "shippingAddress": shippingAddress,
          "shippingCost": shippingCost,
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

        if (responseData['message'] == 'Order created successfully') {
          _removeAllFromCart(); //removing cart item from backend , not using await so it will be done in background ,so user does not have to wait
          cartItems.clear();
          //            Navigator.push(
          // context,
          // MaterialPageRoute(
          //   builder: (context) => OrderSuccessScreen(),
          // ),
          // );
          print("*****ORDER-ID-CART-SCREEN********${responseData["data"]}");
          final shouldRefresh = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OrderSuccessScreen(
                orderId: responseData['data']['orderId'],
              ),
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

  void showUploadPrescriptionBottomSheet(BuildContext context) {
    showModalBottomSheet(
        context: context,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (_) {
          return Container(
            decoration: BoxDecoration(
                color: ligtBlackColor,
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20))),
            height: 160,
            width: MediaQuery.of(context).size.width,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(
                  height: 20,
                ),
                Text(
                  "Upload Prescription",
                  style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      fontFamily: "Urbanist",
                      color: whiteColor),
                ),
                SizedBox(
                  height: 20,
                ),
                Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      GestureDetector(
                        onTap: () async {
                          await pickFromCamera();
                          Navigator.of(context).pop();
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 15, vertical: 11),
                          decoration: BoxDecoration(
                            color: scaffoldBlackColor,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.camera_alt_outlined,
                                  size: 18, color: Colors.white),
                              const SizedBox(width: 6),
                              Text(
                                "Camera",
                                style: const TextStyle(
                                  fontFamily: "Urbanist",
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () async {
                          await pickFromGallery();
                          Navigator.of(context).pop();
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 15, vertical: 11),
                          decoration: BoxDecoration(
                            color: scaffoldBlackColor,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.photo_library,
                                  size: 18, color: Colors.white),
                              const SizedBox(width: 6),
                              Text(
                                "Gallery",
                                style: const TextStyle(
                                  fontFamily: "Urbanist",
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          );
        });
  }

  Future<void> pickFromCamera() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      _imageFile = File(pickedFile.path);
      imagePicked = true;
      payNow = true;
      setState(() {});
    }
  }

  Future<void> pickFromGallery() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      _imageFile = File(pickedFile.path);
      imagePicked = true;
      payNow = true;
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            toolbarHeight: widget.isNavigated ? 48 : 0,
            backgroundColor: scaffoldBlackColor,
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
                      Icon(Icons.arrow_back, color: greenColor),
                      Text(
                        "Back",
                        style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            fontFamily: "Urbanist",
                            color: whiteColor),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
          body: Container(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).size.height * 0.06),
            color: scaffoldBlackColor,
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 0.0, horizontal: 18),
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
                                  fontSize:
                                      MediaQuery.of(context).size.width * 0.06,
                                  fontFamily: "JosefinSans",
                                  color: whiteColor),
                            )
                          ]),
                          if (requiresPrescription)
                            GestureDetector(
                              onTap: () {
                                showUploadPrescriptionBottomSheet(context);
                              },
                              child: Container(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 16),
                                height: 56,
                                decoration: BoxDecoration(
                                  color: const Color(
                                      0xFF1A1A1A), // or any color you want
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Upload your prescription',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontFamily: "JosefinSans",
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    Container(
                                      width: 16,
                                      height: 16,
                                      decoration: BoxDecoration(
                                        color: imagePicked
                                            ? greenColor
                                            : Colors.black,
                                        shape: BoxShape.circle,
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            )
                          else
                            Container(),
                          Container(
                            width: MediaQuery.of(context).size.width,
                            decoration: BoxDecoration(
                                color: ligtBlackColor,
                                borderRadius: BorderRadius.circular(10)),
                            child: Stack(
                              children: [
                                isLoading
                                    ? Center(
                                        child: Padding(
                                        padding: const EdgeInsets.all(12.0),
                                        child: CircularProgressIndicator(
                                          color: whiteColor,
                                        ),
                                      ))
                                    : cartItems.isEmpty
                                        ? SizedBox(
                                            width: MediaQuery.of(context)
                                                .size
                                                .width,
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      vertical: 16.0),
                                                  child: Text(
                                                    "No Items in Cart",
                                                    style: TextStyle(
                                                        fontSize: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width *
                                                            0.07,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color:
                                                            Color(0xFFFFFFFF)),
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
                                                            productPrice:
                                                                item["productPrice"] ??
                                                                    0.0,
                                                            reBuild: reBuild,
                                                            productName:
                                                                item['name'],
                                                            packLabel:
                                                                item['packagingDetail'] ??
                                                                    " ",
                                                            quantity:
                                                                item['quantity'] ??
                                                                    1,
                                                            productId: item[
                                                                'productId'],
                                                            sellingPrice: item[
                                                                    'sellingPrice'] ??
                                                                0.0,
                                                            onUpdate:
                                                                fetchCartDetails,
                                                            onRemove: () async {
                                                              print(
                                                                  "on remove is called");
                                                              removeItemFromCart(
                                                                  item[
                                                                      'productId']);
                                                            },
                                                            isDeleting:
                                                                ItemDeleting,
                                                            productImages: item[
                                                                    'imageUrls'] ??
                                                                ''))
                                                        .toList(),
                                                  ),
                                                ],
                                              ),
                                              Padding(
                                                padding: EdgeInsets.only(
                                                  left: screenWidth *
                                                      0.075, // ≈30 for width ≈ 400
                                                  right: screenWidth *
                                                      0.055, // ≈22
                                                  top: screenHeight *
                                                      0.035, // ≈28 for height ≈ 800
                                                  bottom: screenHeight *
                                                      0.0175, // ≈14
                                                ),
                                                child: Column(
                                                  spacing: screenWidth * 0.045,
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
                                                            fontSize:
                                                                screenWidth *
                                                                    0.03,
                                                            fontFamily:
                                                                "Urbanist",
                                                            color: greyColor,
                                                          ),
                                                        ),
                                                        Text(
                                                          "₹${(totalAmount)}",
                                                          style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.w400,
                                                            fontSize:
                                                                screenWidth *
                                                                    0.03,
                                                            fontFamily:
                                                                "Urbanist",
                                                            color: greyColor,
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
                                                          spacing: screenWidth *
                                                              0.05,
                                                          children: [
                                                            Text(
                                                              "Delivery Fee",
                                                              style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w400,
                                                                fontSize:
                                                                    screenWidth *
                                                                        0.03,
                                                                fontFamily:
                                                                    "Urbanist",
                                                                color:
                                                                    greyColor,
                                                              ),
                                                            ),
                                                            Image.asset(
                                                              "lib/images/cart_i_button.png",
                                                              height: 10,
                                                              width: 10,
                                                              fit: BoxFit
                                                                  .contain,
                                                            )
                                                          ],
                                                        ),
                                                        Text(
                                                          "₹${deliveryServiceFees}",
                                                          style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.w400,
                                                            fontSize:
                                                                screenWidth *
                                                                    0.03,
                                                            fontFamily:
                                                                "Urbanist",
                                                            color: greyColor,
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
                                                          spacing: screenWidth *
                                                              0.05,
                                                          children: [
                                                            Text(
                                                              "GST and Platform Fees",
                                                              style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w400,
                                                                fontSize:
                                                                    screenWidth *
                                                                        0.03,
                                                                fontFamily:
                                                                    "Urbanist",
                                                                color:
                                                                    greyColor,
                                                              ),
                                                            ),
                                                            Image.asset(
                                                              "lib/images/cart_i_button.png",
                                                              height: 10,
                                                              width: 10,
                                                              fit: BoxFit
                                                                  .contain,
                                                            )
                                                          ],
                                                        ),
                                                        Text(
                                                          "₹${taxServices}",
                                                          style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.w400,
                                                            fontSize:
                                                                screenWidth *
                                                                    0.03,
                                                            fontFamily:
                                                                "Urbanist",
                                                            color: greyColor,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    Padding(
                                                      padding: EdgeInsets.only(
                                                          top: screenHeight *
                                                              0.05),
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
                                                          height: screenHeight *
                                                              0.06,
                                                          width:
                                                              screenWidth * 0.3,
                                                          alignment:
                                                              Alignment.center,
                                                          decoration:
                                                              BoxDecoration(
                                                            border: Border.all(
                                                              color: greenColor,
                                                              width: 1,
                                                            ),
                                                            color:
                                                                ligtBlackColor, // Setting the background color to primary color
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        10), // Setting the border radius to 10
                                                          ),
                                                          child:
                                                              GestureDetector(
                                                            onTap: () {
                                                              if (addresses
                                                                      .length ==
                                                                  0) {
                                                                Navigator.of(
                                                                        context)
                                                                    .pushReplacement(MaterialPageRoute(
                                                                        builder:
                                                                            (context) =>
                                                                                GoogleMapsScreen()));
                                                                return;
                                                              }
                                                              if (payNow ==
                                                                  false) {
                                                                ScaffoldMessenger.of(
                                                                        context)
                                                                    .showSnackBar(
                                                                  SnackBar(
                                                                      content: Text(
                                                                          'Upload Prescription')),
                                                                );
                                                                return;
                                                              }
                                                              RazorpayPayment
                                                                  razorpayPayment =
                                                                  RazorpayPayment(
                                                                onSuccess:
                                                                    (PaymentSuccessResponse
                                                                        response) {
                                                                  createCheckout(
                                                                    (totalWholeAmount)
                                                                        .toStringAsFixed(
                                                                            2),
                                                                    deliveryServiceFees,
                                                                    "${Address.CurrentAddress!["address"]}",
                                                                    response
                                                                        .paymentId
                                                                        .toString(),
                                                                  );
                                                                },
                                                                onFailure:
                                                                    (PaymentFailureResponse
                                                                        response) {
                                                                  // Handle payment failure
                                                                  print(
                                                                      'Payment Failed: ${response.message}');
                                                                  ScaffoldMessenger.of(
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
                                                              child: addresses
                                                                          .length ==
                                                                      0
                                                                  ? Text(
                                                                      "Add your address first",
                                                                      style:
                                                                          TextStyle(
                                                                        color:
                                                                            greenColor,
                                                                        fontFamily:
                                                                            "Urbanist",
                                                                        fontSize:
                                                                            screenWidth *
                                                                                0.025,
                                                                      ),
                                                                    )
                                                                  : Text(
                                                                      "Pay Now",
                                                                      style:
                                                                          TextStyle(
                                                                        color: payNow
                                                                            ? greenColor
                                                                            : greyColor,
                                                                        fontSize:
                                                                            screenWidth *
                                                                                0.045,
                                                                        fontFamily:
                                                                            "Urbanist",
                                                                        fontWeight:
                                                                            FontWeight.w600,
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
                                                                    FontWeight
                                                                        .w600,
                                                                fontSize:
                                                                    screenWidth *
                                                                        0.04,
                                                                fontFamily:
                                                                    "Urbanist",
                                                                color:
                                                                    greyColor),
                                                          ),
                                                          Text(
                                                            "₹${totalWholeAmount.toStringAsFixed(2)}",
                                                            style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w700,
                                                              fontSize:
                                                                  screenWidth *
                                                                      0.05,
                                                              fontFamily:
                                                                  "Urbanist",
                                                              color: whiteColor,
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
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 0.0),
                            child: Container(
                              padding: EdgeInsets.only(
                                right: MediaQuery.of(context).size.width *
                                    0.04, // 4% of screen width
                                left: MediaQuery.of(context).size.width *
                                    0.05, // 5% of screen width
                                top: MediaQuery.of(context).size.height *
                                    0.04, // 5% of screen height
                                bottom: MediaQuery.of(context).size.height *
                                    0.04, // 5% of screen height
                              ),
                              margin: EdgeInsets.only(bottom: 60),
                              decoration: BoxDecoration(
                                  color: ligtBlackColor,
                                  borderRadius: BorderRadius.circular(10)),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                spacing: screenHeight * 0.02,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "Delivery Address",
                                        style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: screenWidth * 0.035,
                                          fontFamily: "JosefinSans",
                                          color: whiteColor,
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: _navigateToAddressScreen,
                                        child: Container(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.035, // ~14 on 400px width
                                            vertical: MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                0.0075, // ~6 on 800px height
                                          ),
                                          decoration: BoxDecoration(
                                              color: greenColor,
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
                                                  color: whiteColor,
                                                ),
                                              ),
                                              Icon(
                                                Icons.play_arrow,
                                                color: whiteColor,
                                                size: 18,
                                              )
                                            ],
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                  Text(
                                    Address.CurrentAddress != null
                                        ? "${Address.CurrentAddress!['address']} ${Address.CurrentAddress!['landmark'] != "" ? "\n landmark : ${Address.CurrentAddress!['landmark']}" : ""} ${Address.CurrentAddress!["floor"] != "" ? "\n floor : ${Address.CurrentAddress!["floor"]}" : ""}"
                                        : "N/A",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w400,
                                      fontSize:
                                          MediaQuery.of(context).size.width *
                                              0.03,
                                      fontFamily: "Urbanist",
                                      color: whiteColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        if (isDeleting) const BubbleLoadingOverlay(),
      ],
    );
  }
}
