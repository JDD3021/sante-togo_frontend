import '../domain/vaccination.dart';

/// Mock implementation of a vaccination schedule repository
///
/// NOTE: This is a MOCK implementation, UI-only for the MVP — there is no
/// vaccination endpoint on the backend yet. It deterministically derives a
/// standard PEV (Programme Élargi de Vaccination) schedule from the
/// patient's id so the same patient always sees the same schedule.
class MockVaccinationRepository {
  static const List<String> _scheduleAtBirth = ['BCG', 'Polio 0'];
  static const List<String> _schedule6Weeks = ['Penta 1', 'Polio 1', 'Pneumo 1', 'Rota 1'];
  static const List<String> _schedule10Weeks = ['Penta 2', 'Polio 2', 'Pneumo 2', 'Rota 2'];
  static const List<String> _schedule14Weeks = ['Penta 3', 'Polio 3', 'Pneumo 3'];
  static const List<String> _schedule9Months = ['Rougeole-Rubéole', 'Fièvre jaune'];

  Future<List<Vaccination>> getScheduleForPatient(String patientId) async {
    await Future.delayed(const Duration(milliseconds: 300));

    // Deterministic reference date derived from the patient id so results
    // are stable across reloads without needing real birth-date data.
    final seed = patientId.codeUnits.fold<int>(0, (sum, c) => sum + c);
    final referenceBirth =
        DateTime.now().subtract(Duration(days: 200 + (seed % 500)));

    final entries = <Vaccination>[];
    var doseIndex = 0;

    void addBatch(List<String> vaccines, Duration offset) {
      final scheduledDate = referenceBirth.add(offset);
      for (final vaccine in vaccines) {
        doseIndex++;
        final isPast = scheduledDate.isBefore(DateTime.now());
        // Roughly 70% of past doses were administered on time, for a
        // realistic mix of "administré" / "en retard" in the demo data.
        final administered = isPast && (seed + doseIndex) % 10 < 7;
        entries.add(Vaccination(
          id: 'VAC-$patientId-$doseIndex',
          patientId: patientId,
          vaccineName: vaccine,
          dose: 'Dose 1',
          scheduledDate: scheduledDate,
          administeredDate: administered ? scheduledDate : null,
        ));
      }
    }

    addBatch(_scheduleAtBirth, Duration.zero);
    addBatch(_schedule6Weeks, const Duration(days: 42));
    addBatch(_schedule10Weeks, const Duration(days: 70));
    addBatch(_schedule14Weeks, const Duration(days: 98));
    addBatch(_schedule9Months, const Duration(days: 270));

    entries.sort((a, b) => a.scheduledDate.compareTo(b.scheduledDate));
    return entries;
  }
}
