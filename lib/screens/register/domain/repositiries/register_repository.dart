import 'package:cureeit_user_app/screens/register/domain/entities/registerEntity.dart';

abstract class registerRepository{
  Future<void> registerUser(RegisterEntity register);
}