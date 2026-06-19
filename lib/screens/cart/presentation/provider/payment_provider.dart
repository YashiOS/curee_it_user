// provider/payment_provider.dart
import 'dart:async';
import 'package:cureeit_user_app/Networking/api_service.dart';
import 'package:cureeit_user_app/screens/Order_SuccessScreen.dart';
import 'package:cureeit_user_app/screens/cart/domain/entities/paymentEntity.dart';
import 'package:cureeit_user_app/screens/cart/domain/repositiries/payment/payment_repo_impl.dart';
import 'package:cureeit_user_app/screens/cart/domain/usecases/payment_useCases.dart';
import 'package:cureeit_user_app/screens/cart/presentation/provider/prescription_provider.dart';
import 'package:cureeit_user_app/utils/cashfree.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cashfree_pg_sdk/utils/cfenums.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter_riverpod/legacy.dart';
import 'package:http/http.dart' as http;

class PaymentState {
  final bool loading;
  final bool paymentStarted;
  final String paymentSessionId;
  final String orderId;
  final String error;
  final bool paymentSuccess;

  PaymentState({
    this.loading = false,
    this.paymentStarted = false,
    this.paymentSessionId = '',
    this.orderId = '',
    this.error = '',
    this.paymentSuccess = false,
  });

  PaymentState copyWith({
    bool? loading,
    bool? paymentStarted,
    String? paymentSessionId,
    String? orderId,
    String? error,
    bool? paymentSuccess,
  }) {
    return PaymentState(
      loading: loading ?? this.loading,
      paymentStarted: paymentStarted ?? this.paymentStarted,
      paymentSessionId: paymentSessionId ?? this.paymentSessionId,
      orderId: orderId ?? this.orderId,
      error: error ?? this.error,
      paymentSuccess: paymentSuccess ?? this.paymentSuccess,
    );
  }
}

class PaymentNotifier extends StateNotifier<PaymentState> {
  final PaymentUsecases usecases;

  Timer? _verificationTimer;

  PaymentNotifier(this.usecases) : super(PaymentState());

  /// Entry point: call from UI to start the flow
  Future<void> getPaymentSessionAndStart({
    required dynamic total,
    required String userId,
    required dynamic shippingCost,
    required String shippingAddress,
    required String availableId,
    required BuildContext context,
    required dynamic userLat,
    required dynamic userLong,
  }) async {
    try {
      state = state.copyWith(loading: true, error: '');
      final finalTotal =double.parse(total);

      print('getPaymentSessionId → userId: $userId | totalAmount: $finalTotal | availableId: $availableId');

      final PaymentOrderData orderData = await usecases.getPaymentSessionId(
        userId: userId,
        totalAmount: finalTotal,
        availableId: availableId,
      );
      print("${orderData.paymentSessionId}");
      state = state.copyWith(
        loading: false,
        paymentSessionId: orderData.paymentSessionId,
        orderId: orderData.orderId,
        paymentStarted: true,
      );

      // 2) Start Cashfree payment (pass context)
      await _startCashfreePayment(
        userId: userId,
        context: context,
        orderId: orderData.orderId,
        paymentSessionId: orderData.paymentSessionId,
        total: finalTotal,
        shippingCost: shippingCost,
        shippingAddress: shippingAddress,
        availableId: availableId,
        userLat: userLat,
        userLong: userLong,
      );


    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
      print('getPaymentSessionAndStart error: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Payment error: ${e.toString()}')),
        );
      }
    }
  }

 Future<void> _startCashfreePayment({
  required String userId,
  required BuildContext context,
  required String orderId,
  required String paymentSessionId,
  required dynamic total,
  required dynamic shippingCost,
  required String shippingAddress,
  required String availableId,
  required dynamic userLat,
  required dynamic userLong,
}) async {
  final cf = CashfreePaymentService(
    context: context,
    environment: CFEnvironment.SANDBOX,
    orderId: orderId,
    paymentSessionId: paymentSessionId,
    onVerifyPayment: (verifiedOrderId) {
      verifyAndCreateCheckout(
        orderId: verifiedOrderId,
        availableId: availableId,
        context: context,
        shippingAddress: shippingAddress,
        userLat: userLat,
        userLong: userLong,
        userId: userId,
      );
    },
    onErrorPayment: (error) {
      state = state.copyWith(error: error, loading: false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Payment error: $error")),
      );
    },
  );

  await cf.initializeCashfree();
  await cf.webCheckout();
}


  /// This method can be used to verify payment (if you want to do it from notifier)
  Future<void> verifyAndCreateCheckout({
    required String orderId,
    required String availableId,
    required BuildContext context,
    required String shippingAddress,
    required dynamic userLat,
    required dynamic userLong,
    required String userId,
  }) async {
    try {
      state = state.copyWith(loading: true);
      final success = await usecases.verifyPaymentStatus(
          orderId: orderId, availableId: availableId);
      print("Success is $success");  
      if (success) {
        // create order on backend
        final createdId = await usecases.createCheckout(
          userId: userId,
          shippingAddress: shippingAddress,
          availableId: availableId,
          userLat: userLat,
          userLong: userLong,
        );
        state = state.copyWith(
          loading: false,
          paymentSuccess: true,
        );
   

        print("Prescription data cleared after successful payment");

        if (!context.mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => OrderSuccessScreen(orderId: createdId),
          ),
        );
      } else {
        state = state.copyWith(loading: false, error: 'Payment failed');
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Payment verification failed')));
      }
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
      print('verifyAndCreateCheckout error: $e');
      if (!context.mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Payment error')));
    }
  }

  Future<void> initiateNonPrescriptionOrder({
    required String userId,
    required String shippingAddress,
    required dynamic userLat,
    required dynamic userLong,
    required BuildContext context,
  }) async {
    try {
      state = state.copyWith(loading: true, error: '');
      final orderData = await usecases.initiateNonPrescriptionOrder(
        userId: userId,
        shippingAddress: shippingAddress,
        userLat: userLat,
        userLong: userLong,
      );

      final paymentData = await usecases.getPaymentSessionId(
        userId: userId,
        totalAmount: orderData.finalTotal,
        availableId: orderData.availableId,
      );
      state = state.copyWith(
        loading: false,
        paymentSessionId: paymentData.paymentSessionId,
        orderId: paymentData.orderId,
        paymentStarted: true,
      );

      await _startCashfreePayment(
        userId: userId,
        context: context,
        orderId: paymentData.orderId,
        paymentSessionId: paymentData.paymentSessionId,
        total: orderData.finalTotal,
        shippingCost: 0,
        shippingAddress: shippingAddress,
        availableId: orderData.availableId,
        userLat: userLat,
        userLong: userLong,
      );
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
      print('initiateNonPrescriptionOrder error: $e');
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to place order: ${e.toString()}')),
      );
    }
  }

  @override
  void dispose() {
    _verificationTimer?.cancel();
    super.dispose();
  }
}
final apiServiceProvider = Provider<ApiService>((ref) => ApiService(http.Client()));

final paymentRepoProvider = Provider<PaymentRepoImpl>((ref) {
  final api = ref.watch(apiServiceProvider);
  return PaymentRepoImpl(apiService: api);
});

final paymentUsecaseProvider = Provider<PaymentUsecases>((ref) {
  final repo = ref.watch(paymentRepoProvider);
  return PaymentUsecases(repository: repo);
});

final paymentProvider =
    StateNotifierProvider<PaymentNotifier, PaymentState>((ref) {
  final usecases = ref.watch(paymentUsecaseProvider);
  return PaymentNotifier(usecases);
});