import 'package:cureeit_user_app/Networking/api_service.dart';
import 'package:cureeit_user_app/screens/order again/domain/entities/reorderEntity.dart';
import 'package:cureeit_user_app/screens/order again/domain/repositiries/reorder_repo_impl.dart';
import 'package:cureeit_user_app/screens/order again/domain/usecases/reorderUsecase.dart';
import 'package:cureeit_user_app/screens/cart/presentation/cart_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:http/http.dart' as http;


/// ---------- STATE ----------
class ReorderState {
  final bool isLoading;
  final bool success;
  final String? error;

  const ReorderState({
    this.isLoading = false,
    this.success = false,
    this.error,
  });

  ReorderState copyWith({
    bool? isLoading,
    bool? success,
    String? error,
  }) {
    return ReorderState(
      isLoading: isLoading ?? this.isLoading,
      success: success ?? this.success,
      error: error ?? this.error,
    );
  }
}

/// ---------- NOTIFIER ----------
class ReorderNotifier extends StateNotifier<ReorderState> {
  final ReorderUseCase _usecase;

  ReorderNotifier(this._usecase) : super(const ReorderState());

  Future<void> reorderItems(BuildContext context, List<dynamic> orderItems,String userId) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      List<String> productIds =
          orderItems.map((item) => item['productId'].toString()).toList();

      final reorderEntity = ReorderEntity(
        userId: userId,
        productIds: productIds,
        quantity: 1,
      );

      bool success = await _usecase.call(reorderEntity);

      if (success) {
        state = state.copyWith(isLoading: false, success: true);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => CartScreen(isNavigated: true)),
        );
      } else {
        state = state.copyWith(isLoading: false, success: false, error: "Failed to reorder.");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to reorder. Please try again.")),
        );
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${e.toString()}")),
      );
    }
  }
}

/// ---------- PROVIDERS ----------
final apiServiceProvider = Provider<ApiService>((ref) => ApiService(http.Client()));

final reorderRepoProvider = Provider<ReorderRepositoryImpl>((ref) {
  final api = ref.watch(apiServiceProvider);
  return ReorderRepositoryImpl(apiService: api);
});

final reorderUsecaseProvider = Provider<ReorderUseCase>((ref) {
  final repo = ref.watch(reorderRepoProvider);
  return ReorderUseCase(repo);
});

final reorderNotifierProvider =
    StateNotifierProvider<ReorderNotifier, ReorderState>((ref) {
  final usecase = ref.watch(reorderUsecaseProvider);
  return ReorderNotifier(usecase);
});
