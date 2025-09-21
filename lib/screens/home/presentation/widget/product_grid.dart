import 'package:cureeit_user_app/screens/home/presentation/widget/products_cart.dart';
import 'package:flutter/material.dart';
import '../../domain/entities/service.dart';

class ProductGrid extends StatelessWidget {
  final List<Service> services;

  const ProductGrid({super.key, required this.services});

  @override
  Widget build(BuildContext context) {
    int itemCount = (services.length / 2).ceil();
    if (services.length > 8) itemCount = 4;

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, rowIndex) {
          int firstIndex = rowIndex * 2;
          int secondIndex = firstIndex + 1;

          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            child: Row(
              children: [
                Expanded(child: ProductCard(service: services[firstIndex])),
                const SizedBox(width: 16),
                secondIndex < services.length
                    ? Expanded(child: ProductCard(service: services[secondIndex]))
                    : const Expanded(child: SizedBox()),
              ],
            ),
          );
        },
        childCount: itemCount,
      ),
    );
  }
}
