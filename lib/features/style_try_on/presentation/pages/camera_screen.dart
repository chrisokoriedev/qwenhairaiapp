import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qwenhairaiapp/core/constants/app_colors.dart';
import 'package:qwenhairaiapp/features/style_try_on/presentation/state/style_try_on_bloc.dart';
import 'package:qwenhairaiapp/features/style_try_on/presentation/state/style_try_on_event.dart';
import 'package:qwenhairaiapp/features/style_try_on/presentation/state/style_try_on_state.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  @override
  void initState() {
    super.initState();
    context.read<StyleTryOnBloc>().add(const GetAvailableStylesEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Hair AI Style Try-On',
          style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.surface,
        elevation: 0,
        centerTitle: true,
      ),
      body: BlocConsumer<StyleTryOnBloc, StyleTryOnState>(
        listener: (context, state) {
          if (state is StyleTryOnError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          } else if (state is StyleProcessSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Style processed successfully!'),
                backgroundColor: AppColors.success,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is StyleTryOnLoading) {
            return const Center(
              child: CircularProgressIndicator(
                color: AppColors.primary,
              ),
            );
          }

          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.camera_alt_outlined,
                  size: 80,
                  color: AppColors.primaryLight.withValues(alpha: 0.8),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Capture or upload an image to try on new styles',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () {
                    context.read<StyleTryOnBloc>().add(
                      const ProcessImageEvent(
                        imagePath: '/path/to/mock_image.png',
                        styleId: 'mock_style_1',
                      ),
                    );
                  },
                  icon: const Icon(Icons.flash_on),
                  label: const Text('Try Style'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.textPrimary,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
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
