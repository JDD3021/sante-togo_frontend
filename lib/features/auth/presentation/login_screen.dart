import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_icons.dart';
import '../../../core/router/app_router.dart';

/// Login screen with PIN keypad
///
/// This is a UI-only implementation for the MVP.
/// Real authentication will be added in a future iteration.
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  String _pin = '';
  static const int _pinLength = 4;

  void _onDigitPressed(String digit) {
    if (_pin.length < _pinLength) {
      setState(() {
        _pin += digit;
      });

      // For MVP: navigate after 4 digits regardless of value
      if (_pin.length >= _pinLength) {
        Future.delayed(const Duration(milliseconds: 300), () {
          if (mounted) {
            context.go(AppRoutes.home);
          }
        });
      }
    }
  }

  void _onDeletePressed() {
    if (_pin.isNotEmpty) {
      setState(() {
        _pin = _pin.substring(0, _pin.length - 1);
      });
    }
  }

  void _onFingerprintPressed() {
    // Visual only for MVP - real biometrics will be added later
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Empreinte digitale - Non implémenté')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.screenBg,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(AppConstants.spacingLg),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: AppConstants.spacingXxl),

                // Logo/Brand
                const Icon(
                  AppIcons.localHospital,
                  size: 80,
                  color: AppColors.primary,
                ),
                const SizedBox(height: AppConstants.spacingMd),
                Text(
                  'SANTÉ+ TOGO',
                  style: AppTextStyles.h3,
                ),
                const SizedBox(height: AppConstants.spacingXxl),

                // Welcome message
                Text(
                  'Bonjour, Agent',
                  style: AppTextStyles.bodyMedium,
                ),
                const SizedBox(height: AppConstants.spacingXxl),

                // PIN dots indicator
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    _pinLength,
                    (index) => _buildPinDot(index < _pin.length),
                  ),
                ),
                const SizedBox(height: AppConstants.spacingXl),

                // Keypad
                _buildKeypad(),
                const SizedBox(height: AppConstants.spacingLg),

                // Fingerprint button (visual only)
                IconButton(
                  onPressed: _onFingerprintPressed,
                  icon: const Icon(
                    AppIcons.fingerprint,
                    size: 48,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: AppConstants.spacingSm),
                Text(
                  'Utiliser l\'empreinte',
                  style: AppTextStyles.secondary,
                ),
                const SizedBox(height: AppConstants.spacingXxl),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPinDot(bool filled) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppConstants.spacingSm),
      width: 16,
      height: 16,
      decoration: BoxDecoration(
        color: filled ? AppColors.primary : AppColors.sandDark,
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _buildKeypad() {
    return Column(
      children: [
        ...[
          ['1', '2', '3'],
          ['4', '5', '6'],
          ['7', '8', '9'],
        ].map((row) => Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: row.map((digit) => _buildKeypadButton(digit)).toList(),
            )),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(width: 72), // Empty space for alignment
            _buildKeypadButton('0'),
            SizedBox(
              width: 72,
              height: 72,
              child: IconButton(
                onPressed: _onDeletePressed,
                icon: const Icon(
                  Icons.backspace,
                  color: AppColors.inkSoft,
                  size: AppConstants.iconLg,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildKeypadButton(String digit) {
    return Container(
      width: 72,
      height: 72,
      margin: const EdgeInsets.all(AppConstants.spacingSm),
      child: ElevatedButton(
        onPressed: () => _onDigitPressed(digit),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.white,
          foregroundColor: AppColors.ink,
          shape: const CircleBorder(),
          elevation: 2,
        ),
        child: Text(
          digit,
          style: AppTextStyles.h3,
        ),
      ),
    );
  }
}
