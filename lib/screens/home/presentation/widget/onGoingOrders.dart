import 'package:cureeit_user_app/screens/home/domain/entities/orderEntity.dart';
import 'package:cureeit_user_app/screens/order_tracking_screen.dart';
import 'package:cureeit_user_app/utils/theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';


class OngoingOrdersSection extends StatefulWidget {
  final List<OrderEntity> onGoingOrders;

  const OngoingOrdersSection({
    Key? key,
    required this.onGoingOrders,
  }) : super(key: key);

  @override
  State<OngoingOrdersSection> createState() => _OngoingOrdersSectionState();
}

class _OngoingOrdersSectionState extends State<OngoingOrdersSection> {
  late final PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.onGoingOrders.isEmpty) return const SizedBox.shrink();

    return Container(
      height: 84,
     decoration: BoxDecoration(
  color: lightGreenColor,
  borderRadius: BorderRadius.circular(8),
  border: Border.all(
    color: Colors.lightGreen.withOpacity(0.1), // or use your custom light green color
    width: 1,
  ),
),

      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              scrollDirection: Axis.horizontal,
              itemCount: widget.onGoingOrders.length,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              itemBuilder: (context, index) {
                final order = widget.onGoingOrders[index];
                final availId = order.availableId;
                String status = switch (order.status) {
                  "Available" => "Order Confirmed",
                  "In Review" => "Verifying Order",
                  "Order Placed" => "Order Placed!",
                  "Packing" => "Packing Items",
                  "On the way" => "Order Enroute",
                  _ => "Order Status",
                };

                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => OrderTrackingScreen(
                                NavigatingFrom: "Order History",
                                orderId: order.availableId,
                              ),
                            ),
                          );              
                  },
                  child: Container(
                    padding: const EdgeInsets.only(
                        left: 16, right: 16, bottom: 6, top: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              status,
                              style: GoogleFonts.mulish(
                                color: blackColor,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              "#$availId",
                              style: GoogleFonts.mulish(
                                color: greyColor,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          height: switch (order.status) {
                            "In Review" => 50,
                            "Order Placed" || "Available" => 36,
                            _ => 80,
                          },
                          child: Image.asset(
                            switch (order.status) {
                              "Available" => "lib/images/ordered.png",
                              "Order Placed" => "lib/images/ordered.png",
                              "Packing" => "lib/images/packing.png",
                              "On the way" => "lib/images/onTheWay.png",
                              "Delivered" => "lib/images/DELIVERED.png",
                              _ => "lib/images/veryfing.png",
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(widget.onGoingOrders.length, (index) {
              return Container(
                margin: const EdgeInsets.only(right: 4),
                width: 4,
                height: 4,
                decoration: BoxDecoration(
                  color: _currentPage == index ? Colors.grey :Colors.white ,
                  shape: BoxShape.circle,
                ),
              );
            }),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}
