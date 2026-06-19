import 'package:cureeit_user_app/screens/home/presentation/providers/cart_provider.dart';
import 'package:cureeit_user_app/screens/item_detail_screen.dart';
import 'package:cureeit_user_app/screens/otp/presentation/provider/otpProvider.dart';

import 'package:cureeit_user_app/utils/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

class CartCard extends ConsumerWidget {
  final String productName;
  final String packLabel;
  final int quantity;
  final String productId;
  final double sellingPrice;
  final double productPrice;
  CartCard({
    super.key,
    required this.productName,
    required this.packLabel,
    required this.quantity,
    required this.productId,
    required this.sellingPrice,
    required this.productPrice,
  });

  String capitalizeFirst(String text) {
  if (text.isEmpty) return text;
  return text[0].toUpperCase() + text.substring(1).toLowerCase();
}


  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartNotifier = ref.read(cartNotifierProvider.notifier);
    final userId = ref.read(OtpNotifierProvider).user!.userId;
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
                              ItemDetailScreen(productId: productId),
                        ),
                      );
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          capitalizeFirst(productName),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.mulish(
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                            color: WhiteColor,
                          ),
                        ),
                        Text(
                          capitalizeFirst(packLabel),
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
                            final value = quantity - 1;
                            if (value == 0) {
                              cartNotifier.removeFromCart(userId, productId);
                              return;
                            }
                            cartNotifier.updateCartQuantity(
                                userId, productId, value);
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
                          "$quantity",
                          style: GoogleFonts.mulish(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            color: homepageWhite,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            final value = quantity + 1;
                            cartNotifier.updateCartQuantity(
                                userId, productId, value);
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
                            "₹$productPrice",
                            style: GoogleFonts.mulish(
                                color: greyColor,
                                decoration: TextDecoration.lineThrough,
                                fontSize: 10,
                                decorationColor: Colors.white),
                          ),
                          Text(
                            "₹$sellingPrice",
                            style: GoogleFonts.mulish(
                              
                               fontWeight: FontWeight.w700,
                              fontSize: 13,
                              color: WhiteColor,
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
