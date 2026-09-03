import 'vaccination.dart';

/// Abstract repository interface for Vaccination data
///
/// Implemented by ApiVaccinationRepository, which calls the backend REST
/// API. The backend auto-generates the standard PEV schedule for a patient
/// the first time it's requested.
abstract class VaccinationRepository {
  /// Get the immunization schedule for a patient
  Future<List<Vaccination>> getScheduleForPatient(String patientId);

  /// Mark a dose as administered
  Future<Vaccination> markAdministered(String vaccinationId, {DateTime? administeredDate});
}
