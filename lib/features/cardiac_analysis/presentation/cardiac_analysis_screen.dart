import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../data/api_cardiac_analysis_repository.dart';
import '../domain/cardiac_analysis.dart';

/// Screen to capture (record or import) a heart sound and analyze it via
/// CardioBeat, then display the result and the patient's analysis history.
class CardiacAnalysisScreen extends ConsumerStatefulWidget {
  final String patientId;
  final String? consultationId;

  const CardiacAnalysisScreen({
    super.key,
    required this.patientId,
    this.consultationId,
  });

  @override
  ConsumerState<CardiacAnalysisScreen> createState() =>
      _CardiacAnalysisScreenState();
}

/// A ≤10s clip is what the CardioBeat model expects (it pads/truncates to
/// 10s during feature extraction), so live recording auto-stops at 10s.
const int _maxRecordingSeconds = 10;

class _CardiacAnalysisScreenState extends ConsumerState<CardiacAnalysisScreen> {
  final ApiCardiacAnalysisRepository _repository =
      ApiCardiacAnalysisRepository();
  final AudioRecorder _audioRecorder = AudioRecorder();

  Uint8List? _capturedAudio;
  String? _capturedFilename;
  bool _isRecording = false;
  int _recordedSeconds = 0;
  Timer? _recordingTimer;
  String? _recordingPath;

  bool _isAnalyzing = false;
  CardiacAnalysis? _result;
  String? _errorMessage;

  List<CardiacAnalysis> _history = [];
  bool _isLoadingHistory = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  @override
  void dispose() {
    _recordingTimer?.cancel();
    _audioRecorder.dispose();
    super.dispose();
  }

