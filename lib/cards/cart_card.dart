import 'package:cureeit_user_app/screens/item_detail_screen.dart';
import 'package:cureeit_user_app/utils/theme.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

class CartCard extends StatefulWidget {
  final String productName;
  final String packLabel;
  final int quantity;
  final String productId;
  final double sellingPrice;
  final Function onUpdate;
  final Function onRemove;
  final Function reBuild;
  final List<dynamic> productImages;
  final Function isDeleting;

  const CartCard(
      {super.key,
      required this.productName,
      required this.packLabel,
      required this.quantity,
      required this.productId,
      required this.sellingPrice,
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
    if (isUpdating) return;
    if (newQuantity == _localQuantity) return;
    setState(() {
      _localQuantity = newQuantity;
      isUpdating = true;
    });

    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      _updateQuantity(newQuantity);
    });
  }

  Future<void> _updateQuantity(int quantity) async {
    final String userId = "68fa72cbdc5f0a68";
    final String productId = widget.productId;
    if (_lastSentQuantity == quantity) return;
    _lastSentQuantity = quantity;

    final Map<String, dynamic> requestData = {
      "userId": userId,
      "productId": productId,
      "quantity": quantity
    };

    final url =
        'http://ec2-13-60-8-94.eu-north-1.compute.amazonaws.com:3000/cart/updateQuantity';
    try {
      final response = await http.put(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(requestData),
      );
      print("Quantity in API is $quantity");
      if (response.statusCode == 200) {
        print("sucessfully updated");

        await widget.onUpdate();
        setState(() {
          isUpdating = false;
        });
      } else {
        print(
            'Failed to update quantity. Status code: ${response.statusCode} ');
      }
    } catch (error) {
      print('Error updating quantity: $error');
    }
  }

  Future<void> _removeFromCart() async {
    widget.isDeleting(true);
    final String userId = "68fa72cbdc5f0a68";
    final String productId = widget.productId;

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
        widget.isDeleting(false);
        widget.onRemove();
      } else {
        print(response.statusCode);
        widget.isDeleting(false);
        print('Failed to remove from cart');
      }
    } catch (error) {
      widget.isDeleting(false);
      print('Error removing from cart: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Padding(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).size.height * 0.035,
        bottom: MediaQuery.of(context).size.height * 0.018,
      ),
      child: Container(
        padding:
            EdgeInsets.only(right: MediaQuery.of(context).size.width * 0.03),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            /// LEFT SECTION - Image + Name + Label
            Expanded(
              child: Row(
                children: [
                  // Product Image
                  SizedBox(
                    height: MediaQuery.of(context).size.width * 0.1,
                    width: MediaQuery.of(context).size.width * 0.1,
                    child: widget.productImages.isNotEmpty
                        ? Image.network(
                            widget.productImages[0],
                            fit: BoxFit.contain,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return const Center(
                                child: CircularProgressIndicator(
                                  color: greenColor,
                                ),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(Icons.error, color: Colors.red);
                            },
                          )
                        : const Icon(Icons.image),
                  ),
                  const SizedBox(width: 10),

                  /// Product Info
                  Expanded(
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
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize:
                                  MediaQuery.of(context).size.height * 0.0175,
                              fontFamily: "JosefinSans",
                              color: whiteColor,
                            ),
                          ),
                          Text(
                            widget.packLabel,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontWeight: FontWeight.w400,
                              fontSize:
                                  MediaQuery.of(context).size.height * 0.015,
                              fontFamily: "JosefinSans",
                              color: whiteColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            /// RIGHT SECTION - Quantity control + price
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Quantity Control
                Container(
                  width: MediaQuery.of(context).size.width * 0.25,
                  height: MediaQuery.of(context).size.height * 0.04,
                  decoration: BoxDecoration(
                    color: greenColor,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
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
                          child: Icon(
                            Icons.remove, // Flutter's built-in minus icon
                            color: Colors.white, // Makes icon white
                            size: screenHeight *
                                0.03, // Matches your original image height
                          )),
                      isUpdating
                          ? SizedBox(
                              height: 14,
                              width: 14,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: whiteColor, // matching the text color
                              ),
                            )
                          : Text(
                              "$_localQuantity",
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
                                fontFamily: "Urbanist",
                                color: whiteColor,
                              ),
                            ),
                      GestureDetector(
                        onTap: () {
                          if (isUpdating == false) {
                            _onQuantityChanged(_localQuantity + 1);
                          }
                        },
                        child: Icon(
                            Icons.add, // Flutter's built-in minus icon
                            color: Colors.white, // Makes icon white
                            size: screenHeight *
                                0.03, // Matches your original image height
                          ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),

                // Price Column
                Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      "₹ ${((widget.sellingPrice * 0.7) * _localQuantity).toStringAsFixed(2)}",
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: screenWidth * 0.03,
                        fontFamily: "Urbanist",
                        color:whiteColor,
                      ),
                    ),
                    Text(
                      "₹ ${(widget.sellingPrice * _localQuantity).toString()}",
                      style: TextStyle(
                        decoration: TextDecoration.lineThrough,
                        fontWeight: FontWeight.w500,
                        fontSize: screenWidth * 0.025,
                        fontFamily: "Urbanist",
                        color: greyColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
