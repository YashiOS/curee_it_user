import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'dart:math';
import 'package:cureeit_user_app/BaseUrl.dart';
import 'package:cureeit_user_app/cartManager/cartManager.dart';
import 'package:cureeit_user_app/cubit/service_avilable_cubit.dart';
import 'package:cureeit_user_app/current_address/api_services.dart';
import 'package:cureeit_user_app/current_address/location_permission_helper.dart';

import 'package:cureeit_user_app/current_address/models/place_from_coordinates.dart';
import 'package:cureeit_user_app/screens/location.dart';
import 'package:cureeit_user_app/screens/order_tracking_screen.dart';
import 'package:cureeit_user_app/selected_Address/currentAddress.dart';
import 'package:cureeit_user_app/user/user.dart';
import 'package:cureeit_user_app/utils/theme.dart';
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
import 'package:location/location.dart' as loc;

import 'package:permission_handler/permission_handler.dart' as perm;

import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  // Add to your state class

  List AllOrders = [];
  List onGoingOrders = [];
  late AnimationController _controller;
  late Animation<double> _bounceAnimation;

  final List<String> hints = [
    "Search for \"diapers\"",
    "Search for \"dolo\"",
    "Search for \"paracetamol\"",
    "Search for \"ORS\"",
    "Search for \"vicks\"",
    "Search for \"thermometer\"",
    "Search for \"stayfree\"",
    "Search for \"anti-allergy\"",
    "Search for \"multivitamins\"",
    "Search for \"ipill\"",
    "Search for \"condom\"",
    "Search for \"nasal drops\"",
    "Search for \"injection\"",
  ];
  int currentIndex = 0;
  String? currentHint;
  late Timer timer;
  Map<String, bool> updatingQuantity = {};
  bool fisrtTime = false;
  Timer? _animationTimer;
  bool loaded = false;
  bool newUser = false;
  bool GotproductDetail = false;
  Map<int, bool> isAddingMap = {};
  List<dynamic> addresses = [];
  List<dynamic> products = [];
  Map<String, dynamic>? SelectedAddress;
  List<Map<String, dynamic>> cartItems = [];
  double totalAmount = 0.00;
  String finaltotalAmount = "";
  int quantityCart = 0;
  bool isLoading = true;
  bool isTapped = false;
  bool? isInRadius;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  Map<int, int> quantities = {};
  String localAddress = "";
  double defaultLat = 26.9124;
  double defaultLng = 75.7873;
  bool _isFetchingCart = false;
  PlaceFromCoordinates placeFromCoordinates = PlaceFromCoordinates();
  late Animation<Offset> _slideTransition;
  final ScrollController _scrollController = ScrollController();
  double _lastScrollOffset = 0.0;
  bool _isScrollingDown = false;
  double _bottomWidgetHeight = 76; // Height of your bottom widget
  late AnimationController _animationController;
  late Animation<double> _animation;
  Timer? _ongoingOrdersTimer;
  bool _isFetchingOngoingOrders = false;
  bool fetching_time=true;
  int estTime=0;
  // To store product quantities

  void _showLocationDeniedDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: ligtBlackColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        title: Text(
          "Location Required",
          style: GoogleFonts.mulish(color: whiteColor),
        ),
        content: Text(
          "Please enable location to use this app.",
          style: GoogleFonts.mulish(color: whiteColor),
        ),
        actions: [
          TextButton(
            style: TextButton.styleFrom(
                backgroundColor: Color(0xFFBE404F),
                foregroundColor: whiteColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                )),
            onPressed: () {
              exit(0); // Exit the app
            },
            child: Text(
              "Exit",
              style: GoogleFonts.mulish(color: whiteColor),
            ),
          ),
        ],
      ),
    );
  }

  void _scrollListener() {
    final currentScrollOffset = _scrollController.offset;

    if (currentScrollOffset > _lastScrollOffset && !_isScrollingDown) {
      // Scrolling down
      _isScrollingDown = true;
      _animationController.reverse();
    } else if (currentScrollOffset < _lastScrollOffset && _isScrollingDown) {
      // Scrolling up
      _isScrollingDown = false;
      _animationController.forward();
    }

    _lastScrollOffset = currentScrollOffset;
  }

  void _startAppInitialization() {
    fetchAddresses();
    fetchProducts();
    changeSearchText();
    fetchOrderHistory();
  }

  void _startOngoingOrdersPolling() {
    print("Hitting every 10 sec");
    // Cancel any existing timer
    _ongoingOrdersTimer?.cancel();

    // Start a new timer that fires every 10 seconds
    _ongoingOrdersTimer = Timer.periodic(Duration(seconds: 10), (timer) async {
      if (onGoingOrders.isEmpty) {
        _ongoingOrdersTimer?.cancel();
        _ongoingOrdersTimer = null;
        _isFetchingOngoingOrders = false;
        return;
      }

      _isFetchingOngoingOrders = true;
      if (_isFetchingOngoingOrders) {
        await fetchOrderHistory(); // This will update onGoingOrders
        // If there are no more ongoing orders, stop the timer
      }
    });
  }

  Future<void> _checkLocationStatus() async {
    
    loc.Location location = loc.Location();

    bool serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        _showLocationDeniedDialog();
        return;
      }
    }

    loc.PermissionStatus permissionGranted = await location.hasPermission();
    if (permissionGranted == loc.PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != loc.PermissionStatus.granted) {
        _showLocationDeniedDialog();
        return;
      }
    }

    // ✅ Location is enabled and permission is granted — now proceed
    _startAppInitialization();
  }

  void changeSearchText() async {
    timer = Timer.periodic(Duration(seconds: 3), (_) async {
      setState(() {
        currentHint = "";
      });

      setState(() {
        currentIndex = (currentIndex + 1) % hints.length;
      });

      setState(() {
        currentHint = hints[currentIndex];
      });
    });
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 900),
      vsync: this,
    )..repeat(reverse: true);
    _bounceAnimation = Tween<double>(
      begin: 0.0,
      end: -50.0, // or whatever vertical/horizontal movement you want
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.bounceIn,
      ),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkLocationStatus();
    });
    _scrollController.addListener(_scrollListener);

    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );

    _animation = Tween<double>(
      begin: -50,
      end: 76,
    ).animate(_animationController);
  }

  @override
  void dispose() {
    timer.cancel();
    _animationTimer?.cancel();
    _controller.dispose();
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    _animationController.dispose();
    _ongoingOrdersTimer?.cancel();
    // TODO: implement dispose
    super.dispose();
  }

  List<dynamic> getOngoingOrders(List<dynamic> allOrders) {
  
    return allOrders
        .where((order) =>
            order['status'] != 'Delivered' &&
            order['status'] != 'delivered')
        .toList();
  }

  Future<void> fetchOrderHistory() async {
   
    var url = Uri.parse('$baseUrl/order/orderHistory');
    var request = http.Request('POST', url)
      ..headers.addAll({
        'Content-Type': 'application/json',
      })
      ..body = jsonEncode({'userId': User.userId});

    var response = await http.Client().send(request);
  
    if (response.statusCode == 200) {
      var responseBody = await response.stream.bytesToString();
      Map<String, dynamic> data = jsonDecode(responseBody);
    

      setState(() {
        AllOrders = data['data'];
        
      
        AllOrders.sort((item1, item2) {
          final dateA = DateTime.parse(item1['purchaseDate']?? '1970-01-01');
          final dateB = DateTime.parse(item2['purchaseDate']?? '1970-01-01');
          return dateB.compareTo(dateA);
        });

        onGoingOrders = AllOrders.where((order) {
            String status = order['status']?.toString()?.toLowerCase() ?? '';
            return status != 'delivered';
          }).toList();
        if (onGoingOrders.isNotEmpty) {
          _startOngoingOrdersPolling();
        }
      });
    } else {
      throw Exception('Failed to load order history');
    }
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
        Uri.parse('$baseUrl/cart/addToCart'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'userId': User.userId,
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
          CartManager.cartQuantities[productId] =
              (CartManager.cartQuantities[productId] ?? 0) + 1;
        });
        Fluttertoast.showToast(msg: "Added To Cart");
      } else {
       
        ScaffoldMessenger.of(context).clearSnackBars();
        isAddingMap[index] = false;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add item to cart')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Network error: $e')),
      );
    }
    setState(() {
      isAddingMap[index] = false;
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
        CartManager.cartQuantities[productId] = 0;
        await fetchCartDetails();
        setState(() {
          if (cartItems.length == 0) {
            isTapped = false;
            cartItems.clear();
            totalAmount = 0;
          }
        });

        Fluttertoast.showToast(msg: "Removed from cart");
        setState(() {});
      } else {
       
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

  Future<void> DidUpdateQuantity(int index, int change) async {
  
    final product = products[index];
    final productId = product['productId'];
    final String? userId = User.userId; // Example userId
    final int currentQuantity = CartManager.cartQuantities[productId] ?? 0;
    final int newQuantity = currentQuantity + change;

    // Update local state immediately for UI responsiveness
    setState(() {
      updatingQuantity[productId] = true;
      if (newQuantity < 1) {
        quantities[index] = 0;
      } else {
        quantities[index] = newQuantity;
      }
    });
    if (newQuantity == 0) {
      _removeFromCart(productId);
      return;
    }

    try {
      final response = await http.put(
        Uri.parse('$baseUrl/cart/updateQuantity'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          "userId": userId,
          "productId": productId,
          "quantity": newQuantity < 1 ? 0 : newQuantity
        }),
      );
      if (response.statusCode == 200) {
        fetchCartDetails();
        CartManager.cartQuantities[productId] = newQuantity;
        setState(() {
          updatingQuantity[productId] = false;
        });
        Fluttertoast.showToast(msg: "Updated Cart");
      }
      if (response.statusCode != 200) {
        setState(() {
          updatingQuantity[productId] = false;
        });
        // Handle error - revert local state in case of failure
        setState(() {
          CartManager.cartQuantities[productId] = currentQuantity;
          quantities[index] = currentQuantity;
        });
        Fluttertoast.showToast(msg: "Failed to update cart");
      }
    } catch (e) {
      // Handle network errors - revert local state
      setState(() {
        updatingQuantity[productId] = false;
        CartManager.cartQuantities[productId] = currentQuantity;
        quantities[index] = currentQuantity;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Network error: $e')),
      );
    }
  }

  Future<void> fetchCartDetails() async {
    setState(() {
      isLoading = true;
    });

    try {
      final cartApiUrl = Uri.parse("$baseUrl/cart/cartDetails");
      final request = http.Request('POST', cartApiUrl)
        ..headers.addAll({'Content-Type': 'application/json'})
        ..body = jsonEncode({"userId": User.userId});

      final response = await http.Client().send(request);
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final responseData = jsonDecode(responseBody);
       
        if (responseData['status'] == 200 && responseData['data'] != null) {
          final cartData = responseData['data'];

          setState(() {
            finaltotalAmount = responseData["finalTotal"]?.toString() ?? "0";

           
          });
          final List<Map<String, dynamic>> tempCart = [];
          double calculatedTotal = 0.0;

          // Process all cart items
          for (var cartItem in cartData) {
            try {
              final productDetails =
                  await fetchProductDetails(cartItem['productId']);
              if (productDetails != null) {
                // Safely parse numeric values
                final quantity =
                    int.tryParse(cartItem['quantity'].toString()) ?? 0;
                final sellingPrice = double.tryParse(
                        (productDetails['sellingPrice'] ?? '0').toString()) ??
                    0.0;
                final productPrice = double.tryParse(
                        (cartItem["productPrice"] ?? '0').toString()) ??
                    0.0;
                if (CartManager.cartQuantities[cartItem["productId"]] == null) {
                  CartManager.cartQuantities[cartItem["productId"]] = quantity;
                }

                calculatedTotal += quantity * sellingPrice;
                quantityCart = CartManager.getTotalQuantity();

                tempCart.add({
                  "productId": cartItem['productId'],
                  "quantity": quantity,
                  "name": productDetails['name'] ?? 'Unknown Product',
                  "sellingPrice": sellingPrice,
                  "packagingDetail": productDetails['packagingDetail'] ?? '',
                  "imageUrls": productDetails['imageUrls'] ?? [],
                  "productPrice": productPrice,
                });
              }
            } catch (e) {
              print("❌ Error processing product ${cartItem['productId']}: $e");
            }
          }

          if (mounted) {
            setState(() {
              cartItems = tempCart;
              totalAmount = calculatedTotal;
              isLoading = false;
            });
          }
        } else {
          print("❌ Response did not contain valid cart data");
          if (mounted) {
            setState(() {
              cartItems = [];
              isLoading = false;
            });
          }
        }
      } else {
        print("❌ Failed to fetch cart details. Status: ${response.statusCode}");
        if (mounted) {
          setState(() {
            cartItems.clear();
            isLoading = false;
          });
        }
      }
    } catch (error) {
      print("❌ Error fetching cart details: $error");
      if (mounted) {
        setState(() {
          isLoading = false;
          _isFetchingCart = false;
        });
      }
    }
   
  }

  Future<Map<String, dynamic>?> fetchProductDetails(String productId) async {
    setState(() {});

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
        GotproductDetail = true;
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
   
    final response =
        await http.get(Uri.parse('https://api.medkaro.in/home/homeProducts'));
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

  Widget buildOutOfRadiusAsSliver() {
    return SliverFillRemaining(
      hasScrollBody: false,
      child: Center(
        child: Text(
          "We’re not in your area yet—but we’re on our way!",
          textAlign: TextAlign.center, // Center this text too
          style: GoogleFonts.mulish(
            fontWeight: FontWeight.w500,
            fontSize: 20,
            color: greyColor,
          ),
        ),
      ),
    );
  }

  Widget buildProductListAsSliver() {
    if (products.isEmpty) {
      return SliverToBoxAdapter(
        child: Center(
          child: Text(
            "No items",
            style: GoogleFonts.mulish(
              fontWeight: FontWeight.w500,
              fontSize: 20,
              color: greyColor,
            ),
          ),
        ),
      );
    }

    int itemCount = (products.length / 2).ceil();
    if (products.length > 8) itemCount = 4;

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, rowIndex) {
          int firstIndex = rowIndex * 2;
          int secondIndex = firstIndex + 1;

          return Container(
            margin: EdgeInsets.only(bottom: 20),
            child: Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 0),
                    child: buildProductItem(firstIndex),
                  ),
                ),
                SizedBox(width: 16),
                secondIndex < products.length
                    ? Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 0),
                          child: buildProductItem(secondIndex),
                        ),
                      )
                    : Expanded(child: Container()),
              ],
            ),
          );
        },
        childCount: itemCount,
      ),
    );
  }

  Widget buildProductItem(int index) {
    final product = products[index];
    final bool isInCart = quantities[index] != null && quantities[index]! > 0;
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    final containerHeight = height * 0.45; // 🟢 Half screen height
    final containerWidth = width * 0.3;

    return Container(
      width: 147,
      height: 202,
      decoration: BoxDecoration(
        color: ligtBlackColor,
        borderRadius: BorderRadius.circular(8),
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
            width: double.infinity,
            height: 109,
            child: GestureDetector(
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ItemDetailScreen(
                      productId: product['productId'],
                    ),
                  ),
                );
                await fetchCartDetails();
              },
              child: Container(
                width: double.infinity,
                height: 109,
                decoration: BoxDecoration(
                  color: whiteColor,
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

          // 🔵 Product Name (15%)
          Container(
            width: 147,
            height: 24,
            margin: EdgeInsets.only(top: 16, left: 10),
            child: Text(
              product['name'] ?? 'Product',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.mulish(
                  fontSize: containerHeight * 0.04, color: whiteColor),
            ),
          ),

          // 🔵 Price (7%)
          Container(
            margin: EdgeInsets.only(left: 10, right: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "₹${product['discountedPrice']}",
                      style: GoogleFonts.mulish(
                        color: whiteColor.withOpacity(0.8),
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      "₹${product['price']}",
                      style: GoogleFonts.mulish(
                          color: greyColor,
                          fontSize: 12,
                          decoration: TextDecoration.lineThrough,
                          decorationColor: greyColor),
                    ),
                  ],
                ),
                Container(
                  width: 50,
                  height: 29,
                  decoration: BoxDecoration(
                    color: ligtBlackColor,
                    border: isInCart ||
                            CartManager.cartQuantities[product['productId']] !=
                                    null &&
                                CartManager
                                        .cartQuantities[product["productId"]]! >
                                    0
                        ? Border.all(color: greenColor, width: 1)
                        : Border.all(color: greenColor, width: 1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: CartManager.cartQuantities[product['productId']] !=
                              null &&
                          CartManager.cartQuantities[product["productId"]]! > 0
                      ? Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(7),
                            color: greenColor,
                          ),
                          child: FittedBox(
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
                                updatingQuantity[product["productId"]] == true
                                    ? Container(
                                        height: 10,
                                        width: 10,
                                        child: CircularProgressIndicator(
                                          color: whiteColor,
                                        ),
                                      )
                                    : Text(
                                        '${CartManager.cartQuantities[product['productId']] ?? 0}',
                                        style: GoogleFonts.mulish(
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
                                    width: 10,
                                    height: 10,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Text(
                                    "Add",
                                    style: GoogleFonts.mulish(
                                      fontSize: containerHeight * 0.03,
                                      fontWeight: FontWeight.w600,
                                      color: greenColor,
                                    ),
                                  ),
                          ),
                        ),
                ),
              ],
            ),
          ), // 🔵 Add to Cart or Quantity Buttons (30%)
        ],
      ),
    );
  }

  Future<void> fetchAddresses() async {
  
    if (Address.CurrentAddress != null) {
      String fullAddress = Address.CurrentAddress!["address"];
     

      setState(() {
        localAddress = fullAddress;
        checkLocation();
      });
    }
    var url = Uri.parse(
      '$baseUrl/address/savedAddress',
    );

    // Create the GET request with the userId as query parameter
    var request = http.Request('GET', url)
      ..headers.addAll({
        'Content-Type': 'application/json',
      })
      ..body = jsonEncode({'userId': User.userId});

    var response = await http.Client().send(request);
   
    if (response.statusCode == 200) {
      String address = await fetchLocationAndAddress();
      final data = json.decode(await response.stream.bytesToString());
      final fetchAddress = data["data"]["address"];
      if (fetchAddress == null || fetchAddress.isEmpty) {
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
        setState(() {
          newUser = true;
          checkLocation();
        });
      } else {
        SelectedAddress = data['data']['address'][0];
        addresses = data['data']['address'];
        if (Address.CurrentAddress == null && SelectedAddress != null) {
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

  Future<void> getEstTime(String lat, String long) async {
   
    final String apiUrl = "$baseUrl/home/getEstTime";
    try {
      final response = await http.post(Uri.parse(apiUrl),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({"userLat": lat, "userLong": long}));

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        setState(() {
          estTime = (responseData["estimatedTimeMinutes"]);
         
        });
       setState(() {
      fetching_time=false;
    });
       
      }
    } catch (e) {
       setState(() {
      fetching_time=false;
    });
      print("error $e");
    }
  }

  Future<void> checkLocation() async {
   
    final String apiUrl = "$baseUrl/home/check_location";

    try {
      String latitude = "${Address.CurrentAddress!["userLat"]}";
      String longitude = "${Address.CurrentAddress!["userLong"]}";

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "latitude": latitude,
          "longitude": longitude,
        }),
      );
     
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
       
        setState(() {
          isInRadius = responseData['isAllowed'] == true;
        });
        if (isInRadius == true) {
          fetchCartDetails();
          context.read<ServiceAvilableCubit>().UpdateServiceAvilable(true);
          getEstTime(latitude,
              longitude);
             
        } else {
          isInRadius = false;
          context.read<ServiceAvilableCubit>().UpdateServiceAvilable(false);
        }
      } else {
        print("Failed to check_location: ${response.body}");
      }
    } catch (error) {
      print("Error to check_location: $error");
    }
  }

  Future<String> fetchLocationAndAddress() async {
    try {
      // Get current position
      final position = await determinePosition();
      defaultLat = position.latitude;
      defaultLng = position.longitude;
    

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
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AnimatedBuilder(
          animation: _bounceAnimation,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, _bounceAnimation.value),
              child: Image.asset(
                "lib/images/capsule.png",
                width: 40,
                height: 60,
              ),
            );
          },
        ),
        SizedBox(height: 8),
        Text(
          "Relief loading...",
          style: GoogleFonts.mulish(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    bool ISserviceAvilable =
        context.watch<ServiceAvilableCubit>().ServiceAvilable;
    return Scaffold(
      backgroundColor: scaffoldBlackColor,
      key: _scaffoldKey,
      body: Stack(children: [
        if (ISserviceAvilable && isInRadius != null && localAddress.isNotEmpty)
          Positioned(
            bottom: 0,
            left: 55, // shift image slightly to the right
            right: 0, // allow some stretching to the right if needed
            child: IgnorePointer(
              child: Image.asset(
                'lib/images/final_homebike1.png',
                fit: BoxFit.contain,
                width: double.infinity,
              ),
            ),
          ),
        Container(
          margin: EdgeInsets.all(20),
          child: CustomScrollView(
            controller: _scrollController,
            slivers: [
              SliverAppBar(
                
                backgroundColor: scaffoldBlackColor,
                expandedHeight: 80,
                floating: false,
                pinned: false,
                flexibleSpace: FlexibleSpaceBar(
                  background: GestureDetector(
                    onTap: () async {
                      if (localAddress.isEmpty) {
                        return;
                      }
                      await Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => LocationScreen()));
                      checkLocation();
                      localAddress = Address.CurrentAddress!["address"];
                    },
                    child: Container(
                        height: 80,
                        decoration: BoxDecoration(
                            color: scaffoldBlackColor,
                            borderRadius: BorderRadius.circular(8)),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              height: 80,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  localAddress == null || localAddress.isEmpty
                                      ? Container(
                                          margin: EdgeInsets.only(bottom: 10),
                                          child: Shimmer.fromColors(
                                            baseColor: ligtBlackColor,
                                            highlightColor: whiteColor,
                                            child: Container(
                                              width: 60,
                                              height: 10,
                                              // Matches your text height
                                              decoration: BoxDecoration(
                                                color: whiteColor,
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                            ),
                                          ),
                                        )
                                      : Container(
                                          width: 70,
                                          child: Image.asset(
                                              "lib/images/final_medkaro_logo.png")),
                                  localAddress == null || localAddress.isEmpty
                                      ? Container(
                                          margin: EdgeInsets.only(bottom: 10),
                                          child: Shimmer.fromColors(
                                            baseColor: ligtBlackColor,
                                            highlightColor: whiteColor,
                                            child: Container(
                                              width: 150,
                                              height: 22,
                                              // Matches your text height
                                              decoration: BoxDecoration(
                                                color: whiteColor,
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                            ),
                                          ),
                                        )
                                      :fetching_time?Container(
                                          margin: EdgeInsets.only(bottom: 10),
                                          child: Shimmer.fromColors(
                                            baseColor: ligtBlackColor,
                                            highlightColor: whiteColor,
                                            child: Container(
                                              width: 150,
                                              height: 22,
                                              // Matches your text height
                                              decoration: BoxDecoration(
                                                color: whiteColor,
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                            ),
                                          ),
                                        ): Text(
                                          "in $estTime minutes",
                                          style: GoogleFonts.mulish(
                                              color:estTime==0?greyColor: whiteColor,
                                              fontSize: 24,
                                              fontWeight: FontWeight.bold),
                                        ),
                                  localAddress == null || localAddress.isEmpty
                                      ? Container(
                                          margin: EdgeInsets.only(top: 10),
                                          child: Shimmer.fromColors(
                                            baseColor: ligtBlackColor,
                                            highlightColor: whiteColor,
                                            child: Container(
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.4,
                                              height: 8,
                                              // Matches your text height
                                              decoration: BoxDecoration(
                                                color: whiteColor,
                                                borderRadius:
                                                    BorderRadius.circular(2),
                                              ),
                                            ),
                                          ),
                                        )
                                      : Container(
                                          width: 280,
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Container(
                                                constraints:
                                                    const BoxConstraints(
                                                  minWidth: 50,
                                                  maxWidth: 250,
                                                ),
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    if (Address.CurrentAddress![
                                                                "type"] !=
                                                            null &&
                                                        Address.CurrentAddress![
                                                                "type"] !=
                                                            "")
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(right: 4),
                                                        child: Text(
                                                          "${Address.CurrentAddress!["type"]} : ",
                                                          style: GoogleFonts
                                                              .mulish(
                                                            color: whiteColor,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 17,
                                                          ),
                                                        ),
                                                      ),
                                                    Flexible(
                                                      child: Text(
                                                        "$localAddress",
                                                        maxLines: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        style:
                                                            GoogleFonts.mulish(
                                                          color: whiteColor,
                                                          fontWeight:
                                                              FontWeight.w300,
                                                          fontSize: 15,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              const Icon(
                                                Icons.arrow_drop_down,
                                                color: Colors.white,
                                              ),
                                            ],
                                          ))
                                ],
                              ),
                            ),
                            GestureDetector(
                              onTap: () async {
                                await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => ProfileScreen()));
                                checkLocation();
                                localAddress =
                                    Address.CurrentAddress!["address"];
                              },
                              child:
                                  localAddress == null || localAddress.isEmpty
                                      ? Container(
                                          child: Shimmer.fromColors(
                                            baseColor: ligtBlackColor,
                                            highlightColor: whiteColor,
                                            child: Container(
                                              width: 36,
                                              height: 36,
                                              // Matches your text height
                                              decoration: BoxDecoration(
                                                color: whiteColor,
                                                borderRadius:
                                                    BorderRadius.circular(50),
                                              ),
                                            ),
                                          ),
                                        )
                                      : Container(
                                          height: 36,
                                          width: 36,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                          ),
                                          child: Image.asset(
                                              "lib/images/profileIcon.png"),
                                        ),
                            ),
                          ],
                        )),
                  ),
                ),
              ),
              if (ISserviceAvilable && onGoingOrders.isNotEmpty)
                SliverAppBar(
                
                  backgroundColor:scaffoldBlackColor,
                  floating: false,
                  expandedHeight: 64,
                  pinned: false,
                  flexibleSpace: FlexibleSpaceBar(
                    background: onGoingOrders.isNotEmpty && localAddress != ""
                        ? Container(
                            
                            height: 94,
                            decoration: BoxDecoration(
                                color: ligtBlackColor,
                                borderRadius: BorderRadius.circular(8)),
                            child: Center(
                              child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: onGoingOrders.length,
                                  itemBuilder: (context, index) {
                                    String status = "";
                                    final order = onGoingOrders[index];
                                    final orederId = order["orderId"]??order["availableID"];
                                   
                                   
                                    if(order["status"]=="Available"){
                                      status="Order Confirmed";
                                    }
                                    if(order["status"]=="In Review"){
                                      status ="Verifying Order";
                                    }
                                    if (order["status"] ==
                                        "Order Placed") {
                                      status = "Order Placed!";
                                    }
                                    if (order["status"] == "Packing") {
                                      status = "Packing Items";
                                    }
                                    if (order["status"] ==
                                        "On the way") {
                                      status = "Order Enroute";
                                    }
                                    return GestureDetector(
                                      onTap: () {
                                        Navigator.of(context).push(
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    OrderTrackingScreen(
                                                        NavigatingFrom: "home",
                                                        orderId: orederId)));
                                      },
                                      child: Container(
                                        padding: EdgeInsets.all(16),
                                        height: 80,
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.9,
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
                                                  "$status",
                                                  style: GoogleFonts.mulish(
                                                      color: whiteColor,
                                                      fontSize: 20,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                                Text(
                                                  "#$orederId",
                                                  style: GoogleFonts.mulish(
                                                      color: greyColor,
                                                      fontSize: 10,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              ],
                                            ),
                                            Container(
                                              height:order["status"]=="In Review"?50 :order["status"] ==
                                                      "Order Placed" ||order["status"]=="Available"
                                                  ? 36
                                                  : 80, // ⬅️ Adjust here
                                              decoration: BoxDecoration(),
                                              child: Image.asset(
                                                order["status"]=="Available"?
                                                "lib/images/ordered.png":
                                                order["status"] ==
                                                        "Order Placed"
                                                    ? 'lib/images/ordered.png'
                                                    : order["status"] ==
                                                            "Packing"
                                                        ? 'lib/images/packing.png'
                                                        : order["status"] ==
                                                                "On the way"
                                                            ? 'lib/images/onTheWay.png'
                                                            : order["status"] ==
                                                                    "Delivered"
                                                                ? 'lib/images/DELIVERED.png'
                                                                : 'lib/images/veryfing.png', // Default image
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  }),
                            ),
                          )
                        : SizedBox(
                            height: 0,
                          ),
                  ),
                ),
              if (ISserviceAvilable)
                SliverAppBar(
                  scrolledUnderElevation: 0,
            elevation: 0,
                 toolbarHeight:MediaQuery.of(context).size.height * 0.09,
            
                  backgroundColor: scaffoldBlackColor,
                 
                  pinned: true,
                  flexibleSpace: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      GestureDetector(
                        onTap: () async {
                          if (ISserviceAvilable) {
                            await Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => Search()));
                            setState(() {});
                            fetchCartDetails();
                          }
                        },
                        child: localAddress == null || localAddress.isEmpty
                            ? Container(
                                child: Shimmer.fromColors(
                                  baseColor: ligtBlackColor,
                                  highlightColor: whiteColor,
                                  child: Container(
                                    width: double.infinity,
                                    height: 43,
                                    // Matches your text height
                                    decoration: BoxDecoration(
                                      color: whiteColor,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                ),
                              )
                            : Container(
                              margin: EdgeInsets.only(top: 20),
                                height: 43,
                                
                                decoration: BoxDecoration(
                                  
                                  color: ligtBlackColor,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                clipBehavior: Clip.hardEdge,
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          left: 16, right: 5),
                                      child: Icon(Icons.search,
                                          color: Colors.white, size: 18),
                                    ),
                                    Container(
                                      width: 250,
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                            left: 5, right: 26),
                                        child: AnimatedSwitcher(
                                          duration: Duration(milliseconds: 300),
                                          transitionBuilder:
                                              (child, animation) {
                                            final inAnimation = Tween<Offset>(
                                              begin:
                                                  Offset(0, 1), // from bottom
                                              end: Offset.zero, // to center
                                            ).animate(animation);

                                            final outAnimation = Tween<Offset>(
                                              begin:
                                                  Offset(0, -1), // from center
                                              end: Offset.zero, //, // to top
                                            ).animate(animation);

                                            return SlideTransition(
                                              position: child.key ==
                                                      ValueKey(
                                                          hints[currentIndex])
                                                  ? inAnimation // incoming child
                                                  : outAnimation, // outgoing child
                                              child: child,
                                            );
                                          },
                                          child: Align(
                                            key: ValueKey<String>(
                                                hints[currentIndex]),
                                            alignment: Alignment.centerLeft,
                                            child: Text(
                                               currentHint ?? "",
                                              style: GoogleFonts.mulish(
                                                color: greyColor,
                                                fontSize: 14,
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
                        margin: EdgeInsets.only(top: 10,bottom: 10),
                        
                        child: Align(
                          
                          alignment: Alignment.bottomLeft,
                          child: Text(
                            isInRadius == null || localAddress.isEmpty
                                ? ""
                                : isInRadius!
                                    ? "Frequently Bought"
                                    : "",
                            style: GoogleFonts.mulish(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: whiteColor,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              if (isInRadius == null || localAddress.isEmpty)
                SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(child: LoadingIndicatorBallClip()))
              else if (isInRadius!)
                SliverPadding(
                  padding: cartItems.isNotEmpty
                      ? EdgeInsets.only(bottom: 135)
                      : EdgeInsets.only(bottom: 50),
                  sliver: buildProductListAsSliver(),
                )
              else
                buildOutOfRadiusAsSliver(),
            ],
          ),
        ),
        if ((!isLoading &&
                cartItems.isNotEmpty &&
                ISserviceAvilable &&
                totalAmount != 0) ||
            ISserviceAvilable && totalAmount != 0 && cartItems.isNotEmpty) ...[
          // Replace your existing Positioned widget with this:
          AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return Positioned(
                right: 0,
                bottom: 76,
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height * 0.10,
                  decoration: BoxDecoration(
                    color: scaffoldBlackColor,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white.withOpacity(0.1),
                        offset: Offset(0, -2),
                        blurRadius: 6,
                        spreadRadius: 1,
                      ),
                      BoxShadow(
                        color: Colors.white.withOpacity(0.1),
                        offset: Offset(-2, 0),
                        blurRadius: 6,
                        spreadRadius: 1,
                      ),
                      BoxShadow(
                        color: Colors.white.withOpacity(0.1),
                        offset: Offset(2, 0),
                        blurRadius: 6,
                        spreadRadius: 1,
                      ),
                    ],
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: MediaQuery.of(context).size.width * 0.045,
                      vertical: MediaQuery.of(context).size.height * 0.012,
                    ),
                    child: Column(
                      spacing: 8,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
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
                                              width: 2, color: greyColor),
                                        ),
                                        child: cartItems[0]['imageUrls']
                                                .isNotEmpty
                                            ? ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                child: Image.network(
                                                  cartItems[0]['imageUrls'][0],
                                                  fit: BoxFit.contain,
                                                  loadingBuilder: (context,
                                                      child, loadingProgress) {
                                                    if (loadingProgress == null)
                                                      return child;
                                                    return const Center(
                                                      child:
                                                          CircularProgressIndicator(
                                                        color: whiteColor,
                                                      ),
                                                    );
                                                  },
                                                  errorBuilder: (context, error,
                                                      stackTrace) {
                                                    return const Center(
                                                      child: Icon(
                                                        Icons.error,
                                                        color: whiteColor,
                                                      ),
                                                    );
                                                  },
                                                ),
                                              )
                                            : Icon(Icons.image),
                                      ),
                                Row(
                                  children: [
                                    Text(
                                      '${quantityCart} Item(s)  ',
                                      style: GoogleFonts.mulish(
                                        color: greyColor,
                                        fontSize: 14,
                                        fontWeight: FontWeight.normal,
                                      ),
                                    ),
                                    Text(
                                      "|  ₹ ${finaltotalAmount}",
                                      style: GoogleFonts.mulish(
                                        color: whiteColor,
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            GestureDetector(
                              onTap: () async {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        CartScreen(isNavigated: true),
                                  ),
                                );
                                setState(() {});
                                fetchCartDetails();
                              },
                              child: Container(
                                width: 90,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: greenColor,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Center(
                                  child: Text(
                                    'View cart',
                                    style: GoogleFonts.mulish(
                                      color: whiteColor,
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          )
        ]
      ]),
    );
  }
}
