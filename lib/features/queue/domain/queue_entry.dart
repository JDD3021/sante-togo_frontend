/// Queue entry domain model for Dekera
/// 
/// This model represents a patient in the waiting queue.
/// It will be synced with the backend database in future iterations.
class QueueEntry {
  final String id;
  final String patientId;
  final String patientName;
  final String patientVillage;
  final int orderNumber; // Numéro d'ordre dans la file
  final QueueStatus status;
  final DateTime arrivalTime;
  final DateTime? startTime;
  final DateTime? endTime;
  final String? notes;

  QueueEntry({
    required this.id,
    required this.patientId,
    required this.patientName,
    required this.patientVillage,
    required this.orderNumber,
    required this.status,
    required this.arrivalTime,
    this.startTime,
    this.endTime,
    this.notes,
  });

  /// Get waiting duration
  Duration get waitingDuration {
    final end = startTime ?? DateTime.now();
    return end.difference(arrivalTime);
  }

  /// Get consultation duration
  Duration? get consultationDuration {
    if (startTime == null || endTime == null) return null;
    return endTime!.difference(startTime!);
  }

  /// Copy with method for immutability
  QueueEntry copyWith({
    String? id,
    String? patientId,
    String? patientName,
    String? patientVillage,
    int? orderNumber,
    QueueStatus? status,
    DateTime? arrivalTime,
    DateTime? startTime,
    DateTime? endTime,
    String? notes,
  }) {
    return QueueEntry(
      id: id ?? this.id,
      patientId: patientId ?? this.patientId,
      patientName: patientName ?? this.patientName,
      patientVillage: patientVillage ?? this.patientVillage,
      orderNumber: orderNumber ?? this.orderNumber,
      status: status ?? this.status,
      arrivalTime: arrivalTime ?? this.arrivalTime,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      notes: notes ?? this.notes,
    );
  }

  /// Convert to JSON (for future API integration)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patientId': patientId,
      'patientName': patientName,
      'patientVillage': patientVillage,
      'orderNumber': orderNumber,
      'status': status.toString(),
      'arrivalTime': arrivalTime.toIso8601String(),
      'startTime': startTime?.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'notes': notes,
    };
  }

  /// Create from JSON (for future API integration)
  factory QueueEntry.fromJson(Map<String, dynamic> json) {
    return QueueEntry(
      id: json['id'] as String,
      patientId: json['patientId'] as String,
      patientName: json['patientName'] as String,
      patientVillage: json['patientVillage'] as String,
      orderNumber: json['orderNumber'] as int,
      status: QueueStatus.values.firstWhere(
        (e) => e.toString() == json['status'],
        orElse: () => QueueStatus.waiting,
      ),
      arrivalTime: DateTime.parse(json['arrivalTime'] as String),
      startTime: json['startTime'] != null
          ? DateTime.parse(json['startTime'] as String)
          : null,
      endTime: json['endTime'] != null
          ? DateTime.parse(json['endTime'] as String)
          : null,
      notes: json['notes'] as String?,
    );
  }
}

/// Queue status enum
enum QueueStatus {
  waiting, // En attente
  next, // Suivant
  inProgress, // En cours
  completed, // Terminé
  cancelled, // Annulé
}

/// French labels for queue status
extension QueueStatusExtension on QueueStatus {
  String get label {
    switch (this) {
      case QueueStatus.waiting:
        return 'Attente';
      case QueueStatus.next:
        return 'Suivant';
      case QueueStatus.inProgress:
        return 'En cours';
      case QueueStatus.completed:
        return 'Terminé';
      case QueueStatus.cancelled:
        return 'Annulé';
    }
  }
}
