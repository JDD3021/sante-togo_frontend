import 'dart:convert';
import 'package:http/http.dart' as http;
import '../domain/vaccination.dart';
import '../domain/vaccination_repository.dart';
import '../../../core/constants/app_constants.dart';

/// API implementation of VaccinationRepository
///
/// Connects to the SANTÉ+ backend's /vaccinations endpoints. The backend
/// auto-generates the standard PEV (Programme Élargi de Vaccination)
/// schedule the first time a patient's calendar is requested.
class ApiVaccinationRepository implements VaccinationRepository {
  final String baseUrl;
  final http.Client client;

  ApiVaccinationRepository({
    this.baseUrl = AppConstants.apiBaseUrl,
    http.Client? client,
  }) : client = client ?? http.Client();

  @override
  Future<List<Vaccination>> getScheduleForPatient(String patientId) async {
    final response = await client.get(
      Uri.parse('$baseUrl${AppConstants.vaccinationsEndpoint}/patient/$patientId'),
    );
    if (response.statusCode != 200) {
      throw Exception(_extractErrorDetail(response));
    }
    final Map<String, dynamic> jsonData = json.decode(response.body);
    final List<dynamic> items = jsonData['items'] as List;
    return items.map((item) => _fromJson(item)).toList();
  }

  @override
  Future<Vaccination> markAdministered(
    String vaccinationId, {
    DateTime? administeredDate,
  }) async {
    final response = await client.put(
      Uri.parse('$baseUrl${AppConstants.vaccinationsEndpoint}/$vaccinationId'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        if (administeredDate != null)
          'administered_date':
              administeredDate.toIso8601String().split('T').first,
      }),
    );
    if (response.statusCode != 200) {
      throw Exception(_extractErrorDetail(response));
    }
    return _fromJson(json.decode(response.body));
  }

  Vaccination _fromJson(Map<String, dynamic> json) {
    return Vaccination(
      id: json['id'].toString(),
      patientId: json['patient_id'].toString(),
      vaccineName: json['vaccine_name'] as String,
      dose: json['dose'] as String,
      scheduledDate: DateTime.parse(json['scheduled_date'] as String),
      administeredDate: json['administered_date'] != null
          ? DateTime.parse(json['administered_date'] as String)
          : null,
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
