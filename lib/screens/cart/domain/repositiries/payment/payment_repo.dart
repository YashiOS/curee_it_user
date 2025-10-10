// repository/payment_repository.dart
import 'package:cureeit_user_app/screens/cart/domain/entities/paymentEntity.dart';



abstract class PaymentRepository {
  Future<PaymentOrderData> getPaymentSessionId({
    required dynamic userId,
    required dynamic totalAmount,
    required dynamic availableId,
  });

  Future<bool> verifyPaymentStatus({
    required String orderId,
    required String availableId,
  });

  Future<String> createCheckout({
    required String userId,
    required String shippingAddress,
    required String availableId,
    required dynamic userLat,
    required dynamic userLong,
  });
}
