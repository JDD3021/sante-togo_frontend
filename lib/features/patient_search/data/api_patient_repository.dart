import 'dart:convert';
import 'package:http/http.dart' as http;
import '../domain/patient.dart';
import '../domain/patient_repository.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../core/network/api_exception.dart';

/// API implementation of PatientRepository
///
/// This repository makes HTTP requests to the backend REST API.
/// It connects to the FastAPI backend running on localhost:8000.
class ApiPatientRepository implements PatientRepository {
  final String baseUrl;
  final http.Client client;

  ApiPatientRepository({
    this.baseUrl = AppConstants.apiBaseUrl,
    http.Client? client,
  }) : client = client ?? http.Client();

  @override
  Future<List<Patient>> getAllPatients() async {
    try {
      final response = await client.get(
        Uri.parse('$baseUrl${AppConstants.patientsEndpoint}/?limit=100'),
      );
      if (response.statusCode != 200) {
        throw apiExceptionFromResponse(response, action: 'Chargement des patients');
      }
      final Map<String, dynamic> jsonData = json.decode(response.body);
      final List<dynamic> items = jsonData['items'] as List;
      return items.map((json) => _fromJson(json)).toList();
    } on ApiException {
      rethrow;
    } catch (e) {
      throw apiExceptionFromError(e, action: 'Chargement des patients');
    }
  }

  @override
  Future<Patient?> getPatientById(String id) async {
    try {
      final response = await client.get(
        Uri.parse('$baseUrl${AppConstants.patientsEndpoint}/$id'),
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return _fromJson(jsonData);
      } else if (response.statusCode == 404) {
        return null;
      }
      throw apiExceptionFromResponse(response, action: 'Chargement du patient');
    } on ApiException {
      rethrow;
    } catch (e) {
      throw apiExceptionFromError(e, action: 'Chargement du patient');
    }
  }

  @override
  Future<List<Patient>> searchPatients(String query) async {
    try {
      final response = await client.get(
        Uri.parse(
            '$baseUrl${AppConstants.patientsEndpoint}/search/$query?limit=100'),
      );
      if (response.statusCode != 200) {
        throw apiExceptionFromResponse(response, action: 'Recherche de patients');
      }
      final Map<String, dynamic> jsonData = json.decode(response.body);
      final List<dynamic> items = jsonData['items'] as List;
      return items.map((json) => _fromJson(json)).toList();
    } on ApiException {
      rethrow;
    } catch (e) {
      throw apiExceptionFromError(e, action: 'Recherche de patients');
    }
  }

  @override
  Future<List<Patient>> getRecentlyViewed(int limit) async {
    try {
      final response = await client.get(
        Uri.parse('$baseUrl${AppConstants.patientsEndpoint}/?limit=$limit'),
      );
      if (response.statusCode != 200) {
        throw apiExceptionFromResponse(response, action: 'Chargement des patients récents');
      }
      final Map<String, dynamic> jsonData = json.decode(response.body);
      final List<dynamic> items = jsonData['items'] as List;
      return items.map((json) => _fromJson(json)).toList();
    } on ApiException {
      rethrow;
    } catch (e) {
      throw apiExceptionFromError(e, action: 'Chargement des patients récents');
    }
  }

  @override
  Future<Patient> createPatient(Patient patient) async {
    try {
      final response = await client.post(
        Uri.parse('$baseUrl${AppConstants.patientsEndpoint}/'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(_toJson(patient)),
      );
      if (response.statusCode == 201) {
        return _fromJson(json.decode(response.body));
      }
      throw apiExceptionFromResponse(response, action: 'Création du patient');
    } on ApiException {
      rethrow;
    } catch (e) {
      throw apiExceptionFromError(e, action: 'Création du patient');
    }
  }

  @override
  Future<Patient> updatePatient(Patient patient) async {
    try {
      final response = await client.put(
        Uri.parse('$baseUrl${AppConstants.patientsEndpoint}/${patient.id}'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(_toJson(patient)),
      );

      if (response.statusCode == 200) {
        return _fromJson(json.decode(response.body));
      }
      throw apiExceptionFromResponse(response, action: 'Modification du patient');
    } on ApiException {
      rethrow;
    } catch (e) {
      throw apiExceptionFromError(e, action: 'Modification du patient');
    }
  }

  @override
  Future<void> deletePatient(String id) async {
    try {
      final response = await client.delete(
        Uri.parse('$baseUrl${AppConstants.patientsEndpoint}/$id'),
      );
      if (response.statusCode != 204) {
        throw apiExceptionFromResponse(response, action: 'Suppression du patient');
      }
    } on ApiException {
      rethrow;
    } catch (e) {
      throw apiExceptionFromError(e, action: 'Suppression du patient');
    }
  }

  /// Convert Patient domain model to API JSON format
  Map<String, dynamic> _toJson(Patient patient) {
    return {
      'first_name': patient.firstName,
      'last_name': patient.lastName,
      'date_of_birth':
          patient.birthYear != null ? '${patient.birthYear}-01-01' : null,
      'sex': patient.sex,
      'phone': patient.phoneNumber,
      'village': patient.village,
      'blood_type': 'Unknown',
      'allergies': patient.allergies ?? [],
      'chronic_conditions':
          patient.chronicConditions != null ? [patient.chronicConditions] : [],
    };
  }

  /// Convert API JSON response to Patient domain model
  Patient _fromJson(Map<String, dynamic> json) {
    // Handle chronic_conditions - it might be a list or string
    String? chronicConditions;
    if (json['chronic_conditions'] != null) {
      if (json['chronic_conditions'] is List) {
        final List<dynamic> conditions = json['chronic_conditions'] as List;
        chronicConditions =
            conditions.isNotEmpty ? conditions.join(', ') : null;
      } else {
        chronicConditions = json['chronic_conditions'] as String?;
      }
    }

    return Patient(
      id: json['id'].toString(),
      firstName: json['first_name'] as String,
      lastName: json['last_name'] as String,
      birthYear: json['date_of_birth'] != null
          ? DateTime.parse(json['date_of_birth']).year
          : null,
      sex: json['sex'] as String? ?? 'M',
      village: json['village'] as String? ?? '',
      phoneNumber: json['phone'] as String?,
      allergies:
          json['allergies'] != null && (json['allergies'] as List).isNotEmpty
              ? List<String>.from(json['allergies'] as List)
              : null,
      chronicConditions: chronicConditions,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : DateTime.now(),
    );
  }
}
