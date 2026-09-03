import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_icons.dart';
import '../../../core/widgets/app_button.dart';
import '../data/api_consultation_repository.dart';
import '../domain/consultation.dart';

/// New consultation screen with 4-step progressive form
class ConsultationScreen extends ConsumerStatefulWidget {
  final String patientId;

  const ConsultationScreen({
    super.key,
    required this.patientId,
  });

  @override
  ConsumerState<ConsultationScreen> createState() => _ConsultationScreenState();
}

class _ConsultationScreenState extends ConsumerState<ConsultationScreen> {
  final ApiConsultationRepository _repository = ApiConsultationRepository();
  int _currentStep = 1;
  static const int _totalSteps = 4;
  bool _isSaving = false;

  // Form data
  String? _selectedReason;
  double? _temperature;
  int? _systolicBP;
  int? _diastolicBP;
  double? _weight;
  String? _diagnosis;
  String? _prescription;
  String? _followUpDate;
  String? _followUpMethod;

  // Reason options
  final List<Map<String, dynamic>> _reasons = [
    {'icon': AppIcons.fever, 'label': 'Fièvre', 'value': 'Fièvre'},
    {'icon': AppIcons.pain, 'label': 'Douleur', 'value': 'Douleur'},
    {'icon': AppIcons.pregnancy, 'label': 'Grossesse', 'value': 'Grossesse'},
    {'icon': AppIcons.injury, 'label': 'Blessure', 'value': 'Blessure'},
    {'icon': AppIcons.calendar, 'label': 'Contrôle', 'value': 'Contrôle'},
    {'icon': AppIcons.other, 'label': 'Autre', 'value': 'Autre'},
  ];

  // Common diagnoses
  final List<String> _commonDiagnoses = [
    'Paludisme',
    'Grippe',
    'Gastro-entérite',
    'Hypertension',
    'Diabète',
    'Infection respiratoire',
  ];

  void _nextStep() {
    if (_currentStep < _totalSteps) {
      setState(() => _currentStep++);
    } else {
      _finishConsultation();
    }
  }

  void _previousStep() {
    if (_currentStep > 1) {
      setState(() => _currentStep--);
    }
  }

