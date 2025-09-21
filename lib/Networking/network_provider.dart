import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'api_service.dart';

final httpClientProvider = Provider((ref) => http.Client());

final apiServiceProvider = Provider<ApiService>((ref) {
  final client = ref.watch(httpClientProvider);
  return ApiService(client);
});
