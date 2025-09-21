import 'package:cureeit_user_app/screens/home/domain/entities/service.dart';

abstract class ServiceRepository {
  Future<List<Service>> fetchServices(String latitude, String longitude);
}
