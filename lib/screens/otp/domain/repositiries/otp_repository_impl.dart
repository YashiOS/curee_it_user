import 'dart:convert';

import 'package:cureeit_user_app/screens/otp/domain/entities/otpEntity.dart';
import 'package:cureeit_user_app/screens/otp/domain/entities/userEntity.dart';

import 'package:cureeit_user_app/screens/otp/domain/repositiries/otp_repository.dart';
import 'package:cureeit_user_app/Networking/api_service.dart';

import 'package:hive/hive.dart';

class OtpRepositoryImpl extends OtpRepository {
  final ApiService apiService;

  OtpRepositoryImpl({required this.apiService});

  @override
  Future<User> verifyingOTP(OtpModel otpModel) async {
    final response =
        await apiService.post("/auth/user/verifyOTP", body: otpModel.toJson());
    print("DATA FROM OTP API : ${response.body}");
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
    
      return User.fromJson(data);
    }
    throw Exception('Failed to Verify OTP');
  }

  @override
  void saveUserData(User user)  {
    final _myBox = Hive.box("Mybox");

    _myBox.put('user', {
      'id': user.id,
      'userId': user.userId,
      'name': user.name,
      'phoneNumber': user.mobileNumber,
    });
  }

  @override
  User? getUserData() {
    final _myBox = Hive.box("Mybox");
    final data = _myBox.get('user');
    if (data != null && data is Map) {
      return User(
          id: data['id'],
          name: data['name'],
          userId: data['userId'],
          mobileNumber: data['phoneNumber']);
    }
    return null;
  }

  @override
  void clearUserData() {
    final _myBox = Hive.box("Mybox");
    _myBox.delete('user');
  }

  @override
  bool isUserAvilable() {
    final _myBox = Hive.box("Mybox");
    return _myBox.containsKey('user');
  }
}
