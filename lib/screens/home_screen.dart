import 'dart:convert';

import 'package:cureeit_user_app/screens/cart_screen.dart';
import 'package:cureeit_user_app/screens/item_detail_screen.dart';
import 'package:cureeit_user_app/screens/profile_screen.dart';
import 'package:cureeit_user_app/screens/search.dart';
import 'package:cureeit_user_app/utils/theme.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<dynamic> products = [];
  List<Map<String, dynamic>> cartItems = [];
  double totalAmount = 0.00;
  bool isLoading = true;
  bool isTapped = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  Map<int, int> quantities = {}; // To store product quantities

  @override
  void initState() {
    super.initState();
    fetchCartDetails();
    fetchProducts();
  }

  Future<void> didAddToCart(int index) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final product = products[index];
    final productId = product['productId'];
    try {
      final response = await http.post(
        Uri.parse(
            'http://ec2-13-60-8-94.eu-north-1.compute.amazonaws.com:3000/cart/addToCart'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'userId': "68fa72cbdc5f0a68",
          'productId': productId,
          'quantity': 1,
        }),
      );

      if (response.statusCode == 200) {
        setState(() {
          quantities[index] = 1;
          fetchCartDetails();
          isTapped = true;
        });
        Fluttertoast.showToast(msg: "Added To Cart");
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add item to cart')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Network error: $e')),
      );
    }
  }

  Future<void> DidUpdateQuantity(int index, int change) async {
    final product = products[index];
    final productId = product['productId'];
    final String userId = "68fa72cbdc5f0a68"; // Example userId
    final int currentQuantity = quantities[index] ?? 0;
    final int newQuantity = currentQuantity + change;

    // Update local state immediately for UI responsiveness
    setState(() {
      if (newQuantity < 1) {
        quantities[index] = 0;
      } else {
        quantities[index] = newQuantity;
      }
    });

    try {
      final response = await http.put(
        Uri.parse(
            'http://ec2-13-60-8-94.eu-north-1.compute.amazonaws.com:3000/cart/updateQuantity'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          "userId": userId,
          "productId": productId,
          "quantity": newQuantity < 1 ? 0 : newQuantity
        }),
      );

      if (response.statusCode != 200) {
        // Handle error - revert local state in case of failure
        setState(() {
          quantities[index] = currentQuantity;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update cart')),
        );
      }
    } catch (e) {
      // Handle network errors - revert local state
      setState(() {
        quantities[index] = currentQuantity;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Network error: $e')),
      );
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

          for (var cartItem in cartData) {
            print(
                "🔵 Fetching product details for Product ID: ${cartItem['productId']}");

            Map<String, dynamic>? productDetails =
                await fetchProductDetails(cartItem['productId']);

            if (productDetails != null) {
              if (productDetails['sellingPrice'] is int) {
                totalAmount = totalAmount +
                    (cartItem['quantity'] *
                        productDetails['sellingPrice'].toDouble());
              } else {
                totalAmount = totalAmount +
                    (cartItem['quantity'] * productDetails['sellingPrice']);
              }
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
            if (cartItems.isNotEmpty) {
              isLoading = false;
            }
          });

          print("🟢 Updated cartItems: $cartItems");
        } else {
          print("❌ Response did not contain valid cart data");
        }
      } else {
        final responseBody = await response.stream.bytesToString();
        print("❌ Failed to fetch cart details. Response: $responseBody");
        if (responseBody.contains("No products available")) {
          setState(() {
            if (cartItems.isNotEmpty) {
              isLoading = false;
            } // Stop loading and show "No Items in Cart"
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

  Future<void> fetchProducts() async {
    final response = await http.get(Uri.parse(
        'http://ec2-13-60-8-94.eu-north-1.compute.amazonaws.com:3000/home/homeProducts'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        products = data['data'];
        for (int i = 0; i < products.length; i++) {
          quantities[i] = 0;
        }
      });
    } else {
      throw Exception('Failed to load products');
    }
  }

  void addToCart(int index) {
    setState(() {
      quantities[index] = 1;
    });
  }

  void updateQuantity(int index, int change) {
    setState(() {
      quantities[index] = (quantities[index] ?? 0) + change;
      if (quantities[index]! < 1) quantities[index] = 0;
    });
  }

  Widget buildProductGrid() {
    if (products.isEmpty) {
      return Center(
          child: CircularProgressIndicator(
        color: secondaryColor,
      ));
    }

    List<Widget> productWidgets = [];

    int itemsToShow = products.length > 6 ? 6 : products.length;

    for (int i = 0; i < itemsToShow; i++) {
      productWidgets.add(buildProductItem(i));
    }

    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      childAspectRatio: 0.64,
      crossAxisSpacing: 20,
      mainAxisSpacing: 20,
      children: productWidgets,
    );
  }

  Widget buildProductItem(int index) {
    final product = products[index];
    final bool isInCart = quantities[index] != null && quantities[index]! > 0;

    return Column(
      children: [
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ItemDetailScreen(
                  productId: product['productId'],
                ),
              ),
            );
          },
          child: Container(
            width: 110,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Stack(
              children: [
                Transform.translate(
                  offset: Offset(0, -10),
                  child: Center(
                    child: product['imageMediaUrls'][0] != null &&
                            product['imageMediaUrls'][0].toString().isNotEmpty
                        ? Image.network(
                            product['imageMediaUrls'][0],
                            fit: BoxFit.contain,
                            width: 70,
                            height: 70,
                            errorBuilder: (context, error, stackTrace) => Icon(
                                Icons.image_not_supported,
                                size: 70,
                                color: Colors.grey[200]),
                          )
                        : Icon(
                            Icons.image_not_supported,
                            size: 70,
                            color: Colors.grey[200],
                          ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  left: 0,
                  child: Container(
                    height: 30,
                    decoration: BoxDecoration(
                      color: isInCart
                          ? Colors.white.withOpacity(0.8)
                          : primaryColor,
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(8),
                        bottomRight: Radius.circular(8),
                      ),
                    ),
                    child: isInCart
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              InkWell(
                                onTap: () => DidUpdateQuantity(index, -1),
                                child: Icon(Icons.remove,
                                    size: 20, color: primaryColor),
                              ),
                              Text(
                                '${quantities[index]}',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                              InkWell(
                                onTap: () => DidUpdateQuantity(index, 1),
                                child: Icon(Icons.add,
                                    size: 20, color: primaryColor),
                              ),
                            ],
                          )
                        : InkWell(
                            onTap: () {
                              didAddToCart(index);
                              setState(() {
                                isLoading = true;
                              });
                              fetchCartDetails();
                            },
                            child: Center(
                              child: Text(
                                "Add To Cart",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Container(
          width: 110,
          padding: EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          child: Text(
            product['name'] ?? 'Product',
            textAlign: TextAlign.left,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 2,
            // overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: Colors.grey.shade100.withOpacity(0.5),
        toolbarHeight: 90,
        leadingWidth: 90,
        leading: Container(
          height: 60,
          width: 60,
          padding: const EdgeInsets.all(0.0),
          child: Transform.translate(
            offset: Offset(0, -12),
            child: GestureDetector(
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => ProfileScreen()));
                },
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Container(
                    decoration: BoxDecoration(
                        border: Border.all(
                            color: Colors.blueGrey.withOpacity(0.2),
                            width: 1.6),
                        borderRadius: BorderRadius.circular(10)),
                    child: Icon(
                      Icons.person,
                      color: primaryColor,
                    ),
                  ),
                )),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Container(
              alignment: Alignment.topCenter,
              height: 26,
              width: 26,
              padding: const EdgeInsets.all(0.0),
              child: GestureDetector(
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => Search()));
                },
                child: Transform.translate(
                  offset: Offset(0, -10),
                  child: Image.asset(
                    'lib/images/search_button.png',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
          ),
        ],
        title: Transform.translate(
          offset: Offset(0, -10),
          child: Column(
            children: [
              Text(
                "Curee it",
                style: TextStyle(
                  color: primaryColor,
                  fontSize: 20,
                  fontFamily: "Urbanist",
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                "Get in 15 mins",
                style: TextStyle(
                  color: const Color.fromARGB(255, 85, 83, 83),
                  fontSize: 18,
                  fontFamily: "JosefinSans",
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
      body: Container(
        color: Colors.grey.shade100.withOpacity(0.5),
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Stack(
          children: [
            ListView(
              shrinkWrap: true,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 18.0, vertical: 10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Featured Products",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                        ),
                      ),
                      SizedBox(height: 10),
                      buildProductGrid(),
                      //SizedBox(height: 60),
                    ],
                  ),
                )
              ],
            ),
            if ((!isLoading && cartItems.isNotEmpty) || (isTapped)) ...[
              Positioned(
                  bottom: 72,
                  child: Container(
                    color: Colors.white,
                    width: MediaQuery.of(context).size.width,
                    height: 96,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 18.0, vertical: 10),
                      child: Column(
                        spacing: 8,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Delivering in 20 minutes !',
                            style: TextStyle(
                                color: primaryColor,
                                fontFamily: "Urbanist",
                                fontSize: 12,
                                fontWeight: FontWeight.w600),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                spacing: 12,
                                children: [
                                  isLoading
                                      ? Text("")
                                      : Container(
                                          height: 48,
                                          width: 48,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            border: Border.all(
                                                width: 2,
                                                color: Colors.grey
                                                    .withOpacity(0.3)),
                                          ),
                                          child: cartItems[0]['imageUrls']
                                                  .isNotEmpty
                                              ? Image.network(
                                                  cartItems[0]['imageUrls'][0],
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
                                                      color: secondaryColor,
                                                    ));
                                                  },
                                                  errorBuilder: (context, error,
                                                      stackTrace) {
                                                    return const Center(
                                                        child: Icon(
                                                      Icons.error,
                                                      color: Color.fromRGBO(
                                                          7, 9, 84, 1),
                                                    ));
                                                  },
                                                )
                                              : Icon(Icons.image)),
                                  Row(
                                    children: [
                                      Text(
                                        '${cartItems.length} Item(s)  ',
                                        style: TextStyle(
                                            fontFamily: "Urbanist",
                                            fontSize: 14,
                                            fontWeight: FontWeight.normal),
                                      ),
                                      Text(
                                        "|  ₹ ${(totalAmount * 0.7).toStringAsFixed(2) ?? ''}",
                                        style: TextStyle(
                                            fontFamily: "Urbanist",
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  )
                                ],
                              ),
                              GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => CartScreen(
                                                  isNavigated: true,
                                                )));
                                  },
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                        vertical: 14, horizontal: 22),
                                    decoration: BoxDecoration(
                                        color: secondaryColor,
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    child: Text(
                                      'Checkout',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontFamily: "Urbanist",
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ))
                            ],
                          ),
                        ],
                      ),
                    ),
                  ))
            ]
          ],
        ),
      ),
    );
  }
}
