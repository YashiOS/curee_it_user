import 'dart:async';

import 'package:cureeit_user_app/BaseUrl.dart';
import 'package:cureeit_user_app/cartManager/cartManager.dart';
import 'package:cureeit_user_app/screens/cart/presentation/cart_screen.dart';
import 'package:cureeit_user_app/user/user.dart';
import 'package:cureeit_user_app/utils/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';


class ItemDetailScreen extends StatefulWidget {
  final String productId;
  const ItemDetailScreen({super.key, required this.productId});

  @override
  State<ItemDetailScreen> createState() => _ItemDetailScreenState();
}

class _ItemDetailScreenState extends State<ItemDetailScreen> {
  final PageController _controller = PageController();
  int _currentPage = 0;
  late Future<Map<String, dynamic>> productDetails;
  int quantity = 1; // Initialize quantity
  bool isFav = false;
  bool isInCart = false;
  bool addingToCart = false;
  bool addingToFav = false;
  bool readMore = false;
  int? currentQuantity;
  bool isUpdatingQun = false;
  Timer? _debounceTimer;

  @override
  void initState() {
    print('INIT STATE CALLED');
    super.initState();
   
    productDetails = fetchProductDetails(widget.productId);
    _controller.addListener(() {
      if (_controller.page?.toInt() != _currentPage) {
        setState(() {
          _currentPage = _controller.page!.toInt();
        });
      }
    });
  }

