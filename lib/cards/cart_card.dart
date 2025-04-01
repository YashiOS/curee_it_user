import 'package:cureeit_user_app/screens/item_detail_screen.dart';
import 'package:cureeit_user_app/utils/theme.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CartCard extends StatefulWidget {
  final String productName;
  final String packLabel;
  final int quantity;
  final String productId;
  final double sellingPrice;
  final Function onUpdate;
  final Function onRemove;
  final List<dynamic> productImages;

  const CartCard(
      {super.key,
      required this.productName,
      required this.packLabel,
      required this.quantity,
      required this.productId,
      required this.sellingPrice,
      required this.onUpdate,
      required this.onRemove,
      required this.productImages});

  @override
  State<CartCard> createState() => _CartCardState();
}

class _CartCardState extends State<CartCard> {
  Future<void> _updateQuantity(int quantity) async {
    final String userId = "68fa72cbdc5f0a68"; // Example userId
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

      if (response.statusCode == 200) {
        widget.onUpdate();
        // Optionally, handle the success, e.g., show a success message
      } else {
        print('Failed to update quantity. Status code: ${response.statusCode}');
        // Optionally, handle the error, e.g., show an error message
      }
    } catch (error) {
      print('Error updating quantity: $error');
      // Optionally, handle the error, e.g., show an error message
    }
  }

  Future<void> _removeFromCart() async {
    final String userId = "68fa72cbdc5f0a68"; // Example userId
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
        // Optionally, you can show a success message or update the UI
        // For example, you could navigate back to the previous screen or refresh the cart
      } else {
      }
    } catch (error) {

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
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 10,
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
                                loadingBuilder:
                                    (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return const Center(
                                      child: CircularProgressIndicator(
                                    color: secondaryColor,
                                  ));
                                },
                                errorBuilder: (context, error, stackTrace) {
                                  return const Center(
                                      child: Icon(
                                    Icons.error,
                                    color: Color.fromRGBO(7, 9, 84, 1),
                                  ));
                                },
                              )
                            : Icon(Icons.image))),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ItemDetailScreen(
                                  productId: widget.productId,
                                )));
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: MediaQuery.of(context).size.width / 3,
                        child: Text(
                          widget.productName,
                          style: TextStyle(
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
                          style: TextStyle(
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
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.center,
              spacing: 16,
              children: [
                Container(
                  width: 90,
                  height: 30,
                  decoration: BoxDecoration(
                      color: secondaryColor.withOpacity(0.16),
                      borderRadius: BorderRadius.circular(30)),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () {
                            if (widget.quantity > 1) {
                              _updateQuantity(widget.quantity - 1);
                            } else {
                              _removeFromCart();
                              widget.onRemove;
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
                          "${widget.quantity}",
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                            fontFamily: "Urbanist",
                            color: Color(0xFF1F1970),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            _updateQuantity(widget.quantity + 1);
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
                SizedBox(
                  width: 48,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        "₹ ${((widget.sellingPrice * 0.7 ?? 0) * widget.quantity.toDouble()).toString()}",
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 12,
                          fontFamily: "Urbanist",
                          color: Color(0xFF1F1970),
                        ),
                      ),
                      Text(
                        "₹ ${(widget.sellingPrice * widget.quantity.toDouble()).toString()}",
                        style: TextStyle(
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
            )
          ],
        ),
      ),
    );
  }
}
