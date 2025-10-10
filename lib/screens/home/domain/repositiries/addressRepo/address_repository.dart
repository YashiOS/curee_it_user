// lib/domain/repositories/address_repository.dart
import 'package:cureeit_user_app/screens/home/domain/entities/addressEntity.dart';

abstract class AddressRepository {
  Future<List<AddressEntity>> fetchAddresses(String userId);
 
  Future<AddressEntity?> getCurrentAddress();
  Future<bool> getLocationPermission();
  Future<void> setCurrentAddress(AddressEntity address,int index);
}



