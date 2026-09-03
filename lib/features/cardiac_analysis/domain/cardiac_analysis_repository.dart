import 'dart:typed_data';
import 'cardiac_analysis.dart';

/// Abstract repository interface for CardiacAnalysis (CardioBeat) data
///
/// Currently implemented by ApiCardiacAnalysisRepository, which calls the
/// SANTÉ+ backend (not CardioBeat directly — the backend handles CardioBeat
/// authentication and persistence).
abstract class CardiacAnalysisRepository {
  /// Sends a heart sound recording for AI analysis and returns the result
  Future<CardiacAnalysis> analyze({
    required String patientId,
    String? consultationId,
    required Uint8List audioBytes,
    required String filename,
  });

  /// Gets the analysis history for a patient, most recent first
  Future<List<CardiacAnalysis>> getHistory(String patientId);
}
