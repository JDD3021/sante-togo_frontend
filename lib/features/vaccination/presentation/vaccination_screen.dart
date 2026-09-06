import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_icons.dart';
import '../../../core/widgets/app_badge.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../data/api_vaccination_repository.dart';
import '../domain/vaccination.dart';
import '../../../core/network/api_exception.dart';

/// Vaccination calendar for a patient
///
/// Backed by the SANTÉ+ backend, which auto-generates the standard PEV
/// schedule the first time a patient's calendar is requested.
class VaccinationScreen extends ConsumerStatefulWidget {
  final String patientId;

  const VaccinationScreen({super.key, required this.patientId});

  @override
  ConsumerState<VaccinationScreen> createState() => _VaccinationScreenState();
}

class _VaccinationScreenState extends ConsumerState<VaccinationScreen> {
  final ApiVaccinationRepository _repository = ApiVaccinationRepository();
  List<Vaccination> _schedule = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final schedule = await _repository.getScheduleForPatient(widget.patientId);
      if (!mounted) return;
      setState(() {
        _schedule = schedule;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = e is ApiException ? e.message : 'Une erreur inattendue est survenue.';
      });
    }
  }

  static const _months = [
    'jan', 'fév', 'mar', 'avr', 'mai', 'juin',
    'juil', 'août', 'sep', 'oct', 'nov', 'déc',
  ];

  String _formatDate(DateTime date) =>
      '${date.day} ${_months[date.month - 1]} ${date.year}';

  @override
  Widget build(BuildContext context) {
    final done = _schedule.where((v) => v.status == VaccinationStatus.done).length;

    return Scaffold(
      backgroundColor: AppColors.screenBg,
      appBar: AppBar(
        title: Text('Calendrier de vaccination', style: AppTextStyles.h4),
        backgroundColor: AppColors.screenBg,
        elevation: 0,
      ),
      body: _isLoading
          ? const LoadingIndicator(message: 'Chargement...')
          : _errorMessage != null
              ? ErrorState(message: _errorMessage!, onRetry: _load)
              : _schedule.isEmpty
              ? const EmptyState(
                  icon: AppIcons.baby,
                  title: 'Aucun calendrier',
                  subtitle: 'Aucune donnée de vaccination pour ce patient',
                )
              : ListView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.spacingMd,
                    vertical: AppConstants.spacingSm,
                  ),
                  children: [
                    _buildProgressSummary(done, _schedule.length),
                    const SizedBox(height: AppConstants.spacingMd),
                    ..._schedule.map(_buildVaccinationRow),
                  ],
                ),
    );
  }

  Widget _buildProgressSummary(int done, int total) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppConstants.spacingMd),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(AppConstants.radiusXl),
      ),
      child: Row(
        children: [
          const Icon(AppIcons.baby, color: AppColors.primaryDark),
          const SizedBox(width: AppConstants.spacingSm),
          Expanded(
            child: Text(
              '$done sur $total doses administrées',
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.primaryDark),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVaccinationRow(Vaccination v) {
    final StatusType statusType;
    final IconData statusIcon;
    switch (v.status) {
      case VaccinationStatus.done:
        statusType = StatusType.success;
        statusIcon = Icons.check_circle;
        break;
      case VaccinationStatus.overdue:
        statusType = StatusType.warning;
        statusIcon = Icons.schedule;
        break;
      case VaccinationStatus.upcoming:
        statusType = StatusType.neutral;
        statusIcon = Icons.event;
        break;
    }

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: AppConstants.spacingSm),
      padding: const EdgeInsets.all(AppConstants.spacingMd),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppConstants.radiusXl),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowSoft,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(statusIcon, color: AppColors.inkSoft),
          const SizedBox(width: AppConstants.spacingMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(v.vaccineName, style: AppTextStyles.bodyMedium),
                const SizedBox(height: AppConstants.spacingXxs),
                Text(
                  _formatDate(v.scheduledDate),
                  style: AppTextStyles.secondary,
                ),
              ],
            ),
          ),
          StatusBadge(text: v.status.label, type: statusType),
        ],
      ),
    );
  }
}
