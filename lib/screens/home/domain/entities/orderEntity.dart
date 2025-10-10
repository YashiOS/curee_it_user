// lib/data/models/order_model.dart
class OrderEntity {
  final String availableId;
  final String status;
  final String purchaseDate;
  final dynamic finalTotal;
  final List<dynamic> products;
  final String orderId;

  OrderEntity({
    required this.finalTotal,
    required this.availableId,
    required this.products,
    required this.status,
    required this.purchaseDate,
    required this.orderId,
  });

  factory OrderEntity.fromJson(Map<String, dynamic> json) {
    return OrderEntity(
      orderId: json['paymentDetails']?['order_id']??'',
      finalTotal: json['paymentDetails']?['order_amount']??'',
      products: json['products']??'',
      availableId: json['availableID'] ?? '',
      status: json['status'] ?? '',
      purchaseDate: json['purchaseDate'] ?? '1970-01-01',
    );
  }
}