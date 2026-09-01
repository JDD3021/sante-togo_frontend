import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/router/app_router.dart';

/// Settings screen
///
/// UI-only for the MVP: notification/sync toggles are visual, real
/// preference persistence will be added in a future iteration.
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _autoSyncEnabled = true;

  void _onLogout() {
    context.go(AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.screenBg,
      appBar: AppBar(
        title: Text('Réglages', style: AppTextStyles.h4),
        backgroundColor: AppColors.screenBg,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppConstants.spacingMd),
        children: [
          _buildProfileCard(),
          const SizedBox(height: AppConstants.spacingLg),
          Text('Préférences', style: AppTextStyles.label),
          const SizedBox(height: AppConstants.spacingSm),
          _buildSwitchTile(
            icon: Icons.notifications_outlined,
            title: 'Notifications',
            subtitle: 'Rappels de suivi et alertes',
            value: _notificationsEnabled,
            onChanged: (v) => setState(() => _notificationsEnabled = v),
          ),
          const SizedBox(height: AppConstants.spacingSm),
          _buildSwitchTile(
            icon: Icons.sync,
            title: 'Synchronisation automatique',
            subtitle: 'Envoyer les données dès qu\'une connexion est disponible',
            value: _autoSyncEnabled,
            onChanged: (v) => setState(() => _autoSyncEnabled = v),
          ),
          const SizedBox(height: AppConstants.spacingLg),
          Text('À propos', style: AppTextStyles.label),
          const SizedBox(height: AppConstants.spacingSm),
          _buildInfoTile(icon: Icons.info_outline, title: 'Version', value: '1.0.0 (MVP)'),
          const SizedBox(height: AppConstants.spacingXl),
          _buildLogoutButton(),
        ],
      ),
    );
  }

  Widget _buildProfileCard() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spacingLg),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppConstants.radiusXl),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowSoft,
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: const BoxDecoration(
              color: AppColors.primaryLight,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.person, color: AppColors.primaryDark, size: 28),
          ),
          const SizedBox(width: AppConstants.spacingMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Agent de santé', style: AppTextStyles.bodyBold),
                const SizedBox(height: AppConstants.spacingXxs),
                Text('Centre de Santé', style: AppTextStyles.secondary),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppConstants.radiusXl),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowSoft,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: AppColors.white,
        clipBehavior: Clip.antiAlias,
        borderRadius: BorderRadius.circular(AppConstants.radiusXl),
        child: SwitchListTile(
          value: value,
          onChanged: onChanged,
          activeThumbColor: AppColors.primary,
          secondary: Icon(icon, color: AppColors.primary),
          title: Text(title, style: AppTextStyles.bodyMedium),
          subtitle: Text(subtitle, style: AppTextStyles.secondary),
        ),
      ),
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppConstants.radiusXl),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowSoft,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: AppColors.white,
        clipBehavior: Clip.antiAlias,
        borderRadius: BorderRadius.circular(AppConstants.radiusXl),
        child: ListTile(
          leading: Icon(icon, color: AppColors.primary),
          title: Text(title, style: AppTextStyles.bodyMedium),
          trailing: Text(value, style: AppTextStyles.secondary),
        ),
      ),
    );
  }

  Widget _buildLogoutButton() {
    // Note: red is reserved exclusively for critical medical alerts, so
    // logout uses the neutral ink tone instead.
    return SizedBox(
      width: double.infinity,
      height: AppConstants.touchTargetMin,
      child: OutlinedButton.icon(
        onPressed: _onLogout,
        icon: const Icon(Icons.logout, color: AppColors.inkSoft),
        label: Text(
          'Déconnexion',
          style: AppTextStyles.labelMedium.copyWith(color: AppColors.inkSoft),
        ),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: AppColors.line, width: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.radiusXl),
          ),
        ),
      ),
    );
  }
}
