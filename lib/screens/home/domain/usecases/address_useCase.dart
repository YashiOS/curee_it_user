// lib/screens/home/domain/usecases/address_usecase.dart
import 'package:cureeit_user_app/screens/home/domain/entities/addressEntity.dart';
import 'package:cureeit_user_app/screens/home/domain/repositiries/addressRepo/address_repository.dart';

class AddressUseCase {
  final AddressRepository repository;

  AddressUseCase({required this.repository});

  /// Fetch all saved addresses for a user
  Future<List<AddressEntity>> fetchAddresses(String userId) {
  
    return repository.fetchAddresses(userId);
  }

  /// Save the current selected address locally (Hive)
  Future<void> setCurrentAddress(AddressEntity addressEntity, int index) {
    return repository.setCurrentAddress(addressEntity, index);
  }

  /// Get the currently saved address from local storage (Hive)
  Future<AddressEntity?> getCurrentAddress() {
    return repository.getCurrentAddress();
  }
  
  Future<bool> getLocationPermission() {
    return repository.getLocationPermission();
  }

}

