import 'package:cureeit_user_app/screens/home/domain/entities/cartItemEntity.dart';
import 'package:cureeit_user_app/screens/home/domain/repositiries/cartRepo/cart_repository.dart';



class CartUseCase {
  final CartRepository repository;

  CartUseCase({required this.repository});

  Future<CartResponseEntity> fetchCart(String userId) {

    return repository.fetchCartDetails(userId);
  }

  Future<void> addToCart(String userId, String productId, int quantity) {
    return repository.addToCart(userId, productId, quantity);
  }

  Future<void> updateCartQuantity(String userId, String productId, int quantity) {
    return repository.updateQuantity(userId, productId, quantity);
  }

  Future<void> removeFromCart(String userId, String productId) {
    return repository.removeFromCart(userId, productId);
  }
}
