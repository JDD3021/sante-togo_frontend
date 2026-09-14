import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_icons.dart';
import '../../../core/router/app_router.dart';
import '../../../core/widgets/gradient_header.dart';
import '../../../core/widgets/app_button.dart';
import '../application/auth_provider.dart';

enum _LoginMode { password, otpRequest, otpVerify }

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  _LoginMode _mode = _LoginMode.password;
  bool _isRegistering = false;

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _codeController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _fullNameController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _submitPassword() async {
    final notifier = ref.read(authProvider.notifier);
    final success = _isRegistering
        ? await notifier.register(
            _emailController.text.trim(),
            _passwordController.text,
            _fullNameController.text.trim().isEmpty ? null : _fullNameController.text.trim(),
          )
        : await notifier.login(_emailController.text.trim(), _passwordController.text);
    if (success && mounted) context.go(AppRoutes.home);
  }

  Future<void> _requestOtp() async {
    final success = await ref.read(authProvider.notifier).requestOtp(_emailController.text.trim());
    if (success && mounted) setState(() => _mode = _LoginMode.otpVerify);
  }

  Future<void> _verifyOtp() async {
    final success = await ref
        .read(authProvider.notifier)
        .verifyOtp(_emailController.text.trim(), _codeController.text.trim());
    if (success && mounted) context.go(AppRoutes.home);
  }

  Future<void> _loginWithGoogle() async {
    final success = await ref.read(authProvider.notifier).loginWithGoogle();
    if (success && mounted) context.go(AppRoutes.home);
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: AppColors.screenBg,
      body: SingleChildScrollView(
        child: Column(
          children: [
            GradientHeader(
              child: Column(
                children: [
                  const SizedBox(height: AppConstants.spacingLg),
                  Container(
                    width: 88,
                    height: 88,
                    decoration: BoxDecoration(
                      color: AppColors.white.withValues(alpha: 0.18),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      AppIcons.localHospital,
                      size: 44,
                      color: AppColors.white,
                    ),
                  ),
                  const SizedBox(height: AppConstants.spacingMd),
                  Text(
                    'DEKERA',
                    style: AppTextStyles.h3.copyWith(color: AppColors.white),
                  ),
                  const SizedBox(height: AppConstants.spacingXxs),
                  Text(
                    'Le soignant connecté',
                    style: AppTextStyles.secondaryMedium
                        .copyWith(color: AppColors.white.withValues(alpha: 0.85)),
                  ),
                  const SizedBox(height: AppConstants.spacingXs),
                  Text(
                    'Bonjour, Agent',
                    style: AppTextStyles.bodyMedium
                        .copyWith(color: AppColors.white.withValues(alpha: 0.85)),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppConstants.spacingLg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: AppConstants.spacingSm),
                  if (authState.errorMessage != null) ...[
                    Container(
                      padding: const EdgeInsets.all(AppConstants.spacingSm),
                      decoration: BoxDecoration(
                        color: AppColors.accentLight,
                        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                      ),
                      child: Text(
                        authState.errorMessage!,
                        style: AppTextStyles.secondaryMedium.copyWith(color: AppColors.accent),
                      ),
                    ),
                    const SizedBox(height: AppConstants.spacingMd),
                  ],
                  if (_mode == _LoginMode.password) _buildPasswordForm(authState),
                  if (_mode == _LoginMode.otpRequest) _buildOtpRequestForm(authState),
                  if (_mode == _LoginMode.otpVerify) _buildOtpVerifyForm(authState),
                  const SizedBox(height: AppConstants.spacingLg),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPasswordForm(AuthState authState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(_isRegistering ? 'Créer un compte' : 'Connexion', style: AppTextStyles.h4),
        const SizedBox(height: AppConstants.spacingMd),
        if (_isRegistering) ...[
          TextField(
            controller: _fullNameController,
            decoration: const InputDecoration(labelText: 'Nom complet'),
          ),
          const SizedBox(height: AppConstants.spacingSm),
        ],
        TextField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(labelText: 'Email'),
        ),
        const SizedBox(height: AppConstants.spacingSm),
        TextField(
          controller: _passwordController,
          obscureText: true,
          decoration: const InputDecoration(labelText: 'Mot de passe'),
        ),
        const SizedBox(height: AppConstants.spacingLg),
        AppButton(
          text: _isRegistering ? 'Créer le compte' : 'Se connecter',
          isLoading: authState.isLoading,
          onPressed: _submitPassword,
        ),
        const SizedBox(height: AppConstants.spacingSm),
        TextButton(
          onPressed: () => setState(() => _isRegistering = !_isRegistering),
          child: Text(
            _isRegistering ? 'J\'ai déjà un compte' : 'Créer un compte',
            style: AppTextStyles.secondaryMedium.copyWith(color: AppColors.primary),
          ),
        ),
        const SizedBox(height: AppConstants.spacingMd),
        _buildDivider(),
        const SizedBox(height: AppConstants.spacingMd),
        AppSecondaryButton(
          text: 'Recevoir un code par email',
          icon: Icons.mail_outline,
          onPressed: () => setState(() => _mode = _LoginMode.otpRequest),
        ),
        const SizedBox(height: AppConstants.spacingSm),
        AppSecondaryButton(
          text: 'Continuer avec Google',
          icon: Icons.g_mobiledata,
          onPressed: authState.isLoading ? null : _loginWithGoogle,
        ),
      ],
    );
  }

  Widget _buildOtpRequestForm(AuthState authState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Code par email', style: AppTextStyles.h4),
        const SizedBox(height: AppConstants.spacingXs),
        Text(
          'Recevez un code de connexion à usage unique par email.',
          style: AppTextStyles.secondary,
        ),
        const SizedBox(height: AppConstants.spacingMd),
        TextField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(labelText: 'Email'),
        ),
        const SizedBox(height: AppConstants.spacingLg),
        AppButton(
          text: 'Envoyer le code',
          isLoading: authState.isLoading,
          onPressed: _requestOtp,
        ),
        const SizedBox(height: AppConstants.spacingSm),
        TextButton(
          onPressed: () => setState(() => _mode = _LoginMode.password),
          child: Text('Retour', style: AppTextStyles.secondaryMedium.copyWith(color: AppColors.primary)),
        ),
      ],
    );
  }

  Widget _buildOtpVerifyForm(AuthState authState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Entrez le code', style: AppTextStyles.h4),
        const SizedBox(height: AppConstants.spacingXs),
        Text(
          'Code envoyé à ${_emailController.text.trim()}',
          style: AppTextStyles.secondary,
        ),
        const SizedBox(height: AppConstants.spacingMd),
        TextField(
          controller: _codeController,
          keyboardType: TextInputType.number,
          maxLength: 6,
          decoration: const InputDecoration(labelText: 'Code à 6 chiffres'),
        ),
        const SizedBox(height: AppConstants.spacingSm),
        AppButton(
          text: 'Valider',
          isLoading: authState.isLoading,
          onPressed: _verifyOtp,
        ),
        const SizedBox(height: AppConstants.spacingSm),
        TextButton(
          onPressed: () => setState(() => _mode = _LoginMode.otpRequest),
          child: Text('Renvoyer un code', style: AppTextStyles.secondaryMedium.copyWith(color: AppColors.primary)),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        const Expanded(child: Divider(color: AppColors.line)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppConstants.spacingSm),
          child: Text('ou', style: AppTextStyles.caption),
        ),
        const Expanded(child: Divider(color: AppColors.line)),
      ],
    );
  }
}
