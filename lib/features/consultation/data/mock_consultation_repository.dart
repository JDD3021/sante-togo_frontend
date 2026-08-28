import '../domain/consultation.dart';
import '../domain/consultation_repository.dart';

/// Mock implementation of ConsultationRepository
/// 
/// This repository uses in-memory data to simulate a real backend.
/// It contains realistic consultation data for demonstration.
/// 
/// NOTE: This is a MOCK implementation. Replace with ApiConsultationRepository
/// when the backend REST API is ready. The interface (ConsultationRepository)
/// ensures the rest of the code doesn't need to change.
class MockConsultationRepository implements ConsultationRepository {
  final List<Consultation> _consultations;

  MockConsultationRepository() : _consultations = _generateMockConsultations();

  @override
  Future<List<Consultation>> getConsultationsByPatient(String patientId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _consultations.where((c) => c.patientId == patientId).toList();
  }

  @override
  Future<Consultation?> getConsultationById(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    try {
      return _consultations.firstWhere((c) => c.id == id);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<Consultation> createConsultation(Consultation consultation) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final newConsultation = consultation.copyWith(
      id: 'CON${DateTime.now().millisecondsSinceEpoch}',
      createdAt: DateTime.now(),
    );
    _consultations.add(newConsultation);
    return newConsultation;
  }

  @override
  Future<Consultation> updateConsultation(Consultation consultation) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final index = _consultations.indexWhere((c) => c.id == consultation.id);
    if (index != -1) {
      _consultations[index] = consultation;
      return _consultations[index];
    }
    throw Exception('Consultation not found');
  }

  @override
  Future<void> deleteConsultation(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _consultations.removeWhere((c) => c.id == id);
  }

  @override
  Future<List<Consultation>> getConsultationsByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _consultations.where((c) {
      return c.date.isAfter(startDate) && c.date.isBefore(endDate);
    }).toList();
  }

  /// Generate realistic mock consultation data
  static List<Consultation> _generateMockConsultations() {
    final now = DateTime.now();
    return [
      // Consultations for PAT001 (Kofi Kokou)
      Consultation(
        id: 'CON001',
        patientId: 'PAT001',
        date: now.subtract(const Duration(days: 30)),
        reason: 'Fièvre',
        diagnosis: 'Paludisme',
        prescription: 'Artemisinine 3 jours',
        temperature: 38.5,
        systolicBP: 120,
        diastolicBP: 80,
        weight: 70.0,
        followUpDate: now.subtract(const Duration(days: 23)).toIso8601String(),
        followUpMethod: 'SMS',
        notes: 'Patient répond bien au traitement',
        createdAt: now.subtract(const Duration(days: 30)),
      ),
      Consultation(
        id: 'CON002',
        patientId: 'PAT001',
        date: now.subtract(const Duration(days: 15)),
        reason: 'Contrôle',
        diagnosis: 'Guéri',
        prescription: null,
        temperature: 36.8,
        systolicBP: 118,
        diastolicBP: 78,
        weight: 70.5,
        followUpDate: null,
        followUpMethod: null,
        notes: 'Pas de fièvre, bon état général',
        createdAt: now.subtract(const Duration(days: 15)),
      ),
      // Consultations for PAT002 (Awa Kossi - has allergy)
      Consultation(
        id: 'CON003',
        patientId: 'PAT002',
        date: now.subtract(const Duration(days: 25)),
        reason: 'Douleur abdominale',
        diagnosis: 'Gastrite',
        prescription: 'Oméprazole 20mg',
        temperature: 37.0,
        systolicBP: 110,
        diastolicBP: 70,
        weight: 58.0,
        followUpDate: now.subtract(const Duration(days: 18)).toIso8601String(),
        followUpMethod: 'SMS',
        notes: 'Attention: allergie pénicilline notée',
        createdAt: now.subtract(const Duration(days: 25)),
      ),
      // Consultations for PAT003 (Yao Agbéyomé - chronic condition)
      Consultation(
        id: 'CON004',
        patientId: 'PAT003',
        date: now.subtract(const Duration(days: 20)),
        reason: 'Contrôle hypertension',
        diagnosis: 'Hypertension stable',
        prescription: 'Lisinopril 10mg',
        temperature: 36.5,
        systolicBP: 135,
        diastolicBP: 85,
        weight: 75.0,
        followUpDate: now.toIso8601String(),
        followUpMethod: 'SMS',
        notes: 'Tension bien contrôlée, continuer traitement',
        createdAt: now.subtract(const Duration(days: 20)),
      ),
      Consultation(
        id: 'CON005',
        patientId: 'PAT003',
        date: now.subtract(const Duration(days: 10)),
        reason: 'Toux',
        diagnosis: 'Rhume',
        prescription: 'Paracétamol si besoin',
        temperature: 37.2,
        systolicBP: 130,
        diastolicBP: 82,
        weight: 75.0,
        followUpDate: null,
        followUpMethod: null,
        notes: 'Pas d\'antibiotique nécessaire',
        createdAt: now.subtract(const Duration(days: 10)),
      ),
      // Consultation for PAT005 (Komlan Améwuga - multiple allergies)
      Consultation(
        id: 'CON006',
        patientId: 'PAT005',
        date: now.subtract(const Duration(days: 10)),
        reason: 'Douleur articulaire',
        diagnosis: 'Arthrose',
        prescription: 'Paracétamol (éviter AINS)',
        temperature: 36.8,
        systolicBP: 140,
        diastolicBP: 90,
        weight: 80.0,
        followUpDate: now.subtract(const Duration(days: 3)).toIso8601String(),
        followUpMethod: 'SMS',
        notes: 'Attention: allergies aspirine et ibuprofène. Diabète type 2.',
        createdAt: now.subtract(const Duration(days: 10)),
      ),
    ];
  }
}
