import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../constants/app_constants.dart';

/// Badge component for SANTÉ+ TOGO
///
/// Used for status indicators, counts, and labels
class AppBadge extends StatelessWidget {
  final String text;
  final Color? backgroundColor;
  final Color? textColor;
  final IconData? icon;

  const AppBadge({
    super.key,
    required this.text,
    this.backgroundColor,
    this.textColor,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.spacingSm,
        vertical: AppConstants.spacingXxs,
      ),
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.sand,
        borderRadius: BorderRadius.circular(AppConstants.radiusPill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: AppConstants.iconSm,
              color: textColor ?? AppColors.inkSoft,
            ),
            const SizedBox(width: AppConstants.spacingXxs),
          ],
          Text(
            text,
            style: AppTextStyles.caption.copyWith(
              color: textColor ?? AppColors.inkSoft,
            ),
          ),
        ],
      ),
    );
  }
}

/// Status badge with predefined styles
class StatusBadge extends StatelessWidget {
  final String text;
  final StatusType type;

  const StatusBadge({
    super.key,
    required this.text,
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color textColor;

    switch (type) {
      case StatusType.success:
        bgColor = AppColors.primaryLight;
        textColor = AppColors.primaryDark;
        break;
      case StatusType.warning:
        bgColor = AppColors.accentLight;
        textColor = AppColors.accent;
        break;
      case StatusType.error:
        // CRITICAL: Only use red for medical alerts
        bgColor = AppColors.redLight;
        textColor = AppColors.red;
        break;
      case StatusType.neutral:
      default:
        bgColor = AppColors.sand;
        textColor = AppColors.inkSoft;
        break;
    }

    return AppBadge(
      text: text,
      backgroundColor: bgColor,
      textColor: textColor,
    );
  }
}

enum StatusType {
  success,
  warning,
  error,
  neutral,
}

/// Connection status indicator
///
/// [onDark] switches text/dot styling for use on the gradient hero headers.
class ConnectionStatusBadge extends StatelessWidget {
  final bool isOnline;
  final bool onDark;

  const ConnectionStatusBadge({
    super.key,
    required this.isOnline,
    this.onDark = false,
  });

  @override
  Widget build(BuildContext context) {
    final dotColor = isOnline
        ? (onDark ? AppColors.white : AppColors.primary)
        : AppColors.accent;
    final textStyle = onDark
        ? AppTextStyles.secondary.copyWith(color: AppColors.white)
        : AppTextStyles.secondary;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.spacingSm,
        vertical: AppConstants.spacingXxs,
      ),
      decoration: BoxDecoration(
        color: onDark ? AppColors.white.withValues(alpha: 0.18) : null,
        borderRadius: BorderRadius.circular(AppConstants.radiusPill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
          ),
          const SizedBox(width: AppConstants.spacingXs),
          Text(isOnline ? 'En ligne' : 'Hors-ligne', style: textStyle),
        ],
      ),
    );
  }
}