  Future<void> _removeFromCart(String ProductId) async {
    final String userId = User.userId!;
    final String productId = ProductId;

    final Map<String, dynamic> requestData = {
      "userId": userId,
      "productId": productId,
    };

    final url = '$baseUrl/cart/removeFromCart';
    try {
      final response = await http.delete(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(requestData),
      );

      if (response.statusCode == 200) {
        setState(() {
          isInCart = false;
          CartManager.cartQuantities.remove(widget.productId);
        });

        Fluttertoast.showToast(msg: "Removed from cart");
      } else {
        print(response.statusCode);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Failed to remove from cart",
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
        print('Failed to remove from cart');
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Error removing from cart ",
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
      print('Error removing from cart: $error');
    }
  }

  Future<void> DidUpdateQuantity(int change, String productId) async {
    _debounceTimer?.cancel();
    final newQuantity = CartManager.cartQuantities[widget.productId]! + change;
    setState(() {
      
      currentQuantity = newQuantity;
        CartManager.cartQuantities[widget.productId] = newQuantity;
    });

    if (newQuantity < 1) {
      setState(() {
        isUpdatingQun=true;
      });
      await _removeFromCart(widget.productId);
      setState(() {
       isUpdatingQun=false;
       
      });
      // Remove from cart if quantity goes to 0

      return;
    }

    final String? userId = User.userId; // Example userId

    // Update local state immediately for UI responsiveness
_debounceTimer=Timer(Duration(seconds: 1), ()async{

});
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/cart/updateQuantity'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          "userId": userId,
          "productId": productId,
          "quantity": newQuantity,
        }),
      );
    
      
      if (response.statusCode != 200) {
        // Handle error - revert local state in case of failure
        setState(() {
         

          currentQuantity = newQuantity;
           CartManager.cartQuantities[widget.productId] = currentQuantity!;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update cart')),
        );
      }
    } catch (e) {
      // Handle network errors - revert local state
      setState(() {
        
          currentQuantity = newQuantity;
           CartManager.cartQuantities[widget.productId] = currentQuantity!;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Network error: $e')),
      );
    }
   
  }

 
 

  Future<void> addToCart() async {
    //setState(() {
    //addingToCart = true;
    //});
    setState(() {
      CartManager.cartQuantities[widget.productId] = 1;
    });

    try {
      var url = Uri.parse('$baseUrl/cart/addToCart');
      var request = http.Request('POST', url)
        ..headers.addAll({
          'Content-Type': 'application/json',
        })
        ..body = jsonEncode({
          "productId": widget.productId,
          "userId": User.userId,
          "quantity": 1
        });

      var response = await http.Client().send(request);

      if (response.statusCode == 200) {
       // Fluttertoast.showToast(msg: "Added To Cart");
        setState(() {
          currentQuantity = 1;
          isInCart = true;
        });

        var responseBody = await response.stream.bytesToString();
        Map<String, dynamic> responseData = jsonDecode(responseBody);
        setState(() {
          addingToCart = false;
        });

        if (responseData['message'] == 'Added To Cart') {}
      } else {
        setState(() {
          addingToCart = false;
          isInCart = false;
          CartManager.cartQuantities[widget.productId] = 0;
        });

        throw Exception('Failed to add to cart');
      }
    } catch (error) {
      setState(() {
        isInCart = false;
        CartManager.cartQuantities.remove(widget.productId);
        addingToCart = false;
      });
      print('Error adding to cart: $error');
    }
    addingToCart = false;
  }

  Future<Map<String, dynamic>> fetchProductDetails(String productId) async {
    try {
      var url = Uri.parse('$baseUrl/product/productDetail');
      var response = await http.post(url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'productId': productId}));

      if (response.statusCode == 200) {
        var responseBody = jsonDecode(response.body);
        Map<String, dynamic> jsonData = responseBody;
        productId = jsonData["data"]["productId"];

        if (jsonData['data'] == null) {
          return {};
        }

        return {
          'name': jsonData['data']['name'] ?? 'Unknown Product',
          'saltComposition': jsonData['data']['saltComposition'] ?? 'N/A',
          'marketer':
              jsonData['data']['marketer'] ?? 'Manufacturer not available',
          'introduction': jsonData['data']['introduction'] ?? 'N/A',
          'benefits': jsonData['data']['benefits'] ?? 'N/A',
          'usageInstruction': jsonData['data']['usageInstruction'] ?? 'N/A',
          'packagingDetail': jsonData['data']['packagingDetail'] ?? 'N/A',
          'productForm': jsonData['data']['productForm'] ?? 'N/A',
          'sellingPrice': jsonData['data']['sellingPrice'] ?? 'N/A',
          'mainUse': jsonData['data']['mainUse'] ?? 'N/A',
          'mrp': jsonData['data']['mrp'],
          'imageUrls': jsonData['data']['imageUrls'] ?? [],
        };
      } else {
        throw Exception(
            'Failed to load product details: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception("Failed to fetch data");
    }
  }

  void decreaseQuantity() {
    if (quantity > 1) {
      setState(() {
        quantity--;
      });
    }
  }

  void increaseQuantity() {
    setState(() {
      quantity++;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:  scaffoldWhiteColor,
      appBar: AppBar(
        scrolledUnderElevation: 0,
        elevation: 0,
        centerTitle: true,
        shape: ContinuousRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(10),
            bottomRight: Radius.circular(10),
          ),
        ),
        title: Text(
          "Medicine Details",
          style: GoogleFonts.mulish(
              color: blackColor, fontSize: 22.69, fontWeight: FontWeight.w400),
        ),
        backgroundColor: lightWhiteColor,
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
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
                        ColorFilter.mode(blackColor, BlendMode.srcIn),
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
      body: FutureBuilder<Map<String, dynamic>>(
          future: productDetails,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                  child: CircularProgressIndicator(
                color: blackColor,
              ));
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (snapshot.hasData) {
              final product = snapshot.data!;

              return SingleChildScrollView(
                child: Container(
                  margin:
                      EdgeInsets.only(top: 24, right: 24, left: 24, bottom: 24),
                  decoration: BoxDecoration(
                      color: lightWhiteColor,
                      borderRadius: BorderRadius.circular(8)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: MediaQuery.of(context).size.width,
                        height: 250,
                        child: PageView.builder(
                          controller: _controller,
                          itemCount: product['imageUrls'].length,
                          itemBuilder: (context, index) {
                            return InteractiveViewer(
                              panEnabled: true,
                              scaleEnabled: true,
                              minScale: 1,
                              maxScale: 4,
                              child: Container(
                                height: 203,
                                margin: EdgeInsets.all(24),
                                decoration: BoxDecoration(
                                  color: blackColor,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                padding: EdgeInsets.only(bottom: 40),
                                child: ClipRRect(
                                    borderRadius: BorderRadius.circular(20),
                                    child: SizedBox(
                                      width: MediaQuery.of(context).size.width,
                                      height: 203,
                                      child: Padding(
                                          padding: EdgeInsets.only(top: 28),
                                          child: product['imageUrls'] != []
                                              ? SizedBox(
                                                  width: 176,
                                                  child: Image.network(
                                                    product['imageUrls'][index],
                                                    fit: BoxFit.contain,
                                                    loadingBuilder: (context,
                                                        child, loadingProgress) {
                                                      if (loadingProgress ==
                                                          null) {
                                                        return child;
                                                      }
                                                      return const Center(
                                                          child:
                                                              CircularProgressIndicator(
                                                        color: blackColor,
                                                      ));
                                                    },
                                                    errorBuilder: (context, error,
                                                        stackTrace) {
                                                      return const Center(
                                                          child: Icon(Icons.error,
                                                              color: blackColor));
                                                    },
                                                  ),
                                                )
                                              : Text(
                                                  "No Image",
                                                  style: TextStyle(
                                                      fontSize:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .height *
                                                              0.027,
                                                      fontWeight: FontWeight.bold,
                                                      color: Colors.grey
                                                          .withValues(alpha: 0.4)),
                                                )),
                                    )),
                              ),
                            );
                          },
                        ),
                      ),
                      Row(
                          spacing: 4,
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: List.generate(product['imageUrls'].length,
                              (index) {
                            return Container(
                              height: 8,
                              width: 8,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  color: _currentPage == index
                                      ? blackColor
                                      : greyColor),
                            );
                          })),
                      Container(
                        margin: EdgeInsets.only(left: 24, top: 24, right: 24),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              width: 280,
                              child: Text(
                                product['name'] ?? 'Unknown Product',
                                style: GoogleFonts.mulish(
                                    fontWeight: FontWeight.w500,
                                    fontSize:
                                        MediaQuery.of(context).size.height *
                                            0.026,
                                    color: blackColor),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(
                          left: 24,
                        ),
                        height: 20,
                        child: Text(
                          product['packagingDetail'] ?? 'N/A',
                          style: GoogleFonts.mulish(
                            fontWeight: FontWeight.w300,
                            fontSize: 16,
                            color: blackColor,
                          ),
                        ),
                      ),
                      Container(
                          margin: EdgeInsets.only(left: 24),
                          height: 15,
                          child: Text(
                            "${product['marketer'] ?? 'Manufacturer not available'}",
                            style: GoogleFonts.mulish(color: blackColor),
                          )),
                      SizedBox(
                        height: 20,
                      ),
                      if (product["saltComposition"] != null &&
                          product["saltComposition"] != "")
                        Container(
                            margin: EdgeInsets.only(left: 24),
                            height: 18,
                            child: Text(
                              "Salt composition",
                              style: GoogleFonts.mulish(color: greyColor),
                            )),
                      if (product["saltComposition"] != null &&
                          product["saltComposition"] != "")
                        SizedBox(
                          height: 5,
                        ),
                      if (product["saltComposition"] != null &&
                          product["saltComposition"] != "")
                        Container(
                            margin: EdgeInsets.only(left: 24),
                            height: 18,
                            child: Text(
                              "${product['saltComposition'] ?? 'N/A'}",
                              style: GoogleFonts.mulish(color: blackColor),
                            )),
                      if (product["saltComposition"] != null &&
                          product["saltComposition"] != "")
                        SizedBox(
                          height: 10,
                        ),
                      if (product["mainUse"] != null &&
                          product["mainUse"] != "")
                        Container(
                            margin: EdgeInsets.only(left: 24),
                            height: 15,
                            child: Text(
                              "Use",
                              style: GoogleFonts.mulish(color: greyColor),
                            )),
                      if (product["mainUse"] != null &&
                          product["mainUse"] != "")
                        SizedBox(
                          height: 5,
                        ),
                      if (product["mainUse"] != null &&
                          product["mainUse"] != "")
                        Container(
                            margin: EdgeInsets.only(left: 24),
                            height: 18,
                            child: Text(
                              "${product['mainUse'] ?? ''}",
                              style: GoogleFonts.mulish(color: blackColor),
                            )),
                      if (product["mainUse"] != null &&
                          product["mainUse"] != "")
                        SizedBox(
                          height: 10,
                        ),
                      if (product["usageInstruction"] != null &&
                          product["usageInstruction"] != "" &&
                          product["usageInstruction"] != "N/A")
                        Container(
                            margin: EdgeInsets.only(left: 24),
                            height: 18,
                            child: Text(
                              "Instruction",
                              style: GoogleFonts.mulish(color: greyColor),
                            )),
                      if (product["usageInstruction"] != null &&
                          product["usageInstruction"] != "" &&
                          product["usageInstruction"] != "N/A")
                        Container(
                          margin: EdgeInsets.only(left: 24, top: 5, right: 24),
                          child: Text(
                            "${product['usageInstruction'] ?? ''}",
                            style: GoogleFonts.mulish(color: blackColor),
                          ),
                        ),
                      Container(
                        margin: EdgeInsets.only(
                            top: 24, left: 24, right: 24, bottom: 24),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "₹${(product["mrp"]) ?? "00"}",
                                    style: GoogleFonts.mulish(
                                      fontWeight: FontWeight.w400,
                                      decoration: TextDecoration.lineThrough,
                                      decorationColor: greyColor,
                                      fontSize:
                                          MediaQuery.of(context).size.height *
                                              0.013,
                                      color: greyColor,
                                    ),
                                  ),
                                  Text(
                                    "₹${(product["sellingPrice"]) ?? "00"}",
                                    style: GoogleFonts.mulish(
                                      fontWeight: FontWeight.w400,
                                      fontSize:
                                          MediaQuery.of(context).size.height *
                                              0.018,
                                      color: blackColor,
                                    ),
                                  ),
                                ],
                              ),
                              isInCart ||
                                      CartManager.cartQuantities[
                                                  widget.productId] !=
                                              null &&
                                          CartManager.cartQuantities[
                                                  widget.productId]! >
                                              0
                                  ? Container(
                                      width: 160,
                                      height: 36,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Container(
                                            decoration: BoxDecoration(
                                              color: greenColor,
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            width: 113,
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                IconButton(
                                                  padding: EdgeInsets.zero,
                                                  constraints: BoxConstraints(),
                                                  icon: Icon(
                                                    Icons.remove,
                                                    size: 20,
                                                    color: blackColor,
                                                  ),
                                                  onPressed: () {
                                                    DidUpdateQuantity(
                                                        -1, widget.productId);
                                                  },
                                                ),
                                                isUpdatingQun
                                                    ? Container(
                                                        width: 10,
                                                        height: 10,
                                                        child:
                                                            CircularProgressIndicator(
                                                          color: blackColor,
                                                          strokeWidth: 2,
                                                        ),
                                                      )
                                                    : Text(
                                                        '${CartManager.cartQuantities[widget.productId] ?? 0}',
                                                        style:
                                                            GoogleFonts.mulish(
                                                          color: blackColor,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 13,
                                                        ),
                                                      ),
                                                IconButton(
                                                  padding: EdgeInsets.zero,
                                                  constraints: BoxConstraints(),
                                                  icon: Icon(
                                                    Icons.add,
                                                    size: 20,
                                                    color: blackColor,
                                                  ),
                                                  onPressed: () {
                                                    DidUpdateQuantity(
                                                        1, widget.productId);
                                                  },
                                                ),
                                              ],
                                            ),
                                          ),
                                          Container(
                                            decoration: BoxDecoration(
                                              color: greenColor,
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            width: 40,
                                            child: TextButton(
                                              onPressed: () async {
                                                // Navigate to cart screen
                                                await Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        CartScreen(
                                                            isNavigated: true),
                                                  ),
                                                );
                                                setState(() {});
                                              },
                                              style: TextButton.styleFrom(
                                                padding: EdgeInsets.zero,
                                              ),
                                              child: Icon(
                                                Icons.shopping_cart_outlined,
                                                color: blackColor,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  : GestureDetector(
                                      onTap: addToCart,
                                      child: Container(
                                        alignment: Alignment.center,
                                        width: 156,
                                        height: 36,
                                        decoration: BoxDecoration(
                                            color: lightWhiteColor,
                                            border: Border.all(
                                              color: greenColor,
                                              width: 1,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(8)),
                                        child: addingToCart
                                            ? Container(
                                                decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            40)),
                                                height: 10, // 40/667 ≈ 0.06
                                                width: 10,
                                                child:
                                                    CircularProgressIndicator(
                                                  color: blackColor,
                                                  strokeWidth: 2,
                                                ))
                                            : Text(
                                                "Add to Cart",
                                                style: GoogleFonts.mulish(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 12,
                                                  color: greenColor,
                                                ),
                                              ),
                                      ),
                                    ),
                            ]),
                      )
                    ],
                  ),
                ),
              );
            } else {
              return Center(child: Text('No data available'));
            }
          }),
    );
  }
}
