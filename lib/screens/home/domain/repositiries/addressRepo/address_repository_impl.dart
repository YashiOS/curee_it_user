// lib/data/datasources/remote_data_source.dart
import 'dart:convert';

import 'package:cureeit_user_app/Networking/api_service.dart';
import 'package:location/location.dart' as loc;
import 'package:cureeit_user_app/screens/home/domain/entities/addressEntity.dart';
import 'package:cureeit_user_app/screens/home/domain/repositiries/addressRepo/address_repository.dart';
import 'package:hive/hive.dart';

class AddressRepositoryImpl implements AddressRepository {
  final ApiService apiService;

  AddressRepositoryImpl({required this.apiService});

  Future<List<AddressEntity>> fetchAddresses(String userId) async {
    
    final response = await apiService
        .get("/address/savedAddress?userId=$userId");

    if (response.statusCode == 200) {
 
      final data = json.decode(response.body);
    
      return (data['data']['address'] as List)
          .map((e) => AddressEntity.fromJson(e))
          .toList();
    }
    throw Exception('Failed to load addresses');
  }

  @override
  Future<void> setCurrentAddress(AddressEntity addressEntity, int index) async {
    final _myBox = Hive.box("Mybox");
    // Assuming _myBox is defined elsewhere and accessible here
    await _myBox.put('userAddress', {
      "index": index,
      "address": addressEntity.address,
      "landmark": addressEntity.landmark,
      "floor": addressEntity.floor,
      "userLat": addressEntity.userLat,
      "userlong": addressEntity.userLong,
      "type": addressEntity.type
    });
  }

  @override
  Future<AddressEntity?> getCurrentAddress() async {
    final _myBox = Hive.box("Mybox");
    final addressData = await _myBox.get('userAddress');
    if (addressData != null) {
      return AddressEntity(
        address: addressData!['address'],
        landmark: addressData['landmark'],
        floor: addressData['floor'],
        userLat: addressData['userLat'],
        userLong: addressData['userlong'],
        type: addressData['type'],
      );
    }
    return null;
  }

  @override
  Future<bool> getLocationPermission() async{
     loc.Location location = loc.Location();

    bool serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
       
        return false;
      }
    }

    loc.PermissionStatus permissionGranted = await location.hasPermission();
    if (permissionGranted == loc.PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != loc.PermissionStatus.granted) {
        return false;
      }
    }

    return true;

  }

  // Implement similar methods for other endpoints...
}
