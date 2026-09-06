import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../constants/app_constants.dart';

/// A pulsing placeholder block used to build skeleton loading screens.
///
/// Uses a looping opacity fade rather than a shimmer gradient so it needs
/// no extra package — cheap to render and still reads clearly as "loading".
class SkeletonBox extends StatefulWidget {
  final double? width;
  final double height;
  final BorderRadius borderRadius;

  const SkeletonBox({
    super.key,
    this.width,
    this.height = 14,
    this.borderRadius = const BorderRadius.all(Radius.circular(6)),
  });

  @override
  State<SkeletonBox> createState() => _SkeletonBoxState();
}

class _SkeletonBoxState extends State<SkeletonBox>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat(reverse: true);

  late final Animation<double> _opacity = Tween<double>(begin: 0.4, end: 1.0)
      .animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          color: AppColors.line,
          borderRadius: widget.borderRadius,
        ),
      ),
    );
  }
}

/// Skeleton placeholder shaped like a typical list row in this app: a
/// leading square (icon/avatar), two lines of text, a trailing pill badge.
class SkeletonListTile extends StatelessWidget {
  const SkeletonListTile({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: AppConstants.spacingSm),
      child: Row(
        children: [
          SkeletonBox(
            width: 48,
            height: 48,
            borderRadius: BorderRadius.all(Radius.circular(AppConstants.radiusLg)),
          ),
          SizedBox(width: AppConstants.spacingMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonBox(width: 140),
                SizedBox(height: AppConstants.spacingXs),
                SkeletonBox(width: 90, height: 12),
              ],
            ),
          ),
          SizedBox(width: AppConstants.spacingMd),
          SkeletonBox(
            width: 64,
            height: 24,
            borderRadius: BorderRadius.all(Radius.circular(AppConstants.radiusPill)),
          ),
        ],
      ),
    );
  }
}

/// A column of skeleton rows for list-shaped loading screens (queue,
/// search results, patient lists...). Drop-in replacement for
/// `LoadingIndicator` wherever the loaded content is a list.
class SkeletonList extends StatelessWidget {
  final int count;

  const SkeletonList({super.key, this.count = 6});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.spacingMd,
        vertical: AppConstants.spacingSm,
      ),
      itemCount: count,
      itemBuilder: (_, __) => const SkeletonListTile(),
    );
  }
}
