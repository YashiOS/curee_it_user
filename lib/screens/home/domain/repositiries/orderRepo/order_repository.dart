// lib/domain/repositories/order_repository.dart
import 'package:cureeit_user_app/screens/home/domain/entities/orderEntity.dart';

abstract class OrderRepository {
  Future<List<OrderEntity>> fetchOrderHistory(String userId);
  Future<bool> checklocation(double lat, double lng);
  Future<dynamic> checkServiceability(double lat,double lng);
  Future<String> getEstimatedTime(double lat, double lng);
}