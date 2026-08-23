
abstract class PrescriptionRepo {
  Future<String> sendPrescription(String userId, List<String> prescriptions);
  Future<String> checkPrescriptionStatus(String availableId);
  Future<String> submitDoctorCallConsent(String userId, bool allowDoctorCall);
  Future<String> checkDoctorStatus(String userId, String availableId);
}
