import 'dart:convert';

import 'package:cureeit_user_app/Networking/api_service.dart';
import 'package:cureeit_user_app/screens/home/domain/entities/productEntities.dart';
import 'package:cureeit_user_app/screens/home/domain/repositiries/productRepo/service_repository.dart';

class ServiceRepositoryImpl implements ServiceRepository {
  final ApiService apiService;
  ServiceRepositoryImpl(this.apiService);

  @override
  Future<List<ProductEntity>> fetchServices(String latitude, String longitude) async {
     final result = await apiService.get(
    "/home/homeProducts?latitude=$latitude&longitude=$longitude",
  );
   final response=jsonDecode(result.body);
  final List data = response["data"] ?? [];
  return data.map((e) => ProductEntity.fromJson(e)).toList();
  }
  
}
