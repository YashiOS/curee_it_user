// lib/features/auth/domain/repositories/auth_repository.dart
import 'package:cureeit_user_app/screens/login/domain/entities/loginEntity.dart';

abstract class LoginRepository {
  Future<Map<String,dynamic>> verifyPhoneNumber(LoginEntity loginEntity);
}