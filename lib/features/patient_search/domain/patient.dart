/// Patient domain model for SANTÉ+ TOGO
/// 
/// This model represents a patient in the medical records system.
/// It will be synced with the backend database in future iterations.
class Patient {
  final String id;
  final String firstName;
  final String lastName;
  final int? birthYear; // Approximate year of birth (common in rural areas)
  final String sex; // 'M' or 'F'
  final String village;
  final String? phoneNumber;
  final List<String>? allergies; // List of allergies (empty if none)
  final String? chronicConditions; // Chronic diseases if any
  final DateTime createdAt;
  final DateTime updatedAt;

  Patient({
    required this.id,
    required this.firstName,
    required this.lastName,
    this.birthYear,
    required this.sex,
    required this.village,
    this.phoneNumber,
    this.allergies,
    this.chronicConditions,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Get full name
  String get fullName => '$firstName $lastName';

  /// Get initials for avatar
  String get initials => '${firstName[0]}${lastName[0]}'.toUpperCase();

  /// Get approximate age from birth year
  int? get approximateAge {
    if (birthYear == null) return null;
    final currentYear = DateTime.now().year;
    return currentYear - birthYear!;
  }

  /// Check if patient has allergies
  bool get hasAllergies => allergies != null && allergies!.isNotEmpty;

  /// Check if patient has chronic conditions
  bool get hasChronicConditions => chronicConditions != null && chronicConditions!.isNotEmpty;

  /// Copy with method for immutability
  Patient copyWith({
    String? id,
    String? firstName,
    String? lastName,
    int? birthYear,
    String? sex,
    String? village,
    String? phoneNumber,
    List<String>? allergies,
    String? chronicConditions,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Patient(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      birthYear: birthYear ?? this.birthYear,
      sex: sex ?? this.sex,
      village: village ?? this.village,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      allergies: allergies ?? this.allergies,
      chronicConditions: chronicConditions ?? this.chronicConditions,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Convert to JSON (for future API integration)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'birthYear': birthYear,
      'sex': sex,
      'village': village,
      'phoneNumber': phoneNumber,
      'allergies': allergies,
      'chronicConditions': chronicConditions,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Create from JSON (for future API integration)
  factory Patient.fromJson(Map<String, dynamic> json) {
    return Patient(
      id: json['id'] as String,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      birthYear: json['birthYear'] as int?,
      sex: json['sex'] as String,
      village: json['village'] as String,
      phoneNumber: json['phoneNumber'] as String?,
      allergies: json['allergies'] != null 
          ? List<String>.from(json['allergies'] as List)
          : null,
      chronicConditions: json['chronicConditions'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }
}
