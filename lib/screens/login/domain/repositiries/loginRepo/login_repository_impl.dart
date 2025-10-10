// lib/features/auth/data/repositories/auth_repository_impl.dart
import 'dart:convert';
import 'package:cureeit_user_app/Networking/api_service.dart';
import 'package:cureeit_user_app/screens/login/domain/repositiries/loginRepo/login_repository.dart';
import 'package:cureeit_user_app/screens/login/domain/entities/loginEntity.dart';



class LoginRepositoryImpl implements LoginRepository {
   final ApiService apiService;

  LoginRepositoryImpl({required this.apiService});

  @override
  Future<Map<String,dynamic>> verifyPhoneNumber(LoginEntity loginEntity) async {
    final response = await apiService.post(
      "/auth/user/verify",
      body: {
        "mobileNumber":loginEntity.mobileNumber,
        "fcmToken":loginEntity.fcmToken
      }
    );

    final Map<String, dynamic> responseBody = json.decode(response.body);;

    if (response.statusCode == 200) {
      return {
        "status": true,
        "message":"User exists"
      } ; // Success - user exists
    } else if (response.statusCode == 400) {
           return{
            "status": true,
            "message":"User not found"
           }; // User needs to register
    } else {
      throw Exception('Failed to verify phone number: ${responseBody['message']}');
    }
  }
  
}

