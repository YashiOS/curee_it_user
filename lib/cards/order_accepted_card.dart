
import 'package:cureeit_user_app/utils/theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class OrderAcceptedCard extends StatefulWidget {
  final String productName;
  final String marketeproductMarketer;
  final int quantity;
  final String productId;
  final double sellingPrice;
  final double productPrice;

  OrderAcceptedCard({
    super.key,
    required this.productName,
    required this.marketeproductMarketer,
    required this.quantity,
    required this.productId,
    required this.sellingPrice,
    required this.productPrice,
  });

  @override
  State<OrderAcceptedCard> createState() => _OrderCardState();
}

class _OrderCardState extends State<OrderAcceptedCard> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    int quantity=widget.quantity;
    final productPrice = double.tryParse(widget.productPrice.toString()) ?? 0.0;
    final sellingPrice = double.tryParse(widget.sellingPrice.toString()) ?? 0.0;
  
    
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
                        widget.marketeproductMarketer,
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
              ],
            ),

            /// RIGHT SECTION - Quantity control + price
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Quantity Control
                Container(
                  width: 44,
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
                        Text(
                          "${widget.quantity}",
                          style: GoogleFonts.mulish(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            color: whiteColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Price Column
                Container(
                  width: 70,
                  height: 60,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "₹${(productPrice * quantity).toStringAsFixed(2)}",
                            style: GoogleFonts.mulish(
                                color: greyColor,
                                decoration: TextDecoration.lineThrough,
                                fontSize: 10,
                                decorationColor: greyColor),
                          ),
                          Text(
                            "₹${(sellingPrice * quantity).toStringAsFixed(2)}",
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
