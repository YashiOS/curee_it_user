import 'package:cureeit_user_app/screens/cart_screen.dart';
import 'package:cureeit_user_app/screens/order_tracking_screen.dart';
import 'package:cureeit_user_app/utils/theme.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class OrderSuccessScreen extends StatefulWidget {
  final String orderId;
  OrderSuccessScreen({super.key, required this.orderId});
  @override
  _OrderSuccessScreenState createState() => _OrderSuccessScreenState();
}

class _OrderSuccessScreenState extends State<OrderSuccessScreen> {
  @override
  void initState() {
    super.initState();
    
    Future.delayed(Duration(seconds: 4), () {
      Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (context) => OrderTrackingScreen(
                NavigatingFrom: "Order_SuccessScreen",
                orderId: widget.orderId,
              )));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: scaffoldBlackColor,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Lottie.asset(
              'lib/images/Success_order.json',
              width: 350,
              height: 350,
              repeat: true,
            ),
            Text(
              'Order placed successfully!',
              style: TextStyle(
                fontSize: 45,
                fontWeight: FontWeight.w800,
                color: greyColor,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
