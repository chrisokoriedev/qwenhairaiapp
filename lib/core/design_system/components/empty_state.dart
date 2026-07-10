import 'package:flutter/material.dart';

import '../tokens/app_spacing.dart';
import 'gradient_button.dart';

/// Branded empty placeholder. Illustration slot + headline + body + optional CTA.
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.illustration,
    required this.title,
    required this.description,
    this.action,
  });

  final Widget illustration;
  final String title;
  final String description;
  final ({String label, VoidCallback onPressed})? action;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            illustration,
            const SizedBox(height: AppSpacing.xxl),
            Text(
              title,
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              description,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: Theme.of(context).colorScheme.onSurface),
              textAlign: TextAlign.center,
            ),
            if (action != null) ...[
              const SizedBox(height: AppSpacing.xl),
              GradientButton(
                label: action!.label,
                onPressed: action!.onPressed,
                variant: GradientButtonVariant.secondary,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
