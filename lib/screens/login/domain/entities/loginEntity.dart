// lib/features/auth/domain/entities/login_entity.dart
class LoginEntity {
  final String mobileNumber;
  final String fcmToken;

  LoginEntity({
    required this.mobileNumber,
    required this.fcmToken,
  });

  Map<String, dynamic> toJson() {
    return {
      'mobileNumber': mobileNumber,
      'fcmToken': fcmToken,
    };
  }
}