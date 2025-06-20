import 'package:flutter_cashfree_pg_sdk/api/cferrorresponse/cferrorresponse.dart';
import 'package:flutter_cashfree_pg_sdk/api/cfpayment/cfwebcheckoutpayment.dart';
import 'package:flutter_cashfree_pg_sdk/api/cfpaymentgateway/cfpaymentgatewayservice.dart';
import 'package:flutter_cashfree_pg_sdk/api/cfsession/cfsession.dart';
import 'package:flutter_cashfree_pg_sdk/utils/cfenums.dart';
import 'package:flutter_cashfree_pg_sdk/utils/cfexceptions.dart';

class CashfreePaymentService {
  final CFPaymentGatewayService cfPaymentGatewayService = CFPaymentGatewayService();
  late CFEnvironment environment;
  late String orderId;
  late String paymentSessionId;

  CashfreePaymentService({
    required this.environment,
    required this.orderId,
    required this.paymentSessionId,
  });

  Future<void> initializeCashfree() async {
    try {
      cfPaymentGatewayService.setCallback(verifyPayment, onError);
    } catch (e) {
      print("Cashfree initialization error: $e");
    }
  }

  void verifyPayment(String orderId) {
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
