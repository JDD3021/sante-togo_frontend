import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/app_button.dart';
import '../data/api_patient_repository.dart';
import '../domain/patient.dart';
import '../../../core/network/api_exception.dart';

/// New patient registration form
class NewPatientScreen extends ConsumerStatefulWidget {
  const NewPatientScreen({super.key});

  @override
  ConsumerState<NewPatientScreen> createState() => _NewPatientScreenState();
}

class _NewPatientScreenState extends ConsumerState<NewPatientScreen> {
  final ApiPatientRepository _repository = ApiPatientRepository();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _birthYearController = TextEditingController();
  final _villageController = TextEditingController();
  final _phoneController = TextEditingController();
  final _allergiesController = TextEditingController();
  final _chronicController = TextEditingController();

  String _sex = 'M';
  bool _isSaving = false;
  String? _errorMessage;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _birthYearController.dispose();
    _villageController.dispose();
    _phoneController.dispose();
    _allergiesController.dispose();
    _chronicController.dispose();
    super.dispose();
  }

  bool get _isValid =>
      _firstNameController.text.trim().isNotEmpty &&
      _lastNameController.text.trim().isNotEmpty &&
      _villageController.text.trim().isNotEmpty;

  Future<void> _onSave() async {
    if (!_isValid || _isSaving) return;

    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    final allergies = _allergiesController.text
        .split(',')
        .map((a) => a.trim())
        .where((a) => a.isNotEmpty)
        .toList();

    final now = DateTime.now();
    final patient = Patient(
      id: '',
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      birthYear: int.tryParse(_birthYearController.text.trim()),
      sex: _sex,
      village: _villageController.text.trim(),
      phoneNumber: _phoneController.text.trim().isEmpty
          ? null
          : _phoneController.text.trim(),
      allergies: allergies.isEmpty ? null : allergies,
      chronicConditions: _chronicController.text.trim().isEmpty
          ? null
          : _chronicController.text.trim(),
      createdAt: now,
      updatedAt: now,
    );

    try {
      final created = await _repository.createPatient(patient);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${created.fullName} enregistré(e) avec succès'),
          backgroundColor: AppColors.primary,
        ),
      );
      context.pushReplacement('/patient/${created.id}');
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isSaving = false;
        _errorMessage = '⚠️ ${e is ApiException ? e.message : 'Une erreur inattendue est survenue.'}';
      });
    }
  }

  void _clearError() {
    if (_errorMessage != null) {
      setState(() => _errorMessage = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.screenBg,
      appBar: AppBar(
        title: Text('Nouveau patient', style: AppTextStyles.h4),
        backgroundColor: AppColors.screenBg,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.spacingMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Error message display
            if (_errorMessage != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppConstants.spacingMd),
                margin: const EdgeInsets.only(bottom: AppConstants.spacingMd),
                decoration: BoxDecoration(
                  color: AppColors.redLight,
                  borderRadius: BorderRadius.circular(AppConstants.radiusLg),
                  border: Border.all(color: AppColors.red, width: 1),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: AppColors.red,
                      size: AppConstants.iconLg,
                    ),
                    const SizedBox(width: AppConstants.spacingSm),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.red,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: AppColors.red),
                      onPressed: _clearError,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ),
            Text('Identité', style: AppTextStyles.label),
            const SizedBox(height: AppConstants.spacingSm),
            TextField(
              controller: _firstNameController,
              decoration: const InputDecoration(labelText: 'Prénom *'),
              onChanged: (_) {
                setState(() {});
                _clearError();
              },
            ),
            const SizedBox(height: AppConstants.spacingMd),
            TextField(
              controller: _lastNameController,
              decoration: const InputDecoration(labelText: 'Nom *'),
              onChanged: (_) {
                setState(() {});
                _clearError();
              },
            ),
            const SizedBox(height: AppConstants.spacingMd),
            _buildSexSelector(),
            const SizedBox(height: AppConstants.spacingMd),
            TextField(
              controller: _birthYearController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Année de naissance (approximative)',
                hintText: 'Ex: 1985',
              ),
            ),
            const SizedBox(height: AppConstants.spacingLg),
            Text('Localisation & contact', style: AppTextStyles.label),
            const SizedBox(height: AppConstants.spacingSm),
            TextField(
              controller: _villageController,
              decoration: const InputDecoration(labelText: 'Village *'),
              onChanged: (_) {
                setState(() {});
                _clearError();
              },
            ),
            const SizedBox(height: AppConstants.spacingMd),
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Téléphone',
                hintText: '+228...',
              ),
              onChanged: (_) => _clearError(),
            ),
            const SizedBox(height: AppConstants.spacingLg),
            Text('Antécédents médicaux (optionnel)',
                style: AppTextStyles.label),
            const SizedBox(height: AppConstants.spacingSm),
            TextField(
              controller: _allergiesController,
              decoration: const InputDecoration(
                labelText: 'Allergies',
                hintText: 'Séparées par des virgules',
              ),
            ),
            const SizedBox(height: AppConstants.spacingMd),
            TextField(
              controller: _chronicController,
              decoration: const InputDecoration(
                labelText: 'Maladies chroniques',
              ),
            ),
            const SizedBox(height: AppConstants.spacingXl),
            AppButton(
              text: 'Enregistrer',
              isLoading: _isSaving,
              onPressed: _isValid ? _onSave : null,
            ),
            const SizedBox(height: AppConstants.spacingLg),
          ],
        ),
      ),
    );
  }

  Widget _buildSexSelector() {
    return Row(
      children: [
        Expanded(child: _buildSexOption('M', 'Homme')),
        const SizedBox(width: AppConstants.spacingMd),
        Expanded(child: _buildSexOption('F', 'Femme')),
      ],
    );
  }

  Widget _buildSexOption(String value, String label) {
    final isSelected = _sex == value;
    return InkWell(
      onTap: () => setState(() => _sex = value),
      borderRadius: BorderRadius.circular(AppConstants.radiusXl),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppConstants.spacingMd),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.white,
          borderRadius: BorderRadius.circular(AppConstants.radiusXl),
          border: isSelected ? null : Border.all(color: AppColors.line),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: AppTextStyles.labelMedium.copyWith(
            color: isSelected ? AppColors.white : AppColors.ink,
          ),
        ),
      ),
    );
  }
}