  void _finishConsultation() {
    // Show confirmation dialog with consultation details
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirmer la consultation', style: AppTextStyles.h4),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Motif: $_selectedReason', style: AppTextStyles.body),
            if (_diagnosis != null)
              Text('Diagnostic: $_diagnosis', style: AppTextStyles.body),
            if (_prescription != null)
              Text('Prescription: $_prescription', style: AppTextStyles.body),
            if (_followUpDate != null)
              Text('Suivi: $_followUpDate ($_followUpMethod)',
                  style: AppTextStyles.body),
            const SizedBox(height: 16),
            Text(
              'Voulez-vous enregistrer cette consultation ?',
              style: AppTextStyles.secondary,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Non', style: AppTextStyles.label),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _saveConsultation();
            },
            child: Text('Oui', style: AppTextStyles.label),
          ),
        ],
      ),
    );
  }

  Future<void> _saveConsultation() async {
    if (_isSaving) return;
    setState(() => _isSaving = true);

    final now = DateTime.now();
    final consultation = Consultation(
      id: '',
      patientId: widget.patientId,
      date: now,
      reason: _selectedReason ?? 'Autre',
      diagnosis: _diagnosis,
      prescription: _prescription,
      temperature: _temperature,
      systolicBP: _systolicBP,
      diastolicBP: _diastolicBP,
      weight: _weight,
      followUpDate: _followUpDate,
      followUpMethod: _followUpMethod,
      createdAt: now,
    );

    try {
      await _repository.createConsultation(consultation);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Consultation enregistrée')),
      );
      context.pop();
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              '⚠️ Échec de l\'enregistrement : ${e.toString().replaceFirst('Exception: ', '')}'),
          backgroundColor: AppColors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.screenBg,
      appBar: AppBar(
        title: Text(
          'Nouvelle Consultation',
          style: AppTextStyles.h4,
        ),
        backgroundColor: AppColors.screenBg,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.monitor_heart_outlined),
            tooltip: 'Analyse cardiaque IA',
            onPressed: () =>
                context.push('/patient/${widget.patientId}/cardiac-analysis'),
          ),
        ],
      ),
      body: Column(
        children: [
          // Progress indicator
          _buildProgressIndicator(),

          // Step content
          Expanded(
            child: _buildStepContent(),
          ),

          // Navigation buttons
          _buildNavigationButtons(),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spacingLg),
      child: Row(
        children: List.generate(_totalSteps, (index) {
          final stepNumber = index + 1;
          final isCompleted = stepNumber < _currentStep;
          final isCurrent = stepNumber == _currentStep;

          return Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 4,
                    decoration: BoxDecoration(
                      color: isCompleted || isCurrent
                          ? AppColors.primary
                          : AppColors.sandDark,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                if (index < _totalSteps - 1) const SizedBox(width: 8),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 1:
        return _buildReasonStep();
      case 2:
        return _buildVitalsStep();
      case 3:
        return _buildDiagnosisStep();
      case 4:
        return _buildPrescriptionStep();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildReasonStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.spacingLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Étape 1/4 : Motif',
            style: AppTextStyles.h3,
          ),
          const SizedBox(height: AppConstants.spacingSm),
          Text(
            'Quel est le motif de la consultation ?',
            style: AppTextStyles.secondary,
          ),
          const SizedBox(height: AppConstants.spacingLg),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: AppConstants.spacingSm,
              crossAxisSpacing: AppConstants.spacingSm,
              childAspectRatio: 1.0,
            ),
            itemCount: _reasons.length,
            itemBuilder: (context, index) {
              final reason = _reasons[index];
              final isSelected = _selectedReason == reason['value'];
              return InkWell(
                onTap: () {
                  setState(() => _selectedReason = reason['value']);
                },
                borderRadius: BorderRadius.circular(AppConstants.radiusXl),
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary : AppColors.white,
                    borderRadius: BorderRadius.circular(AppConstants.radiusXl),
                    border: isSelected
                        ? null
                        : Border.all(color: AppColors.line),
                    boxShadow: [
                      BoxShadow(
                        color: isSelected
                            ? AppColors.primary.withValues(alpha: 0.3)
                            : AppColors.shadowSoft,
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(AppConstants.spacingMd),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        reason['icon'],
                        size: AppConstants.iconXl,
                        color: isSelected ? AppColors.white : AppColors.inkSoft,
                      ),
                      const SizedBox(height: AppConstants.spacingSm),
                      Text(
                        reason['label'],
                        style: AppTextStyles.label.copyWith(
                          color: isSelected ? AppColors.white : AppColors.ink,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildVitalsStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.spacingLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Étape 2/4 : Constantes',
            style: AppTextStyles.h3,
          ),
          const SizedBox(height: AppConstants.spacingSm),
          Text(
            'Entrez les constantes vitales',
            style: AppTextStyles.secondary,
          ),
          const SizedBox(height: AppConstants.spacingLg),
          _buildVitalField(
            label: 'Température (°C)',
            icon: AppIcons.thermometer,
            value: _temperature,
            unit: '°C',
            onIncrement: () =>
                setState(() => _temperature = (_temperature ?? 37) + 0.1),
            onDecrement: () =>
                setState(() => _temperature = (_temperature ?? 37) - 0.1),
          ),
          const SizedBox(height: AppConstants.spacingMd),
          _buildVitalField(
            label: 'Tension (mmHg)',
            icon: AppIcons.heart,
            value: _systolicBP?.toDouble(),
            unit: 'systolique',
            onIncrement: () =>
                setState(() => _systolicBP = (_systolicBP ?? 120) + 5),
            onDecrement: () =>
                setState(() => _systolicBP = (_systolicBP ?? 120) - 5),
          ),
          const SizedBox(height: AppConstants.spacingMd),
          _buildVitalField(
            label: 'Tension (mmHg)',
            icon: AppIcons.heart,
            value: _diastolicBP?.toDouble(),
            unit: 'diastolique',
            onIncrement: () =>
                setState(() => _diastolicBP = (_diastolicBP ?? 80) + 5),
            onDecrement: () =>
                setState(() => _diastolicBP = (_diastolicBP ?? 80) - 5),
          ),
          const SizedBox(height: AppConstants.spacingMd),
          _buildVitalField(
            label: 'Poids (kg)',
            icon: AppIcons.weight,
            value: _weight,
            unit: 'kg',
            onIncrement: () => setState(() => _weight = (_weight ?? 70) + 1),
            onDecrement: () => setState(() => _weight = (_weight ?? 70) - 1),
          ),
        ],
      ),
    );
  }

  Widget _buildVitalField({
    required String label,
    required IconData icon,
    required double? value,
    required String unit,
    required VoidCallback onIncrement,
    required VoidCallback onDecrement,
  }) {
    return Container(
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
        children: [
          Icon(icon, color: AppColors.primary, size: AppConstants.iconLg),
          const SizedBox(width: AppConstants.spacingMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: AppTextStyles.labelSmall),
                Text(
                  '${value?.toStringAsFixed(1) ?? '-'} $unit',
                  style: AppTextStyles.h4,
                ),
              ],
            ),
          ),
          Row(
            children: [
              IconButton(
                onPressed: onDecrement,
                icon: const Icon(Icons.remove_circle_outline),
                color: AppColors.primary,
              ),
              IconButton(
                onPressed: onIncrement,
                icon: const Icon(Icons.add_circle_outline),
                color: AppColors.primary,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDiagnosisStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.spacingLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Étape 3/4 : Diagnostic',
            style: AppTextStyles.h3,
          ),
          const SizedBox(height: AppConstants.spacingSm),
          Text(
            'Sélectionnez un diagnostic ou entrez-en un',
            style: AppTextStyles.secondary,
          ),
          const SizedBox(height: AppConstants.spacingLg),

          // Common diagnoses
          Wrap(
            spacing: AppConstants.spacingSm,
            runSpacing: AppConstants.spacingSm,
            children: _commonDiagnoses.map((diagnosis) {
              final isSelected = _diagnosis == diagnosis;
              return InkWell(
                onTap: () {
                  setState(() => _diagnosis = diagnosis);
                },
                borderRadius: BorderRadius.circular(AppConstants.radiusPill),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.spacingMd,
                    vertical: AppConstants.spacingSm,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary : AppColors.white,
                    borderRadius: BorderRadius.circular(AppConstants.radiusPill),
                    border: isSelected
                        ? null
                        : Border.all(color: AppColors.line),
                  ),
                  child: Text(
                    diagnosis,
                    style: AppTextStyles.label.copyWith(
                      color: isSelected ? AppColors.white : AppColors.ink,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: AppConstants.spacingLg),

          // Custom diagnosis
          TextField(
            decoration: const InputDecoration(
              hintText: 'Autre diagnostic (optionnel)',
              labelText: 'Diagnostic personnalisé',
            ),
            onChanged: (value) {
              setState(() => _diagnosis = value.isEmpty ? null : value);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPrescriptionStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.spacingLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Étape 4/4 : Prescription & Suivi',
            style: AppTextStyles.h3,
          ),
          const SizedBox(height: AppConstants.spacingSm),
          Text(
            'Prescription et suivi (optionnel)',
            style: AppTextStyles.secondary,
          ),
          const SizedBox(height: AppConstants.spacingLg),
          TextField(
            decoration: const InputDecoration(
              labelText: 'Prescription (optionnel)',
              hintText: 'Médicaments, posologie...',
            ),
            maxLines: 3,
            onChanged: (value) {
              setState(() => _prescription = value.isEmpty ? null : value);
            },
          ),
          const SizedBox(height: AppConstants.spacingLg),
          Text('Rappel de suivi (optionnel)', style: AppTextStyles.label),
          const SizedBox(height: AppConstants.spacingSm),
          TextField(
            decoration: const InputDecoration(
              labelText: 'Date de suivi',
              hintText: 'JJ/MM/AAAA',
            ),
            onChanged: (value) {
              setState(() => _followUpDate = value.isEmpty ? null : value);
            },
          ),
          const SizedBox(height: AppConstants.spacingMd),
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(
              labelText: 'Méthode de rappel',
            ),
            items: const [
              DropdownMenuItem(value: 'SMS', child: Text('SMS')),
              DropdownMenuItem(value: 'Appel', child: Text('Appel')),
              DropdownMenuItem(value: 'Aucun', child: Text('Aucun')),
            ],
            onChanged: (value) {
              setState(() {
                _followUpMethod = value;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationButtons() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spacingLg),
      decoration: const BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.line,
            blurRadius: 4,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          if (_currentStep > 1)
            Expanded(
              child: AppSecondaryButton(
                text: 'Précédent',
                onPressed: _previousStep,
              ),
            ),
          if (_currentStep > 1) const SizedBox(width: AppConstants.spacingMd),
          Expanded(
            child: AppButton(
              text: _currentStep == _totalSteps ? 'Terminer' : 'Continuer',
              isLoading: _isSaving,
              onPressed: _isSaving ||
                      !(_selectedReason != null || _currentStep > 1)
                  ? null
                  : _nextStep,
            ),
          ),
        ],
      ),
    );
  }
}
