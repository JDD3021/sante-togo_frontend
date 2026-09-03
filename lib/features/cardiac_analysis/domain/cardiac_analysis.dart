/// Result of an AI heart sound analysis (CardioBeat), for SANTÉ+ TOGO
///
/// Mirrors the SANTÉ+ backend's `/api/v1/cardiac-analysis` response, which
/// itself relays the result produced by the external CardioBeat service.
enum HeartSoundPrediction { normal, anormal }

class CardiacAnalysis {
  final String id;
  final String patientId;
  final String? consultationId;
  final HeartSoundPrediction prediction;
  final double confidence; // %
  final double normalProbability; // %
  final double abnormalProbability; // %
  final double riskScore; // 0-100
  final double? audioDuration; // seconds
  final String? summary;
  final List<String> tags;
  final double? heartRate; // bpm
  final String? audioUrl;
  final String? waveformUrl;
  final String? spectrogramUrl;
  final String? mfccUrl;
  final String disclaimer;
  final DateTime createdAt;

  const CardiacAnalysis({
    required this.id,
    required this.patientId,
    this.consultationId,
    required this.prediction,
    required this.confidence,
    required this.normalProbability,
    required this.abnormalProbability,
    required this.riskScore,
    this.audioDuration,
    this.summary,
    this.tags = const [],
    this.heartRate,
    this.audioUrl,
    this.waveformUrl,
    this.spectrogramUrl,
    this.mfccUrl,
    required this.disclaimer,
    required this.createdAt,
  });

  bool get isNormal => prediction == HeartSoundPrediction.normal;

  factory CardiacAnalysis.fromApiJson(Map<String, dynamic> json) {
    return CardiacAnalysis(
      id: json['id'].toString(),
      patientId: json['patient_id'].toString(),
      consultationId: json['consultation_id']?.toString(),
      prediction: (json['prediction'] as String) == 'NORMAL'
          ? HeartSoundPrediction.normal
          : HeartSoundPrediction.anormal,
      confidence: (json['confidence'] as num).toDouble(),
      normalProbability: (json['normal_probability'] as num).toDouble(),
      abnormalProbability: (json['abnormal_probability'] as num).toDouble(),
      riskScore: (json['risk_score'] as num).toDouble(),
      audioDuration: (json['audio_duration'] as num?)?.toDouble(),
      summary: json['summary'] as String?,
      tags: (json['tags'] as List?)?.map((e) => e.toString()).toList() ?? const [],
      heartRate: (json['heart_rate'] as num?)?.toDouble(),
      audioUrl: json['audio_url'] as String?,
      waveformUrl: json['waveform_url'] as String?,
      spectrogramUrl: json['spectrogram_url'] as String?,
      mfccUrl: json['mfcc_url'] as String?,
      disclaimer: json['disclaimer'] as String? ??
          'Résultat indicatif généré par IA — ne remplace pas un diagnostic médical.',
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}
