
abstract class PrescriptionRepo {
  Future<String> sendPrescription(String userId,List<String> prescriptions);
}
