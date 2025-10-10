// lib/data/models/address_model.dart
class AddressEntity {
  final String? id;
  final String address;
  final String? landmark;
  final String? floor;
  final dynamic userLat;
  final dynamic userLong;
  final String type;

  AddressEntity({
    this.id,
    required this.address,
    this.landmark,
    this.floor,
    required this.userLat,
    required this.userLong,
    required this.type,
  });

  factory AddressEntity.fromJson(Map<String, dynamic> json) {
    return AddressEntity(
      id: json['_id'],
      address: json['address'] ?? '',
      landmark: json['landmark'],
      floor: json['floor'],
      userLat: json['userLat'],
      userLong: json['userLong'] ,
      type: json['type'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) '_id': id,
      'address': address,
      'landmark': landmark,
      'floor': floor,
      'userLat': userLat,
      'userLong': userLong,
      'type': type,
    };
  }
}