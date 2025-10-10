// lib/data/models/cart_item_model.dart
class CartResponseEntity {
  final List<CartItemEntity> items;
  final dynamic finaltotal;
  final dynamic deliveryFee;
  final dynamic taxServices;
  final dynamic total;
  final dynamic discount;


  CartResponseEntity({
    required this.items,
    required this.taxServices,
    required this.finaltotal,
    required this.deliveryFee,
    required this.total,
    required this.discount,
  });

  factory CartResponseEntity.fromJson(Map<String, dynamic> json) {
    final itemsData = (json['data'] as List<dynamic>?) ?? [];
   
    return CartResponseEntity(
      discount:json['discount']??0 ,
      items: itemsData.map((item) => CartItemEntity.fromJson(item)).toList(),
      taxServices: json['taxServicesFees']??0,
      total: json['totalAmount'] ?? 0,
      deliveryFee: json['deliveryFees'] ?? 0,
      finaltotal: json['finalTotal'] ?? 0
    );
  }
}



class CartItemEntity {
  final String productId;
  final int quantity;
  final String name;
  final double sellingPrice;
  final String productMarketer;
  final String prescription;
  final List<String> imageUrls;
  final double productPrice;

  CartItemEntity({
    required this.prescription,
    required this.productId,
    required this.quantity,
    required this.name,
    required this.sellingPrice,
    required this.productMarketer,
    required this.imageUrls,
    required this.productPrice,
  });

  factory CartItemEntity.fromJson(Map<String, dynamic> json) {
    return CartItemEntity(
      prescription: json['prescription_required']??'N/A',
      productId: json['productId'] ?? '',
      quantity: json['quantity'] ?? '0',
      name: json['productName'] ?? '',
      sellingPrice:json['sellingPrice'] ,
      productMarketer: json['productMarketer'] ?? '',
      imageUrls: List<String>.from(json['imageUrls'] ?? []),
      productPrice: (json['productPrice'] as num).toDouble(),
    );
  }
}