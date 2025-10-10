import 'package:cureeit_user_app/screens/register/domain/entities/registerEntity.dart';
import 'package:cureeit_user_app/screens/register/domain/repositiries/register_repository.dart';

class RegisterUseCase {
  final registerRepository repository;
  RegisterUseCase({required this.repository});

  Future<void> registerUser(RegisterEntity register){
    return repository.registerUser(register);
  }



}