// lib/core/network/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cureeit_user_app/BaseUrl.dart';

class ApiService {
  final http.Client client;
  ApiService(this.client);

  Future<dynamic> post(
    String endpoint, {
    Map<String, String>? headers,
    Map<String, dynamic>? body,
  }) async {
    final url = Uri.parse('$baseUrl$endpoint');
    final response = await client.post(
      url,
      headers: headers ?? {'Content-Type': 'application/json'},
      body: body != null ? jsonEncode(body) : null,
    );

    return _processResponse(response);
  }

   Future<dynamic> put(
    String endpoint, {
    Map<String, String>? headers,
    Map<String, dynamic>? body,
  }) async {
    final url = Uri.parse('$baseUrl$endpoint');
    final response = await client.put(
      url,
      headers: headers ?? {'Content-Type': 'application/json'},
      body: body != null ? jsonEncode(body) : null,
    );

    return _processResponse(response);
  }

  Future<dynamic> delete(
    String endpoint, {
    Map<String, String>? headers,
    Map<String, dynamic>? body,
  }) async {
    final url = Uri.parse('$baseUrl$endpoint');
    final response = await client.delete(
      url,
      headers: headers ?? {'Content-Type': 'application/json'},
      body: body != null ? jsonEncode(body) : null,
    );

    return _processResponse(response);
  }

  Future<dynamic> get(
    String endpoint, {
    Map<String, String>? headers,
    
  }) async {
    final url = Uri.parse('$baseUrl$endpoint');
    final response = await client.get(
      url,
      headers: headers ?? {'Content-Type': 'application/json'},
     
     
    );

    return _processResponse(response);
  }

  dynamic _processResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode <= 400) {
      return response;
    } else {
      throw Exception(
          'API Error: ${response.statusCode} → ${response.reasonPhrase}');
    }
  }
}
