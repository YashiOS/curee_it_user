class ReorderEntity {
  final String userId;
  final List<String> productIds;
  final int quantity;

  ReorderEntity({
    required this.userId,
    required this.productIds,
    required this.quantity,
  });

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'productIds': productIds,
      'quantity': quantity,
    };
  }
}
