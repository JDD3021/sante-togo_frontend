/// Vaccination domain model for Dekera
///
/// Represents a single dose in a patient's immunization schedule, based on
/// the Togolese Expanded Programme on Immunization (PEV).
class Vaccination {
  final String id;
  final String patientId;
  final String vaccineName;
  final String dose; // Ex: "Dose 1", "Rappel"
  final DateTime scheduledDate;
  final DateTime? administeredDate;

  Vaccination({
    required this.id,
    required this.patientId,
    required this.vaccineName,
    required this.dose,
    required this.scheduledDate,
    this.administeredDate,
  });

  VaccinationStatus get status {
    if (administeredDate != null) return VaccinationStatus.done;
    if (scheduledDate.isBefore(DateTime.now())) return VaccinationStatus.overdue;
    return VaccinationStatus.upcoming;
  }
}

enum VaccinationStatus {
  done, // Administré
  upcoming, // À venir
  overdue, // En retard
}

extension VaccinationStatusExtension on VaccinationStatus {
  String get label {
    switch (this) {
      case VaccinationStatus.done:
        return 'Administré';
      case VaccinationStatus.upcoming:
        return 'À venir';
      case VaccinationStatus.overdue:
        return 'En retard';
    }
  }
}
