import 'package:cureeit_user_app/screens/home/presentation/providers/service_providers.dart';
import 'package:cureeit_user_app/screens/home/presentation/widget/product_grid.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomeScreen extends ConsumerWidget {
  final String latitude;
  final String longitude;

  const HomeScreen({
    super.key,
    required this.latitude,
    required this.longitude,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final servicesAsync = ref.watch(servicesProvider((latitude, longitude)));

    return Scaffold(
      backgroundColor: Colors.black,
      body: servicesAsync.when(
        data: (services) => CustomScrollView(
          slivers: [
            ProductGrid(services: services),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator(color: Colors.white)),
        error: (err, _) => Center(child: Text("Error: $err", style: const TextStyle(color: Colors.red))),
      ),
    );
  }
}
