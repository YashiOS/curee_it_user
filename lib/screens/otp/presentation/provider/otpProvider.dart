import 'package:cureeit_user_app/Networking/api_service.dart';
import 'package:cureeit_user_app/screens/otp/domain/entities/otpEntity.dart';
import 'package:cureeit_user_app/screens/otp/domain/entities/userEntity.dart';

import 'package:cureeit_user_app/screens/otp/domain/repositiries/otp_repository_impl.dart';
import 'package:cureeit_user_app/screens/otp/domain/usecases/otpUsecase.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:http/http.dart' as http;

class otpState {
  final bool isLoading;
  final bool verifyed;
  final String? error;
  final User? user;

  otpState(
      {this.isLoading = false, this.verifyed = false, this.error, this.user});

  otpState copyWith(
      {bool? isLoading, bool? verifyed, String? error, User? user}) {
    return otpState(
      isLoading: isLoading ?? this.isLoading,
      verifyed: verifyed ?? this.verifyed,
      error: error ?? this.error,
      user: user ?? this.user,
    );
  }
}

class OtpNotifier extends StateNotifier<otpState> {
  OtpUseCase useCase;

  OtpNotifier(this.useCase) : super(otpState());

  Future<User?> verifyOtp(OtpModel otpModel) async {
    try {
      state = state.copyWith(isLoading: true);
      final user = await useCase.verifyOtp(otpModel);
      state = state.copyWith(isLoading: false, verifyed: true, error: null);
      return user;
    } catch (e) {
      state = state.copyWith(
          error: e.toString(), verifyed: false, isLoading: false);
      return null;
    }
  }

  void clearError() {
    if (state.error != null) {
      state = state.copyWith(error: null);
    }
  }

  void saveUserData(User user) {
    useCase.saveUserData(user);
    state = state.copyWith(
        user: User(
            id: user.id,
            name: user.name,
            userId: user.userId,
            mobileNumber: user.mobileNumber));
  }

  User? getUserData() {
    final user = useCase.getUserData();
    if (user != null) {
      state = state.copyWith(
          user: User(
              id: user.id,
              name: user.name,
              userId: user.userId,
              mobileNumber: user.mobileNumber));
    }
    return useCase.getUserData();
  }

  void clearUserData() {
    useCase.clearUserData();
  }

  bool isUserAvilable() {
    return useCase.isUserAvilable();
  }
}

final apiServiceProvider =
    Provider<ApiService>((ref) => ApiService(http.Client()));

final OtpRepositoryProvider = Provider<OtpRepositoryImpl>((ref) {
  final api = ref.watch(apiServiceProvider);
  return OtpRepositoryImpl(apiService: api);
});

final OtpUseCaseProvider = Provider<OtpUseCase>((ref) {
  final repo = ref.watch(OtpRepositoryProvider);
  return OtpUseCase(repository: repo);
});

final OtpNotifierProvider = StateNotifierProvider<OtpNotifier, otpState>((ref) {
  final useCase = ref.watch(OtpUseCaseProvider);
  return OtpNotifier(useCase);
});
