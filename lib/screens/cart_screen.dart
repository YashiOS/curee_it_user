import 'dart:io';
import 'package:cureeit_user_app/BaseUrl.dart';
import 'package:cureeit_user_app/cards/cart_card.dart';
import 'package:cureeit_user_app/cartManager/cartManager.dart';
import 'package:cureeit_user_app/current_address/google_maps_screen.dart';
import 'package:cureeit_user_app/screens/Order_SuccessScreen.dart';
import 'package:cureeit_user_app/screens/addresses_screen.dart';
import 'package:cureeit_user_app/screens/base_screen.dart';
import 'package:cureeit_user_app/screens/loading.dart';
import 'package:cureeit_user_app/screens/placeOrder_screen.dart';
import 'package:cureeit_user_app/selected_Address/currentAddress.dart';
import 'package:cureeit_user_app/user/user.dart';
import 'package:cureeit_user_app/utils/razor_pay.dart';
import 'package:cureeit_user_app/utils/theme.dart';
import 'package:cureeit_user_app/utils/widgets/LoadingIndicater.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_svg/svg.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'dart:convert';

import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:shimmer/shimmer.dart';

class CartScreen extends StatefulWidget {
  final isNavigated;
  const CartScreen({super.key, required this.isNavigated});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  double totalProductPrice = 0.0; // Total of original prices
  double totalSellingPrice = 0.0; // Total of discounted prices
  bool isDeleting = false;
  bool continueWithoutPre = false;
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
  String placeOrderButton="Place Order";
  bool fetchingCart=false;
  bool Servisable=true;

 

  @override
  void initState() {
    super.initState();
    fetchCartDetails();
    fetchAddresses();
    PharmacyOpen();
  }

