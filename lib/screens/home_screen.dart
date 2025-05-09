import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:cureeit_user_app/cubit/service_avilable_cubit.dart';
import 'package:cureeit_user_app/current_address/api_services.dart';
import 'package:cureeit_user_app/current_address/location_permission_helper.dart';
import 'package:cureeit_user_app/current_address/models/place_from_coordinates.dart';
import 'package:cureeit_user_app/screens/location.dart';
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
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  List AllOrders=[];
  List onGoingOrders=[];
  late AnimationController _controller;
  late Animation<double> _bounceAnimation;
  int _currentImageIndex = 0;
  final List<String> _images = [
    "lib/images/capsule.png",
    "lib/images/capsule_image.png"
  ];
  final List<String> hints = [
    "Search for your medicine",
    "Try 'Paracetamol'",
    "Looking for Cough Syrup?",
    "Enter salt or brand name",
    "Got a headache? Try 'Saridon'",
    "Search by symptoms like 'cold'",
    "Find Ayurvedic medicines too",
    "Try 'Disprin' for quick relief",
    "Type 'Crocin' for fever meds",
    "Try 'ORS' for dehydration",
    "Search homeopathic remedies",
    "Search for baby care products",
  ];
  int currentIndex = 0;
  String? currentHint;
  late Timer timer;

  Timer? _animationTimer;
  bool loaded = false;
  bool newUser = false;
  bool GotproductDetail=false;
  Map<int, bool> isAddingMap = {};
  List<dynamic> addresses = [];
  List<dynamic> products = [];
  Map<String, dynamic>? SelectedAddress;
  List<Map<String, dynamic>> cartItems = [];
  double totalAmount = 0.00;
  String finaltotalAmount = "";
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
      duration: const Duration(milliseconds: 800),
      vsync: this, // Make sure your class mixes with TickerProviderStateMixin
    )..repeat(reverse: true); // This makes the animation loop back and forth

    _bounceAnimation = Tween<double>(begin: 0, end: -20).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
    fetchAddresses();
    fetchCartDetails();
    fetchProducts();
    changeSearchText();
    fetchOrderHistory();
  }

  @override
  void dispose() {
    timer.cancel();
    // TODO: implement dispose
    super.dispose();
  }

  List<dynamic> getOngoingOrders(List<dynamic> allOrders) {
  return allOrders.where((order) => 
    order['status'] != 'Delivered' && 
    order['status'] != 'delivered'
  ).toList();
}

    Future<void> fetchOrderHistory() async {
    var url = Uri.parse(
        'http://ec2-13-60-8-94.eu-north-1.compute.amazonaws.com:3000/order/orderHistory');
    var request =  http.Request('GET', url)
      ..headers.addAll({
        'Content-Type': 'application/json',
      })
      ..body = jsonEncode({'userId':User.userId});

    var response = await http.Client().send(request);
 
    if (response.statusCode == 200) {
      var responseBody = await response.stream.bytesToString();
      Map<String, dynamic> data = jsonDecode(responseBody);
      
      setState(() {
      
        AllOrders = data['data'];
         
        AllOrders.sort((item1, item2) {
  final dateA = DateTime.parse(item1['purchaseDate']);
  final dateB = DateTime.parse(item2['purchaseDate']);
  return dateB.compareTo(dateA); 
  
});

   onGoingOrders=getOngoingOrders(AllOrders);



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
        Uri.parse(
            'http://ec2-13-60-8-94.eu-north-1.compute.amazonaws.com:3000/cart/addToCart'),
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
        });
        Fluttertoast.showToast(msg: "Added To Cart");
      } else {
        print(response.statusCode);
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
  }

  Future<void> DidUpdateQuantity(int index, int change) async {
    final product = products[index];
    final productId = product['productId'];
    final String? userId = User.userId; // Example userId
    final int currentQuantity = quantities[index] ?? 0;
    final int newQuantity = currentQuantity + change;

    // Update local state immediately for UI responsiveness
    setState(() {
      if (newQuantity <= 1) {
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
    final String? userId = User.userId; // Replace with the actual userId

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
          finaltotalAmount = responseData["finalTotal"];
          List<Map<String, dynamic>> tempCart = [];

          for (var cartItem in cartData) {
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
                "sellingPrice": cartItem["sellingPrice"] ?? '0',
                "packagingDetail": productDetails['packagingDetail'],
                "imageUrls": productDetails['imageUrls'],
                "productPrice": cartItem["productPrice"] ?? 0,
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
        GotproductDetail=true;
        final responseBody = await response.stream.bytesToString();
        final responseData = jsonDecode(responseBody);

        if (responseData['status'] == 200 && responseData['data'] != null) {
          print(responseData["data"]);
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
      child: Column(
        mainAxisSize: MainAxisSize
            .min, // Ensures column takes only as much space as needed
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Sorry! Our services are not available in your area yet.",
            textAlign: TextAlign.center, // Center the text inside the widget
            style: GoogleFonts.mulish(
              fontWeight: FontWeight.w700,
              fontSize: 24,
              color: whiteColor,
            ),
          ),
          SizedBox(height: 12), // Add spacing between the two texts
          Text(
            "We will notify you as soon as the services are available",
            textAlign: TextAlign.center, // Center this text too
            style: GoogleFonts.mulish(
              fontWeight: FontWeight.w500,
              fontSize: 14,
              color: greyColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildProductList() {
    if (products.isEmpty) {
      return Center(
        child: CircularProgressIndicator(color: secondaryColor),
      );
    }

    // Calculate number of rows needed (2 items per row)
    int itemCount = (products.length / 2).ceil();
    if (products.length > 6) itemCount = 3; // Limit to 6 items (3 rows)

    return ListView.builder(
      shrinkWrap: true,
      physics: ClampingScrollPhysics(),
      itemCount: itemCount,
      itemBuilder: (context, rowIndex) {
        int firstIndex = rowIndex * 2;
        int secondIndex = firstIndex + 1;

        return Container(
          margin: cartItems.isNotEmpty
              ? EdgeInsets.only(bottom: 20)
              : EdgeInsets.only(bottom: 20),
          child: Row(
            children: [
              // First product
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: 0),
                  child: buildProductItem(firstIndex),
                ),
              ),
              SizedBox(
                width: 16,
              ),
              // Second product (or empty container if odd count)
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
              maxLines: 2,
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
                  width: 49,
                  height: 29,
                  decoration: BoxDecoration(
                    color: ligtBlackColor,
                    border: Border.all(
                      color: greenColor,
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: isInCart
                      ? Container(
                          width: 49,
                          height: 29,
                          decoration: BoxDecoration(
                            color: greenColor,
                            borderRadius: BorderRadius.circular(8),
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
                                Text(
                                  '${quantities[index]}',
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
                                    width: 18,
                                    height: 18,
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
      ..body = jsonEncode({'userId': User.userId});

    var response = await http.Client().send(request);
    print(response.statusCode);
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

  Future<void> checkLocation() async {
    print("checking location...");
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
          print("checking if its in radius...");
         
          isInRadius = responseData['insideRadius'] == true;
           print(isInRadius);
          if (isInRadius == true) {
            context.read<ServiceAvilableCubit>().UpdateServiceAvilable(true);
          } else {
            isInRadius = false;
            context.read<ServiceAvilableCubit>().UpdateServiceAvilable(false);
          }
        });
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
            fontWeight: FontWeight.w700,
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
          Container(
            color: scaffoldBlackColor,
            padding: EdgeInsets.only(left: 20, right: 20, top: 40),
            margin: EdgeInsets.only(bottom: cartItems.isEmpty ? 45 : 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () async {
                    await Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => LocationScreen()));
                    checkLocation();
                    localAddress = Address.CurrentAddress!["address"];
                  },
                  child: Container(
                      height: 100,
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
                                            "lib/images/Medkaro (1) 2.png")),
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
                                    : Text(
                                        "in 10 minutes",
                                        style: GoogleFonts.mulish(
                                            color: whiteColor,
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
                                              constraints: BoxConstraints(
                                                minWidth: 100,
                                                maxWidth: 250,
                                              ),
                                              child: Text(
                                                "$localAddress",
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: GoogleFonts.mulish(
                                                    color: whiteColor,
                                                    fontWeight: FontWeight.w300,
                                                    fontSize: 15),
                                              ),
                                            ),
                                            Icon(
                                              Icons.arrow_drop_down,
                                              color: whiteColor,
                                            )
                                          ],
                                        ),
                                      )
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
                              localAddress = Address.CurrentAddress!["address"];
                            },
                            child: localAddress == null || localAddress.isEmpty
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
                                      image: DecorationImage(
                                        image:
                                            AssetImage('lib/images/user.png'),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                          ),
                        ],
                      )),
                ),
                onGoingOrders.isNotEmpty &&localAddress!=""?Container(
                  margin: EdgeInsets.only(bottom: 20),
                  height: 94,
                  decoration: BoxDecoration(
                    color: ligtBlackColor,
                    borderRadius: BorderRadius.circular(8)
                  ),
                  child: ListView.builder(
                itemCount:onGoingOrders.length ,
                itemBuilder: (context, index){
                  final order=onGoingOrders[index];
                  return Container(
                  height: 90,
                  child: Row(
                    children: [],
                  ),
                );

                } 
                  ),
                ) :SizedBox(height: 0,),
                GestureDetector(
                  onTap: () {
                    if (ISserviceAvilable) {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => Search()));
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
                                padding:
                                    const EdgeInsets.only(left: 16, right: 5),
                                child: Icon(Icons.search,
                                    color: Colors.white, size: 16),
                              ),
                              Container(
                                width: 250,
                                child: Padding(
                                  padding:
                                      const EdgeInsets.only(left: 5, right: 26),
                                  child: AnimatedSwitcher(
                                    duration: Duration(milliseconds: 300),
                                    transitionBuilder: (child, animation) {
                                      final inAnimation = Tween<Offset>(
                                        begin: Offset(0, 1), // from bottom
                                        end: Offset.zero, // to center
                                      ).animate(animation);

                                      final outAnimation = Tween<Offset>(
                                        begin: Offset(0, -1), // from center
                                        end: Offset.zero, //, // to top
                                      ).animate(animation);

                                      return SlideTransition(
                                        position: child.key ==
                                                ValueKey(hints[currentIndex])
                                            ? inAnimation // incoming child
                                            : outAnimation, // outgoing child
                                        child: child,
                                      );
                                    },
                                    child: Align(
                                      key:
                                          ValueKey<String>(hints[currentIndex]),
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        currentHint ?? "",
                                        style: GoogleFonts.mulish(
                                          color: whiteColor,
                                          fontSize: 15,
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
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: EdgeInsets.only(top: 10, bottom: 15),
                        child: Text(
                          isInRadius == null
                              ? ""
                              : isInRadius!
                                  ? "Featured Products"
                                  : "",
                          style: GoogleFonts.mulish(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: whiteColor,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          
                          color: scaffoldBlackColor,
                          child: Center(
                            child: MediaQuery.removePadding(
                              context: context,
                              removeTop: true,
                              child: Container(
                                  color: scaffoldBlackColor,
                                  padding: cartItems.isNotEmpty
                                      ? EdgeInsets.only(bottom: 180)
                                      : EdgeInsets.only(bottom: 20),
                                  child: isInRadius == null
                                      ? LoadingIndicatorBallClip()
                                      : isInRadius!
                                          ? buildProductList()
                                          : buildOutOfRadius()),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if ((!isLoading &&
                  cartItems.isNotEmpty &&
                  ISserviceAvilable &&
                  totalAmount != 0) ||
              (isTapped) && ISserviceAvilable && totalAmount != 0) ...[
            Positioned(
                right: 0,
                bottom: 76,
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height *
                      0.12, // 12% of screen height
                  decoration: BoxDecoration(
                      color: ligtBlackColor,
                      boxShadow: [
                        // Top shadow
                        BoxShadow(
                          color: Colors.white.withOpacity(0.1),
                          offset: Offset(0, -2),
                          blurRadius: 6,
                          spreadRadius: 1,
                        ),
                        // Left shadow
                        BoxShadow(
                          color: Colors.white.withOpacity(0.1),
                          offset: Offset(-2, 0),
                          blurRadius: 6,
                          spreadRadius: 1,
                        ),
                        // Right shadow
                        BoxShadow(
                          color: Colors.white.withOpacity(0.1),
                          offset: Offset(2, 0),
                          blurRadius: 6,
                          spreadRadius: 1,
                        ),
                      ],
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(30),
                          topRight: Radius.circular(30))),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: MediaQuery.of(context).size.width * 0.045,
                        vertical: MediaQuery.of(context).size.height * 0.012),
                    child: Column(
                      spacing: 8,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Delivering in 10 minutes!',
                          style: GoogleFonts.mulish(
                              color: whiteColor,
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
                                              width: 2, color: greyColor),
                                        ),
                                        child: cartItems[0]['imageUrls']
                                                .isNotEmpty
                                            ? Image.network(
                                                cartItems[0]['imageUrls'][0],
                                                fit: BoxFit.contain,
                                                loadingBuilder: (context, child,
                                                    loadingProgress) {
                                                  if (loadingProgress == null) {
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
                                          fontWeight: FontWeight.normal),
                                    ),
                                    Text(
                                      "|  ₹ ${finaltotalAmount}",
                                      style: TextStyle(
                                          color: whiteColor,
                                          fontFamily: "Urbanist",
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                )
                              ],
                            ),
                            GestureDetector(
                                onTap: ()async {
                                  await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => CartScreen(
                                                isNavigated: true,
                                              )));
                                  
                                            
                                },
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                      vertical:
                                          MediaQuery.of(context).size.height *
                                              0.017,
                                      horizontal:
                                          MediaQuery.of(context).size.width *
                                              0.05),
                                  decoration: BoxDecoration(
                                      color: greenColor,
                                      borderRadius: BorderRadius.circular(8)),
                                  child: Text(
                                    'View cart',
                                    style: GoogleFonts.mulish(
                                        color: whiteColor,
                                        fontSize:
                                            MediaQuery.of(context).size.height *
                                                0.017,
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
        ]));
  }
}
