// lib/domain/repositories/cart_repository.dart
import 'package:cureeit_user_app/screens/home/domain/entities/cartItemEntity.dart';

abstract class CartRepository {
  Future<CartResponseEntity> fetchCartDetails(String userId);
  Future<void> addToCart(String userId, String productId, int quantity);
  Future<void> updateQuantity(String userId, String productId, int quantity);
  Future<void> removeFromCart(String userId, String productId);
}