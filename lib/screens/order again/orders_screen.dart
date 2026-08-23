
import 'package:cureeit_user_app/screens/order%20again/presentation/widget/order_card.dart';
import 'package:cureeit_user_app/screens/base_screen.dart';
import 'package:cureeit_user_app/screens/home/presentation/providers/order_provider.dart';
import 'package:cureeit_user_app/screens/order_tracking_screen.dart';

import 'package:cureeit_user_app/utils/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';


class OrdersScreen extends ConsumerWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orderState = ref.watch(orderNotifierProvider);


    // Fetch orders once when screen opens
    ref.listenManual(orderNotifierProvider, (previous, next) {
      // optional: handle side effects here if needed
    });

    return Scaffold(
      backgroundColor:Colors.black,
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        backgroundColor: blackColor,
        shape: const ContinuousRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(10),
            bottomRight: Radius.circular(10),
          ),
        ),
        title: Text(
          "Order Again",
          style: GoogleFonts.mulish(
            fontWeight: FontWeight.w500,
            fontSize: 22.69,
            color: WhiteColor,
          ),
        ),
        leading: GestureDetector(
          onTap: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const BaseScreen(Navigatedfrom: ""),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.only(left: 24.0),
            child: Row(
              spacing: 4,
              children: [
                SvgPicture.asset(
                  "lib/images/back.svg",
                  colorFilter:
                      const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                  width: 24,
                  height: 24,
                ),
              ],
            ),
          ),
        ),
      ),
      body: orderState.isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Colors.white),
            )
          : orderState.allOrders.isEmpty
              ? Center(
                  child: Text(
                    "No Orders!",
                    style: GoogleFonts.mulish(
                      fontWeight: FontWeight.w500,
                      fontSize: 20,
                      color: WhiteColor.withValues(alpha: 0.5),
                    ),
                  ),
                )
              : Container(
                  margin: EdgeInsets.only(
                    top: 12,
                    bottom: MediaQuery.of(context).size.height * 0.11,
                  ),
                  
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                  color: Colors.black,
                  child: ListView.builder(
                    itemCount: orderState.allOrders.length,
                    itemBuilder: (context, index) {
                      final order = orderState.allOrders[index];
                      return GestureDetector(
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => OrderTrackingScreen(
                                NavigatingFrom: "Order History",
                                orderId: order.availableId,
                              ),
                            ),
                          );                         
                        },
                        child: OrderCard(
                          AvailorderId: order.availableId,                         
                          orderData:order,
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
