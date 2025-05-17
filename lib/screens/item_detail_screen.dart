import 'package:cureeit_user_app/screens/cart_screen.dart';
import 'package:cureeit_user_app/screens/search.dart';
import 'package:cureeit_user_app/user/user.dart';
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
  bool isInCart = false;
  bool addingToCart = false;
  bool addingToFav = false;
  bool readMore = false;
  int? currentQuantity;

  @override
  void initState() {
    print('INIT STATE CALLED');
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

  Future<void> DidUpdateQuantity(int change, String productId) async {
    final newQuantity = currentQuantity! + change;
    setState(() {
      currentQuantity = newQuantity;
    });

    if (newQuantity < 1) {
      // Remove from cart if quantity goes to 0
      setState(() {
        currentQuantity = 1;
      });
      return;
    }

    final String? userId = User.userId; // Example userId

    // Update local state immediately for UI responsiveness

    try {
      final response = await http.put(
        Uri.parse(
            'http://ec2-13-60-8-94.eu-north-1.compute.amazonaws.com:3000/cart/updateQuantity'),
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
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update cart')),
        );
      }
    } catch (e) {
      // Handle network errors - revert local state
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Network error: $e')),
      );
    }
    setState(() {});
  }

  Future<void> checkIfFav() async {
    try {
      const url =
          'http://ec2-13-60-8-94.eu-north-1.compute.amazonaws.com:3000/product/getfavouritesList';

      var request = http.Request('GET', Uri.parse(url))
        ..headers.addAll({
          'Content-Type': 'application/json',
        })
        ..body = jsonEncode({'userId': User.userId});

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
            if (isFav) {
              addingToFav = false;
            }
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
      addingToFav = true;
    });

    final String apiUrl =
        "http://ec2-13-60-8-94.eu-north-1.compute.amazonaws.com:3000/product/favourites";

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "productId": widget.productId,
          "userId": User.userId,
        }),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['status'] == 200) {
          checkIfFav();
          setState(() {
            addingToFav = false;
          });

          Fluttertoast.showToast(msg: "Item added to Favourites");
        } else {
          setState(() {
            addingToFav = false;
          });
        }
      } else {}
    } catch (error) {}
    checkIfFav();
  }

  Future<void> addToCart() async {
    setState(() {
      addingToCart = true;
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
          "userId": User.userId,
          "quantity": 1
        });

      var response = await http.Client().send(request);

      if (response.statusCode == 200) {
        Fluttertoast.showToast(msg: "Added To Cart");
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
        });
        throw Exception('Failed to add to cart');
      }
    } catch (error) {
      setState(() {
        addingToCart = false;
      });
      print('Error adding to cart: $error');
    }
    addingToCart = false;
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
        print(jsonData["data"]);
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
      backgroundColor: scaffoldBlackColor,
      appBar: AppBar(
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
              color: whiteColor, fontSize: 22.69, fontWeight: FontWeight.w400),
        ),
        backgroundColor: ligtBlackColor,
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
                children: [Image.asset("lib/images/Vector 9.png")],
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

              return SingleChildScrollView(
                child: Container(
                  margin:
                      EdgeInsets.only(top: 24, right: 24, left: 24, bottom: 24),
                  decoration: BoxDecoration(
                      color: ligtBlackColor,
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
                            return Container(
                              height: 203,
                              margin: EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: whiteColor,
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
                                                      color: whiteColor,
                                                    ));
                                                  },
                                                  errorBuilder: (context, error,
                                                      stackTrace) {
                                                    return const Center(
                                                        child: Icon(Icons.error,
                                                            color: whiteColor));
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
                                                        .withOpacity(0.4)),
                                              )),
                                  )),
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
                                      ? whiteColor
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
                                    color: whiteColor),
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
                            color: whiteColor,
                          ),
                        ),
                      ),
                      Container(
                          margin: EdgeInsets.only(left: 24),
                          height: 15,
                          child: Text(
                            "${product['marketer'] ?? 'Manufacturer not available'}",
                            style: GoogleFonts.mulish(color: whiteColor),
                          )),
                      SizedBox(
                        height: 20,
                      ),
                      Container(
                          margin: EdgeInsets.only(left: 24),
                          height: 18,
                          child: Text(
                            "Salt composition",
                            style: GoogleFonts.mulish(color: greyColor),
                          )),
                      SizedBox(
                        height: 5,
                      ),
                      Container(
                          margin: EdgeInsets.only(left: 24),
                          height: 18,
                          child: Text(
                            "${product['saltComposition'] ?? 'N/A'}",
                            style: GoogleFonts.mulish(color: whiteColor),
                          )),
                      SizedBox(
                        height: 10,
                      ),
                      Container(
                          margin: EdgeInsets.only(left: 24),
                          height: 15,
                          child: Text(
                            "Use",
                            style: GoogleFonts.mulish(color: greyColor),
                          )),
                      SizedBox(
                        height: 5,
                      ),
                      Container(
                          margin: EdgeInsets.only(left: 24),
                          height: 18,
                          child: Text(
                            "${product['mainUse'] ?? ''}",
                            style: GoogleFonts.mulish(color: whiteColor),
                          )),
                      SizedBox(
                        height: 10,
                      ),
                      Container(
                          margin: EdgeInsets.only(left: 24),
                          height: 18,
                          child: Text(
                            "Description",
                            style: GoogleFonts.mulish(color: greyColor),
                          )),
                      Container(
                        margin: EdgeInsets.only(left: 24, top: 5, right: 24),
                        child: Text(
                          "${product['usageInstruction'] ?? ''}",
                          style: GoogleFonts.mulish(color: whiteColor),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(
                            top: 24, left: 24, right: 24, bottom: 24),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "₹${(product["sellingPrice"]) ?? "00"}",
                                style: GoogleFonts.mulish(
                                  fontWeight: FontWeight.w400,
                                  fontSize: MediaQuery.of(context).size.height *
                                      0.026,
                                  color: whiteColor,
                                ),
                              ),
                              isInCart
                                  ? Container(
                                      width: 156,
                                      height: 36,
                                     
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Container(
                                            decoration: BoxDecoration(
                                        color: greenColor,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                            width: 108,
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
                                                    color: whiteColor,
                                                  ),
                                                  onPressed: () {
                                                    DidUpdateQuantity(
                                                        -1, widget.productId);
                                                  },
                                                ),
                                                Text(
                                                  '$currentQuantity',
                                                  style: GoogleFonts.mulish(
                                                    color: whiteColor,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 13,
                                                  ),
                                                ),
                                                IconButton(
                                                  padding: EdgeInsets.zero,
                                                  constraints: BoxConstraints(),
                                                  icon: Icon(
                                                    Icons.add,
                                                    size: 20,
                                                    color: whiteColor,
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
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                            width: 40,
                                            child: TextButton(
                                              onPressed: () {
                                                // Navigate to cart screen
                                                Navigator.pushReplacement(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        CartScreen(
                                                            isNavigated: true),
                                                  ),
                                                );
                                              },
                                              style: TextButton.styleFrom(
                                                padding: EdgeInsets.zero,
                                              ),
                                              child: Icon(Icons.shopping_cart_outlined,color: whiteColor,),
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
                                            color: ligtBlackColor,
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
                                                  color: whiteColor,
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
