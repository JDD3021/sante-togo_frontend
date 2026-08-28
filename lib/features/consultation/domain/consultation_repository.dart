import 'consultation.dart';

/// Abstract repository interface for Consultation data
/// 
/// This interface defines the contract for consultation data operations.
/// Currently implemented by MockConsultationRepository with in-memory data.
/// In future iterations, this will be replaced by ApiConsultationRepository
/// that calls the real backend REST API.
/// 
/// NOTE: This is a MOCK implementation. Replace with real API calls
/// when the backend is ready.
abstract class ConsultationRepository {
  /// Get all consultations for a patient
  Future<List<Consultation>> getConsultationsByPatient(String patientId);

  /// Get consultation by ID
  Future<Consultation?> getConsultationById(String id);

  /// Create a new consultation
  Future<Consultation> createConsultation(Consultation consultation);

  /// Update an existing consultation
  Future<Consultation> updateConsultation(Consultation consultation);

  /// Delete a consultation
  Future<void> deleteConsultation(String id);

  /// Get consultations for a specific date range
  Future<List<Consultation>> getConsultationsByDateRange(
    DateTime startDate,
    DateTime endDate,
  );
}
