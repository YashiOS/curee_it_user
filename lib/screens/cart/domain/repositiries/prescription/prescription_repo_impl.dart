import 'dart:convert';
import 'package:cureeit_user_app/Networking/api_service.dart';
import 'package:http/http.dart' as http;
import 'prescription_repo.dart'; // <-- import your abstract repo

class PrescriptionRepoImpl implements PrescriptionRepo {
  final ApiService apiService;
  PrescriptionRepoImpl({required this.apiService});

  @override
  Future<String> sendPrescription(
      String userId, List<String> prescriptions) async {
    final body = {
      "userId": userId,
      "prescriptionPhotos": prescriptions, // base64 list
    };

    final response =
        await apiService.post("/order/createPrescription", body: body);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data["data"]["availableID"] ?? "";
    } else {
      throw Exception(
        "Failed to send prescription: ${response.body} ${response.statusCode}",
      );
    }
  }

  @override
  Future<String> checkPrescriptionStatus(String availableId) async {
    final body = {
      "availableId": availableId,
    };

    final response =
        await apiService.post("/order/orderTracking", body: body);

    if (response.statusCode == 200) {
      final responseBody = jsonDecode(response.body);
      final data = responseBody["data"];

     
      final status = (data is List && data.isNotEmpty)
          ? data[0]["status"] ?? "Unknown"
          : "Unknown";

      return status;
    } else {
      throw Exception(
        "Failed to load prescription status: ${response.body} ${response.statusCode}",
      );
    }
  }
}
