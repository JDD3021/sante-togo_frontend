import 'dart:convert';
import 'package:http/http.dart' as http;
import '../domain/queue_entry.dart';
import '../domain/queue_repository.dart';
import '../../../core/constants/app_constants.dart';
import '../../patient_search/data/api_patient_repository.dart';
import '../../patient_search/domain/patient_repository.dart';

/// API implementation of QueueRepository
///
/// Connects to the FastAPI backend's /queue endpoints. The backend only
/// stores `patient_id` on a queue entry (no name/village), so each entry is
/// enriched with the patient's name and village via [patientRepository].
/// The backend has no "next" status (only waiting/in_progress/completed/
/// cancelled), so [QueueStatus.next] is never returned by this repository.
class ApiQueueRepository implements QueueRepository {
  final String baseUrl;
  final http.Client client;
  final PatientRepository patientRepository;

  ApiQueueRepository({
    this.baseUrl = AppConstants.apiBaseUrl,
    http.Client? client,
    PatientRepository? patientRepository,
  })  : client = client ?? http.Client(),
        patientRepository = patientRepository ?? ApiPatientRepository();

  @override
  Future<List<QueueEntry>> getTodayQueue() async {
    final response = await client.get(
      Uri.parse('$baseUrl${AppConstants.queueEndpoint}/?limit=100'),
    );
    if (response.statusCode != 200) {
      throw Exception(_extractErrorDetail(response));
    }
    final Map<String, dynamic> jsonData = json.decode(response.body);
    final List<dynamic> items = jsonData['items'] as List;

    final entries = <QueueEntry>[];
    for (var i = 0; i < items.length; i++) {
      entries.add(await _fromJson(items[i], orderNumber: i + 1));
    }
    return entries;
  }

  @override
  Future<QueueEntry?> getQueueEntryById(String id) async {
    final response = await client.get(
      Uri.parse('$baseUrl${AppConstants.queueEndpoint}/$id'),
    );
    if (response.statusCode == 200) {
      return _fromJson(json.decode(response.body), orderNumber: 0);
    } else if (response.statusCode == 404) {
      return null;
    }
    throw Exception(_extractErrorDetail(response));
  }

  @override
  Future<QueueEntry> addToQueue(QueueEntry entry) async {
    final response = await client.post(
      Uri.parse('$baseUrl${AppConstants.queueEndpoint}/'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'patient_id': int.parse(entry.patientId),
        'notes': entry.notes,
      }),
    );
    if (response.statusCode == 201) {
      return _fromJson(json.decode(response.body), orderNumber: 0);
    }
    throw Exception(_extractErrorDetail(response));
  }

  @override
  Future<QueueEntry> updateQueueEntry(QueueEntry entry) async {
    final response = await client.put(
      Uri.parse('$baseUrl${AppConstants.queueEndpoint}/${entry.id}'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'status': _statusToApi(entry.status),
        'notes': entry.notes,
      }),
    );
    if (response.statusCode == 200) {
      return _fromJson(json.decode(response.body), orderNumber: 0);
    }
    throw Exception(_extractErrorDetail(response));
  }

  @override
  Future<void> removeFromQueue(String id) async {
    final response = await client.delete(
      Uri.parse('$baseUrl${AppConstants.queueEndpoint}/$id'),
    );
    if (response.statusCode != 204) {
      throw Exception(_extractErrorDetail(response));
    }
  }

  @override
  Future<QueueEntry?> getCurrentPatient() async {
    final queue = await getTodayQueue();
    try {
      return queue.firstWhere((e) => e.status == QueueStatus.inProgress);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<QueueEntry?> getNextPatient() async {
    final queue = await getTodayQueue();
    try {
      return queue.firstWhere((e) => e.status == QueueStatus.waiting);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<int> getTodayQueueCount() async {
    final queue = await getTodayQueue();
    return queue.length;
  }

  String _statusToApi(QueueStatus status) {
    switch (status) {
      case QueueStatus.waiting:
      case QueueStatus.next:
        return 'waiting';
      case QueueStatus.inProgress:
        return 'in_progress';
      case QueueStatus.completed:
        return 'completed';
      case QueueStatus.cancelled:
        return 'cancelled';
    }
  }

  QueueStatus _statusFromApi(String status) {
    switch (status) {
      case 'waiting':
        return QueueStatus.waiting;
      case 'in_progress':
        return QueueStatus.inProgress;
      case 'completed':
        return QueueStatus.completed;
      case 'cancelled':
        return QueueStatus.cancelled;
      default:
        return QueueStatus.waiting;
    }
  }

  Future<QueueEntry> _fromJson(
    Map<String, dynamic> json, {
    required int orderNumber,
  }) async {
    final patientId = json['patient_id'].toString();
    String patientName = 'Patient #$patientId';
    String patientVillage = '';
    try {
      final patient = await patientRepository.getPatientById(patientId);
      if (patient != null) {
        patientName = patient.fullName;
        patientVillage = patient.village;
      }
    } catch (_) {
      // Keep the fallback name/village if the patient lookup fails.
    }

    return QueueEntry(
      id: json['id'].toString(),
      patientId: patientId,
      patientName: patientName,
      patientVillage: patientVillage,
      orderNumber: orderNumber,
      status: _statusFromApi(json['status'] as String),
      arrivalTime: DateTime.parse(json['arrival_time'] as String),
      startTime: json['start_time'] != null
          ? DateTime.parse(json['start_time'] as String)
          : null,
      endTime: json['completion_time'] != null
          ? DateTime.parse(json['completion_time'] as String)
          : null,
      notes: json['notes'] as String?,
    );
  }

  String _extractErrorDetail(http.Response response) {
    try {
      final body = json.decode(response.body);
      if (body is Map && body['detail'] is String) {
        return body['detail'] as String;
      }
    } catch (_) {
      // Response body wasn't JSON; fall through to the generic message.
    }
    return 'Erreur ${response.statusCode}';
  }
}
