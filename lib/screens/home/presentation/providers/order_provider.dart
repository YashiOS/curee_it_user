import 'package:cureeit_user_app/Networking/api_service.dart';
import 'package:cureeit_user_app/screens/home/domain/entities/loctionEntity.dart';
import 'package:cureeit_user_app/screens/home/domain/entities/orderEntity.dart';
import 'package:cureeit_user_app/screens/home/domain/repositiries/orderRepo/order_repository_implementation.dart';
import 'package:cureeit_user_app/screens/home/domain/usecases/order_useCase.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import 'package:http/http.dart' as http;

class OrderState {
  final List<OrderEntity> allOrders;
  final List<OrderEntity> ongoingOrders;
  
  final bool? currentLocationAvailable;
  final String? estimatedTime;
  final bool isLoading;
  final String? error;

  OrderState({
    this.allOrders = const [],
    this.ongoingOrders = const [],
    this.currentLocationAvailable,
    this.estimatedTime,
    this.isLoading = false,
    this.error,
  });

  OrderState copyWith({
    List<OrderEntity>? allOrders,
    List<OrderEntity>? ongoingOrders,
    bool? currentLocationAvailable,
    String? estimatedTime,
    bool? isLoading,
    String? error,
  }) {
    return OrderState(
      allOrders: allOrders ?? this.allOrders,
      ongoingOrders: ongoingOrders ?? this.ongoingOrders,
      currentLocationAvailable:
          currentLocationAvailable ?? this.currentLocationAvailable,
      estimatedTime: estimatedTime ?? this.estimatedTime,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class OrderNotifier extends StateNotifier<OrderState> {
  final OrderUseCase useCase;

  OrderNotifier(this.useCase) : super(OrderState());

  Future<void> fetchOrderHistory(String userId) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      final orders = await useCase.fetchOrderHistory(userId);
      orders.sort((a, b) => b.purchaseDate.compareTo(a.purchaseDate));
      final ongoing = orders.where((o) {
        final status = o.status.toLowerCase();
        return status != 'delivered' && status != 'not available';
      }).toList();
    

      state = state.copyWith(
          allOrders: orders, ongoingOrders: ongoing, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> checkLocation(double lat, double long) async {
    try {
      final location = await useCase.checkLocation(lat, long);
      state = state.copyWith(currentLocationAvailable: location);
      final servicibility = await useCase.checkServiceability(lat, long);
     print("AVILABLE IN THIS ADDRESS $location");
     print("DARKSTORE IS OPEN $servicibility");
      if (location) {
        if (servicibility==true) {
          final estTime = await useCase.getEstimatedTime(lat, long);
          state = state.copyWith(estimatedTime: estTime);
        }else{
          state=state.copyWith(estimatedTime: servicibility);
        }
      }
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }
}

// Providers
final apiServiceProvider =
    Provider<ApiService>((ref) => ApiService(http.Client()));

final orderRepositoryProvider = Provider<OrderRepositoryImpl>((ref) {
  final api = ref.watch(apiServiceProvider);
  return OrderRepositoryImpl(apiService: api);
});

final orderUseCaseProvider = Provider<OrderUseCase>((ref) {
  final repo = ref.watch(orderRepositoryProvider);
  return OrderUseCase(repository: repo);
});

final orderNotifierProvider =
    StateNotifierProvider<OrderNotifier, OrderState>((ref) {
  final useCase = ref.watch(orderUseCaseProvider);
  return OrderNotifier(useCase);
});
