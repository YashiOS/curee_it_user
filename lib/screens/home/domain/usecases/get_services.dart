import 'package:cureeit_user_app/screens/home/domain/entities/service.dart';
import 'package:cureeit_user_app/screens/home/domain/repositiries/service_repository.dart';

class GetServices {
  final ServiceRepository repository;
  GetServices(this.repository);

  Future<List<Service>> call(String latitude, String longitude) {
    return repository.fetchServices(latitude, longitude);
  }
}
