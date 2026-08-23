import 'dart:convert';
import 'package:cureeit_user_app/Networking/api_service.dart';
import 'prescription_repo.dart'; // <-- import your abstract repo

class PrescriptionRepoImpl implements PrescriptionRepo {
  final ApiService apiService;
  PrescriptionRepoImpl({required this.apiService});

  @override
  Future<String> sendPrescription(
      String userId, List<String> prescriptions) async {
    final body = {
      "userId": userId,
      "prescriptionPhotos": prescriptions,
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

  @override
  Future<String> submitDoctorCallConsent(String userId, bool allowDoctorCall) async {
    final body = {
      "userId": userId,
      "allowDoctorCall": allowDoctorCall,
    };

    final response = await apiService.post(
      "/cart/sendRequestToDoctor",
      body: body,
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
        "Failed to submit doctor call consent: ${response.body} ${response.statusCode}",
      );
    }

    final responseBody = jsonDecode(response.body);
    final data = responseBody["data"] ?? responseBody;

    if (data is Map) {
      final availableId = data["availableID"] ?? data["availableId"] ?? '';
      if (availableId is String && availableId.isNotEmpty) {
        return availableId;
      }
    }

    return '';
  }

  @override
  Future<String> checkDoctorStatus(String userId, String availableId) async {
    final body = {
      "userId": userId,
      "availableID": availableId
    };

    final response = await apiService.post(
      "/cart/doctorStatus",
      body: body,
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
        "Failed to fetch doctor status: ${response.body} ${response.statusCode}",
      );
    }

    final responseBody = jsonDecode(response.body);
    final data = responseBody["data"] ?? responseBody;

    if (data is Map) {
      final status = data["status"] ?? data["doctorStatus"] ?? '';
      if (status is String) return status;
    }

    if (data is List && data.isNotEmpty && data.first is Map) {
      final status = data.first["status"] ?? data.first["doctorStatus"] ?? '';
      if (status is String) return status;
    }

    return 'Unknown';
  }
}
