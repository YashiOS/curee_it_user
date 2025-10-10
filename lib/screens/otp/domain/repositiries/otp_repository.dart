import 'package:cureeit_user_app/screens/otp/domain/entities/otpEntity.dart';
import 'package:cureeit_user_app/screens/otp/domain/entities/userEntity.dart';

abstract class OtpRepository{
  Future<User> verifyingOTP(OtpModel otpModel);
 void saveUserData(User user);
  User? getUserData();
  void clearUserData();
  bool isUserAvilable();

}