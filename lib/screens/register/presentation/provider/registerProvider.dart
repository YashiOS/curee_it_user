import 'package:cureeit_user_app/Networking/api_service.dart';
import 'package:cureeit_user_app/screens/register/domain/entities/registerEntity.dart';
import 'package:cureeit_user_app/screens/register/domain/repositiries/register_repository_impl.dart';
import 'package:cureeit_user_app/screens/register/domain/usecases/registerUseCase.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:http/http.dart' as http;


class registerState {
  final bool isLoading;
  final bool registered;
  final String? error;

  registerState({this.isLoading = false, this.registered = false, this.error});

  registerState copyWith({bool? isLoading, bool? registered, String? error}) {
    return registerState(
      isLoading: isLoading ?? this.isLoading,
      registered: registered ?? this.registered,
      error: error ?? this.error,
    );
  }
}

class RegisterNotifier extends StateNotifier<registerState> {
  RegisterUseCase useCase;

  RegisterNotifier(this.useCase) : super(registerState());

  Future<void> registerUser(RegisterEntity register) async {
    try {
      state = state.copyWith(isLoading: true);
      await useCase.registerUser(register);
      state = state.copyWith(isLoading: false, registered: true, error: null);
      return ;
    } catch (e) {
      state=state.copyWith(error: e.toString(),registered: false,isLoading: false);
      return null;
    }
  }

    void clearError() {
    if (state.error != null) {
      state = state.copyWith(error: null);
    }
  }


}

final apiServiceProvider =
    Provider<ApiService>((ref) => ApiService(http.Client()));

final RegisterRepositoryProvider = Provider<RegisterRepositoryImpl>((ref) {
  final api = ref.watch(apiServiceProvider);
  return RegisterRepositoryImpl(apiService: api);
});

final RegisterUseCaseProvider = Provider<RegisterUseCase>((ref) {
  final repo = ref.watch(RegisterRepositoryProvider);
  return RegisterUseCase(repository: repo);
});

final RegisterNotifierProvider =
    StateNotifierProvider<RegisterNotifier, registerState>((ref) {
  final useCase = ref.watch(RegisterUseCaseProvider);
  return RegisterNotifier(useCase);
});