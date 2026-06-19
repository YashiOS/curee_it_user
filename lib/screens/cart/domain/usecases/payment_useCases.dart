// usecases/payment_usecases.dart

import 'package:cureeit_user_app/screens/cart/domain/entities/paymentEntity.dart';
import 'package:cureeit_user_app/screens/cart/domain/repositiries/payment/payment_repo.dart';

class PaymentUsecases {
  final PaymentRepository repository;

  PaymentUsecases({required this.repository});

  Future<PaymentOrderData> getPaymentSessionId({
    required dynamic userId,
    required dynamic totalAmount,
    required dynamic availableId,
  }) {
    return repository.getPaymentSessionId(
      userId: userId,
      totalAmount: totalAmount,
      availableId: availableId,
    );
  }

  Future<bool> verifyPaymentStatus({
    required String orderId,
    required String availableId,
  }) {
    return repository.verifyPaymentStatus(orderId: orderId, availableId: availableId);
  }

  Future<String> createCheckout({
    required String userId,
    required String shippingAddress,
    required String availableId,
    required dynamic userLat,
    required dynamic userLong,
  }) {
    return repository.createCheckout(
      userId: userId,
      shippingAddress: shippingAddress,
      availableId: availableId,
      userLat: userLat,
      userLong: userLong,
    );
  }

  Future<NonPrescriptionOrderData> initiateNonPrescriptionOrder({
    required String userId,
    required String shippingAddress,
    required dynamic userLat,
    required dynamic userLong,
  }) {
    return repository.initiateNonPrescriptionOrder(
      userId: userId,
      shippingAddress: shippingAddress,
      userLat: userLat,
      userLong: userLong,
    );
  }
}
