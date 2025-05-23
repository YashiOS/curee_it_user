import 'dart:async';
import 'package:cureeit_user_app/cartManager/cartManager.dart';
import 'package:cureeit_user_app/screens/cart_screen.dart';
import 'package:cureeit_user_app/screens/item_detail_screen.dart';
import 'package:cureeit_user_app/user/user.dart';
import 'package:flutter/material.dart';
import 'package:cureeit_user_app/utils/theme.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Search extends StatefulWidget {
  const Search({super.key});

  @override
  State<Search> createState() => _SearchState();
}

class _SearchState extends State<Search> {
  final TextEditingController _controller = TextEditingController();
  Timer? _debounce;
  final FocusNode _focusNode = FocusNode();
  List<dynamic> _searchResults = [];
  bool _isLoading = false;
  bool isIncart = false;
  Map<String, bool> _inCartMap = {};
 Map<String,bool> isAdding={};
 Map<String,bool>isUpdating={};

  // Track quantities for each product
  Map<String, int> _quantityMap = {};
  // Function to call search API
  Future<void> _fetchSearchResults(String query) async {
    if (query.length < 3) {
      setState(() {
        _searchResults.clear();
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.get(Uri.parse(
          "http://ec2-13-60-8-94.eu-north-1.compute.amazonaws.com:3000/search/searchProducts?keyword=$query"));

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        if (jsonResponse["success"] == true) {
          setState(() {
            _searchResults = jsonResponse["data"];
            print("SEARCH RESULT****");
            print(_searchResults);
          });
        } else {
          setState(() {
            _searchResults.clear();
          });
        }
      } else {
        setState(() {
          _searchResults.clear();
        });
      }
    } catch (e) {
      setState(() {
        _searchResults.clear();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Debounce search input
  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      final query = _controller.text.trim();

      print("Query  sent is $query");
      if (query.isEmpty) {
        // Clear results immediately
        setState(() {
          _searchResults.clear();
        });
        return;
      }
      if (query.isNotEmpty) {
        _fetchSearchResults(query);
        print("done sent");
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      _onSearchChanged();
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(_focusNode);
    });
  }

   Future<void> _removeFromCart(String ProductId) async {
  
    final String userId = User.userId!;
    final String productId = ProductId;

    final Map<String, dynamic> requestData = {
      "userId": userId,
      "productId": productId,
    };
   

    final url =
        'http://ec2-13-60-8-94.eu-north-1.compute.amazonaws.com:3000/cart/removeFromCart';
    try {
      final response = await http.delete(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(requestData),
      );

      if (response.statusCode == 200) {
      CartManager.cartQuantities[productId]=0;
        
        
        
       Fluttertoast.showToast(msg: "Removed from cart");
       setState(() {
         
       });
        
      } else {
        print(response.statusCode);
      
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to remove from cart",style: GoogleFonts.mulish(),),
            backgroundColor: greenColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            duration: Duration(seconds: 2),
          ),);
        print('Failed to remove from cart');
      }
    } catch (error) {
     
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error removing from cart ",style: GoogleFonts.mulish(),),
            backgroundColor: greenColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            duration: Duration(seconds: 2),
          ),);
      print('Error removing from cart: $error');
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  Future<void> didAddToCart({
    required String userId,
    required String productId,
    int quantity = 1,
  }) async {
    try {
      setState(() {
        _inCartMap[productId] = true;
        _quantityMap[productId] = 1;
        isAdding[productId]=true;
      });
      final response = await http.post(
        Uri.parse(
            'http://ec2-13-60-8-94.eu-north-1.compute.amazonaws.com:3000/cart/addToCart'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'userId': userId,
          'productId': productId,
          'quantity': quantity,
        }),
      );

      if (response.statusCode == 200) {
       

        setState(() {
          isAdding[productId]=false;
           CartManager.cartQuantities[productId]=(CartManager.cartQuantities[productId]??0)+1;
          isIncart = true;
        });
        Fluttertoast.showToast(msg: "Added To Cart");
      } else {
        setState(() {
          isAdding[productId]=false;
          _inCartMap.remove(productId);
          _quantityMap.remove(productId);
        });
        print('❌ Failed to add item to cart. Status: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Network error: $e');
    }
    
    setState(() {
      isAdding[productId]=false;
    });
  }

  Future<void> DidUpdateQuantity(
      int index, int change, String productId) async {
    final currentQuantity =CartManager.cartQuantities[productId]?? 1;
    final newQuantity = currentQuantity + change;

    if (newQuantity < 1) {
     await _removeFromCart(productId);
     
      // Remove from cart if quantity goes to 0
      setState(() {
        isUpdating[productId]=false;
        _inCartMap.remove(productId);
        _quantityMap.remove(productId);
      });
      return;
    }

    final String? userId = User.userId; // Example userId
    setState(() {
      isUpdating[productId]=true;
      _quantityMap[productId] = newQuantity;
    });

    // Update local state immediately for UI responsiveness

    try {
      final response = await http.put(
        Uri.parse(
            'http://ec2-13-60-8-94.eu-north-1.compute.amazonaws.com:3000/cart/updateQuantity'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          "userId": userId,
          "productId": productId,
          "quantity": newQuantity
        }),
      );
      setState(() {
        isUpdating[productId]=false;
        CartManager.cartQuantities[productId]=newQuantity;
      });
     
      if (response.statusCode != 200) {
        CartManager.cartQuantities[productId]=currentQuantity;
        // Handle error - revert local state in case of failure
        setState(() {
          isUpdating[productId]=false;
          _quantityMap[productId] = currentQuantity;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update cart')),
        );
      }
    } catch (e) {
      // Handle network errors - revert local state
      setState(() {
        isUpdating[productId]=false;
        _quantityMap[productId] = currentQuantity;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Network error: $e')),
      );
    }
    setState(() {
      isUpdating[productId]=false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    final containerHeight = height * 0.45; // 🟢 Half screen height
    final containerWidth = width * 0.3;
    return Scaffold(
      floatingActionButton: _inCartMap.isNotEmpty
          ? FloatingActionButton(
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => CartScreen(isNavigated: true)));
              },
              child: Icon(
                Icons.shopping_cart_outlined,
                color: whiteColor,
              ),
              backgroundColor: greenColor,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            )
          : null,
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
          "Search",
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
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 8),
            Container(
              height: 48,
              decoration: BoxDecoration(
                color: ligtBlackColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: TextField(
                        focusNode: _focusNode,
                        autofocus: true,
                        cursorColor: whiteColor,
                        style: GoogleFonts.mulish(color: whiteColor),
                        controller: _controller,
                        decoration: InputDecoration(
                          hintText: "Search",
                          hintStyle: GoogleFonts.mulish(color: whiteColor),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 12),
            Expanded(
              child: _isLoading
                  ? Center(
                      child: CircularProgressIndicator(
                      color: whiteColor,
                    ))
                  : _searchResults.isEmpty
                      ? Center(
                          child: Text("No results found",
                              style: GoogleFonts.mulish(color: greyColor)))
                      : ListView.builder(
                          itemCount: _searchResults.length,
                          itemBuilder: (context, index) {
                            final item = _searchResults[index];
                            print(item);
                            final productId = item["productId"];
                            final IsInCart = _inCartMap[productId] ?? false;


                            return GestureDetector(
                              onTap: () {
                                print("clicked");
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ItemDetailScreen(
                                      productId: item["productId"],
                                    ),
                                  ),
                                );
                              },
                              child: Card(
                                color: ligtBlackColor,
                                margin: EdgeInsets.symmetric(vertical: 8),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Container(
                                  width: 311,
                                  padding: EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // First row with name and price
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Container(
                                            width: 200,
                                            child: Text(
                                              item['name'],
                                              maxLines: 1,
                                              style: GoogleFonts.mulish(
                                                fontSize: 17.02,
                                                fontWeight: FontWeight.w400,
                                                color: whiteColor,
                                              ),
                                            ),
                                          ),
                                          Row(
                                            children: [
                                              Text(
                                                "₹${item['price']}",
                                                style: GoogleFonts.mulish(
                                                  fontSize: 15,
                                                  decoration: TextDecoration.lineThrough,
                                                  decorationColor: greyColor,
                                                  fontWeight: FontWeight.w500,
                                                  color: greyColor,
                                                ),
                                              ),
                                              SizedBox(width: 5,),
                                              Text(
                                                "₹${item['sellingPrice']}",
                                                style: GoogleFonts.mulish(
                                                  fontSize: 17,
                                                  fontWeight: FontWeight.w500,
                                                  color: whiteColor,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      SizedBox(
                                        height: 5,
                                      ),
                                      // Second row with packaging info and Add button
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            width: 200,
                                            
                                            child: Text(
                                              item['description'] ??
                                                  'Medicine information',
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: GoogleFonts.mulish(
                                                color: greyColor,
                                                fontSize: 14,
                                              ),
                                            ),
                                          ),
                                          GestureDetector(
                                            onTap: () {
                                              if (!IsInCart) {
                                                didAddToCart(
                                                  userId: User.userId!,
                                                  productId: productId,
                                                );
                                              }
                                            },
                                            child: IsInCart &&CartManager.cartQuantities[productId]!=null &&CartManager.cartQuantities[productId]!>0
                                                ? Container(
                                                    width: 50,
                                                    height: 29,
                                                    decoration: BoxDecoration(
                                                        color: greenColor,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8),
                                                        border: Border.all(
                                                            color: greenColor,
                                                            width: 1)),
                                                    child: FittedBox(
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          IconButton(
                                                              padding:
                                                                  EdgeInsets
                                                                      .zero,
                                                              constraints:
                                                                  BoxConstraints(),
                                                              icon: Icon(
                                                                Icons.remove,
                                                                size:
                                                                    containerHeight *
                                                                        0.06,
                                                                color:
                                                                    whiteColor,
                                                              ),
                                                              onPressed: () {
                                                                DidUpdateQuantity(
                                                                    index,
                                                                    -1,
                                                                    productId);
                                                              }),
                                                         isUpdating[productId]==true?Container(height: 10,width: 10,child: CircularProgressIndicator(color: whiteColor,),): Text(
                                                            '${CartManager.cartQuantities[productId]}',
                                                            style: GoogleFonts
                                                                .mulish(
                                                              color: whiteColor,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontSize:
                                                                  containerHeight *
                                                                      0.05,
                                                            ),
                                                          ),
                                                          IconButton(
                                                              padding:
                                                                  EdgeInsets
                                                                      .zero,
                                                              constraints:
                                                                  BoxConstraints(),
                                                              icon: Icon(
                                                                Icons.add,
                                                                size:
                                                                    containerHeight *
                                                                        0.06,
                                                                color:
                                                                    whiteColor,
                                                              ),
                                                              onPressed: () {
                                                                DidUpdateQuantity(
                                                                    index,
                                                                    1,
                                                                    productId);
                                                              }),
                                                        ],
                                                      ),
                                                    ),
                                                  )
                                                : Container(
                                                    width: 50,
                                                    height: 29,
                                                    decoration: BoxDecoration(
                                                        color: ligtBlackColor,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8),
                                                        border: Border.all(
                                                            color: greenColor,
                                                            width: 1)),
                                                    child: Center(
                                                      child:isAdding[productId]==true?Container(height:10,width: 10, child:CircularProgressIndicator(color: whiteColor,strokeWidth: 2,)) :Text(
                                                        'Add',
                                                        style:
                                                            GoogleFonts.mulish(
                                                          fontSize: 10,
                                                          color: greenColor,
                                                          fontWeight:
                                                              FontWeight.w600,
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
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
