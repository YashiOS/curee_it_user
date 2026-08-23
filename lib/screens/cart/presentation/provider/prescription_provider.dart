import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cureeit_user_app/Networking/api_service.dart';
import 'package:cureeit_user_app/screens/cart/domain/repositiries/prescription/prescription_repo_impl.dart';
import 'package:cureeit_user_app/screens/cart/domain/usecases/prescription_useCases.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

/// State class
class PrescriptionState {
  final List<XFile> images; // Original images (if needed in UI)
  final List<String> base64List;
  final String AvailableId;
  final String prescriptionStatus;
  final String AddPrescriptionButton;
  final int countdown;
  final bool payNow;
  final bool doctorCallLocked;

  PrescriptionState({
    this.images = const [],
    this.base64List = const [],
    this.AvailableId = '',
    this.prescriptionStatus = '',
    this.AddPrescriptionButton = 'Upload Prescription',
    this.countdown = 30,
    this.payNow = false,
    this.doctorCallLocked = false,
  });

  PrescriptionState copyWith({
    List<XFile>? images,
    List<String>? base64List,
    String? availableId,
    String? prescriptionStatus,
    String? AddPrescriptionButton,
    int? countdown,
    bool? payNow,
    bool? doctorCallLocked,
  }) {
    return PrescriptionState(
      AvailableId: availableId ?? this.AvailableId,
      images: images ?? this.images,
      base64List: base64List ?? this.base64List,
      prescriptionStatus: prescriptionStatus ?? this.prescriptionStatus,
      AddPrescriptionButton: AddPrescriptionButton ?? this.AddPrescriptionButton,
      countdown: countdown ?? this.countdown,
      payNow: payNow ?? this.payNow,
      doctorCallLocked: doctorCallLocked ?? this.doctorCallLocked,
    );
  }
}

/// Notifier
class PrescriptionNotifier extends StateNotifier<PrescriptionState> {
  final PrescriptionUsecases usecases;
  final ImagePicker _picker = ImagePicker();
  Timer? pollingTimer;
  Timer? countdownTimer;
  Timer? doctorStatusTimer;
  int elapsedSeconds = 0;

  PrescriptionNotifier(this.usecases) : super(PrescriptionState()) {}

  Future<void> pickImages(String userId) async {
    try {
      final List<XFile>? pickedFiles = await _picker.pickMultiImage(
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );

      if (pickedFiles != null && pickedFiles.isNotEmpty) {
        final updated = [...state.images, ...pickedFiles];
        state = state.copyWith(images: updated);

        // Convert new images to base64
        await _convertToBase64(updated);
        sendPrescription(userId);
      
      }
    } catch (e) {
      print("Error picking images: $e");
    }
  }

  Future<String> sendPrescription(String userId) async {
    try {
     
      final availableId = await usecases.sendPrescription(
        userId,
        state.base64List,
      );

      // update state with response
      state = state.copyWith(availableId: availableId);
      startCountdownTimer();
      print('Available ID is ${availableId}');
      startPolling(availableId);
      print("Prescription sent successfully. AvailableId: $availableId");
      return availableId;
    } catch (e) {
      print("Error sending prescription: $e");
      rethrow;
    }
  }
   void startCountdownTimer() {
    countdownTimer?.cancel();

    countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.prescriptionStatus == "Accepted") {
        timer.cancel();
        return;
      }

      int newCountdown = state.countdown - 1;
      if (newCountdown <= 0) newCountdown = 30;

      state = state.copyWith(
        AddPrescriptionButton:
            "Verifying Prescription in $newCountdown sec",
        countdown: newCountdown,
      );

