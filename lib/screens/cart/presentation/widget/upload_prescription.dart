import 'dart:io';

import 'package:cureeit_user_app/screens/cart/presentation/provider/prescription_provider.dart';
import 'package:cureeit_user_app/screens/otp/presentation/provider/otpProvider.dart';
import 'package:cureeit_user_app/utils/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

class UploadPrescriptionBottomSheet extends ConsumerWidget {
  const UploadPrescriptionBottomSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userId = ref.read(OtpNotifierProvider).user!.userId;
    final prescriptionState = ref.watch(prescriptionProvider);
    final notifier = ref.read(prescriptionProvider.notifier);

    ref.listen<PrescriptionState>(prescriptionProvider, (previous, next) {
      if (next.prescriptionStatus == "Accepted") {
        final modalRoute = ModalRoute.of(context);
        if (modalRoute != null && modalRoute.isCurrent) {
          Navigator.of(context).pop();
        }
      }
    });

    return Container(
      decoration: BoxDecoration(
        color: lightWhiteColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      width: MediaQuery.of(context).size.width,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 20),
          Text(
            "Upload Prescription",
            style: GoogleFonts.mulish(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: blackColor,
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              "You can select multiple prescription images",
              textAlign: TextAlign.center,
              style: GoogleFonts.mulish(
                fontSize: 12,
                color: greyColor,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Image Grid
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: SingleChildScrollView(
              scrollDirection:
                  Axis.horizontal, // 👈 Makes it scrollable left/right
              child: Row(
                children: [
                  for (int i = 0; i < prescriptionState.images.length; i++)
                    Padding(
                      padding: const EdgeInsets.only(
                          right: 12), // spacing between items
                      child: _buildImageContainer(
                        prescriptionState.images[i],
                        i,
                        notifier,
                      ),
                    ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Add Button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: GestureDetector(
              onTap: () => notifier.pickImages(userId),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color:  scaffoldWhiteColor,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: greenColor, width: 1),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add, color: greenColor, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      "${prescriptionState.AddPrescriptionButton}",
                      style: GoogleFonts.mulish(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: greenColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildImageContainer(
      XFile file, int index, PrescriptionNotifier notifier) {
    return Stack(
      children: [
        Container(
          width: 100,
          height: 140,
          margin: const EdgeInsets.only(top: 10, right: 10),
          decoration: BoxDecoration(
            color:  scaffoldWhiteColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: greenColor.withOpacity(0.3), width: 1),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.file(
              File(file.path),
              fit: BoxFit.cover,
            ),
          ),
        ),
        Positioned(
          top: 4,
          right: 4,
          child: GestureDetector(
            onTap: () => notifier.removeImage(index),
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              padding: const EdgeInsets.all(4),
              child: const Icon(Icons.close, size: 14, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}
