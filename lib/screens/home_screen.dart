import 'dart:convert';

import 'package:cureeit_user_app/current_address/google_maps_screen.dart';
import 'package:cureeit_user_app/screens/cart_screen.dart';
import 'package:cureeit_user_app/screens/item_detail_screen.dart';
import 'package:cureeit_user_app/screens/profile_screen.dart';
import 'package:cureeit_user_app/screens/search.dart';
import 'package:cureeit_user_app/utils/theme.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import './add_address_screen.dart';
import './addresses_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<dynamic> addresses = [];
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
    fetchAddresses();
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
      childAspectRatio: 0.54,
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      children: productWidgets,
    );
  }

  Widget buildProductItem(int index) {
    final product = products[index];
    final bool isInCart = quantities[index] != null && quantities[index]! > 0;

    return Container(
      width: 120,
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
            child: AspectRatio(
              aspectRatio: 1,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: product['imageMediaUrls'][0] != null &&
                        product['imageMediaUrls'][0].toString().isNotEmpty
                    ? Image.network(
                        product['imageMediaUrls'][0],
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) => Icon(
                          Icons.image_not_supported,
                          size: 40,
                          color: Colors.grey.shade400,
                        ),
                      )
                    : Icon(
                        Icons.image_not_supported,
                        size: 40,
                        color: Colors.grey.shade400,
                      ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          SizedBox(
            height: 34,
            child: Text(
              product['name'] ?? 'Product',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Container(
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
                        child:
                            Icon(Icons.remove, size: 20, color: primaryColor),
                      ),
                      Text(
                        '${quantities[index]}',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      InkWell(
                        onTap: () => DidUpdateQuantity(index, 1),
                        child: Icon(Icons.add, size: 20, color: primaryColor),
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
          const SizedBox(height: 4),
          Text(
            "₹ ${product['price']}",
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.green.shade700,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> fetchAddresses() async {
    var url = Uri.parse(
      'http://ec2-13-60-8-94.eu-north-1.compute.amazonaws.com:3000/address/savedAddress',
    );

    // Create the GET request with the userId as query parameter
    var request = http.Request('GET', url)
      ..headers.addAll({
        'Content-Type': 'application/json',
      })
      ..body = jsonEncode({'userId': "68fa72cbdc5f0a68"});

    var response = await http.Client().send(request);

    if (response.statusCode == 200) {
      final data = json.decode(await response.stream.bytesToString());
      setState(() {
        addresses = data['data']['address'];
      });
    } else {
      print('Failed to load addresses');
    }
  }

  void _locationBottomSheet() {
    showModalBottomSheet(
      backgroundColor: const Color.fromARGB(255, 228, 233, 233),
      context: context,
      isScrollControlled:
          true, // Allows the sheet to expand to full height if needed
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Draggable handle and close button
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(width: 30),
                  Expanded(
                    child: Align(
                      alignment: Alignment.center,
                      child: Container(
                        width: 60,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade400,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Title
              const Center(
                child: Text(
                  "Select delivery location",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 10),

              // Search field
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search for area or apartment',
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    contentPadding:
                        const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Current Location Container
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => GoogleMapsScreen()));
                  },
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.green.shade100,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.my_location,
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        "Use my current location",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Add New Address Container
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: GestureDetector(
                  onTap: () {},
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.blue.shade100,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.add,
                          color: Colors.blue,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        "Add new address",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Saved Addresses Header
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.0),
                child: Text(
                  "Your saved addresses",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // Saved Addresses List Container
              Container(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height *0.3, // Adjust as needed
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: addresses.isEmpty
                    ? const Center(child: Text("No saved addresses"))
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: const ClampingScrollPhysics(),
                        itemCount: addresses.length,
                        itemBuilder: (context, index) {
                          var address = addresses[index];
                          return ListTile(
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            leading: Container(
                              padding: EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color.fromARGB(255, 204, 235, 231)
                                    , // Soft blue background
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color:const Color.fromARGB(255, 171, 234, 225), // Light blue border
                                  width: 1.5,
                                ),
                              ),
                              child: Icon(
                                Icons.home_rounded, // More modern home icon
                                color: primaryColor, // Matching blue icon
                                size: 22,
                              ),
                            ),
                            title: Text(
                              address['address'] ?? '',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey
                                    .shade800, // Darker text for better readability
                              ),
                            ),
                            subtitle: Text(
                              address['landmark'] ?? '',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey
                                    .shade600, // Slightly lighter than title
                              ),
                            ),
                            
                          );
                        },
                      ),
              ),
              const SizedBox(height: 16), // Extra space at bottom
            ],
          ),
        );
      },
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
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () {
              _locationBottomSheet();
              // Handle tap to show city selection
              print('Location selector tapped');
            },
            child: Container(
              padding: EdgeInsets.only(left: 10),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.location_on,
                    color: primaryColor,
                    size: 20,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'New York', // Replace with your city variable
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Color.fromARGB(255, 85, 83, 83),
                    ),
                  ),
                  SizedBox(width: 4),
                  Icon(
                    Icons.arrow_drop_down,
                    color: Colors.grey,
                  ),
                ],
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(
                  context, MaterialPageRoute(builder: (context) => Search()));
            },
            child: Container(
              margin: EdgeInsets.all(10),
              height: 58,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                    width: 1, color: Color.fromARGB(255, 202, 188, 188)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: TextField(
                        style: TextStyle(fontFamily: "Urbanist"),
                        decoration: InputDecoration(
                          enabled: false,
                          hintText: "Search",
                          hintStyle: TextStyle(fontFamily: "Urbanist"),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: GestureDetector(
                      onTap: () {},
                      child: Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: secondaryColor,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Icon(Icons.search, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Container(
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
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
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
                                                        cartItems[0]
                                                            ['imageUrls'][0],
                                                        fit: BoxFit.contain,
                                                        loadingBuilder: (context,
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
                                                                secondaryColor,
                                                          ));
                                                        },
                                                        errorBuilder: (context,
                                                            error, stackTrace) {
                                                          return const Center(
                                                              child: Icon(
                                                            Icons.error,
                                                            color:
                                                                Color.fromRGBO(
                                                                    7,
                                                                    9,
                                                                    84,
                                                                    1),
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
                                                  fontWeight:
                                                      FontWeight.normal),
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
                                                  builder: (context) =>
                                                      CartScreen(
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
          ),
        ],
      ),
    );
  }
}
