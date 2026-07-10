import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:qwenhairaiapp/core/constants/app_colors.dart';
import 'package:qwenhairaiapp/features/style_try_on/presentation/pages/render_viewer_screen.dart';
import 'package:qwenhairaiapp/features/style_try_on/presentation/state/style_try_on_bloc.dart';
import 'package:qwenhairaiapp/features/style_try_on/presentation/state/style_try_on_event.dart';
import 'package:qwenhairaiapp/features/style_try_on/presentation/state/style_try_on_state.dart';

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

  Future<void> _captureImage(String angle) async {
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

  void _submitReconstruction() {
    if (!_allImagesCaptured) return;

    context.read<StyleTryOnBloc>().add(
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
      appBar: AppBar(
        title: const Text(
          '3D Hair Scan Scanner',
          style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.surface,
        elevation: 0,
        centerTitle: true,
      ),
      body: BlocConsumer<StyleTryOnBloc, StyleTryOnState>(
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
                  CircularProgressIndicator(
                    color: AppColors.primary,
                    strokeWidth: 5,
                  ),
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
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
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
                    final imagePath = _capturedImages[angle];
                    return GestureDetector(
                      onTap: () => _captureImage(angle),
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: imagePath != null
                                ? AppColors.primary
                                : AppColors.surface,
                            width: 2,
                          ),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: imagePath != null
                            ? Stack(
                                fit: StackFit.expand,
                                children: [
                                  Image.file(
                                    File(imagePath),
                                    fit: BoxFit.cover,
                                  ),
                                  Container(
                                    decoration: const BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: [
                                          Colors.transparent,
                                          Colors.black87,
                                        ],
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 8,
                                    left: 8,
                                    right: 8,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          angle,
                                          style: const TextStyle(
                                            color: AppColors.textPrimary,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const Icon(
                                          Icons.check_circle,
                                          color: AppColors.primaryLight,
                                          size: 20,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              )
                            : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.camera_alt_outlined,
                                    size: 40,
                                    color: AppColors.textSecondary.withValues(alpha: 0.6),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    angle,
                                    style: const TextStyle(
                                      color: AppColors.textPrimary,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  const Text(
                                    'Tap to capture',
                                    style: TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 32),
                ElevatedButton.icon(
                  onPressed: _allImagesCaptured ? _submitReconstruction : null,
                  icon: const Icon(Icons.cloud_upload_outlined),
                  label: const Text(
                    'Generate 3D Hair Model',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.textPrimary,
                    disabledBackgroundColor: AppColors.surface,
                    disabledForegroundColor: AppColors.textSecondary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