  Future<void> _loadHistory() async {
    try {
      final history = await _repository.getHistory(widget.patientId);
      if (!mounted) return;
      setState(() {
        _history = history;
        _isLoadingHistory = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoadingHistory = false);
    }
  }

  Future<void> _startRecording() async {
    if (!await _audioRecorder.hasPermission()) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Permission microphone refusée'),
          backgroundColor: AppColors.red,
        ),
      );
      return;
    }

    final dir = await getTemporaryDirectory();
    final path =
        '${dir.path}/cardiac_${DateTime.now().millisecondsSinceEpoch}.wav';

    await _audioRecorder.start(
      const RecordConfig(encoder: AudioEncoder.wav),
      path: path,
    );

    setState(() {
      _isRecording = true;
      _recordingPath = path;
      _recordedSeconds = 0;
      _result = null;
      _errorMessage = null;
    });

    _recordingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() => _recordedSeconds++);
      if (_recordedSeconds >= _maxRecordingSeconds) {
        _stopRecording();
      }
    });
  }

  Future<void> _stopRecording() async {
    _recordingTimer?.cancel();
    if (!_isRecording) return;

    final path = await _audioRecorder.stop();
    setState(() => _isRecording = false);

    final resolvedPath = path ?? _recordingPath;
    if (resolvedPath == null) return;

    final bytes = await File(resolvedPath).readAsBytes();
    setState(() {
      _capturedAudio = bytes;
      _capturedFilename = 'enregistrement.wav';
    });
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['wav', 'mp3', 'm4a', 'flac'],
      withData: true,
    );
    if (result == null || result.files.isEmpty) return;

    final picked = result.files.single;
    if (picked.bytes == null) return;

    setState(() {
      _capturedAudio = picked.bytes;
      _capturedFilename = picked.name;
      _result = null;
      _errorMessage = null;
    });
  }

  Future<void> _analyze() async {
    final audio = _capturedAudio;
    final filename = _capturedFilename;
    if (audio == null || filename == null) return;

    setState(() {
      _isAnalyzing = true;
      _errorMessage = null;
    });

    try {
      final analysis = await _repository.analyze(
        patientId: widget.patientId,
        consultationId: widget.consultationId,
        audioBytes: audio,
        filename: filename,
      );
      if (!mounted) return;
      setState(() {
        _result = analysis;
        _isAnalyzing = false;
        _history = [analysis, ..._history];
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isAnalyzing = false;
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  void _reset() {
    setState(() {
      _capturedAudio = null;
      _capturedFilename = null;
      _result = null;
      _errorMessage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.screenBg,
      appBar: AppBar(
        title: Text('Analyse cardiaque IA', style: AppTextStyles.h4),
        backgroundColor: AppColors.screenBg,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.spacingLg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Écoutez le cœur avec un stéthoscope numérique, enregistrez '
              'ou importez le son (10 secondes max), puis lancez l\'analyse.',
              style: AppTextStyles.secondary,
            ),
            const SizedBox(height: AppConstants.spacingLg),
            if (_result != null)
              _buildResultCard(_result!)
            else ...[
              _buildCaptureCard(),
              if (_errorMessage != null) ...[
                const SizedBox(height: AppConstants.spacingMd),
                _buildErrorBanner(_errorMessage!),
              ],
            ],
            const SizedBox(height: AppConstants.spacingXl),
            Text('Historique des analyses', style: AppTextStyles.label),
            const SizedBox(height: AppConstants.spacingSm),
            _buildHistory(),
          ],
        ),
      ),
    );
  }

  Widget _buildCaptureCard() {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _buildCaptureButton(
                  icon: _isRecording ? Icons.stop_circle : Icons.mic,
                  label: _isRecording
                      ? 'Arrêter (${_recordedSeconds}s)'
                      : 'Enregistrer',
                  onTap: _isAnalyzing
                      ? null
                      : (_isRecording ? _stopRecording : _startRecording),
                  isActive: _isRecording,
                ),
              ),
              const SizedBox(width: AppConstants.spacingMd),
              Expanded(
                child: _buildCaptureButton(
                  icon: Icons.upload_file,
                  label: 'Importer',
                  onTap: (_isAnalyzing || _isRecording) ? null : _pickFile,
                  isActive: false,
                ),
              ),
            ],
          ),
          if (_isRecording) ...[
            const SizedBox(height: AppConstants.spacingMd),
            LinearProgressIndicator(
              value: _recordedSeconds / _maxRecordingSeconds,
              backgroundColor: AppColors.sand,
              valueColor: const AlwaysStoppedAnimation(AppColors.primary),
            ),
          ],
          if (_capturedAudio != null && !_isRecording) ...[
            const SizedBox(height: AppConstants.spacingMd),
            Container(
              padding: const EdgeInsets.all(AppConstants.spacingMd),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(AppConstants.radiusMd),
              ),
              child: Row(
                children: [
                  const Icon(Icons.audiotrack, color: AppColors.primaryDark),
                  const SizedBox(width: AppConstants.spacingSm),
                  Expanded(
                    child: Text(
                      _capturedFilename ?? '',
                      style: AppTextStyles.label,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 18),
                    onPressed: _isAnalyzing ? null : _reset,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppConstants.spacingMd),
            AppButton(
              text: 'Analyser',
              icon: Icons.favorite,
              isLoading: _isAnalyzing,
              onPressed: _isAnalyzing ? null : _analyze,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCaptureButton({
    required IconData icon,
    required String label,
    required VoidCallback? onTap,
    required bool isActive,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppConstants.radiusLg),
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: AppConstants.spacingMd,
        ),
        decoration: BoxDecoration(
          color: isActive ? AppColors.red : AppColors.primaryLight,
          borderRadius: BorderRadius.circular(AppConstants.radiusLg),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isActive ? AppColors.white : AppColors.primaryDark,
              size: AppConstants.iconLg,
            ),
            const SizedBox(height: AppConstants.spacingXs),
            Text(
              label,
              style: AppTextStyles.label.copyWith(
                color: isActive ? AppColors.white : AppColors.primaryDark,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorBanner(String message) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spacingMd),
      decoration: BoxDecoration(
        color: AppColors.redLight,
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
        border: Border.all(color: AppColors.red),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: AppColors.red),
          const SizedBox(width: AppConstants.spacingSm),
          Expanded(
            child: Text(
              message,
              style: AppTextStyles.label.copyWith(color: AppColors.red),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultCard(CardiacAnalysis analysis) {
    final isNormal = analysis.isNormal;
    final color = isNormal ? AppColors.primary : AppColors.red;
    final lightColor = isNormal ? AppColors.primaryLight : AppColors.redLight;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppConstants.spacingMd),
                decoration: BoxDecoration(
                  color: lightColor,
                  borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                ),
                child: Row(
                  children: [
                    Icon(
                      isNormal ? Icons.favorite : Icons.warning_amber_rounded,
                      color: color,
                      size: AppConstants.iconXl,
                    ),
                    const SizedBox(width: AppConstants.spacingMd),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isNormal ? 'NORMAL' : 'ANORMAL',
                            style: AppTextStyles.h3.copyWith(color: color),
                          ),
                          Text(
                            'Confiance : ${analysis.confidence.toStringAsFixed(1)}%',
                            style: AppTextStyles.label.copyWith(color: color),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppConstants.spacingMd),
              _buildRiskBar(analysis.riskScore, color),
              if (analysis.summary != null) ...[
                const SizedBox(height: AppConstants.spacingMd),
                Text(analysis.summary!, style: AppTextStyles.body),
              ],
              if (analysis.tags.isNotEmpty) ...[
                const SizedBox(height: AppConstants.spacingSm),
                Wrap(
                  spacing: AppConstants.spacingXs,
                  runSpacing: AppConstants.spacingXs,
                  children: analysis.tags
                      .map((tag) => Chip(
                            label: Text(tag, style: AppTextStyles.caption),
                            backgroundColor: AppColors.sand,
                          ))
                      .toList(),
                ),
              ],
              const SizedBox(height: AppConstants.spacingMd),
              Container(
                padding: const EdgeInsets.all(AppConstants.spacingSm),
                decoration: BoxDecoration(
                  color: AppColors.sand,
                  borderRadius: BorderRadius.circular(AppConstants.radiusSm),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline,
                        size: AppConstants.iconSm, color: AppColors.inkSoft),
                    const SizedBox(width: AppConstants.spacingXs),
                    Expanded(
                      child: Text(
                        analysis.disclaimer,
                        style: AppTextStyles.caption,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (analysis.waveformUrl != null || analysis.spectrogramUrl != null)
          _buildVisualizations(analysis),
        const SizedBox(height: AppConstants.spacingMd),
        AppSecondaryButton(
          text: 'Nouvelle analyse',
          icon: Icons.refresh,
          onPressed: _reset,
        ),
      ],
    );
  }

  Widget _buildRiskBar(double riskScore, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Niveau de risque estimé', style: AppTextStyles.labelSmall),
        const SizedBox(height: AppConstants.spacingXxs),
        ClipRRect(
          borderRadius: BorderRadius.circular(AppConstants.radiusPill),
          child: LinearProgressIndicator(
            value: (riskScore / 100).clamp(0, 1),
            minHeight: 10,
            backgroundColor: AppColors.sand,
            valueColor: AlwaysStoppedAnimation(color),
          ),
        ),
        const SizedBox(height: AppConstants.spacingXxs),
        Text('${riskScore.toStringAsFixed(0)}%', style: AppTextStyles.caption),
      ],
    );
  }

  Widget _buildVisualizations(CardiacAnalysis analysis) {
    final images = [
      analysis.waveformUrl,
      analysis.spectrogramUrl,
      analysis.mfccUrl,
    ].whereType<String>().toList();

    if (images.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: AppConstants.spacingMd),
      child: SizedBox(
        height: 120,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding:
              const EdgeInsets.symmetric(horizontal: AppConstants.spacingMd),
          itemCount: images.length,
          separatorBuilder: (_, __) =>
              const SizedBox(width: AppConstants.spacingSm),
          itemBuilder: (context, index) => ClipRRect(
            borderRadius: BorderRadius.circular(AppConstants.radiusMd),
            child: Image.network(
              images[index],
              width: 160,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const SizedBox.shrink(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHistory() {
    if (_isLoadingHistory) {
      return const Padding(
        padding: EdgeInsets.all(AppConstants.spacingLg),
        child: LoadingIndicator(),
      );
    }
    if (_history.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: AppConstants.spacingMd),
        child: Text('Aucune analyse enregistrée', style: AppTextStyles.secondary),
      );
    }
    return Column(
      children: _history.map((analysis) {
        final isNormal = analysis.isNormal;
        final color = isNormal ? AppColors.primary : AppColors.red;
        return AppCard(
          margin: const EdgeInsets.only(bottom: AppConstants.spacingSm),
          child: Row(
            children: [
              Icon(
                isNormal ? Icons.favorite : Icons.warning_amber_rounded,
                color: color,
              ),
              const SizedBox(width: AppConstants.spacingSm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isNormal ? 'Normal' : 'Anormal',
                      style: AppTextStyles.bodyMedium.copyWith(color: color),
                    ),
                    Text(
                      _formatDate(analysis.createdAt),
                      style: AppTextStyles.caption,
                    ),
                  ],
                ),
              ),
              Text(
                '${analysis.confidence.toStringAsFixed(0)}%',
                style: AppTextStyles.label,
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/${date.year} '
        '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
