import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../domain/entities/service.dart';

class ProductCard extends StatelessWidget {
  final Service service;

  const ProductCard({super.key, required this.service});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          service.imageMediaUrls.isNotEmpty && service.imageMediaUrls[0].isNotEmpty
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    service.imageMediaUrls[0],
                    height: 100,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                )
              : Container(
                  height: 100,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[800],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.image, color: Colors.white),
                ),
          const SizedBox(height: 8),
          Text(
            service.name,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.mulish(color: Colors.white, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Text(
            "₹${service.discountedPrice}",
            style: GoogleFonts.mulish(color: Colors.greenAccent, fontWeight: FontWeight.bold),
          ),
          if (service.discountedPrice < service.price)
            Text(
              "₹${service.price}",
              style: GoogleFonts.mulish(
                color: Colors.grey,
                decoration: TextDecoration.lineThrough,
              ),
            ),
        ],
      ),
    );
  }
}
