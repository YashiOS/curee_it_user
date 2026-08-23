import 'package:cureeit_user_app/Networking/api_service.dart';
import 'package:cureeit_user_app/screens/home/domain/entities/addressEntity.dart';
import 'package:cureeit_user_app/screens/home/domain/repositiries/addressRepo/address_repository_impl.dart';
import 'package:cureeit_user_app/selected_Address/currentAddress.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../domain/usecases/address_usecase.dart';
import 'package:http/http.dart' as http;

class AddressState {
  final List<AddressEntity> addresses;
  final AddressEntity? currentAddress;
  final bool permissionGranted;
  final bool isLoading;
  final String? error;

  AddressState({
    this.addresses = const [],
    this.currentAddress,
    this.permissionGranted = false,
    this.isLoading = false,
    this.error,
  });

  AddressState copyWith({
    List<AddressEntity>? addresses,
    AddressEntity? currentAddress,
    bool? permissionGranted,
    bool? isLoading,
    String? error,
  }) =>
      AddressState(
        addresses: addresses ?? this.addresses,
        currentAddress: currentAddress ?? this.currentAddress,
        permissionGranted: permissionGranted ?? this.permissionGranted,
        isLoading: isLoading ?? this.isLoading,
        error: error,
      );
}

class AddressNotifier extends StateNotifier<AddressState> {
  final AddressUseCase useCase;
  AddressNotifier(this.useCase) : super(AddressState());

  Future<void> fetchAddresses(String userId) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      final result = await useCase.fetchAddresses(userId);
      state = state.copyWith(addresses: result, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> setCurrentAddress(AddressEntity address, int index) async {
    try {
      await useCase.setCurrentAddress(address, index);
      // Keep the legacy global Address.CurrentAddress in sync so screens
      // that still read from it (place order, order tracking) get the
      // right coordinates without requiring a manual address selection.
      Address.CurrentAddress = address.toJson();
      Address.selectedIndex = index;
      state = state.copyWith(currentAddress: address);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> getCurrentAddress() async {
    try {
      final saved = await useCase.getCurrentAddress();
      if (saved != null) state = state.copyWith(currentAddress: saved);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> getLocationPermission() async {
    try {
      final res = await useCase.getLocationPermission();
      state = state.copyWith(permissionGranted: res);
    } catch (e) {
      state = state.copyWith(error: e.toString(),permissionGranted:false);
    }
  }
}

// Providers
final apiServiceProvider =
    Provider<ApiService>((ref) => ApiService(http.Client()));

final addressRepositoryProvider = Provider<AddressRepositoryImpl>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return AddressRepositoryImpl(apiService: apiService);
});

final addressUseCaseProvider = Provider<AddressUseCase>((ref) {
  final repository = ref.watch(addressRepositoryProvider);
  return AddressUseCase(repository: repository);
});

final addressNotifierProvider =
    StateNotifierProvider<AddressNotifier, AddressState>((ref) {
  final useCase = ref.watch(addressUseCaseProvider);
  return AddressNotifier(useCase);
});
