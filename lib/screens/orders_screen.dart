import 'package:cureeit_user_app/cards/order_card.dart';
import 'package:cureeit_user_app/utils/theme.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  List<dynamic> orders = [];
  bool isLoading = true;

  Future<void> fetchOrderHistory() async {
    var url = Uri.parse(
        'http://ec2-13-60-8-94.eu-north-1.compute.amazonaws.com:3000/order/orderHistory');
    var request = http.Request('GET', url)
      ..headers.addAll({
        'Content-Type': 'application/json',
      })
      ..body = jsonEncode({'userId': "68fa72cbdc5f0a68"});

    var response = await http.Client().send(request);

    if (response.statusCode == 200) {
      var responseBody = await response.stream.bytesToString();
      Map<String, dynamic> data = jsonDecode(responseBody);

      setState(() {
        orders = data['data'];
        isLoading = false;
      });
    } else {
      throw Exception('Failed to load order history');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchOrderHistory();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey.shade100.withOpacity(0.5),
        leadingWidth: 200,
        toolbarHeight: 60,
        leading: Padding(
          padding: const EdgeInsets.only(left: 12.0, top: 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 20,
            children: [
              Text(
                "Orders",
                style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 24,
                    fontFamily: "JosefinSans",
                    color: primaryColor),
              ),
            ],
          ),
        ),
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(
              color: secondaryColor,
            )) // Show loader while data is loading
          : Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              color: Colors.grey.shade100.withOpacity(0.5),
              child: Padding(
                padding: const EdgeInsets.only(
                    top: 6.0, left: 18, right: 18, bottom: 60),
                child: ListView.builder(
                  itemCount:
                      orders.length, // Use the length of the orders array
                  itemBuilder: (context, index) {
                    return OrderCard(
                        orderData:
                            orders[index]); // Pass the order data to the card
                  },
                ),
              ),
            ),
    );
  }
}
