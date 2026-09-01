import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_icons.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../data/api_consultation_repository.dart';
import '../domain/consultation.dart';

/// Consultation history for a patient
class ConsultationHistoryScreen extends ConsumerStatefulWidget {
  final String patientId;

  const ConsultationHistoryScreen({super.key, required this.patientId});

  @override
  ConsumerState<ConsultationHistoryScreen> createState() =>
      _ConsultationHistoryScreenState();
}

class _ConsultationHistoryScreenState
    extends ConsumerState<ConsultationHistoryScreen> {
  final ApiConsultationRepository _repository = ApiConsultationRepository();
  List<Consultation> _consultations = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    final results =
        await _repository.getConsultationsByPatient(widget.patientId);
    results.sort((a, b) => b.date.compareTo(a.date));
    setState(() {
      _consultations = results;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.screenBg,
      appBar: AppBar(
        title: Text('Historique des consultations', style: AppTextStyles.h4),
        backgroundColor: AppColors.screenBg,
        elevation: 0,
      ),
      body: _isLoading
          ? const LoadingIndicator(message: 'Chargement...')
          : _consultations.isEmpty
              ? const EmptyState(
                  icon: AppIcons.calendar,
                  title: 'Aucune consultation',
                  subtitle: 'Ce patient n\'a pas encore de consultation enregistrée',
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.spacingMd,
                    vertical: AppConstants.spacingSm,
                  ),
                  itemCount: _consultations.length,
                  itemBuilder: (context, index) =>
                      _buildConsultationCard(_consultations[index]),
                ),
    );
  }

  static const _months = [
    'janvier', 'février', 'mars', 'avril', 'mai', 'juin',
    'juillet', 'août', 'septembre', 'octobre', 'novembre', 'décembre',
  ];

  String _formatDate(DateTime date) {
    return '${date.day} ${_months[date.month - 1]} ${date.year}';
  }

  Widget _buildConsultationCard(Consultation consultation) {
    final dateLabel = _formatDate(consultation.date);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: AppConstants.spacingMd),
      padding: const EdgeInsets.all(AppConstants.spacingMd),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppConstants.radiusXl),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowSoft,
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(dateLabel, style: AppTextStyles.secondaryMedium),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.spacingSm,
                  vertical: AppConstants.spacingXxs,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(AppConstants.radiusPill),
                ),
                child: Text(
                  consultation.reason,
                  style: AppTextStyles.caption
                      .copyWith(color: AppColors.primaryDark),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.spacingSm),
          if (consultation.diagnosis != null) ...[
            Text(
              consultation.diagnosis!,
              style: AppTextStyles.bodyBold,
            ),
            const SizedBox(height: AppConstants.spacingXxs),
          ],
          if (consultation.prescription != null)
            Text(
              'Prescription : ${consultation.prescription}',
              style: AppTextStyles.secondary,
            ),
          if (_vitalsSummary(consultation) != null) ...[
            const SizedBox(height: AppConstants.spacingSm),
            Text(
              _vitalsSummary(consultation)!,
              style: AppTextStyles.caption,
            ),
          ],
          if (consultation.hasFollowUp) ...[
            const SizedBox(height: AppConstants.spacingSm),
            Row(
              children: [
                const Icon(Icons.event_repeat,
                    size: AppConstants.iconSm, color: AppColors.accent),
                const SizedBox(width: AppConstants.spacingXxs),
                Text(
                  'Suivi : ${consultation.followUpDate} (${consultation.followUpMethod ?? '-'})',
                  style: AppTextStyles.secondary
                      .copyWith(color: AppColors.accent),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  String? _vitalsSummary(Consultation c) {
    final parts = <String>[];
    if (c.temperature != null) parts.add('${c.temperature!.toStringAsFixed(1)}°C');
    if (c.bloodPressure != null) parts.add(c.bloodPressure!);
    if (c.weight != null) parts.add('${c.weight!.toStringAsFixed(1)} kg');
    return parts.isEmpty ? null : parts.join(' · ');
  }
}
