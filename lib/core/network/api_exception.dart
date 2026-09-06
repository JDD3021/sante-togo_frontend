import 'dart:convert';
import 'dart:developer' as developer;
import 'package:http/http.dart' as http;

/// Error thrown by the API repositories.
///
/// [message] is always safe to show directly in the UI: plain French,
/// no HTTP status code, no stack trace. The technical detail (status code,
/// URL, raw response body) is logged to the console via `dart:developer`
/// at construction time, so it stays available for debugging without ever
/// reaching the screen.
class ApiException implements Exception {
  final String message;

  ApiException(this.message, {required String technicalDetail, int? statusCode}) {
    developer.log(
      technicalDetail,
      name: 'api',
      level: 900, // WARNING
      error: statusCode != null ? 'HTTP $statusCode' : null,
    );
  }

  @override
  String toString() => message;
}

/// Human-readable French labels for the API field names that show up in
/// FastAPI/Pydantic validation errors (422 responses).
const Map<String, String> _fieldLabels = {
  'first_name': 'Prénom',
  'last_name': 'Nom',
  'date_of_birth': 'Date de naissance',
  'sex': 'Sexe',
  'phone': 'Téléphone',
  'village': 'Village',
  'blood_type': 'Groupe sanguin',
  'allergies': 'Allergies',
  'chronic_conditions': 'Maladies chroniques',
  'patient_id': 'Patient',
  'consultation_id': 'Consultation',
  'reason': 'Motif',
  'reason_description': 'Motif',
  'temperature': 'Température',
  'systolic_bp': 'Tension systolique',
  'diastolic_bp': 'Tension diastolique',
  'heart_rate': 'Fréquence cardiaque',
  'oxygen_saturation': 'Saturation en oxygène',
  'weight': 'Poids',
  'height': 'Taille',
  'diagnosis': 'Diagnostic',
  'severity': 'Gravité',
  'clinical_notes': 'Notes cliniques',
  'medications': 'Médicaments',
  'dosage': 'Posologie',
  'instructions': 'Instructions',
  'follow_up_date': 'Date de suivi',
  'status': 'Statut',
  'priority_level': 'Niveau de priorité',
  'notes': 'Notes',
  'vaccine_name': 'Vaccin',
  'dose': 'Dose',
  'scheduled_date': 'Date prévue',
  'administered_date': "Date d'administration",
  'file': 'Fichier audio',
};

String _fieldLabel(String field) => _fieldLabels[field] ?? field;

String _genericMessageFor(int statusCode) {
  switch (statusCode) {
    case 400:
    case 422:
      return 'Certaines informations saisies sont invalides. Vérifiez le formulaire.';
    case 401:
      return 'Vous devez vous reconnecter pour continuer.';
    case 403:
      return "Vous n'avez pas les droits nécessaires pour cette action.";
    case 404:
      return 'Élément introuvable.';
    case 409:
      return 'Cette information existe déjà.';
    case 500:
    case 502:
    case 503:
    case 504:
      return 'Le serveur rencontre un problème. Réessayez dans un instant.';
    default:
      return 'Une erreur est survenue. Réessayez.';
  }
}

/// Builds an [ApiException] from a failed [http.Response].
///
/// Extracts FastAPI's error shape — `{"detail": "..."}` or, for 422
/// validation failures, `{"detail": [{"loc": [...], "msg": "..."}]}` — into
/// a clear French message. Falls back to a generic per-status message when
/// the body isn't usable, and always keeps the raw status/body for the logs.
ApiException apiExceptionFromResponse(http.Response response, {String? action}) {
  dynamic body;
  try {
    body = json.decode(response.body);
  } catch (_) {
    body = null;
  }

  String? detailMessage;
  if (body is Map && body['detail'] != null) {
    final detail = body['detail'];
    if (detail is String) {
      detailMessage = detail;
    } else if (detail is List && detail.isNotEmpty) {
      detailMessage = detail.map((err) {
        if (err is Map) {
          final loc = err['loc'];
          final field = (loc is List && loc.isNotEmpty) ? loc.last.toString() : '';
          // Pydantic wraps custom @validator ValueErrors with a "Value error, "
          // prefix — our own validators already raise French messages, so
          // strip the English wrapper to avoid a mixed-language message.
          final msg = (err['msg']?.toString() ?? 'valeur invalide')
              .replaceFirst(RegExp(r'^Value error,\s*'), '');
          return field.isNotEmpty ? '${_fieldLabel(field)} : $msg' : msg;
        }
        return err.toString();
      }).join('\n');
    }
  }

  final prefix = action != null ? '$action — ' : '';
  return ApiException(
    detailMessage ?? _genericMessageFor(response.statusCode),
    technicalDetail:
        '$prefix${response.request?.method ?? ''} ${response.request?.url ?? ''} '
        '→ HTTP ${response.statusCode}: ${response.body}',
    statusCode: response.statusCode,
  );
}

/// Wraps a network-level failure (no response received: connection refused,
/// DNS failure, timeout...) into an [ApiException] with a clear message.
ApiException apiExceptionFromError(Object error, {String? action}) {
  final prefix = action != null ? '$action — ' : '';
  return ApiException(
    'Impossible de contacter le serveur. Vérifiez votre connexion.',
    technicalDetail: '$prefix$error',
  );
}
