class RegisterEntity {
  final String phoneNumber;
  final String name;
  final String? fcmToken;

  RegisterEntity({required this.phoneNumber,required this.name,required this.fcmToken});

  Map<String,dynamic> toJson()=>{
   "mobileNumber":phoneNumber,
   "name":name,
   "fcmToken":fcmToken
  };
} 