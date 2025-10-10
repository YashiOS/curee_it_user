import 'dart:convert';
import 'package:cureeit_user_app/Networking/api_service.dart';
import 'package:cureeit_user_app/screens/home/domain/entities/loctionEntity.dart';
import 'package:cureeit_user_app/screens/home/domain/entities/orderEntity.dart';
import 'package:cureeit_user_app/screens/home/domain/repositiries/orderRepo/order_repository.dart';
import 'package:http/http.dart' as http;

class OrderRepositoryImpl implements OrderRepository {
  final ApiService apiService;

  OrderRepositoryImpl({required this.apiService});

  @override
  Future<List<OrderEntity>> fetchOrderHistory(String userId) async {
    final response =
        await apiService.post('/order/orderHistory', body: {"userId": userId});
    final data = jsonDecode(response.body);
    final orders = (data['data'] as List<dynamic>?) ?? [];

    
    return orders.map((json) => OrderEntity.fromJson(json)).toList();
  }

  @override
  Future<bool> checklocation(double latitude, double longitude) async {
    final response = await apiService.post('/home/check_location', body: {
      "latitude": latitude.toString(),
      "longitude": longitude.toString(),
    });
    final data = jsonDecode(response.body);
    return data['isAllowed'] == true;
  }

  @override
  Future<String> getEstimatedTime(double latitude, double longitude) async {
    final response = await apiService.post('/home/getEstTime', body: {
      "userLat": latitude.toString(),
      "userLong": longitude.toString(),
    });
    final data = jsonDecode(response.body);
    return (data["estimatedTimeMinutes"] ?? 0).toString();
  }

  @override
  Future<dynamic> checkServiceability(double lat, double lng) async {
    final response = await apiService.post('/home/check-serviceability', body: {
      "userLat": lat.toString(),
      "userLong": lng.toString(),
    });
    final data = jsonDecode(response.body);
    if (data["serviceable"] == true) {
      return true;
    } else {
      return data["reason"];
    }
  }
}
