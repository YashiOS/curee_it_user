import 'dart:convert';
import 'package:cureeit_user_app/cubit/service_avilable_cubit.dart';
import 'package:cureeit_user_app/current_address/api_services.dart';
import 'package:cureeit_user_app/current_address/location_permission_helper.dart';
import 'package:cureeit_user_app/current_address/models/place_from_coordinates.dart';
import 'package:cureeit_user_app/selected_Address/currentAddress.dart';
import 'package:cureeit_user_app/utils/theme.dart';
import 'package:cureeit_user_app/widgets/LoadingIndicater.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cureeit_user_app/current_address/google_maps_screen.dart';
import 'package:cureeit_user_app/screens/cart_screen.dart';
import 'package:cureeit_user_app/screens/item_detail_screen.dart';
import 'package:cureeit_user_app/screens/profile_screen.dart';
import 'package:cureeit_user_app/screens/search.dart';
import 'package:cureeit_user_app/selected_Address/currentAddress.dart';
import 'package:cureeit_user_app/utils/theme.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:loading_indicator/loading_indicator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool loaded = false;
  bool newUser = false;
  Map<int, bool> isAddingMap = {};
  List<dynamic> addresses = [];
  List<dynamic> products = [];
  Map<String, dynamic>? SelectedAddress;
  List<Map<String, dynamic>> cartItems = [];
  double totalAmount = 0.00;
  String finaltotalAmount="";
  bool isLoading = true;
  bool isTapped = false;
  bool? isInRadius;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  Map<int, int> quantities = {};
  String localAddress = "";
  double defaultLat = 26.9124;
  double defaultLng = 75.7873;
  PlaceFromCoordinates placeFromCoordinates = PlaceFromCoordinates();
  // To store product quantities

  @override
  void initState() {
    print("in intit state");
    super.initState();
    fetchAddresses();
    fetchCartDetails();
    fetchProducts();
  }

  void UpdateAddress1() {
    localAddress = Address.CurrentAddress!["address"];
    checkLocation();
    setState(() {});
  }

  void UpdateAddress(Map<String, dynamic> address) {
    Address.CurrentAddress = address;
    localAddress = Address.CurrentAddress!["address"];

    setState(() {});
  }

  Future<void> didAddToCart(int index) async {
    setState(() {
      isAddingMap[index] = true;
    });
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
          isAddingMap[index] = false;
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
          finaltotalAmount=responseData["finalTotal"];
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

  Widget buildOutOfRadius() {
    return Container(
      color: scaffoldBlackColor,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize
              .min, // Ensures column takes only as much space as needed
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Sorry! Our services are not available in your area yet.",
              textAlign: TextAlign.center, // Center the text inside the widget
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 24,
                fontFamily: "Urbanist",
                color: whiteColor,
              ),
            ),
            SizedBox(height: 12), // Add spacing between the two texts
            Text(
              "We will notify you as soon as the services are available",
              textAlign: TextAlign.center, // Center this text too
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14,
                fontFamily: "Urbanist",
                color: greenColor,
              ),
            ),
          ],
        ),
      ),
    );
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
      crossAxisCount: 2,
      shrinkWrap: true,
      scrollDirection: Axis.vertical,
      childAspectRatio: 0.8,
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      children: productWidgets,
    );
  }

  Widget buildProductItem(int index) {
    print(products[index]);
    final product = products[index];
    final bool isInCart = quantities[index] != null && quantities[index]! > 0;
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    final containerHeight = height * 0.45; // 🟢 Half screen height
    final containerWidth = width * 0.3;

    return Container(
      width: containerWidth,
      height: containerHeight,
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: ligtBlackColor,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: ligtBlackColor,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🔵 Product Image (30%)
          SizedBox(
            width: width,
            height: containerHeight * 0.3,
            child: GestureDetector(
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
                decoration: BoxDecoration(
                  color: ligtBlackColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: product['imageMediaUrls'][0] != null &&
                        product['imageMediaUrls'][0].toString().isNotEmpty
                    ? Image.network(
                        product['imageMediaUrls'][0],
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) => Icon(
                          Icons.image_not_supported,
                          size: containerHeight * 0.1,
                          color: Colors.grey.shade400,
                        ),
                      )
                    : Icon(
                        Icons.image_not_supported,
                        size: containerHeight * 0.1,
                        color: Colors.grey.shade400,
                      ),
              ),
            ),
          ),

          SizedBox(height: containerHeight * 0.01),

          // 🔵 Product Name (15%)
          SizedBox(
            height: containerHeight * 0.12,
            child: Text(
              product['name'] ?? 'Product',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  fontFamily: "Roboto",
                  fontSize: containerHeight * 0.04,
                  color: whiteColor),
            ),
          ),

          // 🔵 Price (7%)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "₹${product['price']}",
                style: GoogleFonts.inter(
                  fontSize: containerHeight * 0.04,
                  color: greyColor,
                ),
              ),
              SizedBox(width: containerWidth * 0.01),
              Container(
                width: width * 0.25,
                height: containerHeight * 0.09,
                decoration: BoxDecoration(
                  color: ligtBlackColor,
                  border: Border.all(
                    color: greenColor,
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: isInCart
                    ? FittedBox(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              padding: EdgeInsets.zero,
                              constraints: BoxConstraints(),
                              icon: Icon(
                                Icons.remove,
                                size: containerHeight * 0.06,
                                color: whiteColor,
                              ),
                              onPressed: () => DidUpdateQuantity(index, -1),
                            ),
                            Text(
                              '${quantities[index]}',
                              style: TextStyle(
                                color: whiteColor,
                                fontWeight: FontWeight.bold,
                                fontSize: containerHeight * 0.05,
                              ),
                            ),
                            IconButton(
                              padding: EdgeInsets.zero,
                              constraints: BoxConstraints(),
                              icon: Icon(
                                Icons.add,
                                size: containerHeight * 0.06,
                                color: whiteColor,
                              ),
                              onPressed: () => DidUpdateQuantity(index, 1),
                            ),
                          ],
                        ),
                      )
                    : TextButton(
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: Size.zero,
                        ),
                        onPressed: () {
                          didAddToCart(index);
                          setState(() => isLoading = true);
                          fetchCartDetails();
                        },
                        child: Center(
                          child: isAddingMap[index] == true
                              ? SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(
                                  "Add to Cart",
                                  style: GoogleFonts.lato(
                                    fontSize: containerHeight * 0.03,
                                    fontWeight: FontWeight.w600,
                                    color: greenColor,
                                  ),
                                ),
                        ),
                      ),
              ),
            ],
          ), // 🔵 Add to Cart or Quantity Buttons (30%)
        ],
      ),
    );
  }

  Future<void> fetchAddresses() async {
    if (Address.CurrentAddress != null) {
      String fullAddress = Address.CurrentAddress!["address"];
      print("in 2nd if condition");

      setState(() {
        localAddress = fullAddress;
        checkLocation();
      });
    }
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
      final fetchAddress = data["data"]["address"];
      if (fetchAddress == null || fetchAddress.isEmpty) {
        setState(() {
          newUser = true;
        });
      } else {
        SelectedAddress = data['data']['address'][0];
        addresses = data['data']['address'];
        if (Address.CurrentAddress == null && SelectedAddress != null) {
          String address = await fetchLocationAndAddress();

          setState(() {
            Address.CurrentAddress = {
              "address": address,
              "landmark": "",
              "floor": "",
              "userLat": defaultLat,
              "userLong": defaultLng,
              "type": "",
              "_id": ""
            };
            localAddress = address;
            Address.selectedIndex = null;
          });
          checkLocation();

          return;
        }
      }
    } else {
      print('Failed to load addresses');
    }
  }

  Future<void> checkLocation() async {
    final String apiUrl =
        "http://ec2-13-60-8-94.eu-north-1.compute.amazonaws.com:3000/home/check_location";

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "latitude": Address.CurrentAddress!["userLat"],
          "longitude": Address.CurrentAddress!["userLong"],
        }),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        setState(() {
          isInRadius = responseData['insideRadius'] == true;
          if (isInRadius == true) {
            context.read<ServiceAvilableCubit>().UpdateServiceAvilable(true);
          } else {
            isInRadius = false;
            context.read<ServiceAvilableCubit>().UpdateServiceAvilable(false);
          }

          print("IsInRadius value is ${isInRadius}");
        });
      } else {
        print("Failed to check_location: ${response.body}");
      }
    } catch (error) {
      print("Error to check_location: $error");
    }
  }

  void _locationBottomSheet() {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
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
          padding: EdgeInsets.all(width * 0.05),
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
                    onPressed: () {
                      Navigator.pop(context);
                      setState(() {});
                    },
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Title
              const Center(
                child: Text(
                  "Select delivery location",
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      fontFamily: "Urbanist"),
                ),
              ),
              const SizedBox(height: 10),

              // Search field
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: GestureDetector(
                  onTap: () async {
                    await Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => GoogleMapsScreen()));
                    Navigator.pop(context);
                    UpdateAddress1();
                  },
                  child: TextField(
                    enabled: false,
                    decoration: InputDecoration(
                      hintText: 'Search for area or apartment',
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 0, horizontal: 16),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Current Location Container
              GestureDetector(
                onTap: () async {
                  await Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => GoogleMapsScreen()));
                  Navigator.pop(context);
                  UpdateAddress1();
                },
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
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
                          fontFamily: "Urbanist",
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
                  onTap: () async {
                    await Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => GoogleMapsScreen()));
                    Navigator.pop(context);
                    UpdateAddress1();
                  },
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
                          fontFamily: "Urbanist",
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
                    fontFamily: "Urbanist",
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // Saved Addresses List Container
              ClipRRect(
                borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(10),
                    bottomLeft: Radius.circular(10),
                    bottomRight: Radius.circular(10)),
                child: Container(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height *
                        0.3, // Adjust as needed
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                  ),
                  child: addresses.isEmpty
                      ? const Center(
                          child: Text(
                          "No saved addresses",
                          style: TextStyle(
                            fontFamily: "Urbanist",
                          ),
                        ))
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const ClampingScrollPhysics(),
                          itemCount: addresses.length,
                          itemBuilder: (context, index) {
                            var address = addresses[index];
                            bool isSelected = Address.selectedIndex == index;
                            return GestureDetector(
                              onTap: () {
                                print(address);
                                UpdateAddress(address);

                                setState(() {
                                  Address.selectedIndex = index;
                                });
                                checkLocation();
                                Navigator.of(context).pop();
                              },
                              child: Column(
                                children: [
                                  Container(
                                    color: isSelected
                                        ? const Color.fromARGB(
                                            255, 194, 226, 205)
                                        : Colors.white,
                                    child: ListTile(
                                      contentPadding: EdgeInsets.symmetric(
                                          horizontal: 16, vertical: 3),
                                      leading: Container(
                                        padding: EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: Color.fromARGB(255, 204, 235,
                                              231), // Soft blue background
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          border: Border.all(
                                            color: isSelected
                                                ? Colors.white
                                                : Color.fromARGB(255, 171, 234,
                                                    225), // Light blue border
                                            width: 1.5,
                                          ),
                                        ),
                                        child: Icon(
                                          Icons
                                              .home_rounded, // More modern home icon
                                          color:
                                              primaryColor, // Matching blue icon
                                          size: 22,
                                        ),
                                      ),
                                      title: Text(
                                        address['address'] ?? '',
                                        style: TextStyle(
                                          fontFamily: "Urbanist",
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.grey
                                              .shade800, // Darker text for better readability
                                        ),
                                      ),
                                      subtitle: Text(
                                        address['landmark'] ?? '',
                                        style: TextStyle(
                                          fontFamily: "Urbanist",
                                          fontSize: 13,
                                          color: Colors.grey
                                              .shade600, // Slightly lighter than title
                                        ),
                                      ),
                                    ),
                                  ),
                                  Image.asset(
                                    "lib/images/dotted_divider.png",
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ),
              ),

              const SizedBox(height: 16), // Extra space at bottom
            ],
          ),
        );
      },
    );
  }

  Future<String> fetchLocationAndAddress() async {
    try {
      // Get current position
      final position = await determinePosition();
      defaultLat = position.latitude;
      defaultLng = position.longitude;
      print("📍 Location: $defaultLat, $defaultLng");

      // Get address from coordinates
      var value =
          await ApiServices().placeFromCoordinates(defaultLat, defaultLng);

      placeFromCoordinates = value;
      isLoading = false;
      defaultLat = value.results?[0].geometry?.location?.lat ?? 0.0;
      defaultLng = value.results?[0].geometry?.location?.lng ?? 0.0;
      List<dynamic> components =
          placeFromCoordinates.results?[0].addressComponents ?? [];
      String city = "";
      for (var component in components) {
        if (component.types?.contains("locality") ?? false) {
          city = component.longName ?? "";
          break;
        }
      }
      // Update Address model here

      return city;
    } catch (e) {
      print("❌ Error: $e");
      return "";
    }
  }

  Widget LoadingIndicatorBallClip() {
    return LoadingIndicator(indicatorType: Indicator.ballClipRotateMultiple);
  }

  @override
  Widget build(BuildContext context) {
    bool ISserviceAvilable =
        context.watch<ServiceAvilableCubit>().ServiceAvilable;
    return Scaffold(
      backgroundColor: scaffoldBlackColor,
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: scaffoldBlackColor,
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
                  if (ISserviceAvilable) {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ProfileScreen()));
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Container(
                    decoration: BoxDecoration(
                        border: Border.all(
                            color: Colors.blueGrey.withOpacity(0.2),
                            width: 1.6),
                        borderRadius: BorderRadius.circular(10)),
                    child: ISserviceAvilable
                        ? Icon(
                            Icons.person,
                            color: greenColor,
                          )
                        : Icon(
                            Icons.person_off,
                            color: Colors.grey,
                          ),
                  ),
                )),
          ),
        ),
        centerTitle: true,
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
                  if (ISserviceAvilable) {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => Search()));
                  }
                },
                child: Transform.translate(
                  offset: Offset(0, -10),
                  child: ISserviceAvilable
                      ? Icon(
                          Icons.search, // You can use any suitable icon
                          size: 32, // Adjust size as needed
                          color: whiteColor, // Optional color
                        )
                      : Icon(
                          Icons
                              .search_off, // A suitable icon to indicate "unavailable"
                          size: 32,
                          color: Colors.red,
                        ),
                ),
              ),
            ),
          ),
        ],
        title: Transform.translate(
            offset: Offset(0, -10),
            child: Image.asset("lib/images/medkarolog.png")),
      ),
      body: Container(
        color: scaffoldBlackColor,
        margin: EdgeInsets.only(bottom: cartItems.isEmpty ? 45 : 0),
        child: Column(
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
                      // Location Icon
                      Icon(
                        Icons.location_on,
                        color: greenColor,
                        size: 24, // Slightly larger icon
                      ),
                      SizedBox(width: 8),

                      // Address Text Column
                      Flexible(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // "HOME" Label
                            Text(
                              (Address.CurrentAddress != null &&
                                      Address.CurrentAddress!["type"] != null &&
                                      Address.CurrentAddress!["type"] != "")
                                  ? Address.CurrentAddress!["type"]
                                      .toString()
                                      .toUpperCase()
                                  : "HOME",
                              style: TextStyle(
                                fontFamily: "Urbanist",
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: greenColor,
                                letterSpacing: 0.5,
                              ),
                            ),
                            SizedBox(height: 2), // Small gap between lines

                            // Actual Address
                            localAddress == null || localAddress.isEmpty
                                ? Shimmer.fromColors(
                                    baseColor: ligtBlackColor!,
                                    highlightColor: greenColor!,
                                    child: Container(
                                      width: MediaQuery.of(context).size.width *
                                          0.2,
                                      height: 16, // Matches your text height
                                      decoration: BoxDecoration(
                                        color: whiteColor,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                    ),
                                  )
                                : Text(
                                    localAddress,
                                    style: TextStyle(
                                      fontFamily: "Urbanist",
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: whiteColor,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                          ],
                        ),
                      ),
                      SizedBox(width: 4),

                      // Dropdown Icon
                      Icon(
                        Icons.arrow_drop_down,
                        color: whiteColor,
                        size: 20,
                      ),
                    ],
                  ),
                )),
            GestureDetector(
              onTap: () {
                if (ISserviceAvilable) {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => Search()));
                }
              },
              child: Container(
                margin: EdgeInsets.all(10),
                height: 58,
                decoration: BoxDecoration(
                  color: ligtBlackColor,
                  borderRadius: BorderRadius.circular(16),
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
                            hintStyle: TextStyle(fontFamily: "Urbanist",color: greyColor),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: GestureDetector(
                        onTap: () {
                          if (ISserviceAvilable) {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => Search()));
                          }
                        },
                        child: Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color:
                                ISserviceAvilable ? greenColor : Colors.white,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: ISserviceAvilable
                              ? Icon(Icons.search, color: Colors.white)
                              : Icon(Icons.search_off, color: Colors.grey),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: Container(
                color: scaffoldBlackColor,
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                child: Stack(
                  children: [
                    ListView(
                      shrinkWrap: true,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10.0, vertical: 5.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isInRadius == null
                                    ? ""
                                    : isInRadius!
                                        ? "Featured Products"
                                        : "",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  fontFamily: "Urbanist",
                                  color: greenColor,
                                ),
                              ),
                              SizedBox(height: 10),
                              Container(
                                  color: scaffoldBlackColor,
                                  height: cartItems.isNotEmpty
                                      ? MediaQuery.of(context).size.height *
                                          0.47
                                      : null,
                                  child: isInRadius == null
                                      ? Shimmer.fromColors(
                                          baseColor: Colors.grey[300]!,
                                          highlightColor: Colors.grey[100]!,
                                          child: LoadingIndicatorBallClip(),
                                        )
                                      : isInRadius!
                                          ? buildProductGrid()
                                          : buildOutOfRadius()),
                            ],
                          ),
                        )
                      ],
                    ),
                    if ((!isLoading &&
                            cartItems.isNotEmpty &&
                            ISserviceAvilable &&
                            totalAmount != 0) ||
                        (isTapped) &&
                            ISserviceAvilable &&
                            totalAmount != 0) ...[
                      Positioned(
                          bottom: 76,
                          child: Container(
                            color: ligtBlackColor,
                            width: MediaQuery.of(context).size.width,
                            height: MediaQuery.of(context).size.height *
                                0.12, // 12% of screen height

                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal:
                                      MediaQuery.of(context).size.width * 0.045,
                                  vertical: MediaQuery.of(context).size.height *
                                      0.012),
                              child: Column(
                                spacing: 8,
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Delivering in 20 minutes !',
                                    style: TextStyle(
                                        color: greenColor,
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
                                                        BorderRadius.circular(
                                                            10),
                                                    border: Border.all(
                                                        width: 2,
                                                        color: greyColor),
                                                  ),
                                                  child: cartItems[0]
                                                              ['imageUrls']
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
                                                              color: whiteColor,
                                                            ));
                                                          },
                                                          errorBuilder:
                                                              (context, error,
                                                                  stackTrace) {
                                                            return const Center(
                                                                child: Icon(
                                                              Icons.error,
                                                              color: whiteColor,
                                                            ));
                                                          },
                                                        )
                                                      : Icon(Icons.image)),
                                          Row(
                                            children: [
                                              Text(
                                                '${cartItems.length} Item(s)  ',
                                                style: TextStyle(
                                                    color: greyColor,
                                                    fontFamily: "Urbanist",
                                                    fontSize: 14,
                                                    fontWeight:
                                                        FontWeight.normal),
                                              ),
                                              Text(
                                                "|  ₹ ${finaltotalAmount}",
                                                style: TextStyle(
                                                    color: whiteColor,
                                                    fontFamily: "Urbanist",
                                                    fontSize: 14,
                                                    fontWeight:
                                                        FontWeight.bold),
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
                                                vertical: MediaQuery.of(context)
                                                        .size
                                                        .height *
                                                    0.0175,
                                                horizontal:
                                                    MediaQuery.of(context)
                                                            .size
                                                            .width *
                                                        0.055),
                                            decoration: BoxDecoration(
                                                color: greenColor,
                                                borderRadius:
                                                    BorderRadius.circular(10)),
                                            child: Text(
                                              'Checkout',
                                              style: TextStyle(
                                                  color: whiteColor,
                                                  fontFamily: "Urbanist",
                                                  fontSize:
                                                      MediaQuery.of(context)
                                                              .size
                                                              .height *
                                                          0.0175,
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
      ),
    );
  }
}
