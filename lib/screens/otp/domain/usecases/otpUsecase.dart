import 'package:cureeit_user_app/screens/otp/domain/entities/otpEntity.dart';
import 'package:cureeit_user_app/screens/otp/domain/entities/userEntity.dart';
import 'package:cureeit_user_app/screens/otp/domain/repositiries/otp_repository.dart';

class OtpUseCase {
  final OtpRepository repository;

  OtpUseCase({required this.repository});

  Future<User> verifyOtp(OtpModel otpModel) async {
    return repository.verifyingOTP(otpModel);
  }

  void saveUserData(User user){
    return repository.saveUserData(user);
  }

  User? getUserData(){
    return repository.getUserData();
  }

  void clearUserData(){
    return repository.clearUserData();
  }

   bool isUserAvilable(){
    return repository.isUserAvilable();
   }

}
