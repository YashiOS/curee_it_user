class ProductEntity {
  final String productId;
  final String name;
  final String type;
  final double price;
  final double discountedPrice;
  final String productForm;
  final String primaryUse;
  final bool prescriptionRequired;
  final List<String> imageMediaUrls;

  ProductEntity({
    required this.productId,
    required this.name,
    required this.type,
    required this.price,
    required this.discountedPrice,
    required this.productForm,
    required this.primaryUse,
    required this.prescriptionRequired,
    required this.imageMediaUrls,
  });

  factory ProductEntity.fromJson(Map<String, dynamic> json) {
    return ProductEntity(
      productId: json["productId"] ?? "",
      name: json["name"] ?? "",
      type: json["type"] ?? "",
      price: (json["price"] ?? 0).toDouble(),
      discountedPrice: (json["discountedPrice"] ?? 0).toDouble(),
      productForm: json["product_Form"] ?? "",
      primaryUse: json["primaryUse"] ?? "",
      prescriptionRequired: json["prescriptionRequired"] ?? false,
      imageMediaUrls: json["imageMediaUrls"] != null
          ? List<String>.from(json["imageMediaUrls"])
          : [],
    );
  }
}
