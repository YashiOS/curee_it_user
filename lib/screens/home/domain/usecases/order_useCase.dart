
import 'package:cureeit_user_app/screens/home/domain/entities/orderEntity.dart';
import 'package:cureeit_user_app/screens/home/domain/repositiries/orderRepo/order_repository.dart';



class OrderUseCase {
  final OrderRepository repository;

  OrderUseCase({required this.repository});

  Future<List<OrderEntity>> fetchOrderHistory(String userId) {
    return repository.fetchOrderHistory(userId);
  }

  Future<bool> checkLocation(double latitude, double longitude) {
    return repository.checklocation(latitude, longitude);
  }

  Future<String> getEstimatedTime(double latitude, double longitude) {
    return repository.getEstimatedTime(latitude, longitude);
  }

  Future<dynamic> checkServiceability(double latitude ,double longitude){
   return repository.checkServiceability(latitude, longitude);
  }
}
