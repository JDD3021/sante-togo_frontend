import 'patient.dart';

/// Abstract repository interface for Patient data
/// 
/// This interface defines the contract for patient data operations.
/// Implemented by ApiPatientRepository, which calls the backend REST API.
abstract class PatientRepository {
  /// Get all patients
  Future<List<Patient>> getAllPatients();

  /// Get patient by ID
  Future<Patient?> getPatientById(String id);

  /// Search patients by name or village
  Future<List<Patient>> searchPatients(String query);

  /// Get recently viewed patients
  Future<List<Patient>> getRecentlyViewed(int limit);

  /// Create a new patient
  Future<Patient> createPatient(Patient patient);

  /// Update an existing patient
  Future<Patient> updatePatient(Patient patient);

  /// Delete a patient
  Future<void> deletePatient(String id);
}
