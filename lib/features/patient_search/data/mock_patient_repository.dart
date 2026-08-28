import '../domain/patient.dart';
import '../domain/patient_repository.dart';

/// Mock implementation of PatientRepository
/// 
/// This repository uses in-memory data to simulate a real backend.
/// It contains realistic Togolese patient data for demonstration.
/// 
/// NOTE: This is a MOCK implementation. Replace with ApiPatientRepository
/// when the backend REST API is ready. The interface (PatientRepository)
/// ensures the rest of the code doesn't need to change.
class MockPatientRepository implements PatientRepository {
  final List<Patient> _patients;

  MockPatientRepository() : _patients = _generateMockPatients();

  @override
  Future<List<Patient>> getAllPatients() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 300));
    return List.from(_patients);
  }

  @override
  Future<Patient?> getPatientById(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    try {
      return _patients.firstWhere((p) => p.id == id);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<List<Patient>> searchPatients(String query) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final lowerQuery = query.toLowerCase();
    return _patients.where((p) {
      return p.fullName.toLowerCase().contains(lowerQuery) ||
          p.village.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  @override
  Future<List<Patient>> getRecentlyViewed(int limit) async {
    await Future.delayed(const Duration(milliseconds: 200));
    // Return first N patients as "recently viewed" for demo
    return _patients.take(limit).toList();
  }

  @override
  Future<Patient> createPatient(Patient patient) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final newPatient = patient.copyWith(
      id: 'PAT${DateTime.now().millisecondsSinceEpoch}',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    _patients.add(newPatient);
    return newPatient;
  }

  @override
  Future<Patient> updatePatient(Patient patient) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final index = _patients.indexWhere((p) => p.id == patient.id);
    if (index != -1) {
      _patients[index] = patient.copyWith(updatedAt: DateTime.now());
      return _patients[index];
    }
    throw Exception('Patient not found');
  }

  @override
  Future<void> deletePatient(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _patients.removeWhere((p) => p.id == id);
  }

  /// Generate realistic mock Togolese patient data
  static List<Patient> _generateMockPatients() {
    final now = DateTime.now();
    return [
      Patient(
        id: 'PAT001',
        firstName: 'Kofi',
        lastName: 'Kokou',
        birthYear: 1985,
        sex: 'M',
        village: 'Lomé',
        phoneNumber: '+22890012345',
        allergies: null,
        chronicConditions: null,
        createdAt: now.subtract(const Duration(days: 30)),
        updatedAt: now.subtract(const Duration(days: 30)),
      ),
      Patient(
        id: 'PAT002',
        firstName: 'Awa',
        lastName: 'Kossi',
        birthYear: 1990,
        sex: 'F',
        village: 'Kara',
        phoneNumber: '+22890012346',
        allergies: ['Pénicilline'],
        chronicConditions: null,
        createdAt: now.subtract(const Duration(days: 25)),
        updatedAt: now.subtract(const Duration(days: 25)),
      ),
      Patient(
        id: 'PAT003',
        firstName: 'Yao',
        lastName: 'Agbéyomé',
        birthYear: 1978,
        sex: 'M',
        village: 'Sokodé',
        phoneNumber: '+22890012347',
        allergies: null,
        chronicConditions: 'Hypertension',
        createdAt: now.subtract(const Duration(days: 20)),
        updatedAt: now.subtract(const Duration(days: 20)),
      ),
      Patient(
        id: 'PAT004',
        firstName: 'Mawunyo',
        lastName: 'Tchassim',
        birthYear: 1995,
        sex: 'F',
        village: 'Atakpamé',
        phoneNumber: '+22890012348',
        allergies: null,
        chronicConditions: null,
        createdAt: now.subtract(const Duration(days: 15)),
        updatedAt: now.subtract(const Duration(days: 15)),
      ),
      Patient(
        id: 'PAT005',
        firstName: 'Komlan',
        lastName: 'Améwuga',
        birthYear: 1965,
        sex: 'M',
        village: 'Tsévié',
        phoneNumber: '+22890012349',
        allergies: ['Aspirine', 'Ibuprofène'],
        chronicConditions: 'Diabète type 2',
        createdAt: now.subtract(const Duration(days: 10)),
        updatedAt: now.subtract(const Duration(days: 10)),
      ),
      Patient(
        id: 'PAT006',
        firstName: 'Sélom',
        lastName: 'Kpotou',
        birthYear: 2000,
        sex: 'M',
        village: 'Kpalimé',
        phoneNumber: '+22890012350',
        allergies: null,
        chronicConditions: null,
        createdAt: now.subtract(const Duration(days: 8)),
        updatedAt: now.subtract(const Duration(days: 8)),
      ),
      Patient(
        id: 'PAT007',
        firstName: 'Edem',
        lastName: 'Kodjo',
        birthYear: 1988,
        sex: 'M',
        village: 'Bassar',
        phoneNumber: '+22890012351',
        allergies: null,
        chronicConditions: 'Asthme',
        createdAt: now.subtract(const Duration(days: 5)),
        updatedAt: now.subtract(const Duration(days: 5)),
      ),
      Patient(
        id: 'PAT008',
        firstName: 'Akossiwa',
        lastName: 'Mawulé',
        birthYear: 1992,
        sex: 'F',
        village: 'Notsé',
        phoneNumber: '+22890012352',
        allergies: null,
        chronicConditions: null,
        createdAt: now.subtract(const Duration(days: 3)),
        updatedAt: now.subtract(const Duration(days: 3)),
      ),
      Patient(
        id: 'PAT009',
        firstName: 'Koffi',
        lastName: 'Sénam',
        birthYear: 1972,
        sex: 'M',
        village: 'Dapaong',
        phoneNumber: '+22890012353',
        allergies: ['Sulfamides'],
        chronicConditions: null,
        createdAt: now.subtract(const Duration(days: 2)),
        updatedAt: now.subtract(const Duration(days: 2)),
      ),
      Patient(
        id: 'PAT010',
        firstName: 'Mélané',
        lastName: 'Kougan',
        birthYear: 1998,
        sex: 'F',
        village: 'Aného',
        phoneNumber: '+22890012354',
        allergies: null,
        chronicConditions: null,
        createdAt: now.subtract(const Duration(days: 1)),
        updatedAt: now.subtract(const Duration(days: 1)),
      ),
    ];
  }
}
