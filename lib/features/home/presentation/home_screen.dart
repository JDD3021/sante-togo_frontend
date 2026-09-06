import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_icons.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_badge.dart';
import '../../../core/widgets/gradient_header.dart';
import '../../../core/router/app_router.dart';
import '../../queue/data/api_queue_repository.dart';

/// Home screen with main navigation tiles
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final ApiQueueRepository _queueRepository = ApiQueueRepository();
  bool _isOnline = true;
  int? _queueCount;

  @override
  void initState() {
    super.initState();
    _loadQueueCount();
  }

  Future<void> _loadQueueCount() async {
    try {
      final count = await _queueRepository.getTodayQueueCount();
      if (!mounted) return;
      setState(() {
        _queueCount = count;
        _isOnline = true;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isOnline = false);
    }
  }

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
                        onTap: () => context.push(AppRoutes.newPatient),
                      ),
                      
                      const SizedBox(height: AppConstants.spacingMd),
                      
                      // Queue tile (neutral) with count
                      ActionCard(
                        title: 'File d\'attente',
                        icon: AppIcons.queue,
                        backgroundColor: AppColors.sandDark,
                        subtitle: _queueCount != null
                            ? '$_queueCount patients aujourd\'hui'
                            : 'Chargement...',
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
    return GradientHeader(
      padding: const EdgeInsets.fromLTRB(
        AppConstants.spacingLg,
        AppConstants.spacingMd,
        AppConstants.spacingLg,
        AppConstants.spacingLg,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'SANTÉ+ TOGO',
                style: AppTextStyles.brandBold
                    .copyWith(fontSize: 20, color: AppColors.white),
              ),
              const SizedBox(height: AppConstants.spacingXxs),
              Text(
                'Centre de Santé',
                style: AppTextStyles.secondary
                    .copyWith(color: AppColors.white.withValues(alpha: 0.85)),
              ),
            ],
          ),
          ConnectionStatusBadge(isOnline: _isOnline, onDark: true),
        ],
      ),
    );
  }

  Widget _buildBottomNavBar() {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppConstants.spacingLg,
          0,
          AppConstants.spacingLg,
          AppConstants.spacingMd,
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(
            vertical: AppConstants.spacingSm,
          ),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(AppConstants.radiusXxl),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadowSoft,
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
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
                onTap: () => context.push(AppRoutes.settings),
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
      borderRadius: BorderRadius.circular(AppConstants.radiusPill),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.spacingMd,
          vertical: AppConstants.spacingSm,
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryLight : Colors.transparent,
          borderRadius: BorderRadius.circular(AppConstants.radiusPill),
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
