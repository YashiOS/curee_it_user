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
  final List<dynamic> productImages;

  const CartCard({
    super.key,
    required this.productName,
    required this.packLabel,
    required this.quantity,
    required this.productId,
    required this.sellingPrice,
    required this.onUpdate,
    required this.onRemove,
    required this.productImages,
  });

  @override
  State<CartCard> createState() => _CartCardState();
}

class _CartCardState extends State<CartCard> {
  late int _localQuantity;
  Timer? _debounceTimer;

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

  void _onQuantityChanged(int newQuantity) {
    setState(() {
      _localQuantity = newQuantity;
    });

    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 800), () {
      _updateQuantity(_localQuantity);
    });
  }

  Future<void> _updateQuantity(int quantity) async {
    final String userId = "68fa72cbdc5f0a68";
    final String productId = widget.productId;

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
        print("Success response is ${response.body}");
        widget.onUpdate();
      } else {
        print(
            'Failed to update quantity. Status code: ${response.statusCode} ${response.body}');
      }
    } catch (error) {
      print('Error updating quantity: $error');
    }
  }

  Future<void> _removeFromCart() async {
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
        widget.onRemove();
      } else {
        print('Failed to remove from cart');
      }
    } catch (error) {
      print('Error removing from cart: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 0.0, right: 0, top: 28, bottom: 14),
      child: Container(
        padding: EdgeInsets.only(right: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 0),
                  child: SizedBox(
                    height: 40,
                    width: 40,
                    child: widget.productImages.isNotEmpty
                        ? Image.network(
                            widget.productImages[0],
                            fit: BoxFit.contain,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return const Center(
                                child: CircularProgressIndicator(
                                  color: secondaryColor,
                                ),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) {
                              return const Center(
                                child: Icon(
                                  Icons.error,
                                  color: Color.fromRGBO(7, 9, 84, 1),
                                ),
                              );
                            },
                          )
                        : const Icon(Icons.image),
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ItemDetailScreen(
                          productId: widget.productId,
                        ),
                      ),
                    );
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: MediaQuery.of(context).size.width / 3,
                        child: Text(
                          widget.productName,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                            fontFamily: "JosefinSans",
                            color: Color(0xFF1F1970),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width / 3,
                        child: Text(
                          widget.packLabel,
                          style: const TextStyle(
                            fontWeight: FontWeight.w400,
                            fontSize: 12,
                            fontFamily: "JosefinSans",
                            color: Color(0xFF1F1970),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
            Row(
              children: [
                Container(
                  width: 90,
                  height: 30,
                  decoration: BoxDecoration(
                    color: secondaryColor.withOpacity(0.16),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () {
                            if (_localQuantity > 1) {
                              _onQuantityChanged(_localQuantity - 1);
                            }
                          },
                          child: Image.asset(
                            "lib/images/minus_button.png",
                            height: 20,
                            width: 20,
                            fit: BoxFit.contain,
                          ),
                        ),
                        Text(
                          "$_localQuantity",
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                            fontFamily: "Urbanist",
                            color: Color(0xFF1F1970),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            _onQuantityChanged(_localQuantity + 1);
                          },
                          child: Image.asset(
                            "lib/images/plus_button.png",
                            height: 20,
                            width: 20,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  alignment: Alignment.centerRight,
                  width: 48,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        "₹ ${((widget.sellingPrice * 0.7) * _localQuantity).toStringAsFixed(2)}",
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 12,
                          fontFamily: "Urbanist",
                          color: Color(0xFF1F1970),
                        ),
                      ),
                      Text(
                        "₹ ${(widget.sellingPrice * _localQuantity).toString()}",
                        style: const TextStyle(
                          decoration: TextDecoration.lineThrough,
                          fontWeight: FontWeight.w500,
                          fontSize: 10,
                          fontFamily: "Urbanist",
                          color: Colors.grey,
                        ),
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
