// repository/payment_repo_impl.dart
import 'dart:convert';
import 'package:cureeit_user_app/Networking/api_service.dart';
import 'package:cureeit_user_app/screens/cart/domain/entities/paymentEntity.dart';
import 'package:cureeit_user_app/screens/cart/domain/repositiries/payment/payment_repo.dart';


class PaymentRepoImpl implements PaymentRepository {
  final ApiService apiService;

  PaymentRepoImpl({required this.apiService});

  @override
  Future<PaymentOrderData> getPaymentSessionId({
    required dynamic userId,
    required dynamic totalAmount,
    required dynamic availableId,
  }) async {
    final body = {
      'userId': userId,
      'totalAmount': totalAmount.toString(),
      'availableID': availableId,
    };
    
    final response =
        await apiService.post('/cashfree/getPaymentSessionID', body: body);
    print("SESSION ID IS ${response.statusCode}");
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      // adapt to API structure
      return PaymentOrderData.fromJson(data);
    } else {
      throw Exception(
          'Failed to get payment session id: ${response.statusCode} ${response.body}');
    }
  }

  @override
  Future<bool> verifyPaymentStatus({
    required String orderId,
    required String availableId,
  }) async {
    final body = {'orderId': orderId, 'availableID': availableId};
   print("orderId $orderId");
   print("avilableId $availableId");
    final response =
        await apiService.post('/cashfree/getPaymentStatus', body: body);
   print(response.body);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      // API returned {"paymentStatus": true/false}
      return data['paymentStatus'] == true;
    } else {
      throw Exception(
          'Failed to verify payment status: ${response.statusCode} ${response.body}');
    }
  }

  @override
  Future<String> createCheckout({
    required String userId,
    required String shippingAddress,
    required String availableId,
    required dynamic userLat,
    required dynamic userLong,
  }) async {
    final body = {
      "userId": userId,
      "shippingAddress": shippingAddress,
      "availableId": availableId,
      "userLat":26.849360569751255 ,//userLat,
      "userLong": 75.81019337116403//userLong,
    };

    final response =
        await apiService.post('/order/createCheckout', body: body);
   print(response.body);  
    if (response.statusCode == 200) {
      print("ORDER CREATED");
      final data = jsonDecode(response.body);
      // return availableID of created order (or whatever id you need)
      return data['data']?['availableID'] ?? '';
    } else {
      throw Exception(
          'Failed to create checkout: ${response.statusCode} ${response.body}');
    }
  }
}
