// lib/screens/home/application/service_providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cureeit_user_app/Networking/network_provider.dart';
import 'package:cureeit_user_app/screens/home/domain/repositiries/productRepo/service_repository.dart';
import 'package:cureeit_user_app/screens/home/domain/repositiries/productRepo/service_repository_impl.dart';
import 'package:cureeit_user_app/screens/home/domain/usecases/get_services.dart';
import 'package:cureeit_user_app/screens/home/domain/entities/productEntities.dart';

// Provide ServiceRepositoryImpl
final serviceRepositoryProvider = Provider<ServiceRepository>((ref) {
  final api = ref.watch(apiServiceProvider);
  return ServiceRepositoryImpl(api);
});

// Provide GetServices usecase
final getServicesProvider = Provider<GetServices>((ref) {
  final repo = ref.watch(serviceRepositoryProvider);
  return GetServices(repo);
});

// Async fetch services based on location
final servicesProvider = FutureProvider.family<List<ProductEntity>, (String, String)>((ref, params) async {
  final getServices = ref.watch(getServicesProvider);
  final (lat, lng) = params;
  return getServices(lat, lng);
});