  void showPaymentDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: ligtBlackColor, // Dark background
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Verifying and confirming your order...",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15.02,
                  fontFamily: 'Mulish',
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 24),
              Container(
                height: 36,
                width: double.infinity,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: greenColor,
                  border: Border.all(
                    color: greenColor,
                    width: 1,
                  ),
                  // Setting the background color to primary color
                  borderRadius: BorderRadius.circular(
                      8), // Setting the border radius to 10
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
            ],
          ),
        ),
      ),
    );
  }

  void reBuild() {
    setState(() {});
    
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

  void checkPrescriptionRequirements() {
    print("check prescription is called");
    bool hasPrescriptionItems =
        cartItems.any((item) => item["prescription_required"] == "Yes");

    setState(() {
      requiresPrescription = hasPrescriptionItems;
      payNow = !hasPrescriptionItems;
      if (!hasPrescriptionItems) {
        requiresPrescription = false;
        imagePicked = false;
        _imageFile = null;
      }
    });
    print("done with check prescription");
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
    checkPrescriptionRequirements();
  }

  Future<void> _removeAllFromCart() async {
    final String? userId = User.userId; // Example userId

    final Map<String, dynamic> requestData = {
      "userId": userId,
    };

    final url = '$baseUrl/cart/removeAllFromCart';
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Failed to remove from cart , try again later",
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
      print("item did not got removed $error");
    }
  }

  void _navigateToAddressScreen() async {
    final address = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddressesScreen(userId: User.userId!),
      ),
    );
    setState(() {});
    if (address != null) {
      setState(() {
        selectedAddress = address;
      });
    }
  }

   Future<bool> PharmacyOpen() async {
    String latitude = "${Address.CurrentAddress!["userLat"]}";
    String longitude = "${Address.CurrentAddress!["userLong"]}";
    final String apiUrl = "$baseUrl/home/check-serviceability";
    try {
      final response = await http.post(Uri.parse(apiUrl),
          body: {"userLat": latitude, "userLong": longitude});
      final data = jsonDecode(response.body);
       print("is it servisable");
        print(data["serviceable"]);
      if (data["serviceable"] == true) {
       
        return true;
      } else {
        if (mounted) {
          setState(() {
            Servisable=false;
          placeOrderButton = data["reason"];
          });
        }
        return false;
      }
    } catch (e) {
      print("Error in checking is pharmacy is open $e");
      return false;
    }
  }

  Future<void> fetchCartDetails() async {
    setState(() {
         fetchingCart=true;
    });

    var cartApiUrl = Uri.parse("$baseUrl/cart/cartDetails");
    final String? userId = User.userId; // Replace with the actual userId

    try {
      var request = http.Request('POST', cartApiUrl)
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
          double productTotal = 0.0;
          double sellingTotal = 0.0;
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
              if (cartItem["prescription_required"] == "Yes") {
                payNow = false;
                setState(() {
                  requiresPrescription = true;
                  fetchingCart=false;
                });
              }

              double itemProductPrice =
                  (cartItem['productPrice'] ?? 0).toDouble();
              double itemSellingPrice =
                  (cartItem['sellingPrice'] ?? 0).toDouble();
              int quantity = cartItem['quantity'] ?? 1;
              productTotal += itemProductPrice * quantity;
              sellingTotal += itemSellingPrice * quantity;
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
            totalProductPrice = productTotal;
            totalSellingPrice = sellingTotal;
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
    var productApiUrl = Uri.parse("$baseUrl/product/productDetail");

    try {
      var request = http.Request('POST', productApiUrl)
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
      '$baseUrl/address/savedAddress',
    );

    var request = http.Request('GET', url)
      ..headers.addAll({
        'Content-Type': 'application/json',
      })
      ..body = jsonEncode({'userId': User.userId});

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
    ;
    String base64Image = "";
    if (_imageFile != null) {
      List<int> imageBytes = await _imageFile!.readAsBytes();
      base64Image = base64Encode(imageBytes);
    }

    int Total = double.parse(total).toInt();

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
          //"availableId":
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
        Navigator.pop(context);
        if (responseData['message'] == 'Order created successfully') {
          _removeAllFromCart();
          CartManager.cartQuantities
              .clear(); //removing cart item from backend , not using await so it will be done in background ,so user does not have to wait
          cartItems.clear();

          //            Navigator.push(
          // context,
          // MaterialPageRoute(
          //   builder: (context) => OrderSuccessScreen(),
          // ),
          // );

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
                  style: GoogleFonts.mulish(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
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
                                style: GoogleFonts.mulish(
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
                                style: GoogleFonts.mulish(
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

  Future<File?> compressImage(File imageFile) async {
    try {
      final dir = await getTemporaryDirectory();
      final targetPath = path.join(
          dir.path, "compressed_${DateTime.now().millisecondsSinceEpoch}.jpg");

      final compressedFile = await FlutterImageCompress.compressAndGetFile(
        imageFile.absolute.path,
        targetPath,
        quality: 30,

        // You can tune this
      );
      print("image compressed");
      return File(compressedFile!.path);
    } catch (e) {
      print("Image compression error: $e");
      return null;
    }
  }

  Future<void> pickFromCamera() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      _imageFile = await compressImage(File(pickedFile.path));

      imagePicked = true;
      payNow = true;
      continueWithoutPre = false;
      setState(() {});
    }
  }

  Future<void> pickFromGallery() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      _imageFile = await compressImage(File(pickedFile.path));
      ;
      imagePicked = true;
      payNow = true;
      continueWithoutPre = false;
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
          backgroundColor: scaffoldBlackColor,
          appBar: AppBar(
            scrolledUnderElevation: 0,
            elevation: 0,
            centerTitle: true,
            backgroundColor: ligtBlackColor,
            shape: ContinuousRectangleBorder(
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(10),
                bottomRight: Radius.circular(10),
              ),
            ),
            title: Text(
              "Cart",
              style: GoogleFonts.mulish(
                fontWeight: FontWeight.w400,
                fontSize: 22.69,
                color: whiteColor,
              ),
            ),
            leading: GestureDetector(
              onTap: () {
                if (widget.isNavigated) {
                  Navigator.pop(context);
                  return;
                }

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
          body: isLoading
              ? Center(
                  child: CircularProgressIndicator(
                    color: whiteColor,
                  ),
                )
              : cartItems.isEmpty
                  ? Container(
                      height: double.infinity,
                      width: double.infinity,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          BaseScreen(Navigatedfrom: "")));
                            },
                            child: Center(
                              child: Container(
                                  height: 204,
                                  width: 150,
                                  child:
                                      Image.asset("lib/images/empty cart.png")),
                            ),
                          ),
                        ],
                      ),
                    )
                  : Container(
                      padding: EdgeInsets.only( bottom: widget.isNavigated?20:100),
                      color: scaffoldBlackColor,
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 0.0, horizontal: 18),
                        child: Stack(
                          children: [
                            ListView(
                              children: [
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  spacing: 5,
                                  children: [
                                    GestureDetector(
                                      onTap: () async {
                                        await Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    AddressesScreen(
                                                      userId: User.userId!,
                                                    )));
                                        setState(() {});
                                      },
                                      child: Container(
                                        width: double.infinity,
                                        padding: const EdgeInsets.only(
                                            left: 16,
                                            right: 16,
                                            top: 10,
                                            bottom: 10),
                                        margin: EdgeInsets.only(
                                            top: 28, bottom: 10),
                                        decoration: BoxDecoration(
                                          color: ligtBlackColor,
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    "Delivering to",
                                                    style: GoogleFonts.mulish(
                                                      color: Colors.white,
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                  SizedBox(height: 4),
                                                  Text(
                                                    "${Address.CurrentAddress!["address"]}",
                                                    style: GoogleFonts.mulish(
                                                      color: greyColor,
                                                      fontSize: 13,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Container(
                                              width: 16,
                                              height: 16,
                                              margin: EdgeInsets.only(
                                                  left:
                                                      8), // Space before trailing widget
                                              decoration: BoxDecoration(
                                                color: greenColor,
                                                shape: BoxShape.circle,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    if (requiresPrescription)
                                      GestureDetector(
                                        onTap: () {
                                          showUploadPrescriptionBottomSheet(
                                              context);
                                        },
                                        child: Container(
                                          margin: EdgeInsets.only(bottom: 10),
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 16),
                                          height: 56,
                                          decoration: BoxDecoration(
                                            color:
                                                ligtBlackColor, // or any color you want
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                'Upload Prescription',
                                                style: GoogleFonts.mulish(
                                                  color: Colors.white,
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              Container(
                                                width: 16,
                                                height: 16,
                                                decoration: BoxDecoration(
                                                  color: imagePicked
                                                      ? greenColor
                                                      : scaffoldBlackColor,
                                                  shape: BoxShape.circle,
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                      )
                                    else
                                      SizedBox.shrink(),
                                    if (requiresPrescription)
                                      GestureDetector(
                                        onTap: () {},
                                        child: Container(
                                          margin: EdgeInsets.only(bottom: 10),
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 16),
                                          height: 75,
                                          decoration: BoxDecoration(
                                            color:
                                                ligtBlackColor, // or any color you want
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    'Continue without Prescription',
                                                    style: GoogleFonts.mulish(
                                                      color: greyColor,
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                  Text(
                                                    'We will call you to confirm your order',
                                                    style: GoogleFonts.mulish(
                                                      color: greyColor,
                                                      fontSize: 13,
                                                      fontWeight:
                                                          FontWeight.w300,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Container(
                                                width: 16,
                                                height: 16,
                                                decoration: BoxDecoration(
                                                  color: ligtBlackColor,
                                                  shape: BoxShape.circle,
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                      )
                                    else
                                      SizedBox.shrink(),
                                    Container(
                                      width: MediaQuery.of(context).size.width,
                                      decoration: BoxDecoration(
                                          color: ligtBlackColor,
                                          borderRadius:
                                              BorderRadius.circular(8)),
                                      child: Stack(
                                        children: [
                                          isLoading
                                              ? Center(
                                                  child: Padding(
                                                  padding: const EdgeInsets.all(
                                                      12.0),
                                                  child:
                                                      CircularProgressIndicator(
                                                    color: whiteColor,
                                                  ),
                                                ))
                                              : cartItems.isEmpty
                                                  ? SizedBox(
                                                      width:
                                                          MediaQuery.of(context)
                                                              .size
                                                              .width,
                                                      child: Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .center,
                                                        children: [
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .symmetric(
                                                                    vertical:
                                                                        16.0),
                                                            child: Text(
                                                              "No Items in Cart",
                                                              style: GoogleFonts.mulish(
                                                                  fontSize: MediaQuery.of(
                                                                              context)
                                                                          .size
                                                                          .width *
                                                                      0.07,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  color: Color(
                                                                      0xFFFFFFFF)),
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
                                                                      productPrice: (item["productPrice"] ?? 0).toDouble(),
                                                                      reBuild: reBuild,
                                                                      productName: item['name'],
                                                                      packLabel: item['packagingDetail'] ?? " ",
                                                                      quantity: item['quantity'] ?? 1,
                                                                      productId: item['productId'],
                                                                      sellingPrice: (item['sellingPrice'] ?? 0).toDouble(),
                                                                      onUpdate: fetchCartDetails,
                                                                      onRemove: () async {
                                                                        removeItemFromCart(
                                                                            item['productId']);
                                                                        fetchCartDetails();
                                                                      },
                                                                      isDeleting: ItemDeleting,
                                                                      productImages: item['imageUrls'] ?? ''))
                                                                  .toList(),
                                                            ),
                                                          ],
                                                        ),
                                                        Padding(
                                                          padding:
                                                              EdgeInsets.only(
                                                            right: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width *
                                                                0.055,
                                                            left: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width *
                                                                0.055,
                                                            top: screenHeight *
                                                                0.035, // ≈28 for height ≈ 800
                                                            bottom:
                                                                screenHeight *
                                                                    0.035, // ≈14
                                                          ),
                                                          child: Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            spacing: 10,
                                                            children: [
                                                              Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .spaceBetween,
                                                                children: [
                                                                  Text(
                                                                    "Item Total",
                                                                    style: GoogleFonts
                                                                        .mulish(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w300,
                                                                      fontSize:
                                                                          14,
                                                                      color:
                                                                          whiteColor,
                                                                    ),
                                                                  ),
                                                                  Container(
                                                                    child: Row(
                                                                      children: [
                                                                        Text(
                                                                          "₹${totalProductPrice.toStringAsFixed(2)}",
                                                                          style: GoogleFonts.mulish(
                                                                              fontWeight: FontWeight.w300,
                                                                              fontSize: 12,
                                                                              color: greyColor,
                                                                              decoration: TextDecoration.lineThrough,
                                                                              decorationColor: greyColor),
                                                                        ),
                                                                        SizedBox(
                                                                          width:
                                                                              5,
                                                                        ),
                                                                        Text(
                                                                          "₹${totalSellingPrice.toStringAsFixed(2)}",
                                                                          style: GoogleFonts.mulish(
                                                                              fontWeight: FontWeight.w400,
                                                                              fontSize: 14,
                                                                              color: whiteColor),
                                                                        )
                                                                      ],
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
                                                                    spacing:
                                                                        screenWidth *
                                                                            0.05,
                                                                    children: [
                                                                      Text(
                                                                        "Delivery Fee",
                                                                        style: GoogleFonts
                                                                            .mulish(
                                                                          fontWeight:
                                                                              FontWeight.w400,
                                                                          fontSize:
                                                                              12,
                                                                          color:
                                                                              greyColor,
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                  Text(
                                                                    "₹${deliveryServiceFees}",
                                                                    style: GoogleFonts
                                                                        .mulish(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w400,
                                                                      fontSize:
                                                                          12,
                                                                      color:
                                                                          greyColor,
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
                                                                    spacing:
                                                                        screenWidth *
                                                                            0.05,
                                                                    children: [
                                                                      Text(
                                                                        "GST and Platform Fees",
                                                                        style: GoogleFonts
                                                                            .mulish(
                                                                          fontWeight:
                                                                              FontWeight.w400,
                                                                          fontSize:
                                                                              12,
                                                                          color:
                                                                              greyColor,
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                  Text(
                                                                    "₹${taxServices}",
                                                                    style: GoogleFonts
                                                                        .mulish(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w400,
                                                                      fontSize:
                                                                          12,
                                                                      color:
                                                                          greyColor,
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                              Column(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .start,
                                                                children: [
                                                                  Row(
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .spaceBetween,
                                                                      children: [
                                                                        Column(
                                                                          crossAxisAlignment:
                                                                              CrossAxisAlignment.start,
                                                                          children: [
                                                                            Text(
                                                                              "To Pay",
                                                                              style: GoogleFonts.mulish(
                                                                                fontWeight: FontWeight.bold,
                                                                                fontSize: 16,
                                                                                color: whiteColor,
                                                                              ),
                                                                            ),
                                                                            if(fetchingCart)
                                                                            const SizedBox(height: 2),
                                                                            if(fetchingCart)
                                                                            Shimmer.fromColors(
                                                                              baseColor: ligtBlackColor,
                                                                              highlightColor: greenColor,
                                                                              child: Container(
                                                                                decoration: BoxDecoration(
                                                                                   borderRadius: BorderRadius.circular(5),
                                                                                    color: greenColor,
                                                                                ),
                                                                                width: 50, // or adjust as needed to match "To Pay" width
                                                                                height: 4,
                                                                              
                                                                              ),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                        Text(
                                                                          "₹${totalWholeAmount.toStringAsFixed(2)}",
                                                                          style:
                                                                              GoogleFonts.mulish(
                                                                            fontWeight:
                                                                                FontWeight.w700,
                                                                            fontSize:
                                                                                15,
                                                                            color:
                                                                                whiteColor,
                                                                          ),
                                                                        ),
                                                                      ]),
                                                                  SizedBox(
                                                                    height: 25,
                                                                  ),
                                                                  GestureDetector(
                                                                    onTap: () {
                                                                      if (addresses
                                                                              .length ==
                                                                          0) {
                                                                        ScaffoldMessenger.of(context)
                                                                            .showSnackBar(
                                                                          SnackBar(
                                                                              backgroundColor: ligtBlackColor,
                                                                              content: Text(
                                                                                'add your address first',
                                                                                style: GoogleFonts.mulish(color: whiteColor),
                                                                              )),
                                                                        );
                                                                        return;
                                                                      }
                                                                      if (payNow ==
                                                                          false  ||fetchingCart) {
                                                                        ScaffoldMessenger.of(context)
                                                                            .showSnackBar(
                                                                          SnackBar(
                                                                              backgroundColor: ligtBlackColor,
                                                                              content: Text(
                                                                                'Upload Prescription',
                                                                                style: GoogleFonts.mulish(color: whiteColor),
                                                                              )),
                                                                        );
                                                                        return;
                                                                      }
                                                                      if(Servisable==false){
                                                                         ScaffoldMessenger.of(context)
                                                                            .showSnackBar(
                                                                          SnackBar(
                                                                              backgroundColor: ligtBlackColor,
                                                                              content: Text(
                                                                                '$placeOrderButton',
                                                                                style: GoogleFonts.mulish(color: whiteColor),
                                                                              )),
                                                                        );
                                                                        return;
                                                                      }
                                                                      Navigator.of(context).push(MaterialPageRoute(
                                                                          builder: (context) => MedicineAvailabilityScreen(
                                                                                prescriptionImage: _imageFile,
                                                                              )));

                                                                      CartManager
                                                                          .cartQuantities
                                                                          .clear(); //removing cart item from backend , not using await so it will be done in background ,so user does not have to wait
                                                                      cartItems
                                                                          .clear();
                                                                      //showPaymentDialog(context);
                                                                      /*if (addresses
                                                                              .length ==
                                                                          0) {
                                                                        return;
                                                                      }
                                                                      if (payNow ==
                                                                          false) {
                                                                        ScaffoldMessenger.of(context)
                                                                            .showSnackBar(
                                                                          SnackBar(
                                                                              content: Text(
                                                                            'Upload Prescription',
                                                                            style:
                                                                                GoogleFonts.mulish(color: whiteColor),
                                                                          )),
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
                                                                            (totalWholeAmount).toStringAsFixed(2),
                                                                            deliveryServiceFees,
                                                                            "${Address.CurrentAddress!["address"]}",
                                                                            response.paymentId.toString(),
                                                                          );
                                                                        },
                                                                        onFailure:
                                                                            (PaymentFailureResponse
                                                                                response) {
                                                                          // Handle payment failure
                                                                          print(
                                                                              'Payment Failed: ${response.message}');
                                                                          ScaffoldMessenger.of(context)
                                                                              .showSnackBar(SnackBar(
                                                                            content:
                                                                                Text('Payment Failed'),
                                                                          ));
                                                                        },
                                                                      );

                                                                      razorpayPayment
                                                                          .initiatePayment(
                                                                        totalWholeAmount, // Amount in paise (e.g., 50000 = 500 INR)
                                                                        'CUREEIT MEDICOS PRIVATE LIMITED', // Product Name
                                                                        'Please do the payment', // Description
                                                                        '8890170172',
                                                                        'accounts@cureeit.com',
                                                                      );*/
                                                                    },
                                                                    child:
                                                                        Container(
                                                                      height:
                                                                          36,
                                                                      width: double
                                                                          .infinity,
                                                                      alignment:
                                                                          Alignment
                                                                              .center,
                                                                      decoration:
                                                                          BoxDecoration(
                                                                        color: payNow
                                                                            ? greenColor
                                                                            : ligtBlackColor,
                                                                        border:
                                                                            Border.all(
                                                                          color:
                                                                              greenColor,
                                                                          width:
                                                                              1,
                                                                        ),
                                                                        // Setting the background color to primary color
                                                                        borderRadius:
                                                                            BorderRadius.circular(8), // Setting the border radius to 10
                                                                      ),
                                                                      child:
                                                                          Center(
                                                                        child:
                                                                            Text(
                                                                          "$placeOrderButton",
                                                                          style:
                                                                              GoogleFonts.mulish(
                                                                            color: payNow
                                                                                ? whiteColor
                                                                                : greenColor,
                                                                            fontSize:
                                                                                12,
                                                                            fontWeight:
                                                                                FontWeight.w700,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
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
