import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_icons.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_badge.dart';
import '../../../core/router/app_router.dart';

/// Home screen with main navigation tiles
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  // Mock connection status - will be real in production
  final bool _isOnline = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.screenBg,
      body: SafeArea(
        child: Column(
          children: [
            // Header with connection status
            _buildHeader(),
            
            // Main content
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.spacingMd,
                    vertical: AppConstants.spacingLg,
                  ),
                  child: Column(
                    children: [
                      // Search tile (green)
                      ActionCard(
                        title: 'Chercher',
                        icon: AppIcons.search,
                        backgroundColor: AppColors.primary,
                        onTap: () => context.push(AppRoutes.search),
                      ),
                      
                      const SizedBox(height: AppConstants.spacingMd),
                      
                      // New patient tile (orange)
                      ActionCard(
                        title: 'Nouveau patient',
                        icon: AppIcons.person,
                        backgroundColor: AppColors.accent,
                        onTap: () {
                          // TODO: Navigate to new patient form
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Formulaire nouveau patient - À implémenter')),
                          );
                        },
                      ),
                      
                      const SizedBox(height: AppConstants.spacingMd),
                      
                      // Queue tile (neutral) with count
                      ActionCard(
                        title: 'File d\'attente',
                        icon: AppIcons.queue,
                        backgroundColor: AppColors.sandDark,
                        subtitle: '7 patients aujourd\'hui',
                        onTap: () => context.push(AppRoutes.queue),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            // Bottom navigation bar
            _buildBottomNavBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spacingLg),
      color: AppColors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'SANTÉ+ TOGO',
                style: AppTextStyles.brandBold.copyWith(fontSize: 20),
              ),
              const SizedBox(height: AppConstants.spacingXxs),
              Text(
                'Centre de Santé',
                style: AppTextStyles.secondary,
              ),
            ],
          ),
          ConnectionStatusBadge(isOnline: _isOnline),
        ],
      ),
    );
  }

  Widget _buildBottomNavBar() {
    return Container(
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
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.spacingLg,
            vertical: AppConstants.spacingSm,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                icon: AppIcons.home,
                label: 'Accueil',
                isSelected: true,
                onTap: () {},
              ),
              _buildNavItem(
                icon: AppIcons.search,
                label: 'Chercher',
                isSelected: false,
                onTap: () => context.push(AppRoutes.search),
              ),
              _buildNavItem(
                icon: AppIcons.settings,
                label: 'Réglages',
                isSelected: false,
                onTap: () {
                  // TODO: Navigate to settings
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Réglages - À implémenter')),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppConstants.radiusMd),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.spacingMd,
          vertical: AppConstants.spacingSm,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.primary : AppColors.inkSoft,
              size: AppConstants.iconLg,
            ),
            const SizedBox(height: AppConstants.spacingXxs),
            Text(
              label,
              style: AppTextStyles.caption.copyWith(
                color: isSelected ? AppColors.primary : AppColors.inkSoft,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
