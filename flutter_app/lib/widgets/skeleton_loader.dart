import 'package:flutter/material.dart';
import 'package:subscription_manager_flutter/theme/app_theme.dart';

/// Skeleton loader widget with shimmer effect
class SkeletonLoader extends StatefulWidget {
  const SkeletonLoader({
    super.key,
    this.width,
    this.height,
    this.borderRadius,
    this.child,
  });

  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final Widget? child;

  @override
  State<SkeletonLoader> createState() => _SkeletonLoaderState();
}

class _SkeletonLoaderState extends State<SkeletonLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: widget.borderRadius ?? AppRadii.sm,
            gradient: LinearGradient(
              begin: Alignment(-1.0 - _controller.value * 2, 0),
              end: Alignment(1.0 - _controller.value * 2, 0),
              colors: [
                AppColors.background,
                AppColors.background.withOpacity(0.6),
                AppColors.background,
              ],
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
          child: widget.child,
        );
      },
    );
  }
}

/// Pre-built skeleton loaders
class SkeletonLoaders {
  static Widget card({
    double? width,
    double? height = 120,
  }) {
    return SkeletonLoader(
      width: width,
      height: height,
      borderRadius: AppRadii.md,
    );
  }

  static Widget text({
    double? width,
    double? height = 16,
    double? borderRadius,
  }) {
    return SkeletonLoader(
      width: width,
      height: height,
      borderRadius: borderRadius != null
          ? BorderRadius.circular(borderRadius)
          : BorderRadius.circular(4),
    );
  }

  static Widget circle({double? size = 40}) {
    return SkeletonLoader(
      width: size,
      height: size,
      borderRadius: BorderRadius.circular(size! / 2),
    );
  }

  static Widget summaryCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg + AppSpacing.sm),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withOpacity(0.1),
            AppColors.primary.withOpacity(0.05),
          ],
        ),
        borderRadius: AppRadii.lg,
        border: Border.all(
          color: AppColors.divider.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SkeletonLoaders.text(
            width: 100,
            height: 14,
          ),
          const SizedBox(height: AppSpacing.sm),
          SkeletonLoaders.text(
            width: 200,
            height: 40,
          ),
          const SizedBox(height: AppSpacing.lg),
          SkeletonLoaders.text(
            width: 80,
            height: 28,
            borderRadius: 8,
          ),
        ],
      ),
    );
  }

  static Widget categoryCard({required double width}) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(AppSpacing.md + AppSpacing.xs),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadii.md,
        border: Border.all(
          color: AppColors.divider.withOpacity(0.6),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SkeletonLoaders.circle(size: 38),
              SkeletonLoaders.text(width: 24, height: 20, borderRadius: 6),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          SkeletonLoaders.text(width: 60, height: 13),
          const SizedBox(height: AppSpacing.xs),
          SkeletonLoaders.text(width: 80, height: 15),
        ],
      ),
    );
  }

  static Widget renewalCard() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md + AppSpacing.xs),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadii.md,
        border: Border.all(
          color: AppColors.divider.withOpacity(0.6),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          SkeletonLoaders.circle(size: 38),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonLoaders.text(width: 150, height: 15),
                const SizedBox(height: AppSpacing.xs + 2),
                SkeletonLoaders.text(width: 120, height: 12),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              SkeletonLoaders.text(width: 60, height: 15),
              const SizedBox(height: AppSpacing.xs + 2),
              SkeletonLoaders.text(width: 50, height: 20, borderRadius: 6),
            ],
          ),
        ],
      ),
    );
  }
}
