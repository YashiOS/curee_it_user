import 'package:bloc/bloc.dart';
import 'package:hive/hive.dart';
import 'package:meta/meta.dart';

part 'store_user_state.dart';

class StoreUserCubit extends Cubit<StoreUserState> {
  StoreUserCubit(this._myBox) : super(StoreUserInitial());
  final Box _myBox;

  void saveUserAddress({
    required String userId,
    required String address,
    required String landmark,
    required String floor,
    required String userLat,
    required String userlong,
    required String type,
    required int? index,
  }) {
    _myBox.put('userAddress', {
      "index":index,
      "userId": userId,
      "address": address,
      "landmark": landmark,
      "floor": floor,
      "userLat": userLat,
      "userlong": userlong,
      "type": type
    });
  }

  Map<String, dynamic>? getUserAddress() {
    final data = _myBox.get('userAddress');
    if (data != null && data is Map) {
      return Map<String, dynamic>.from(data);
    }
    return null;
  }

  void saveUserData({
    required String id,
    required String userId,
    required String name,
    required String phoneNumber,
  }) {
    _myBox.put('user', {
      'id': id,
      'userId': userId,
      'name': name,
      'phoneNumber': phoneNumber,
    });
    // emit some success state if needed
  }

  Map<String, dynamic>? getUserData() {
    final data = _myBox.get('user');
    if (data != null && data is Map) {
      return Map<String, dynamic>.from(data);
    }
    return null;
  }

  void clearUserData() {
    _myBox.delete('userAddress');
    _myBox.delete('user');
    // emit a state if needed
  }

  /// Returns true if user data is available in Hive
  bool isUserDataAvailable() {
    return _myBox.containsKey('user');
  }
}
