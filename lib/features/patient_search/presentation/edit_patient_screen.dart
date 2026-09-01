import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/app_button.dart';
import '../data/api_patient_repository.dart';
import '../domain/patient.dart';

/// Edit patient form
class EditPatientScreen extends ConsumerStatefulWidget {
  final String patientId;

  const EditPatientScreen({
    super.key,
    required this.patientId,
  });

  @override
  ConsumerState<EditPatientScreen> createState() => _EditPatientScreenState();
}

class _EditPatientScreenState extends ConsumerState<EditPatientScreen> {
  final ApiPatientRepository _repository = ApiPatientRepository();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _birthYearController = TextEditingController();
  final _villageController = TextEditingController();
  final _phoneController = TextEditingController();
  final _allergiesController = TextEditingController();
  final _chronicController = TextEditingController();

  String _sex = 'M';
  bool _isLoading = true;
  bool _isSaving = false;
  String? _errorMessage;
  Patient? _currentPatient;

  @override
  void initState() {
    super.initState();
    _loadPatient();
  }

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

  Future<void> _loadPatient() async {
    try {
      final patient = await _repository.getPatientById(widget.patientId);
      if (patient != null && mounted) {
        setState(() {
          _currentPatient = patient;
          _firstNameController.text = patient.firstName;
          _lastNameController.text = patient.lastName;
          _birthYearController.text = patient.birthYear?.toString() ?? '';
          _villageController.text = patient.village;
          _phoneController.text = patient.phoneNumber ?? '';
          _sex = patient.sex;
          _allergiesController.text = patient.allergies?.join(', ') ?? '';
          _chronicController.text = patient.chronicConditions ?? '';
          _isLoading = false;
        });
      } else if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Patient non trouvé';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = _formatErrorMessage(e.toString());
        });
      }
    }
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
    final updatedPatient = Patient(
      id: widget.patientId,
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
      createdAt: _currentPatient?.createdAt ?? now,
      updatedAt: now,
    );

    try {
      final updated = await _repository.updatePatient(updatedPatient);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${updated.fullName} modifié(e) avec succès'),
          backgroundColor: AppColors.primary,
        ),
      );
      context.pop(true); // Return true to indicate successful update
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isSaving = false;
        _errorMessage = _formatErrorMessage(e.toString());
      });
    }
  }

  String _formatErrorMessage(String error) {
    String message = error.replaceFirst('Exception: ', '');

    if (message.contains('existe déjà')) {
      return '⚠️ Ce numéro de téléphone est déjà utilisé par un autre patient. Veuillez utiliser un autre numéro.';
    } else if (message.contains('400')) {
      return '⚠️ Données invalides. Veuillez vérifier les champs du formulaire.';
    } else if (message.contains('404')) {
      return '⚠️ Patient non trouvé.';
    } else if (message.contains('500')) {
      return '⚠️ Erreur serveur. Veuillez réessayer plus tard.';
    } else if (message.contains('connexion') || message.contains('network')) {
      return '⚠️ Problème de connexion. Vérifiez votre connexion internet.';
    }

    return '⚠️ $message';
  }

  void _clearError([String? _]) {
    if (_errorMessage != null) {
      setState(() => _errorMessage = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.screenBg,
      appBar: AppBar(
        title: Text('Modifier le patient', style: AppTextStyles.h4),
        backgroundColor: AppColors.screenBg,
        elevation: 0,
        actions: [
          if (!_isLoading && _currentPatient != null)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _showDeleteDialog,
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _currentPatient == null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline,
                          size: 64, color: AppColors.red),
                      const SizedBox(height: AppConstants.spacingMd),
                      Text(
                        _errorMessage ?? 'Patient non trouvé',
                        style: AppTextStyles.h3,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppConstants.spacingLg),
                      ElevatedButton(
                        onPressed: () => context.pop(),
                        child: const Text('Retour'),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(AppConstants.spacingMd),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Error message display
                      if (_errorMessage != null)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(AppConstants.spacingMd),
                          margin: const EdgeInsets.only(
                              bottom: AppConstants.spacingMd),
                          decoration: BoxDecoration(
                            color: AppColors.redLight,
                            borderRadius:
                                BorderRadius.circular(AppConstants.radiusLg),
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
                                icon: const Icon(Icons.close,
                                    color: AppColors.red),
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
                        decoration:
                            const InputDecoration(labelText: 'Prénom *'),
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
                        onChanged: _clearError,
                      ),
                      const SizedBox(height: AppConstants.spacingLg),
                      Text('Localisation & contact',
                          style: AppTextStyles.label),
                      const SizedBox(height: AppConstants.spacingSm),
                      TextField(
                        controller: _villageController,
                        decoration:
                            const InputDecoration(labelText: 'Village *'),
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
                        onChanged: _clearError,
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
                        onChanged: _clearError,
                      ),
                      const SizedBox(height: AppConstants.spacingMd),
                      TextField(
                        controller: _chronicController,
                        decoration: const InputDecoration(
                          labelText: 'Maladies chroniques',
                        ),
                        onChanged: _clearError,
                      ),
                      const SizedBox(height: AppConstants.spacingXl),
                      AppButton(
                        text: 'Enregistrer les modifications',
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
      onTap: () {
        setState(() => _sex = value);
        _clearError();
      },
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

  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer le patient'),
        content: Text(
          'Êtes-vous sûr de vouloir supprimer ${_currentPatient?.fullName} ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await _deletePatient();
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.red),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }

  Future<void> _deletePatient() async {
    try {
      await _repository.deletePatient(widget.patientId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Patient supprimé avec succès'),
            backgroundColor: AppColors.primary,
          ),
        );
        context
            .pop('deleted'); // Return 'deleted' to indicate patient was deleted
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = _formatErrorMessage(e.toString());
        });
      }
    }
  }
}
