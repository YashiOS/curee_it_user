import 'package:cureeit_user_app/screens/home/domain/entities/orderEntity.dart';
import 'package:cureeit_user_app/screens/order again/presentation/provider/reorderProvider.dart';
import 'package:cureeit_user_app/screens/order_tracking_screen.dart';
import 'package:cureeit_user_app/screens/otp/presentation/provider/otpProvider.dart';
import 'package:cureeit_user_app/utils/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class OrderCard extends ConsumerWidget {
  final OrderEntity orderData;
  final String AvailorderId;

  const OrderCard({
    super.key,
    required this.AvailorderId,
    required this.orderData,
  });

  String formatDate(String isoDate) {
    DateTime dateTime = DateTime.parse(isoDate);
    return DateFormat("d MMMM yyyy, h:mm a").format(dateTime);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reorderState = ref.watch(reorderNotifierProvider);
    final reorderNotifier = ref.read(reorderNotifierProvider.notifier);
    final userId = ref.read(OtpNotifierProvider).user!.userId;

    String orderStatus = orderData.status;
    dynamic purchaseDate = orderData.purchaseDate;
    String finalTotal = orderData.finalTotal.toString();
    List orderItems = orderData.products;
    String allItems = formatOrderItems(orderItems);

    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        margin: EdgeInsets.only(left: 18,right: 18),
        decoration: BoxDecoration(
          
          borderRadius: BorderRadius.circular(8),
          color: lightWhiteColor,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// ----------- HEADER -----------
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 165,
                      child: Text(
                        allItems,
                        maxLines: 1,
                        style: GoogleFonts.mulish(
                          fontSize: 17.02,
                          fontWeight: FontWeight.w600,
                          color: blackColor,
                        ),
                      ),
                    ),
                    Text(
                      formatDate(purchaseDate),
                      style: GoogleFonts.mulish(
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                        color: greyColor,
                      ),
                    ),
                  ],
                ),
                if (orderStatus != "In Review" || orderStatus != "Available")
                  Text(
                    "₹$finalTotal",
                    style: GoogleFonts.mulish(
                      fontWeight: FontWeight.w500,
                      fontSize: 17,
                      color: blackColor,
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 10),

            /// ----------- ACTION BUTTON -----------
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                GestureDetector(
                  onTap: reorderState.isLoading
                      ? null
                      : () async {
                          if (orderStatus == "Available") {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => OrderTrackingScreen(
                                  NavigatingFrom: "Order History",
                                  orderId: AvailorderId,
                                ),
                              ),
                            );
                          }
                          if (orderStatus == "Delivered" ||
                              orderStatus.isEmpty) {
                            await reorderNotifier.reorderItems(
                              context,
                              orderItems,
                              userId,
                            );
                          }
                        },
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    decoration: BoxDecoration(
                      color: orderStatus == "Delivered" ||
                              orderStatus == "" ||
                              orderStatus == "Available"
                          ? greenColor
                          : lightWhiteColor,
                      border: orderStatus != "Delivered"
                          ? Border.all(color: greenColor, width: 1)
                          : Border.all(color: Colors.white, width: 0),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _getStatusText(orderStatus),
                      style: GoogleFonts.mulish(
                        fontWeight: FontWeight.bold,
                        fontSize:
                            MediaQuery.of(context).size.height * 0.014,
                        color: orderStatus == "Delivered" ||
                                orderStatus == "" ||
                                orderStatus == "Available"
                            ? Colors.white
                            : greenColor,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getStatusText(String status) {
    switch (status) {
      case "Delivered":
      case "":
        return "Reorder";
      case "In Review":
        return "Verifying";
      case "Order Placed":
        return "Ordered";
      case "On the way":
        return "Enroute";
      case "Available":
        return "Track";
      default:
        return status;
    }
  }

  String formatOrderItems(List orderItems) {
    String allItems = "";
    for (int i = 0; i < orderItems.length; i++) {
      var item = orderItems[i];
      String productId = item['productName'];
      int quantity = item['quantity'];

      if (i > 0) allItems += ", ";
      allItems += "$productId ($quantity)";
    }
    return allItems;
  }
}