      print("Countdown: $newCountdown");
    });
  }

   void startPolling(String availableId) {
    pollingTimer?.cancel();

    pollingTimer = Timer.periodic(const Duration(seconds: 5), (timer) async {
      elapsedSeconds += 5;

      if (elapsedSeconds >= 1200) {
        timer.cancel();
        countdownTimer?.cancel();
        print("Polling stopped after 10 minutes.");
        return;
      }

      print("Checking prescription status...");
      String status = await checkPrescriptionStatus(availableId);
      print(status);
      if (status == "Accepted") {
        print("Prescription is now AVAILABLE!");
        timer.cancel();
        countdownTimer?.cancel();

        state = state.copyWith(
          AddPrescriptionButton: "Prescription Verified",
          payNow: true,
        );
      }
      if(status=="Rejected"){
         timer.cancel();
        countdownTimer?.cancel();

        state = state.copyWith(
          AddPrescriptionButton: "Prescription Rejected",
          availableId:null, 
          images:[],
          base64List: [],


        );
      }
    });
  }

    Future<String> checkPrescriptionStatus(String availableId) async {
    try {
      final status = await usecases.checkPrescriptionStatus(availableId);

      state = state.copyWith(prescriptionStatus: status);

      if (status == "In Verification") {
        state = state.copyWith(
         AddPrescriptionButton:
              "Verifying Prescription in ${state.countdown} sec",
        );
      }

      return status;
    } catch (e) {
      print("Error checking prescription status: $e");
      return "Error";
    }
  }

  Future<void> submitDoctorCallConsent(String userId, bool allowDoctorCall) async {
    try {
      final availableId = await usecases.submitDoctorCallConsent(userId, allowDoctorCall);

      if (allowDoctorCall) {
        state = state.copyWith(
          availableId: availableId,
          payNow: false,
          doctorCallLocked: true,
          prescriptionStatus: 'Pending doctor review',
        );
        startDoctorStatusPolling(userId, availableId);
      } else {
        resetWithoutPrescription();
      }
    } catch (e) {
      print('Doctor call consent request failed: $e');
      rethrow;
    }
  }

  void startDoctorStatusPolling(String userId, String availableId) {
    if (availableId.isEmpty) {
      return;
    }

    doctorStatusTimer?.cancel();

    doctorStatusTimer = Timer.periodic(const Duration(seconds: 5), (timer) async {
      try {
        final status = await usecases.checkDoctorStatus(userId, availableId);
        print('doctorStatus => $status');

        if (status.trim() == 'Rejected by doctor') {
          timer.cancel();
          state = state.copyWith(
            doctorCallLocked: false,
            payNow: false,
            prescriptionStatus: status,
            AddPrescriptionButton: 'Upload Prescription',
          );
          return;
        }

        state = state.copyWith(
          doctorCallLocked: true,
          payNow: false,
          prescriptionStatus: status,
        );
      } catch (e) {
        print('Doctor status polling failed: $e');
      }
    });
  }

  void continueWithoutPrescription() {
    state = state.copyWith(
      payNow: false,
      doctorCallLocked: true,
      prescriptionStatus: 'Pending doctor review',
      AddPrescriptionButton: 'Continue without Prescription',
    );
  }

  void resetWithoutPrescription() {
    doctorStatusTimer?.cancel();
    doctorStatusTimer = null;
    state = state.copyWith(
      payNow: false,
      doctorCallLocked: false,
      prescriptionStatus: 'Declined',
      AddPrescriptionButton: 'Upload Prescription',
    );
  }

  void removeImage(int index) async {
    final updated = [...state.images]..removeAt(index);
    state = state.copyWith(images: updated);

    // Re-generate base64 after removal
    await _convertToBase64(updated);
  }

  /// Compress + convert to base64
  Future<void> _convertToBase64(List<XFile> files) async {
    List<String> base64List = [];

    for (var file in files) {
      try {
        final compressed = await _compressImage(File(file.path));
        final bytes = await compressed!.readAsBytes();
        String base64Str = await base64Encode(bytes);

        base64List.add(base64Str);
      } catch (e) {
        print("Error converting to base64: $e");
      }
    }

    state = state.copyWith(base64List: base64List);
  }

  /// Compress the image using flutter_image_compress
  Future<XFile?> _compressImage(File file) async {
    final dir = await getTemporaryDirectory();
    final targetPath = path.join(
      dir.absolute.path,
      "${DateTime.now().millisecondsSinceEpoch}_${path.basename(file.path)}",
    );

    final result = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      targetPath,
      quality: 70, // adjust quality as needed
    );

    return result;
  }


}

final apiServiceProvider =
    Provider<ApiService>((ref) => ApiService(http.Client()));

final prescriptionRepo = Provider<PrescriptionRepoImpl>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return PrescriptionRepoImpl(apiService: apiService);
});

final prescriptionUsecases = Provider<PrescriptionUsecases>((ref) {
  final repository = ref.watch(prescriptionRepo);
  return PrescriptionUsecases( repository);
});

final prescriptionProvider =
    StateNotifierProvider<PrescriptionNotifier, PrescriptionState>((ref) {
  final useCase = ref.watch(prescriptionUsecases);
  return PrescriptionNotifier(useCase);
});
