import 'package:cureeit_user_app/BaseUrl.dart';
import 'package:cureeit_user_app/cartManager/cartManager.dart';
import 'package:cureeit_user_app/screens/item_detail_screen.dart';
import 'package:cureeit_user_app/user/user.dart';
import 'package:cureeit_user_app/utils/theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

class HandlingUpdate{
  static bool isUpdating=false;
}

class CartCard extends StatefulWidget {
  final String productName;
  final String packLabel;
  final int quantity;
  final String productId;
  final double sellingPrice;
  final double productPrice;
  final Function onUpdate;
  final Function onRemove;
  final Function reBuild;
  final List<dynamic> productImages;
  final Function isDeleting;
 

   CartCard(
      {super.key,
     
      required this.productName,
      required this.packLabel,
      required this.quantity,
      required this.productId,
      required this.sellingPrice,
      required this.productPrice,
      required this.onUpdate,
      required this.onRemove,
      required this.productImages,
      required this.reBuild,
      required this.isDeleting});

  @override
  State<CartCard> createState() => _CartCardState();
}

class _CartCardState extends State<CartCard> {
  int _lastSentQuantity = -1;
  late int _localQuantity;
  Timer? _debounceTimer;
  bool isUpdating = false;

  @override
  void initState() {
    super.initState();
    _localQuantity = widget.quantity;
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant CartCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.quantity != oldWidget.quantity) {
      setState(() {
        _localQuantity = widget.quantity;
      });
    }
  }

  void _onQuantityChanged(int newQuantity) async {
    if (newQuantity == _localQuantity) return;
    setState(() {
      _localQuantity = newQuantity;
     HandlingUpdate.isUpdating=true;
     
    });
    
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(seconds: 1), () {
      _updateQuantity(newQuantity);
    });
  }

  Future<void> _updateQuantity(int quantity) async {
    widget.reBuild;
    final String userId = User.userId!;
    final String productId = widget.productId;
    if (_lastSentQuantity == quantity) return;
    _lastSentQuantity = quantity;
    CartManager.cartQuantities[productId] = quantity;
    final Map<String, dynamic> requestData = {
      "userId": userId,
      "productId": productId,
      "quantity": quantity
    };

    final url = '$baseUrl/cart/updateQuantity';
    try {
      final response = await http.put(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(requestData),
      );

      if (response.statusCode == 200) {
        await widget.onUpdate();
       
         HandlingUpdate.isUpdating=false;
      

      } else {
        setState(() {
          CartManager.cartQuantities[productId] = _lastSentQuantity;
          HandlingUpdate.isUpdating=false;
        
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Failed to update quantity !",
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
        print(
            'Failed to update quantity. Status code: ${response.statusCode} ');
      }
    } catch (error) {
      CartManager.cartQuantities[productId] = _lastSentQuantity;
      print('Error updating quantity: $error');
    }
  }

  Future<void> _removeFromCart() async {
    widget.isDeleting(true);
    final String userId = User.userId!;
    final String productId = widget.productId;

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

        await widget.onRemove();
        widget.isDeleting(false);
      } else {
        widget.isDeleting(false);
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
      widget.isDeleting(false);
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

  @override
  Widget build(BuildContext context) {
   

    return Padding(
      padding: EdgeInsets.only(
        top: 5,
      ),
      child: Container(
        padding: EdgeInsets.only(
            right: MediaQuery.of(context).size.width * 0.055,
            left: MediaQuery.of(context).size.width * 0.03),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            /// LEFT SECTION - Image + Name + Label
            Row(
              children: [
                SizedBox(
                  width: 10,
                ),
                // Product Image

                /// Product Info
                Container(
                  width: 135,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              ItemDetailScreen(productId: widget.productId),
                        ),
                      );
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.productName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.mulish(
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                            color: whiteColor,
                          ),
                        ),
                        Text(
                          widget.packLabel,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.mulish(
                            fontWeight: FontWeight.w400,
                            fontSize:
                                MediaQuery.of(context).size.height * 0.015,
                            color: greyColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            /// RIGHT SECTION - Quantity control + price
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Quantity Control
                Container(
                  width: MediaQuery.of(context).size.width * 0.15,
                  height: 28,
                  decoration: BoxDecoration(
                    color: greenColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Row(
                      // Changed to spaceBetween
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment
                          .spaceEvenly, // Added for vertical centering
                      children: [
                        GestureDetector(
                          onTap: () {
                            if (widget.quantity == 1 || _localQuantity == 1) {
                              _removeFromCart();
                            }
                            if (_localQuantity > 1 && isUpdating == false) {
                              _onQuantityChanged(_localQuantity - 1);
                            }
                          },
                          child: Container(
                            height: 28, // Match parent height
                            width: 24, // Keep your original width
                            alignment: Alignment.center, // Center the icon
                            child: Icon(
                              Icons.remove,
                              size: 18, // Explicit size
                              color: Colors.white,
                            ),
                          ),
                        ),
                        Text(
                          "$_localQuantity",
                          style: GoogleFonts.mulish(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            color: whiteColor,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            if (isUpdating == false) {
                              _onQuantityChanged(_localQuantity + 1);
                            }
                          },
                          child: Container(
                            height: 28, // Match parent height
                            width: 24, // Keep your original width
                            alignment: Alignment.center, // Center the icon
                            child: Icon(
                              Icons.add,
                              size: 18, // Explicit size
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Price Column
                Container(
                  width: MediaQuery.of(context).size.width *
                      0.18, // ~70 if screen is ~390px wide

                  height: 60,

                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "₹${(widget.productPrice * _localQuantity).toStringAsFixed(2)}",
                            style: GoogleFonts.mulish(
                                color: greyColor,
                                decoration: TextDecoration.lineThrough,
                                fontSize: 10,
                                decorationColor: greyColor),
                          ),
                          Text(
                            "₹${((widget.sellingPrice) * _localQuantity).toStringAsFixed(2)}",
                            style: GoogleFonts.mulish(
                              fontWeight: FontWeight.w300,
                              fontSize: 13.78,
                              color: whiteColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
