import 'package:cureeit_user_app/screens/cart/domain/repositiries/prescription/prescription_repo_impl.dart';

class PrescriptionUsecases {
  final PrescriptionRepoImpl repository;
  PrescriptionUsecases(this.repository);

  Future<String> sendPrescription(String userId, List<String> base64List) {
    return repository.sendPrescription(userId, base64List);
  }

  Future<String> checkPrescriptionStatus(String availableId) {
    return repository.checkPrescriptionStatus(availableId);
  }
}
