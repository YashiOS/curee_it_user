import 'dart:convert';
import 'package:cureeit_user_app/Networking/api_service.dart';
import 'package:cureeit_user_app/screens/home/domain/entities/cartItemEntity.dart';
import 'package:cureeit_user_app/screens/home/domain/repositiries/cartRepo/cart_repository.dart';
import 'package:http/http.dart' as http;

class CartRepositoryImpl implements CartRepository {
  final ApiService apiService;

  CartRepositoryImpl({required this.apiService});

  @override
  Future<CartResponseEntity> fetchCartDetails(String userId) async {
    final response =
        await apiService.post('/cart/cartDetails', body: {"userId": userId});
    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return CartResponseEntity.fromJson(data);
    } else {
      throw Exception("Failed To fetch cart");
    }
  }

  @override
  Future<void> addToCart(String userId, String productId, int quantity) async {
  final res=  await apiService.post('/cart/addToCart', body: {
      "userId": userId,
      "productId": productId,
      "quantity": quantity,
    });
  
  }

  @override
  Future<void> removeFromCart(String userId, String productId) async {
    final res = await apiService.delete('/cart/removeFromCart', body: {
      "userId": userId,
      "productId": productId,
    });
    print(res.body);
  }

  @override
  Future<void> updateQuantity(
      String userId, String productId, int quantity) async {
    await apiService.put('/cart/updateQuantity', body: {
      "userId": userId,
      "productId": productId,
      "quantity": quantity,
    });
  }
}
