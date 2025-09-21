import 'package:cureeit_user_app/Networking/api_service.dart';
import 'package:cureeit_user_app/screens/home/domain/entities/service.dart';
import 'package:cureeit_user_app/screens/home/domain/repositiries/service_repository.dart';

class ServiceRepositoryImpl implements ServiceRepository {
  final ApiService apiService;
  ServiceRepositoryImpl(this.apiService);

  @override
  Future<List<Service>> fetchServices(String latitude, String longitude) async {
     final response = await apiService.get(
    "/home/homeProducts?latitude=$latitude&longitude=$longitude",
  );

  final List data = response["data"] ?? [];
  return data.map((e) => Service.fromJson(e)).toList();
  }
}
