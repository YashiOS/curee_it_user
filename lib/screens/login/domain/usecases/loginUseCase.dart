import 'package:cureeit_user_app/screens/login/domain/entities/loginEntity.dart';
import 'package:cureeit_user_app/screens/login/domain/repositiries/loginRepo/login_repository.dart';

class LoginRepositoryUseCase {
  final LoginRepository repository;

  LoginRepositoryUseCase({required this.repository});

  Future<Map<String,dynamic>> verifyPhoneNumber(LoginEntity loginEntity) {
    return repository.verifyPhoneNumber(loginEntity);
  }
}