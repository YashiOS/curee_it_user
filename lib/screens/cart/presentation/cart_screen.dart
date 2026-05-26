import 'package:cureeit_user_app/screens/cart/presentation/provider/payment_provider.dart';
import 'package:cureeit_user_app/screens/cart/presentation/provider/prescription_provider.dart';
import 'package:cureeit_user_app/screens/cart/presentation/widget/cart_card.dart';

import 'package:cureeit_user_app/screens/cart/presentation/widget/upload_prescription.dart';
import 'package:cureeit_user_app/screens/home/presentation/providers/address_provider.dart';
import 'package:cureeit_user_app/screens/home/presentation/providers/cart_provider.dart';

import 'package:cureeit_user_app/screens/base_screen.dart';
import 'package:cureeit_user_app/screens/otp/presentation/provider/otpProvider.dart';

import 'package:cureeit_user_app/utils/theme.dart';
import 'package:dotted_line/dotted_line.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';

import 'package:flutter/material.dart';

import 'package:google_fonts/google_fonts.dart';

import 'package:shimmer/shimmer.dart';

class CartScreen extends ConsumerWidget {
  final isNavigated;
  const CartScreen({super.key, required this.isNavigated});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final prescriptionState = ref.watch(prescriptionProvider);
    final addressState = ref.watch(addressNotifierProvider);
    final userState = ref.watch(OtpNotifierProvider);
    final cartState = ref.watch(cartNotifierProvider);
    final cartItems = cartState.cartItems;
    return Stack(
      children: [
        Scaffold(
          backgroundColor: textFieldFillColor,
          appBar: AppBar(
            scrolledUnderElevation: 0,
            elevation: 0,
            centerTitle: true,
            backgroundColor: WhiteColor,
            shape: ContinuousRectangleBorder(
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(10),
                bottomRight: Radius.circular(10),
              ),
            ),
            title: Text(
              "Cart",
              style: GoogleFonts.mulish(
                fontWeight: FontWeight.w500,
                fontSize: 22.69,
                color: blackColor,
              ),
            ),
            leading: GestureDetector(
              onTap: () {
                if (isNavigated) {
                  Navigator.pop(context);
                  return;
                }
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => BaseScreen(Navigatedfrom: "")));
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
                            ColorFilter.mode(blackColor, BlendMode.srcIn),
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
          body: cartItems.isEmpty
              ? Container(
                  height: double.infinity,
                  width: double.infinity,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      BaseScreen(Navigatedfrom: "")));
                        },
                        child: Center(
                          child: Container(
                              height: 204,
                              width: 150,
                              child: Image.asset("lib/images/empty cart.png")),
                        ),
                      ),
                    ],
                  ),
                )
              : Container(
                  padding: EdgeInsets.only(bottom: isNavigated ? 20 : 100),
                  color: textFieldFillColor,
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                  child: Stack(
                    children: [
                      ListView(
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            spacing: 5,
                            children: [
                              GestureDetector(
                                onTap: () async {},
                                child: Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.only(
                                      left: 16, right: 16, top: 10, bottom: 10),
                                  margin: EdgeInsets.only(
                                      top: 28, bottom: 10, left: 18, right: 18),
                                  decoration: BoxDecoration(
                                    color: WhiteColor,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "Delivering to",
                                              style: GoogleFonts.mulish(
                                                color: blackColor,
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            SizedBox(height: 4),
                                            Text(
                                              "${addressState.currentAddress!.address}",
                                              style: GoogleFonts.mulish(
                                                color: greyColor,
                                                fontWeight: FontWeight.w600,
                                                fontSize: 13,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        width: 16,
                                        height: 16,
                                        margin: EdgeInsets.only(
                                            left:
                                                8), // Space before trailing widget
                                        decoration: BoxDecoration(
                                          color: greenColor,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              if (cartState.prescription_required)
                                GestureDetector(
                                  onTap: () {
                                    showModalBottomSheet(
                                      isDismissible: true,
                                      enableDrag: true,
                                      context: context,
                                      shape: const RoundedRectangleBorder(
                                        borderRadius: BorderRadius.vertical(
                                            top: Radius.circular(20)),
                                      ),
                                      builder: (_) =>
                                          const UploadPrescriptionBottomSheet(),
                                    );
                                  },
                                  child: Container(
                                    margin: EdgeInsets.only(
                                        bottom: 10, left: 18, right: 18),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16),
                                    height: 56,
                                    decoration: BoxDecoration(
                                      color:
                                          WhiteColor, // or any color you want
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Upload Prescription',
                                          style: GoogleFonts.mulish(
                                            color: blackColor,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        Container(
                                          width: 16,
                                          height: 16,
                                          decoration: BoxDecoration(
                                            color: prescriptionState
                                                        .images.length >
                                                    0
                                                ? greenColor
                                                : scaffoldWhiteColor,
                                            shape: BoxShape.circle,
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                )
                              else
                                SizedBox.shrink(),
                              if (cartState.prescription_required)
                                GestureDetector(
                                  onTap: () {},
                                  child: Container(
                                    margin: EdgeInsets.only(
                                        bottom: 10, left: 18, right: 18),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16),
                                    height: 75,
                                    decoration: BoxDecoration(
                                      color:
                                          WhiteColor, // or any color you want
                                      borderRadius: BorderRadius.circular(8),
                                    ),
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
                                              'Continue without Prescription',
                                              style: GoogleFonts.mulish(
                                                color: greyColor,
                                                fontSize: 16,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            Text(
                                              'We will call you to confirm your order',
                                              style: GoogleFonts.mulish(
                                                color: greyColor,
                                                fontSize: 13,
                                                fontWeight: FontWeight.w300,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Container(
                                          width: 16,
                                          height: 16,
                                          decoration: BoxDecoration(
                                            color: lightWhiteColor,
                                            shape: BoxShape.circle,
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                )
                              else
                                SizedBox.shrink(),
                              Container(
                                margin: EdgeInsets.only(
                                    bottom: 10, left: 18, right: 18),
                                width: MediaQuery.of(context).size.width,
                                decoration: BoxDecoration(
                                    color: WhiteColor,
                                    borderRadius: BorderRadius.circular(8)),
                                child: Stack(
                                  children: [
                                    cartItems.isEmpty
                                        ? SizedBox(
                                            width: MediaQuery.of(context)
                                                .size
                                                .width,
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      vertical: 16.0),
                                                  child: Text(
                                                    "No Items in Cart",
                                                    style: GoogleFonts.mulish(
                                                        fontSize: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width *
                                                            0.07,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color:
                                                            Color(0xFFFFFFFF)),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          )
                                        : Column(
                                            children: [
                                              Column(
                                                children: [
                                                  Column(
                                                    children: cartItems
                                                        .map((item) => CartCard(
                                                              productPrice: item
                                                                  .productPrice,
                                                              productName:
                                                                  item.name,
                                                              packLabel: item
                                                                  .productMarketer,
                                                              quantity:
                                                                  item.quantity,
                                                              productId: item
                                                                  .productId,
                                                              sellingPrice: item
                                                                  .sellingPrice,
                                                            ))
                                                        .toList(),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                  ],
                                ),
                              ),
                              Container(
                                  margin: EdgeInsets.only(
                                      bottom: 10, left: 18, right: 18),
                                  decoration: BoxDecoration(
                                    color: WhiteColor, // or any color you want
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Padding(
                                    padding: EdgeInsets.only(
                                      right: MediaQuery.of(context).size.width *
                                          0.055,
                                      left: MediaQuery.of(context).size.width *
                                          0.055,
                                      top: screenHeight *
                                          0.023, // ≈28 for height ≈ 800
                                      bottom: screenHeight * 0.035, // ≈14
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      spacing: 10,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              "Item Total",
                                              style: GoogleFonts.mulish(
                                                fontWeight: FontWeight.w300,
                                                fontSize: 14,
                                                color: blackColor,
                                              ),
                                            ),
                                            Container(
                                              child: Text(
                                                "₹${cartState.total}",
                                                style: GoogleFonts.mulish(
                                                    fontWeight: FontWeight.w400,
                                                    fontSize: 14,
                                                    color: blackColor),
                                              ),
                                            ),
                                          ],
                                        ),
                                        DottedLine(
                                          dashLength: 2,
                                          dashGapLength: 4,
                                          lineThickness: 0.5,
                                          dashColor: greyColor,
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Row(
                                              spacing: screenWidth * 0.05,
                                              children: [
                                                Text(
                                                  "Delivery Fee",
                                                  style: GoogleFonts.mulish(
                                                    fontWeight: FontWeight.w400,
                                                    fontSize: 12,
                                                    color: greyColor,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Text(
                                              "₹${cartState.deliveryFee}",
                                              style: GoogleFonts.mulish(
                                                fontWeight: FontWeight.w400,
                                                fontSize: 12,
                                                color: greyColor,
                                              ),
                                            ),
                                          ],
                                        ),
                                     
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Row(
                                              spacing: screenWidth * 0.05,
                                              children: [
                                                Text(
                                                  "GST and Platform Fees",
                                                  style: GoogleFonts.mulish(
                                                    fontWeight: FontWeight.w400,
                                                    fontSize: 12,
                                                    color: greyColor,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Text(
                                              "₹${cartState.tax}",
                                              style: GoogleFonts.mulish(
                                                fontWeight: FontWeight.w400,
                                                fontSize: 12,
                                                color: greyColor,
                                              ),
                                            ),
                                          ],
                                        ),
                                        DottedLine(
                                          dashLength: 2,
                                          dashGapLength: 4,
                                          lineThickness: 0.5,
                                          dashColor: greyColor,
                                        ),
                                        Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        "To Pay",
                                                        style:
                                                            GoogleFonts.mulish(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 16,
                                                          color: blackColor,
                                                        ),
                                                      ),
                                                      if (cartState.isLoading)
                                                        const SizedBox(
                                                            height: 2),
                                                      if (cartState.isLoading)
                                                        Shimmer.fromColors(
                                                          baseColor:
                                                              lightWhiteColor,
                                                          highlightColor:
                                                              greenColor,
                                                          child: Container(
                                                            decoration:
                                                                BoxDecoration(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          5),
                                                              color: greenColor,
                                                            ),
                                                            width:
                                                                50, // or adjust as needed to match "To Pay" width
                                                            height: 4,
                                                          ),
                                                        ),
                                                    ],
                                                  ),
                                                  Text(
                                                    "₹${cartState.finalTotal}",
                                                    style: GoogleFonts.mulish(
                                                      fontWeight:
                                                          FontWeight.w700,
                                                      fontSize: 15,
                                                      color: blackColor,
                                                    ),
                                                  ),
                                                ]),
                                            SizedBox(
                                              height: 22,
                                            ),
                                            GestureDetector(
                                              onTap: () async {
                                                final total =
                                                    cartState.finalTotal;
                                                final userId =
                                                    userState.user!.userId;
                                                final shippingCost =
                                                    cartState.deliveryFee;
                                                final shippingAddress =
                                                    addressState.currentAddress!
                                                        .address;
                                                final availableId =
                                                    prescriptionState
                                                        .AvailableId;
                                                final userLat = addressState
                                                    .currentAddress!.userLat;
                                                final userLong = addressState
                                                    .currentAddress!.userLong;
                                                await ref
                                                    .read(paymentProvider
                                                        .notifier)
                                                    .getPaymentSessionAndStart(
                                                        total: total,
                                                        userId: userId,
                                                        shippingCost:
                                                            shippingCost,
                                                        shippingAddress:
                                                            shippingAddress,
                                                        availableId:
                                                            availableId,
                                                        context: context,
                                                        userLat: userLat,
                                                        userLong: userLong);
                                              },
                                              child: Container(
                                                height: 36,
                                                width: double.infinity,
                                                alignment: Alignment.center,
                                                decoration: BoxDecoration(
                                                  color:
                                                      prescriptionState.payNow
                                                          ? greenColor
                                                          : lightWhiteColor,
                                                  border: Border.all(
                                                    color: greenColor,
                                                    width: 1,
                                                  ),
                                                  // Setting the background color to primary color
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          8), // Setting the border radius to 10
                                                ),
                                                child: Center(
                                                  child: Text(
                                                    "Confirm And Pay",
                                                    style: GoogleFonts.mulish(
                                                      color: prescriptionState
                                                              .payNow
                                                          ? blackColor
                                                          : greenColor,
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.w700,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ))
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
        ),
      ],
    );
  }
}
