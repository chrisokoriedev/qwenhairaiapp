import 'package:flutter/material.dart';

import '../theme/hair_theme.dart';
import '../tokens/app_spacing.dart';
import 'loading_dots.dart';

enum GradientButtonVariant { primary, secondary, tertiary }

/// Primary CTA — amber→copper gradient. Secondary = ghost outline.
/// Tertiary = text-only.
class GradientButton extends StatelessWidget {
  const GradientButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.variant = GradientButtonVariant.primary,
    this.isLoading = false,
    this.isExpanded = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final GradientButtonVariant variant;
  final bool isLoading;
  final bool isExpanded;

  bool get _isEnabled => onPressed != null && !isLoading;

  @override
  Widget build(BuildContext context) {
    final brand = Theme.of(context).extension<HairTheme>() ??
        HairTheme.forBrightness(Theme.of(context).brightness);
    final child = isLoading
        ? LoadingDots(
            size: LoadingDotsSize.sm,
            color: _foregroundColor(context),
          )
        : Row(
            mainAxisSize: isExpanded ? MainAxisSize.max : MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, color: _foregroundColor(context), size: 20),
                const SizedBox(width: AppSpacing.xs),
              ],
              Text(
                label,
                style: TextStyle(
                  color: _foregroundColor(context),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          );

    return Opacity(
      opacity: _isEnabled ? 1.0 : 0.38,
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: _isEnabled ? onPressed : null,
          borderRadius: BorderRadius.circular(brand.radii.md),
          child: Container(
            width: isExpanded ? double.infinity : null,
            height: 52,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              gradient: variant == GradientButtonVariant.primary
                  ? LinearGradient(
                      colors: [brand.colors.brandAmber, brand.colors.brandCopper],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : null,
              color: variant == GradientButtonVariant.secondary
                  ? Colors.transparent
                  : null,
              borderRadius: BorderRadius.circular(brand.radii.md),
              border: variant == GradientButtonVariant.secondary
                  ? Border.all(color: brand.colors.brandAmber, width: 1.5)
                  : null,
            ),
            child: Center(child: child),
          ),
        ),
      ),
    );
  }

  Color _foregroundColor(BuildContext context) {
    final brand = Theme.of(context).extension<HairTheme>() ??
        HairTheme.forBrightness(Theme.of(context).brightness);
    switch (variant) {
      case GradientButtonVariant.primary:
        return brand.colors.textPrimary;
      case GradientButtonVariant.secondary:
      case GradientButtonVariant.tertiary:
        return brand.colors.brandAmber;
    }
  }
}
