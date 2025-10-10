import 'package:cureeit_user_app/screens/home/domain/entities/productEntities.dart';
import 'package:cureeit_user_app/screens/home/domain/repositiries/productRepo/service_repository.dart';

class GetServices {
  final ServiceRepository repository;
  GetServices(this.repository);

  Future<List<ProductEntity>> call(String latitude, String longitude) {
    return repository.fetchServices(latitude, longitude);
  }
}
