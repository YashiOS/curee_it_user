import 'dart:convert';

import 'package:cureeit_user_app/screens/cart_screen.dart';
import 'package:cureeit_user_app/screens/item_detail_screen.dart';
import 'package:cureeit_user_app/screens/profile_screen.dart';
import 'package:cureeit_user_app/screens/search.dart';
import 'package:cureeit_user_app/utils/theme.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;

class HomeScreen extends StatefulWidget {
  
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<dynamic> products = [];
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  Map<int, int> quantities = {}; // To store product quantities

  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

Future<void> didAddToCart(int index) async {
  final product = products[index];
  final productId = product['productId']; 
  try {
    final response = await http.post(
      Uri.parse('http://ec2-13-60-8-94.eu-north-1.compute.amazonaws.com:3000/cart/addToCart'),
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
      Uri.parse('http://ec2-13-60-8-94.eu-north-1.compute.amazonaws.com:3000/cart/updateQuantity'),
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
      return Center(child: CircularProgressIndicator());
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
      childAspectRatio: 0.7,
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
          height: 110,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Stack(
            children: [
              Center(
                child: product['imageMediaUrls'][0] != null &&
                        product['imageMediaUrls'][0].toString().isNotEmpty
                    ? Image.network(
                        product['imageMediaUrls'][0],
                        fit: BoxFit.contain,
                        width: 70,
                        height: 70,
                        errorBuilder: (context, error, stackTrace) =>
                            Icon(Icons.image_not_supported, size: 70),
                      )
                    : Icon(Icons.image_not_supported, size: 70),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                left: 0,
                child: Container(
                  height: 30, 
                  decoration: BoxDecoration(
                    color: isInCart ? Colors.white.withOpacity(0.8) : primaryColor,
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
                              child: Icon(Icons.remove, size: 20, color: primaryColor),
                            ),
                            Text(
                              '${quantities[index]}',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                            InkWell(
                              onTap: () => DidUpdateQuantity(index, 1),
                              child: Icon(Icons.add, size: 20, color: primaryColor),
                            ),
                          ],
                        )
                      : InkWell(
                          onTap: () => didAddToCart(index),
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
          overflow: TextOverflow.ellipsis,
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
                  padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 10.0),
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
                      SizedBox(height: 60),
                    ],
                  ),
                )
              ],
            ),
            
          ],
        ),
      ),
    );
  }
}