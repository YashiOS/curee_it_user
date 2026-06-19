// models/payment_entity.dart
class PaymentOrderData {
  final String paymentSessionId;
  final String orderId;

  PaymentOrderData({required this.paymentSessionId, required this.orderId});

  factory PaymentOrderData.fromJson(Map<String, dynamic> json) {
    return PaymentOrderData(
      paymentSessionId: json["payment_session_id"] ?? '',
      orderId: json["order_id"] ?? '',
    );
  }
}

class NonPrescriptionOrderData {
  final String availableId;
  final double finalTotal;

  NonPrescriptionOrderData({required this.availableId, required this.finalTotal});
}
