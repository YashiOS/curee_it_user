import 'package:cureeit_user_app/screens/home/domain/entities/productEntities.dart';

abstract class ServiceRepository {
  Future<List<ProductEntity>> fetchServices(String latitude, String longitude);
 
}
