import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_icons.dart';
import '../../../core/widgets/app_badge.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../data/api_consultation_repository.dart';
import '../domain/consultation.dart';

/// Active treatments for a patient
///
/// Derived from consultation prescriptions (no dedicated treatment endpoint
/// yet). A treatment is considered "active" while its follow-up date hasn't
/// passed, "à surveiller" once it has, matching the same data source
/// as the consultation history screen.
class TreatmentsScreen extends ConsumerStatefulWidget {
  final String patientId;

  const TreatmentsScreen({super.key, required this.patientId});

  @override
  ConsumerState<TreatmentsScreen> createState() => _TreatmentsScreenState();
}

class _TreatmentsScreenState extends ConsumerState<TreatmentsScreen> {
  final ApiConsultationRepository _repository = ApiConsultationRepository();
  List<Consultation> _treatments = [];
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
    final withPrescription = results
        .where((c) => c.prescription != null && c.prescription!.isNotEmpty)
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
    setState(() {
      _treatments = withPrescription;
      _isLoading = false;
    });
  }

  bool _isActive(Consultation c) {
    if (c.followUpDate == null) return false;
    final followUp = DateTime.tryParse(c.followUpDate!);
    return followUp != null && followUp.isAfter(DateTime.now());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.screenBg,
      appBar: AppBar(
        title: Text('Traitements', style: AppTextStyles.h4),
        backgroundColor: AppColors.screenBg,
        elevation: 0,
      ),
      body: _isLoading
          ? const LoadingIndicator(message: 'Chargement...')
          : _treatments.isEmpty
              ? const EmptyState(
                  icon: AppIcons.pill,
                  title: 'Aucun traitement',
                  subtitle: 'Aucune prescription enregistrée pour ce patient',
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.spacingMd,
                    vertical: AppConstants.spacingSm,
                  ),
                  itemCount: _treatments.length,
                  itemBuilder: (context, index) =>
                      _buildTreatmentCard(_treatments[index]),
                ),
    );
  }

  Widget _buildTreatmentCard(Consultation c) {
    final active = _isActive(c);
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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(AppConstants.spacingSm),
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(AppConstants.radiusMd),
            ),
            child: const Icon(AppIcons.pill, color: AppColors.primary),
          ),
          const SizedBox(width: AppConstants.spacingMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(c.prescription!, style: AppTextStyles.bodyBold),
                const SizedBox(height: AppConstants.spacingXxs),
                if (c.diagnosis != null)
                  Text(
                    'Pour : ${c.diagnosis}',
                    style: AppTextStyles.secondary,
                  ),
                const SizedBox(height: AppConstants.spacingSm),
                StatusBadge(
                  text: active ? 'En cours' : 'Suivi terminé',
                  type: active ? StatusType.success : StatusType.neutral,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
