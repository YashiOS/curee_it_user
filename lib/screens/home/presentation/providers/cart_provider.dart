import 'package:cureeit_user_app/Networking/api_service.dart';
import 'package:cureeit_user_app/screens/home/domain/entities/cartItemEntity.dart';
import 'package:cureeit_user_app/screens/home/domain/repositiries/cartRepo/cart_repository_implementation.dart';
import 'package:cureeit_user_app/screens/home/domain/usecases/cart_useCase.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import 'package:http/http.dart' as http;

class CartState {
  final List<CartItemEntity> cartItems;
  final bool prescription_required;
  final dynamic total;
  final dynamic finalTotal;
  final dynamic discount;
  final dynamic tax;
  final dynamic deliveryFee;
  final bool isLoading;
  final String? error;

  CartState(
      {this.cartItems = const [],
      this.isLoading = false,
      this.error,
      this.prescription_required = false,
      this.deliveryFee = '',
      this.discount = '',
      this.finalTotal = '',
      this.total = '',
      this.tax=''});

  CartState copyWith(
      {List<CartItemEntity>? cartItems,
      bool? isLoading,
      String? error,
      bool? prescription_required,
      dynamic total,
      dynamic discount,
      dynamic deliveryFee,
      dynamic finalTotal,
      dynamic tax}) {
    return CartState(
      tax: tax??this.tax,
      total: total ?? this.total,
      finalTotal: finalTotal ?? this.finalTotal,
      deliveryFee: deliveryFee ?? this.deliveryFee,
      discount: discount ?? this.discount,
      cartItems: cartItems ?? this.cartItems,
      isLoading: isLoading ?? this.isLoading,
      prescription_required:
          prescription_required ?? this.prescription_required,
      error: error,
    );
  }
}

class CartNotifier extends StateNotifier<CartState> {
  final CartUseCase useCase;

  CartNotifier(this.useCase) : super(CartState());

  Future<void> fetchCart(String userId) async {
    try {
     
      state = state.copyWith( error: null);
      final cartData = await useCase.fetchCart(userId);
     final requiresPrescription =
        cartData.items.any((item) => item.prescription == "Yes");
      
      state = state.copyWith(
          cartItems: cartData.items,
          deliveryFee: cartData.deliveryFee,
          discount: cartData.discount,
          finalTotal: cartData.finaltotal,
          isLoading: false,
          total: cartData.total,
          tax: cartData.taxServices,
          prescription_required: requiresPrescription);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> addToCart(String userId, String productId, int quantity) async {
    try {
      state=state.copyWith(isLoading: true);
      await useCase.addToCart(userId, productId, quantity);
      await fetchCart(userId);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> updateCartQuantity(
      String userId, String productId, int quantity) async {
    try {
       state=state.copyWith(isLoading: true);
      await useCase.updateCartQuantity(userId, productId, quantity);
      await fetchCart(userId);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> removeFromCart(String userId, String productId) async {
    try {
       state=state.copyWith(isLoading: true);
      await useCase.removeFromCart(userId, productId);
      await fetchCart(userId);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }
  

}



// Providers
final apiServiceProvider =
    Provider<ApiService>((ref) => ApiService(http.Client()));

final cartRepositoryProvider = Provider<CartRepositoryImpl>((ref) {
  final api = ref.watch(apiServiceProvider);
  return CartRepositoryImpl(apiService: api);
});

final cartUseCaseProvider = Provider<CartUseCase>((ref) {
  final repo = ref.watch(cartRepositoryProvider);
  return CartUseCase(repository: repo);
});

final cartNotifierProvider =
    StateNotifierProvider<CartNotifier, CartState>((ref) {
  final useCase = ref.watch(cartUseCaseProvider);
  return CartNotifier(useCase);
});
