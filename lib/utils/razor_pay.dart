import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:flutter/material.dart';

class RazorpayPayment {
  late Razorpay _razorpay;

  // Adding the callbacks as parameters
  final Function(PaymentSuccessResponse)? onSuccess;
  final Function(PaymentFailureResponse)? onFailure;

  RazorpayPayment({
    this.onSuccess,
    this.onFailure,
  }) {
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
  }

  // Handle payment success
  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    if (onSuccess != null) {
      onSuccess!(response); // Call the passed callback function for success
    }
  }

  // Handle payment failure
  void _handlePaymentError(PaymentFailureResponse response) {
    if (onFailure != null) {
      onFailure!(response);
    }
  }

  void initiatePayment(int amount, String name, String description, String contact, String email) {
    var options = {
      'key': "rzp_test_zVbDkK876DXdvr", 
      'amount': amount, 
      'name': name,
      'description': description,
      'prefill': {
        'contact': contact,
        'email': email, 
      },
      'theme': {
        'color': '#F37254', 
      }
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      print(e.toString());
    }
  }

  // Dispose the Razorpay instance when not needed
  void dispose() {
    _razorpay.clear();
  }
}
