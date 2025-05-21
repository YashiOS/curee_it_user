// lib/cart_manager.dart

class CartManager {
  static final Map<String, int> cartQuantities = {};
  static int getTotalQuantity() {
    int total = 0;
    cartQuantities.forEach((_, qty) {
      if (qty > 0) total += qty;
    });
    return total;
  }
}
