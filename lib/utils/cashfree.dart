import 'package:flutter/material.dart';
import 'package:flutter_cashfree_pg_sdk/api/cferrorresponse/cferrorresponse.dart';
import 'package:flutter_cashfree_pg_sdk/api/cfpayment/cfwebcheckoutpayment.dart';
import 'package:flutter_cashfree_pg_sdk/api/cfpaymentgateway/cfpaymentgatewayservice.dart';
import 'package:flutter_cashfree_pg_sdk/api/cfsession/cfsession.dart';
import 'package:flutter_cashfree_pg_sdk/utils/cfenums.dart';

class CashfreePaymentService {
  final CFPaymentGatewayService cfPaymentGatewayService =
      CFPaymentGatewayService();

  final BuildContext context;
  final CFEnvironment environment;
  final String orderId;
  final String paymentSessionId;

  final void Function(String orderId) onVerifyPayment;
  final void Function(String error) onErrorPayment;

  CashfreePaymentService({
    required this.context,
    required this.environment,
    required this.orderId,
    required this.paymentSessionId,
    required this.onVerifyPayment,
    required this.onErrorPayment,
  });

  Future<void> initializeCashfree() async {
    try {
      cfPaymentGatewayService.setCallback(onVerifyPayment, _onError);
    } catch (e) {
      print("Cashfree initialization error: $e");
    }
  }

  Future<void> webCheckout() async {
    try {
      final session = CFSessionBuilder()
          .setEnvironment(environment)
          .setOrderId(orderId)
          .setPaymentSessionId(paymentSessionId)
          .build();

      final cfWebCheckout = CFWebCheckoutPaymentBuilder()
          .setSession(session)
          .build();

      await cfPaymentGatewayService.doPayment(cfWebCheckout);
    } catch (e) {
      print("Error starting Cashfree checkout: $e");
    }
  }

  void _onError(CFErrorResponse errorResponse, String orderId) {
    onErrorPayment(errorResponse.getMessage() ?? 'Unknown error');
  }
}
