import 'package:cureeit_user_app/screens/search.dart';
import 'package:cureeit_user_app/utils/theme.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:loading_indicator/loading_indicator.dart';

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
  bool addingToCart=false;
  bool addingToFav=false;
  bool readMore = false;

  @override
  void initState() {
    super.initState();
    checkIfFav();
    productDetails = fetchProductDetails(widget.productId);
    _controller.addListener(() {
      if (_controller.page?.toInt() != _currentPage) {
        setState(() {
          _currentPage = _controller.page!.toInt();
        });
      }
    });
  }

  Future<void> checkIfFav() async {
    try {
      const url =
          'http://ec2-13-60-8-94.eu-north-1.compute.amazonaws.com:3000/product/getfavouritesList';

      var request = http.Request('GET', Uri.parse(url))
        ..headers.addAll({
          'Content-Type': 'application/json',
        })
        ..body = jsonEncode({'userId': "68fa72cbdc5f0a68"});

      var response = await http.Client().send(request);

      if (response.statusCode == 200) {
        var responseBody = await response.stream.bytesToString();
        Map<String, dynamic> responseData = jsonDecode(responseBody);
        if (responseData['status'] == 200) {
          List<dynamic> favouritesList =
              responseData['data']['favouritesItem'] ?? [];

          setState(() {
            // Check if the productId is in the favourites list
            isFav = favouritesList.contains(widget.productId);
            print(isFav);
          });
        } else {
          print(
              "Failed to fetch favourites: ${response.stream.bytesToString()}");
        }
      } else {
        print("Failed to fetch favourites: ${response.stream.bytesToString()}");
      }
    } catch (error) {
      print("Error fetching favourites: $error");
    }
  }

  Future<void> addToFavourites() async {
    setState(() {
      addingToFav=true;
    });
    
    final String apiUrl =
        "http://ec2-13-60-8-94.eu-north-1.compute.amazonaws.com:3000/product/favourites";

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "productId": widget.productId,
          "userId": "68fa72cbdc5f0a68",
        }),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['status'] == 200) {
          checkIfFav();
          setState(() {
            addingToFav=false;
          });
          
          Fluttertoast.showToast(msg: "Item added to Favourites");
        } else {
          setState(() {
             addingToFav=false;
          });
         
        }
      } else {}
    } catch (error) {}
    checkIfFav();
  }

  Future<void> addToCart() async {
    setState(() {
      addingToCart=true;
    });
    
    try {
      var url = Uri.parse(
          'http://ec2-13-60-8-94.eu-north-1.compute.amazonaws.com:3000/cart/addToCart');
      var request = http.Request('POST', url)
        ..headers.addAll({
          'Content-Type': 'application/json',
        })
        ..body = jsonEncode({
          "productId": widget.productId,
          "userId": "68fa72cbdc5f0a68",
          "quantity": 1
        });

      var response = await http.Client().send(request);

      if (response.statusCode == 200) {
        var responseBody = await response.stream.bytesToString();
        Map<String, dynamic> responseData = jsonDecode(responseBody);
        setState(() {
          addingToCart=false;
        });
        
        if (responseData['message'] == 'Added To Cart') {
          Fluttertoast.showToast(
            msg: "Added to Cart",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: primaryColor,
            textColor: Colors.white,
            fontSize: 14.0,
          );
        }
      } else {
        
        setState(() {
          addingToCart=false;
        });
        throw Exception('Failed to add to cart');
      }
    } catch (error) {
      
      setState(() {
        addingToCart=false;
      });
      print('Error adding to cart: $error');
    }
  }

  Future<Map<String, dynamic>> fetchProductDetails(String productId) async {
    try {
      var url = Uri.parse(
          'http://ec2-13-60-8-94.eu-north-1.compute.amazonaws.com:3000/product/productDetail');
      var request = http.Request('GET', url)
        ..headers.addAll({
          'Content-Type': 'application/json',
        })
        ..body = jsonEncode({'productId': productId});

      var response = await http.Client().send(request);

      if (response.statusCode == 200) {
        var responseBody = await response.stream.bytesToString();
        Map<String, dynamic> jsonData = jsonDecode(responseBody);

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
      appBar: AppBar(
        backgroundColor: ligtBlackColor,
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
                  Icon(Icons.arrow_back, color:whiteColor),
                  Text(
                    "Back",
                    style: GoogleFonts.mulish(
                        fontWeight: FontWeight.w600,
                        fontSize: MediaQuery.of(context).size.height * 0.018,
                       
                        color: whiteColor),
                  )
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
                color: whiteColor,
              ));
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (snapshot.hasData) {
              final product = snapshot.data!;

              return Container(
                color: scaffoldBlackColor,
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                child: ListView(
                  children: [
                    Column(
                      spacing: 18,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Stack(
                          children: [
                           
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 22.0, vertical: 18),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    product['name'] ?? 'Unknown Product',
                                    style: GoogleFonts.mulish(
                                        fontWeight: FontWeight.w500,
                                        fontSize: MediaQuery.of(context).size.height * 0.026,
                                        
                                        color: whiteColor),
                                  ),
                                  Text(
                                    product['marketer'] ??
                                        'Manufacturer not available',
                                    style: GoogleFonts.mulish(
                                        fontWeight: FontWeight.w400,
                                        fontSize: MediaQuery.of(context).size.height * 0.015,
                                        
                                        color: whiteColor),
                                  ),
                                  SizedBox(
                                    width: MediaQuery.of(context).size.width,
                                    height: 176,
                                    child: PageView.builder(
                                      controller: _controller,
                                      itemCount: product['imageUrls'].length,
                                      itemBuilder: (context, index) {
                                        return Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color:ligtBlackColor,
                                              borderRadius:  BorderRadius.circular(10),
                                            ),
                                           padding: EdgeInsets.only(bottom: 40),
                                            
                                            child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                                child: SizedBox(
                                                  width: MediaQuery.of(context)
                                                      .size
                                                      .width,
                                                  height: MediaQuery.of(context).size.height * 0.350,
                                                  child: Padding(
                                                      padding: EdgeInsets.only(
                                                          top: 28),
                                                      child: product[
                                                                  'imageUrls'] !=
                                                              []
                                                          ? SizedBox(
                                                              height: MediaQuery.of(context).size.height * 0.350,
                                                              width: 176,
                                                              child:
                                                                  Image.network(
                                                                product['imageUrls']
                                                                    [index],
                                                                fit: BoxFit
                                                                    .contain,
                                                                loadingBuilder:
                                                                    (context,
                                                                        child,
                                                                        loadingProgress) {
                                                                  if (loadingProgress ==
                                                                      null) {
                                                                    return child;
                                                                  }
                                                                  return const Center(
                                                                      child:
                                                                          CircularProgressIndicator(
                                                                    color:
                                                                        whiteColor,
                                                                  ));
                                                                },
                                                                errorBuilder:
                                                                    (context,
                                                                        error,
                                                                        stackTrace) {
                                                                  return const Center(
                                                                      child: Icon(
                                                                    Icons.error,
                                                                    color:whiteColor
                                                                  ));
                                                                },
                                                              ),
                                                            )
                                                          : Text(
                                                              "No Image",
                                                              style: TextStyle(
                                                                  fontSize: MediaQuery.of(context).size.height * 0.027,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  color: Colors
                                                                      .grey
                                                                      .withOpacity(
                                                                          0.4)),
                                                            )),
                                                )),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                        Transform.translate(
                          offset: Offset(0, 0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(bottom: 12.0),
                                child: SizedBox(
                                    width: MediaQuery.of(context).size.width,
                                    height: 8,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(
                                          width: 10,
                                          height: 4,
                                        ),
                                        Row(
                                            spacing: 4,
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: List.generate(
                                                product['imageUrls'].length,
                                                (index) {
                                              return Container(
                                                height: 8,
                                                width: 8,
                                                decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                    color: _currentPage == index
                                                        ? greenColor
                                                        :whiteColor),
                                              );
                                            })),
                                      ],
                                    )),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 12.0, horizontal: 22),
                                child: Container(
                                  decoration: BoxDecoration(
                                      color: ligtBlackColor,
                                      borderRadius: BorderRadius.circular(10)),
                                  child: Stack(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 18.0, vertical: 8),
                                        child: Column(
                                          spacing: 12,
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              spacing: 8,
                                              children: [
                                                Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(vertical: 6.0),
                                                  child: Container(
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width /
                                                            1.28,
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                      horizontal: MediaQuery.of(
                                                                  context)
                                                              .size
                                                              .width *
                                                          0.035, // ~14 on 400px width
                                                      vertical: MediaQuery.of(
                                                                  context)
                                                              .size
                                                              .height *
                                                          0.0075, // ~6 on 800px height
                                                    ),
                                                    decoration: BoxDecoration(
                                                        color: ligtBlackColor,
                                                        border: Border.all(
                                                            color: greenColor,
                                                            width: 0.6),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(30)),
                                                    child: Text(
                                                      product['saltComposition'] ??
                                                          'N/A',
                                                      style: GoogleFonts.mulish(
                                                        fontWeight:
                                                            FontWeight.w400,
                                                        fontSize: MediaQuery.of(context).size.height * 0.018,
                                                        
                                                        color:whiteColor,
                                                      ),
                                                    ),
                                                  ),
                                                )
                                              ],
                                            ),
                                            Text(
                                              product['packagingDetail'] ??
                                                  'N/A',
                                              style: GoogleFonts.mulish(
                                                fontWeight: FontWeight.w500,
                                               fontSize: MediaQuery.of(context).size.height * 0.020,
                                                
                                                color: whiteColor,
                                              ),
                                            ),
                                            Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              spacing: 0,
                                              children: [
                                                Text(
                                                  "USE : ",
                                                  style: GoogleFonts.mulish(
                                                    fontWeight: FontWeight.w700,
                                                    fontSize: MediaQuery.of(context).size.height * 0.012,
                                                   
                                                    color: greenColor,
                                                  ),
                                                ),
                                                Text(
                                                  product['mainUse'] ?? 'N/A',
                                                  maxLines: readMore ? 50 : 2,
                                                  style: GoogleFonts.mulish(
                                                    fontWeight: FontWeight.w400,
                                                    fontSize: MediaQuery.of(context).size.height * 0.015,
                                                   
                                                    color: whiteColor,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            if (readMore) ...[
                                              Text(
                                                product['introduction'] ?? '',
                                                maxLines: readMore ? 50 : 2,
                                                style: GoogleFonts.mulish(
                                                  fontWeight: FontWeight.w300,
                                                  fontSize: MediaQuery.of(context).size.height * 0.015,
                                                 
                                                  color:whiteColor,
                                                ),
                                              ),
                                            ],
                                            Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              spacing: 0,
                                              children: [
                                                Text(
                                                  "INSTRUCTIONS : ",
                                                  style: GoogleFonts.mulish(
                                                    fontWeight: FontWeight.w700,
                                                    fontSize: MediaQuery.of(context).size.height * 0.012,
                                                    
                                                    color: greenColor,
                                                  ),
                                                ),
                                                Text(
                                                  product['usageInstruction'] ??
                                                      '',
                                                  maxLines: readMore ? 50 : 2,
                                                  style: GoogleFonts.mulish(
                                                    fontWeight: FontWeight.w300,
                                                    fontSize: MediaQuery.of(context).size.height * 0.013,
                                                  
                                                    color: whiteColor,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Center(
                                              child: GestureDetector(
                                                onTap: () {
                                                  setState(() {
                                                    if (readMore == false) {
                                                      readMore = true;
                                                    } else {
                                                      readMore = false;
                                                    }
                                                  });
                                                },
                                                child: Container(
                                                  padding: EdgeInsets.symmetric(
                                                      horizontal: 14,
                                                      vertical: 8),
                                                  decoration: BoxDecoration(
                                                      color: secondaryColor
                                                          .withOpacity(0.16),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              30)),
                                                  child: Text(
                                                    readMore
                                                        ? "Read Less"
                                                        : "Read More",
                                                    style: GoogleFonts.mulish(
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      fontSize: MediaQuery.of(context).size.height * 0.015,
                                                      color: greenColor,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Transform.translate(
                                        offset: Offset(-10, 8),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Image.asset(
                                              "lib/images/cart_design_bar.png",
                                              height: 54,
                                              fit: BoxFit.cover,
                                            )
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 22, vertical: 12),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  spacing: 14,
                                  children: [
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 14, vertical: 6),
                                      decoration: BoxDecoration(
                                          color:
                                              secondaryColor.withOpacity(0.16),
                                          borderRadius:
                                              BorderRadius.circular(30)),
                                      child: Text(
                                        "Check Similar Product",
                                        style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                          fontSize: MediaQuery.of(context).size.height * 0.013,
                                          fontFamily: "Urbanist",
                                          color: greenColor,
                                        ),
                                      ),
                                    ),
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      spacing: 4,
                                      children: [
                                        Row(
                                          spacing: 8,
                                          children: [
                                            Text(
                                              "₹${(product['sellingPrice']*0.7).toInt() ?? 00}",
                                              style: TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: MediaQuery.of(context).size.height * 0.017,
                                                fontFamily: "Urbanist",
                                                color: whiteColor,
                                              ),
                                            ),
                                            Row(
                                              spacing: 4,
                                              children: [
                                                Text(
                                                  "MRP",
                                                  style: GoogleFonts.mulish(
                                                    fontWeight: FontWeight.w400,
                                                    fontSize: MediaQuery.of(context).size.height * 0.017,
                                                    
                                                    color: whiteColor,
                                                  ),
                                                ),
                                                Text(
                                                  "₹${product['sellingPrice'] ?? '00'}",
                                                  style: GoogleFonts.mulish(
                                                    decoration: TextDecoration
                                                        .lineThrough,
                                                    fontWeight: FontWeight.w400,
                                                    fontSize: MediaQuery.of(context).size.height * 0.017,
                                                  
                                                    color: whiteColor,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Text(
                                              "30% off",
                                              style: GoogleFonts.mulish(
                                                fontWeight: FontWeight.w600,
                                                fontSize: MediaQuery.of(context).size.height * 0.014,
                                                
                                                color: whiteColor,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Text(
                                          "+ 1% Cashback",
                                          style: GoogleFonts.mulish(
                                            fontWeight: FontWeight.w500,
                                            fontSize: MediaQuery.of(context).size.height * 0.014,
                                            
                                            color:whiteColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      spacing: 8,
                                      children: [
                                        GestureDetector(
                                          onTap: addToCart,
                                          child: Container(
                                            alignment: Alignment.center,
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width /
                                                1.5,
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 14, vertical: 8),
                                            decoration: BoxDecoration(
                                                color: secondaryColor
                                                    .withOpacity(0.16),
                                                borderRadius:
                                                    BorderRadius.circular(10)),
                                            child:addingToCart?Text(
                                              "Adding...",
                                              style: TextStyle(
                                                fontWeight: FontWeight.w500,
                                                fontSize: MediaQuery.of(context).size.height * 0.015,
                                                fontFamily: "Urbanist",
                                                color: greenColor,
                                              ),
                                            ): Text(
                                              "Add to Cart",
                                              style: TextStyle(
                                                fontWeight: FontWeight.w500,
                                                fontSize: MediaQuery.of(context).size.height * 0.015,
                                                fontFamily: "Urbanist",
                                                color: greenColor,
                                              ),
                                            ),
                                          ),
                                        ),
                                        Transform.translate(
                                          offset: Offset(-20, 0),
                                          child: GestureDetector(
                                            onTap: () {
                                              addToFavourites();
                                            },
                                            child:addingToFav?Container(
                                              decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          40)),
                                              height: MediaQuery.of(context).size.height * 0.06, // 40/667 ≈ 0.06
  width: MediaQuery.of(context).size.height * 0.06,
  child:LoadingIndicator(indicatorType: Indicator.orbit,colors: [whiteColor],),
                                            ) : Container(
                                              decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          40)),
                                              height: MediaQuery.of(context).size.height * 0.06, // 40/667 ≈ 0.06
  width: MediaQuery.of(context).size.height * 0.06,
                                              child: Icon(
                                                isFav
                                                    ? Icons.favorite
                                                    : Icons.favorite_border,
                                                color: isFav
                                                    ? greenColor
                                                    : whiteColor
                                                        .withOpacity(0.6),
                                                size: 24,
                                              ),
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(
    horizontal: MediaQuery.of(context).size.width * 0.058,  // 22/375 ≈ 0.058
    vertical: MediaQuery.of(context).size.height * 0.018,   // 12/667 ≈ 0.018
  ),
                                child: Container(
                                  width: MediaQuery.of(context).size.width,
                                  decoration: BoxDecoration(
                                      color:ligtBlackColor,
                                      borderRadius: BorderRadius.circular(10)),
                                  child: Stack(
                                    children: [
                                      Padding(
                                        padding:  EdgeInsets.symmetric(
                                            horizontal: MediaQuery.of(context).size.width * 0.048, vertical: MediaQuery.of(context).size.height * 0.012),
                                        child: Column(
                                          spacing: 12,
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "Return & Expiry",
                                              style: GoogleFonts.mulish(
                                                fontWeight: FontWeight.w500,
                                                fontSize:  MediaQuery.of(context).size.height * 0.015,
                                                
                                                color: greenColor,
                                              ),
                                            ),
                                            Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              spacing: 3,
                                              children: [
                                                Text(
                                                  "7 day free return",
                                                  style: GoogleFonts.mulish(
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: MediaQuery.of(context).size.height * 0.014,
                                                    
                                                    color: whiteColor,
                                                  ),
                                                ),
                                                Text(
                                                  "Easily return the medicine if you have not used it.",
                                                  style: GoogleFonts.mulish(
                                                    fontWeight: FontWeight.w300,
                                                    fontSize: MediaQuery.of(context).size.height * 0.014,
                                                    
                                                    color: whiteColor,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              spacing: 3,
                                              children: [
                                                Text(
                                                  "Expires after Jun 2025",
                                                  style: GoogleFonts.mulish(
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: MediaQuery.of(context).size.height * 0.014,
                                                    
                                                    color: whiteColor,
                                                  ),
                                                ),
                                                Text(
                                                  "The product will have this expiry date on the packet",
                                                  style: GoogleFonts.mulish(
                                                    fontWeight: FontWeight.w300,
                                                    fontSize:MediaQuery.of(context).size.height * 0.014,
                                                    
                                                    color:whiteColor,
                                                  ),
                                                ),
                                              ],
                                            )
                                          ],
                                        ),
                                      ),
                                      Transform.translate(
                                        offset: Offset(-10, 8),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Image.asset(
                                              "lib/images/cart_design_bar.png",
                                              height: 54,
                                              fit: BoxFit.cover,
                                            )
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      ],
                    )
                  ],
                ),
              );
            } else {
              return Center(child: Text('No data available'));
            }
          }),
    );
  }
}
