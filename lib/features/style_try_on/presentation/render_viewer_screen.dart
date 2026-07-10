import 'package:flutter/material.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';
import 'package:qwenhairaiapp/core/constants/app_colors.dart';
import 'package:qwenhairaiapp/core/design_system/components/gradient_button.dart';
import 'package:qwenhairaiapp/core/design_system/components/hair_brand_app_bar.dart';
import 'package:qwenhairaiapp/core/entities/hair_3d_render.dart';

class RenderViewerScreen extends StatelessWidget {
  final Hair3DRender render;

  const RenderViewerScreen({
    super.key,
    required this.render,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: HairBrandAppBar(
        title: '3D Hair Render',
        showBrandMark: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Stack(
        children: [
          ModelViewer(
            backgroundColor: AppColors.background,
            src: render.modelUrl,
            alt: '3D Render of user\'s hair',
            ar: true,
            autoRotate: true,
            cameraControls: true,
            disableZoom: false,
          ),
          Positioned(
            bottom: 24,
            left: 24,
            right: 24,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surface.withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: const Column(
                    children: [
                      Text(
                        'Interactive 3D Preview',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        'Pinch to zoom, drag to rotate your hair render in 3D.',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: GradientButton(
                        label: 'Share',
                        variant: GradientButtonVariant.secondary,
                        icon: Icons.share_outlined,
                        onPressed: () {
                          // Handle share action
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Sharing 3D Model...')),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: GradientButton(
                        label: 'AR Mode',
                        icon: Icons.view_in_ar_outlined,
                        onPressed: () {
                          // Handle AR preview
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Entering Augmented Reality...')),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
