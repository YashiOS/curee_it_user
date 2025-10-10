class User {
  final String id;
  final String name;
  final String userId;
  final String mobileNumber;

  User({
    required this.id,
    required this.name,
    required this.userId,
    required this.mobileNumber,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json["user"]?["_id"] ?? "",
        name: json["user"]?["name"] ?? "",
        userId: json["user"]?["userId"] ?? "",
        mobileNumber: json["user"]?["mobileNumber"] ?? "",
      );
}