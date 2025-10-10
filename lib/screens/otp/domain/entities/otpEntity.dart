class OtpModel {
  final String mobileNumber;
  final String code;
  final String purpose;
  final String name;

  OtpModel({
    required this.mobileNumber,
    required this.code,
    required this.purpose,
    required this.name,
  });

  Map<String, dynamic> toJson() => {
        "mobileNumber": mobileNumber,
        "code": code,
        "purpose": purpose,
        "name": name,
      };
}


