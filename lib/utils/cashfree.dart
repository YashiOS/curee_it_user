import 'dart:convert';

import 'package:cureeit_user_app/BaseUrl.dart';
import 'package:cureeit_user_app/cartManager/cartManager.dart';
import 'package:cureeit_user_app/screens/Order_SuccessScreen.dart';
import 'package:cureeit_user_app/screens/loading.dart';
import 'package:cureeit_user_app/selected_Address/currentAddress.dart';
import 'package:cureeit_user_app/user/user.dart';
import 'package:cureeit_user_app/utils/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cashfree_pg_sdk/api/cferrorresponse/cferrorresponse.dart';
import 'package:flutter_cashfree_pg_sdk/api/cfpayment/cfwebcheckoutpayment.dart';
import 'package:flutter_cashfree_pg_sdk/api/cfpaymentgateway/cfpaymentgatewayservice.dart';
import 'package:flutter_cashfree_pg_sdk/api/cfsession/cfsession.dart';
import 'package:flutter_cashfree_pg_sdk/utils/cfenums.dart';
import 'package:flutter_cashfree_pg_sdk/utils/cfexceptions.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

class CashfreePaymentService {
  final CFPaymentGatewayService cfPaymentGatewayService = CFPaymentGatewayService();
  final BuildContext context;
  late CFEnvironment environment;
  late String total;
   late String shippingAddress;
  late String orderId;
  late String paymentSessionId;
  late double shippingCost;
  late String avlId;

  CashfreePaymentService({
    required this.context,
    required this.avlId,
    required this.shippingAddress,
    required this.shippingCost,
    required this.total,
    required this.environment,
    required this.orderId,
    required this.paymentSessionId,
  });
   Future<void> createCheckout(String total, double shippingCost,
      String shippingAddress, String transactionId, String avlId,) async {
    ;

    try {
     Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => LoadingScreen(),
          fullscreenDialog: true,
        ),
      );
      var url = Uri.parse('$baseUrl/order/createCheckout');
      var request = http.Request('POST', url)
        ..headers.addAll({
          'Content-Type': 'application/json',
        })
        ..body = jsonEncode({
          "userId": User.userId,
          "shippingAddress": shippingAddress,
          "availableId": avlId,
          "userLat": Address.CurrentAddress?["userLat"] ?? 0.0,
          "userLong": Address.CurrentAddress?["userLong"] ?? 0.0,
          "paymentDetails": {
            "gateway": "Paytm",
            "transactionId": transactionId,
            "status": "Paid"
          }
        });

      var response = await http.Client().send(request);

      if (response.statusCode == 200) {

        var responseBody = await response.stream.bytesToString();
        Map<String, dynamic> responseData = jsonDecode(responseBody);

        if (responseData['success'] == true) {
          CartManager.cartQuantities.clear();
            Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OrderSuccessScreen(
                orderId: responseData['data']['availableID'],
              ),
            ),
          );
         
        
        }
      } else {
        var responseBody = await response.stream.bytesToString();
       
        throw Exception('Failed to Create Order --> $responseBody');
      }
    } catch (error) {
      print('Error in Creating Order: $error');
    }
  }

  Future<void> initializeCashfree() async {
    try {
      cfPaymentGatewayService.setCallback(verifyPayment, onError);
    } catch (e) {

      print("Cashfree initialization error: $e");
    }
  }

  void verifyPayment(String orderId) {
    print("hitting creat checkout");
    createCheckout(total, shippingCost, shippingAddress, paymentSessionId, avlId,);
    print("Verify Payment: $orderId");
  }

  void onError(CFErrorResponse errorResponse, String orderId) {
    print(errorResponse.getMessage());
    print("Error while making payment");
  }

  Future<void> webCheckout() async {
    try {
      var session = createSession();
      if (session != null) {
        var cfWebCheckout = CFWebCheckoutPaymentBuilder()
            .setSession(session)
            .build();
        cfPaymentGatewayService.doPayment(cfWebCheckout);
      }
    } on CFException catch (e) {
      print(e.message);
    }
  }

  CFSession? createSession() {
    try {
      return CFSessionBuilder()
          .setEnvironment(environment)
          .setOrderId(orderId)
          .setPaymentSessionId(paymentSessionId)
          .build();
    } on CFException catch (e) {
      print(e.message);
    }
    return null;
  }
}
