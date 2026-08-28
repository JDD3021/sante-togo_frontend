/// Consultation domain model for SANTÉ+ TOGO
/// 
/// This model represents a medical consultation/visit.
/// It will be synced with the backend database in future iterations.
class Consultation {
  final String id;
  final String patientId;
  final DateTime date;
  final String reason; // Motif de consultation
  final String? diagnosis; // Diagnostic
  final String? prescription; // Prescription médicaments
  final double? temperature; // Température en °C
  final int? systolicBP; // Tension systolique
  final int? diastolicBP; // Tension diastolique
  final double? weight; // Poids en kg
  final String? followUpDate; // Date de suivi (ISO string)
  final String? followUpMethod; // Méthode de suivi (SMS, etc.)
  final String? notes; // Notes additionnelles
  final DateTime createdAt;

  Consultation({
    required this.id,
    required this.patientId,
    required this.date,
    required this.reason,
    this.diagnosis,
    this.prescription,
    this.temperature,
    this.systolicBP,
    this.diastolicBP,
    this.weight,
    this.followUpDate,
    this.followUpMethod,
    this.notes,
    required this.createdAt,
  });

  /// Get blood pressure as string
  String? get bloodPressure {
    if (systolicBP == null || diastolicBP == null) return null;
    return '$systolicBP/$diastolicBP mmHg';
  }

  /// Check if follow-up is scheduled
  bool get hasFollowUp => followUpDate != null;

  /// Copy with method for immutability
  Consultation copyWith({
    String? id,
    String? patientId,
    DateTime? date,
    String? reason,
    String? diagnosis,
    String? prescription,
    double? temperature,
    int? systolicBP,
    int? diastolicBP,
    double? weight,
    String? followUpDate,
    String? followUpMethod,
    String? notes,
    DateTime? createdAt,
  }) {
    return Consultation(
      id: id ?? this.id,
      patientId: patientId ?? this.patientId,
      date: date ?? this.date,
      reason: reason ?? this.reason,
      diagnosis: diagnosis ?? this.diagnosis,
      prescription: prescription ?? this.prescription,
      temperature: temperature ?? this.temperature,
      systolicBP: systolicBP ?? this.systolicBP,
      diastolicBP: diastolicBP ?? this.diastolicBP,
      weight: weight ?? this.weight,
      followUpDate: followUpDate ?? this.followUpDate,
      followUpMethod: followUpMethod ?? this.followUpMethod,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Convert to JSON (for future API integration)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patientId': patientId,
      'date': date.toIso8601String(),
      'reason': reason,
      'diagnosis': diagnosis,
      'prescription': prescription,
      'temperature': temperature,
      'systolicBP': systolicBP,
      'diastolicBP': diastolicBP,
      'weight': weight,
      'followUpDate': followUpDate,
      'followUpMethod': followUpMethod,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// Create from JSON (for future API integration)
  factory Consultation.fromJson(Map<String, dynamic> json) {
    return Consultation(
      id: json['id'] as String,
      patientId: json['patientId'] as String,
      date: DateTime.parse(json['date'] as String),
      reason: json['reason'] as String,
      diagnosis: json['diagnosis'] as String?,
      prescription: json['prescription'] as String?,
      temperature: json['temperature'] as double?,
      systolicBP: json['systolicBP'] as int?,
      diastolicBP: json['diastolicBP'] as int?,
      weight: json['weight'] as double?,
      followUpDate: json['followUpDate'] as String?,
      followUpMethod: json['followUpMethod'] as String?,
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}
