import 'dart:convert';
import 'package:cureeit_user_app/Networking/api_service.dart';
import 'package:cureeit_user_app/screens/order%20again/domain/entities/reorderEntity.dart';
import 'package:cureeit_user_app/screens/order%20again/domain/repositiries/reorder_repo.dart';
import 'package:http/http.dart' as http;
import 'package:cureeit_user_app/BaseUrl.dart';

class ReorderRepositoryImpl implements ReorderRepository {
   final ApiService apiService;
   ReorderRepositoryImpl({required this.apiService});
  @override
  Future<bool> reorderItems(ReorderEntity reorderEntity) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/cart/addMultipleToCart'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(reorderEntity.toJson()),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        print("Failed reorder: ${response.body}");
        return false;
      }
    } catch (e) {
      print("Reorder Exception: $e");
      return false;
    }
  }
}
