import 'package:app_settings/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:qwenhairaiapp/core/constants/app_colors.dart';
import 'package:qwenhairaiapp/core/design_system/components/capture_frame.dart';
import 'package:qwenhairaiapp/core/design_system/components/gradient_button.dart';
import 'package:qwenhairaiapp/core/design_system/components/hair_brand_app_bar.dart';
import 'package:qwenhairaiapp/core/design_system/components/loading_dots.dart';
import 'package:qwenhairaiapp/core/design_system/theme/hair_theme.dart';
import 'package:qwenhairaiapp/features/style_try_on/controller/style_try_on_controller.dart';
import 'package:qwenhairaiapp/features/style_try_on/presentation/render_viewer_screen.dart';
import 'package:qwenhairaiapp/features/style_try_on/state/style_try_on_event.dart';
import 'package:qwenhairaiapp/features/style_try_on/state/style_try_on_state.dart';

class HairCaptureScreen extends StatefulWidget {
  const HairCaptureScreen({super.key});

  @override
  State<HairCaptureScreen> createState() => _HairCaptureScreenState();
}

class _HairCaptureScreenState extends State<HairCaptureScreen> {
  final ImagePicker _picker = ImagePicker();
  final Map<String, String?> _capturedImages = {
    'Front': null,
    'Back': null,
    'Left': null,
    'Right': null,
  };
  bool _permissionDenied = false;

  /// Checks and requests camera permission before opening the camera.
  /// Shows a user-friendly rationale if permission was denied.
  Future<bool> _requestCameraPermission() async {
    final status = await Permission.camera.request();
    if (status.isGranted) {
      if (_permissionDenied) {
        setState(() => _permissionDenied = false);
      }
      return true;
    }

    if (status.isPermanentlyDenied) {
      if (mounted) {
        setState(() => _permissionDenied = true);
      }
      return false;
    }

    // Denied but not permanently — user can try again.
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Camera permission is needed to capture hair images.',
          ),
          backgroundColor: Theme.of(context).colorScheme.error,
          action: SnackBarAction(
            label: 'Retry',
            onPressed: () => _captureImage('Front'),
          ),
        ),
      );
    }
    return false;
  }

  Future<void> _captureImage(String angle) async {
    final hasPermission = await _requestCameraPermission();
    if (!hasPermission) return;

    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _capturedImages[angle] = image.path;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to capture image: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  bool get _allImagesCaptured =>
      _capturedImages.values.every((path) => path != null);

  Widget _buildPermissionDenied() {
    final brand = Theme.of(context).extension<HairTheme>()!;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.no_photography_outlined,
              size: 80,
              color: brand.colors.textSecondary.withValues(alpha: 0.6),
            ),
            const SizedBox(height: 24),
            Text(
              'Camera Access Required',
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'HairPredict needs camera access to capture your hair angles for 3D analysis. '
              'Please enable camera permission in your device settings.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: brand.colors.textSecondary,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            GradientButton(
              label: 'Open Settings',
              isExpanded: true,
              icon: Icons.settings,
              onPressed: () => AppSettings.openAppSettings(),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => setState(() => _permissionDenied = false),
              child: Text(
                'Try again',
                style: TextStyle(color: brand.colors.brandAmber),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _submitReconstruction() {
    if (!_allImagesCaptured) return;

    context.read<StyleTryOnController>().add(
          GenerateHair3DModelEvent(
            frontPath: _capturedImages['Front']!,
            backPath: _capturedImages['Back']!,
            leftPath: _capturedImages['Left']!,
            rightPath: _capturedImages['Right']!,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: HairBrandAppBar(
        title: '3D Hair Scan Scanner',
        showBrandMark: true,
      ),
      body: BlocConsumer<StyleTryOnController, StyleTryOnState>(
        listener: (context, state) {
          if (state is Hair3DLoaded) {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => RenderViewerScreen(render: state.render),
              ),
            );
          } else if (state is Hair3DError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is Hair3DProcessing) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  LoadingDots(size: LoadingDotsSize.lg),
                  SizedBox(height: 24),
                  Text(
                    'Reconstructing Hair in 3D...',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Analyzing hair flow and volume via Qwen AI Cloud',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          if (_permissionDenied) {
            return _buildPermissionDenied();
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    'Please capture all 4 angles to generate the 3D model.',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 15,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 16),
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.8,
                  children: _capturedImages.keys.map((angle) {
                    return CaptureFrame(
                      angleLabel: angle,
                      imagePath: _capturedImages[angle],
                      onTap: () => _captureImage(angle),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 32),
                GradientButton(
                  label: 'Generate 3D Hair Model',
                  isExpanded: true,
                  onPressed: _allImagesCaptured ? _submitReconstruction : null,
                  icon: Icons.cloud_upload_outlined,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
