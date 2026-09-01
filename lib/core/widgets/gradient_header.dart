import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../constants/app_constants.dart';

/// Curved gradient hero header used on login, home and patient screens
///
/// Reproduces the soft rounded-blob header look: a primary-gradient panel
/// with a large bottom curve and two faint decorative circles.
class GradientHeader extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;

  const GradientHeader({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.fromLTRB(
      AppConstants.spacingLg,
      AppConstants.spacingLg,
      AppConstants.spacingLg,
      AppConstants.spacingXl,
    ),
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        bottomLeft: Radius.circular(AppConstants.radiusXxl),
        bottomRight: Radius.circular(AppConstants.radiusXxl),
      ),
      child: Container(
        width: double.infinity,
        decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              top: -50,
              right: -40,
              child: _blob(140, Colors.white.withValues(alpha: 0.08)),
            ),
            Positioned(
              bottom: -60,
              left: -30,
              child: _blob(150, Colors.white.withValues(alpha: 0.06)),
            ),
            SafeArea(
              bottom: false,
              child: Padding(padding: padding, child: child),
            ),
          ],
        ),
      ),
    );
  }

  Widget _blob(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}
