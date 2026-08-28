import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_icons.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../../../core/router/app_router.dart';
import '../../patient_search/data/mock_patient_repository.dart';
import '../../patient_search/domain/patient.dart';

/// Patient record screen with action grid
class PatientRecordScreen extends ConsumerStatefulWidget {
  final String patientId;

  const PatientRecordScreen({
    super.key,
    required this.patientId,
  });

  @override
  ConsumerState<PatientRecordScreen> createState() =>
      _PatientRecordScreenState();
}

class _PatientRecordScreenState extends ConsumerState<PatientRecordScreen> {
  final MockPatientRepository _repository = MockPatientRepository();
  Patient? _patient;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPatient();
  }

  Future<void> _loadPatient() async {
    setState(() => _isLoading = true);
    final patient = await _repository.getPatientById(widget.patientId);
    setState(() {
      _patient = patient;
      _isLoading = false;
    });
  }

  void _onActionPressed(String action) {
    switch (action) {
      case 'history':
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Historique des consultations - À implémenter')),
        );
        break;
      case 'treatments':
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Traitements en cours - À implémenter')),
        );
        break;
      case 'vaccinations':
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Calendrier de vaccination - À implémenter')),
        );
        break;
      case 'consultation':
        context.push('${AppRoutes.consultation}/${widget.patientId}');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.screenBg,
      appBar: AppBar(
        title: Text(
          'Fiche Patient',
          style: AppTextStyles.h4,
        ),
        backgroundColor: AppColors.screenBg,
        elevation: 0,
      ),
      body: _isLoading
          ? const LoadingIndicator(message: 'Chargement du patient...')
          : _patient == null
              ? const EmptyState(
                  icon: AppIcons.person,
                  title: 'Patient non trouvé',
                  subtitle: 'Ce patient n\'existe pas dans la base',
                )
              : _buildPatientContent(),
    );
  }

  Widget _buildPatientContent() {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Patient header card
          _buildPatientHeader(),

          // Allergy alert (if applicable)
          if (_patient!.hasAllergies) _buildAllergyAlert(),

          // Action grid
          _buildActionGrid(),
        ],
      ),
    );
  }

  Widget _buildPatientHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppConstants.spacingLg),
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(AppConstants.radiusXl),
          bottomRight: Radius.circular(AppConstants.radiusXl),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.line,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Avatar
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(AppConstants.radiusLg),
            ),
            child: Center(
              child: Text(
                _patient!.initials,
                style: AppTextStyles.h2.copyWith(
                  color: AppColors.primaryDark,
                ),
              ),
            ),
          ),
          const SizedBox(height: AppConstants.spacingMd),

          // Name
          Text(
            _patient!.fullName,
            style: AppTextStyles.h3,
          ),
          const SizedBox(height: AppConstants.spacingXs),

          // Basic info
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _patient!.sex == 'M' ? Icons.male : Icons.female,
                size: AppConstants.iconMd,
                color: AppColors.inkSoft,
              ),
              const SizedBox(width: AppConstants.spacingXxs),
              Text(
                '${_patient!.sex == 'M' ? 'Homme' : 'Femme'} · ${_patient!.approximateAge ?? '?'} ans',
                style: AppTextStyles.secondary,
              ),
            ],
          ),
          const SizedBox(height: AppConstants.spacingXxs),

          // Village
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.location_on,
                size: AppConstants.iconSm,
                color: AppColors.inkSoft,
              ),
              const SizedBox(width: AppConstants.spacingXxs),
              Text(
                _patient!.village,
                style: AppTextStyles.secondary,
              ),
            ],
          ),
          const SizedBox(height: AppConstants.spacingSm),

          // Patient ID
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.spacingSm,
              vertical: AppConstants.spacingXxs,
            ),
            decoration: BoxDecoration(
              color: AppColors.sand,
              borderRadius: BorderRadius.circular(AppConstants.radiusSm),
            ),
            child: Text(
              'Dossier #${_patient!.id}',
              style: AppTextStyles.caption,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAllergyAlert() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(AppConstants.spacingMd),
      padding: const EdgeInsets.all(AppConstants.spacingMd),
      decoration: BoxDecoration(
        color: AppColors.redLight,
        borderRadius: BorderRadius.circular(AppConstants.radiusLg),
        border: Border.all(color: AppColors.red, width: 2),
      ),
      child: Row(
        children: [
          const Icon(
            AppIcons.warning,
            color: AppColors.red,
            size: AppConstants.iconLg,
          ),
          const SizedBox(width: AppConstants.spacingSm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ALLERGIE',
                  style: AppTextStyles.label.copyWith(
                    color: AppColors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppConstants.spacingXxs),
                Text(
                  _patient!.allergies!.join(', '),
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.red,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionGrid() {
    return Padding(
      padding: const EdgeInsets.all(AppConstants.spacingMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Actions',
            style: AppTextStyles.label,
          ),
          const SizedBox(height: AppConstants.spacingSm),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: AppConstants.spacingSm,
            crossAxisSpacing: AppConstants.spacingSm,
            childAspectRatio: 1.2,
            children: [
              _buildActionCard(
                icon: AppIcons.calendar,
                label: 'Historique',
                color: AppColors.sandDark,
                action: 'history',
              ),
              _buildActionCard(
                icon: AppIcons.pill,
                label: 'Traitements',
                color: AppColors.sandDark,
                action: 'treatments',
              ),
              _buildActionCard(
                icon: AppIcons.baby,
                label: 'Vaccinations',
                color: AppColors.sandDark,
                action: 'vaccinations',
              ),
              _buildActionCard(
                icon: AppIcons.medical,
                label: 'Nouvelle consultation',
                color: AppColors.primary,
                action: 'consultation',
                isPrimary: true,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String label,
    required Color color,
    required String action,
    bool isPrimary = false,
  }) {
    return InkWell(
      onTap: () => _onActionPressed(action),
      borderRadius: BorderRadius.circular(AppConstants.radiusLg),
      child: Container(
        decoration: BoxDecoration(
          color: isPrimary ? color : AppColors.white,
          borderRadius: BorderRadius.circular(AppConstants.radiusLg),
          border: isPrimary ? null : Border.all(color: AppColors.line),
        ),
        padding: const EdgeInsets.all(AppConstants.spacingMd),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(AppConstants.spacingSm),
              decoration: BoxDecoration(
                color: isPrimary
                    ? AppColors.white.withValues(alpha: 0.2)
                    : color.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(AppConstants.radiusMd),
              ),
              child: Icon(
                icon,
                size: AppConstants.iconLg,
                color: isPrimary ? AppColors.white : color,
              ),
            ),
            const SizedBox(height: AppConstants.spacingSm),
            Text(
              label,
              style: AppTextStyles.label.copyWith(
                color: isPrimary ? AppColors.white : AppColors.ink,
                fontSize: 13,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
