import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import '../domain/cardiac_analysis.dart';
import '../domain/cardiac_analysis_repository.dart';
import '../../../core/constants/app_constants.dart';

/// API implementation of CardiacAnalysisRepository
///
/// Connects to the SANTÉ+ backend's /cardiac-analysis endpoints. The backend
/// forwards the audio to the external CardioBeat service and persists the
/// result linked to the patient (and optionally the consultation).
class ApiCardiacAnalysisRepository implements CardiacAnalysisRepository {
  final String baseUrl;
  final http.Client client;

  ApiCardiacAnalysisRepository({
    this.baseUrl = AppConstants.apiBaseUrl,
    http.Client? client,
  }) : client = client ?? http.Client();

  @override
  Future<CardiacAnalysis> analyze({
    required String patientId,
    String? consultationId,
    required Uint8List audioBytes,
    required String filename,
  }) async {
    final uri = Uri.parse('$baseUrl${AppConstants.cardiacAnalysisEndpoint}/');
    final request = http.MultipartRequest('POST', uri)
      ..fields['patient_id'] = patientId
      ..files.add(
        http.MultipartFile.fromBytes('file', audioBytes, filename: filename),
      );
    if (consultationId != null) {
      request.fields['consultation_id'] = consultationId;
    }

    final streamedResponse = await client.send(request);
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 201) {
      return CardiacAnalysis.fromApiJson(json.decode(response.body));
    }
    throw Exception(_extractErrorDetail(response));
  }

  @override
  Future<List<CardiacAnalysis>> getHistory(String patientId) async {
    final response = await client.get(
      Uri.parse(
          '$baseUrl${AppConstants.cardiacAnalysisEndpoint}/patient/$patientId'),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonData = json.decode(response.body);
      final List<dynamic> items = jsonData['items'] as List;
      return items
          .map((item) => CardiacAnalysis.fromApiJson(item))
          .toList();
    }
    throw Exception(_extractErrorDetail(response));
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
