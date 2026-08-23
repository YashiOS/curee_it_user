import 'package:cureeit_user_app/Networking/api_service.dart';
import 'package:cureeit_user_app/screens/login/domain/entities/loginEntity.dart';
import 'package:cureeit_user_app/screens/login/domain/repositiries/loginRepo/login_repository_impl.dart';
import 'package:cureeit_user_app/screens/login/domain/usecases/loginUseCase.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import 'package:http/http.dart' as http;

class LoginState {
  final bool isLoggedIn;
  final bool newUser;
  final bool isLoading;
  
  final String? error;

  LoginState(
      {this.isLoading = false,
      this.isLoggedIn = false,
      this.newUser = false,
      
      this.error});

  LoginState copyWith(
      {bool? isLoggedIn, bool? isLoading, String? error, bool? newUser}) {
    return LoginState(
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      newUser: newUser ?? this.newUser,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class LoginNotifier extends StateNotifier<LoginState> {
  final LoginRepositoryUseCase useCase;

  LoginNotifier(this.useCase) : super(LoginState());

  Future<void> verifyPhoneNumber(LoginEntity loginEntity) async {
    try {
      print("In login notifier");
      state = state.copyWith(isLoading: true, error: null);
      final response = await useCase.verifyPhoneNumber(loginEntity);
      print("api called");
      print(response);
      if (response["message"] == "User exists") {
        state = state.copyWith(isLoggedIn: true, isLoading: false, error: null);
      } else if (response["message"] == "User not found") {
        state = state.copyWith(newUser: true, isLoading: false, error: null);
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      print("error $e");
    }
  }

  void clearError() {
    if (state.error != null) {
      state = state.copyWith(error: null);
    }
  }
}



// Providers
final apiServiceProvider =
    Provider<ApiService>((ref) => ApiService(http.Client()));

final loginRepositoryProvider = Provider<LoginRepositoryImpl>((ref) {
  final api = ref.watch(apiServiceProvider);
  return LoginRepositoryImpl(apiService: api);
});

final LoginUseCaseProvider = Provider<LoginRepositoryUseCase>((ref) {
  final repo = ref.watch(loginRepositoryProvider);
  return LoginRepositoryUseCase(repository: repo);
});

final LoginNotifierProvider =
    StateNotifierProvider<LoginNotifier, LoginState>((ref) {
  final useCase = ref.watch(LoginUseCaseProvider);
  return LoginNotifier(useCase);
});
