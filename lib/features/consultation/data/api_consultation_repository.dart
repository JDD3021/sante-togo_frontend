import 'dart:convert';
import 'package:http/http.dart' as http;
import '../domain/consultation.dart';
import '../domain/consultation_repository.dart';
import '../../../../core/constants/app_constants.dart';

/// API implementation of ConsultationRepository
///
/// Connects to the FastAPI backend's /consultations endpoints. The backend
/// classifies consultations under a fixed set of `reason` categories
/// (general, emergency, follow_up, vaccination, prenatal), while the app's
/// step-by-step form collects a French-language motif (Fièvre, Douleur,
/// Grossesse, Blessure, Contrôle, Autre). The exact motif is preserved in
/// `reason_description` and used for display; `reason` only carries the
/// closest backend category.
class ApiConsultationRepository implements ConsultationRepository {
  final String baseUrl;
  final http.Client client;

  ApiConsultationRepository({
    this.baseUrl = AppConstants.apiBaseUrl,
    http.Client? client,
  }) : client = client ?? http.Client();

  static const Map<String, String> _reasonToBackendCategory = {
    'Grossesse': 'prenatal',
    'Contrôle': 'follow_up',
  };

  String _backendCategory(String reason) =>
      _reasonToBackendCategory[reason] ?? 'general';

  @override
  Future<List<Consultation>> getConsultationsByPatient(
      String patientId) async {
    try {
      final response = await client.get(
        Uri.parse(
            '$baseUrl${AppConstants.consultationsEndpoint}/patient/$patientId?limit=100'),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        final List<dynamic> items = jsonData['items'] as List;
        return items.map((json) => _fromJson(json)).toList();
      }
      throw Exception('Failed to load consultations: ${response.statusCode}');
    } catch (e) {
      throw Exception('Error fetching consultations: $e');
    }
  }

  @override
  Future<Consultation?> getConsultationById(String id) async {
    try {
      final response = await client.get(
        Uri.parse('$baseUrl${AppConstants.consultationsEndpoint}/$id'),
      );

      if (response.statusCode == 200) {
        return _fromJson(json.decode(response.body));
      } else if (response.statusCode == 404) {
        return null;
      }
      throw Exception('Failed to load consultation: ${response.statusCode}');
    } catch (e) {
      throw Exception('Error fetching consultation: $e');
    }
  }

  @override
  Future<Consultation> createConsultation(Consultation consultation) async {
    final response = await client.post(
      Uri.parse('$baseUrl${AppConstants.consultationsEndpoint}/'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(_toJson(consultation)),
    );

    if (response.statusCode == 201) {
      return _fromJson(json.decode(response.body));
    }
    throw Exception(_extractErrorDetail(response));
  }

  @override
  Future<Consultation> updateConsultation(Consultation consultation) async {
    final response = await client.put(
      Uri.parse(
          '$baseUrl${AppConstants.consultationsEndpoint}/${consultation.id}'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(_toJson(consultation)),
    );

    if (response.statusCode == 200) {
      return _fromJson(json.decode(response.body));
    }
    throw Exception(_extractErrorDetail(response));
  }

  @override
  Future<void> deleteConsultation(String id) async {
    final response = await client.delete(
      Uri.parse('$baseUrl${AppConstants.consultationsEndpoint}/$id'),
    );

    if (response.statusCode != 204) {
      throw Exception('Failed to delete consultation: ${response.statusCode}');
    }
  }

  @override
  Future<List<Consultation>> getConsultationsByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    // Not exposed by the backend yet.
    throw UnimplementedError(
        'getConsultationsByDateRange is not supported by the API yet');
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

  /// Parses a "JJ/MM/AAAA" follow-up date into an ISO 8601 string.
  /// Returns null if the input is empty or not a valid date.
  String? _parseFollowUpDate(String? raw) {
    if (raw == null || raw.trim().isEmpty) return null;
    final parts = raw.trim().split('/');
    if (parts.length != 3) return null;
    final day = int.tryParse(parts[0]);
    final month = int.tryParse(parts[1]);
    final year = int.tryParse(parts[2]);
    if (day == null || month == null || year == null) return null;
    try {
      return DateTime(year, month, day).toIso8601String();
    } catch (_) {
      return null;
    }
  }

  /// Formats an ISO 8601 follow-up date back into "JJ/MM/AAAA" for display.
  String? _formatFollowUpDate(String? iso) {
    if (iso == null) return null;
    final dt = DateTime.tryParse(iso);
    if (dt == null) return iso;
    return '${dt.day.toString().padLeft(2, '0')}/'
        '${dt.month.toString().padLeft(2, '0')}/${dt.year}';
  }

  Map<String, dynamic> _toJson(Consultation c) {
    return {
      'patient_id': int.parse(c.patientId),
      'reason': _backendCategory(c.reason),
      'reason_description': c.reason,
      'temperature': c.temperature,
      'systolic_bp': c.systolicBP,
      'diastolic_bp': c.diastolicBP,
      'weight': c.weight,
      'diagnosis': c.diagnosis,
      'medications': c.prescription,
      'instructions': c.followUpMethod,
      'follow_up_date': _parseFollowUpDate(c.followUpDate),
      'clinical_notes': c.notes,
    };
  }

  Consultation _fromJson(Map<String, dynamic> json) {
    return Consultation(
      id: json['id'].toString(),
      patientId: json['patient_id'].toString(),
      date: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      reason: (json['reason_description'] as String?) ??
          (json['reason'] as String? ?? 'Autre'),
      diagnosis: json['diagnosis'] as String?,
      prescription: json['medications'] as String?,
      temperature: (json['temperature'] as num?)?.toDouble(),
      systolicBP: json['systolic_bp'] as int?,
      diastolicBP: json['diastolic_bp'] as int?,
      weight: (json['weight'] as num?)?.toDouble(),
      followUpDate: _formatFollowUpDate(json['follow_up_date'] as String?),
      followUpMethod: json['instructions'] as String?,
      notes: json['clinical_notes'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
    );
  }
}
