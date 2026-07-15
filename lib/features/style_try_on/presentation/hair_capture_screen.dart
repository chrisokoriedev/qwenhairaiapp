import 'dart:io';
import 'package:app_settings/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:qwenhairaiapp/core/constants/app_colors.dart';
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

class _HairCaptureScreenState extends State<HairCaptureScreen> with TickerProviderStateMixin {
  final ImagePicker _picker = ImagePicker();
  
  String? _faceScanPath;
  String? _targetHairStylePath;
  
  bool _isScanning = false;
  double _scanProgress = 0.0;
  String _scanStepText = 'Align your face to begin';
  bool _scanCompleted = false;
  bool _permissionDenied = false;

  late AnimationController _pulseController;
  late AnimationController _progressController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 7),
    );

    _progressController.addListener(() {
      setState(() {
        _scanProgress = _progressController.value;
        if (_scanProgress < 0.25) {
          _scanStepText = 'Scan Front: Align face inside the circle...';
        } else if (_scanProgress < 0.50) {
          _scanStepText = 'Turn Left: Scanning profile...';
        } else if (_scanProgress < 0.75) {
          _scanStepText = 'Turn Right: Scanning profile...';
        } else {
          _scanStepText = 'Processing 3D face mesh...';
        }
      });
    });

    _progressController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _isScanning = false;
          _scanCompleted = true;
        });
      }
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  /// Checks and requests camera permission before opening the camera.
  Future<bool> _requestCameraPermission() async {
    final status = await Permission.camera.request();
    if (status.isGranted) {
      if (_permissionDenied) {
        setState(() => _permissionDenied = false);
      }
      return true;
    }

    if (status.isPermanentlyDenied) {
      setState(() => _permissionDenied = true);
      return false;
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Camera permission is needed to capture image.'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
    return false;
  }

  Future<void> _pickImage(bool isFaceScan) async {
    final hasPermission = await _requestCameraPermission();
    if (!hasPermission) return;

    try {
      final source = await showModalBottomSheet<ImageSource>(
        context: context,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (ctx) => SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  isFaceScan ? 'Capture Face Scan Image' : 'Select Hairstyle Image Source',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () => Navigator.pop(ctx, ImageSource.camera),
                        child: Column(
                          children: [
                            const Icon(Icons.camera_alt_outlined, size: 48, color: AppColors.primary),
                            const SizedBox(height: 8),
                            const Text('Camera'),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: InkWell(
                        onTap: () => Navigator.pop(ctx, ImageSource.gallery),
                        child: Column(
                          children: [
                            const Icon(Icons.photo_library_outlined, size: 48, color: AppColors.primary),
                            const SizedBox(height: 8),
                            const Text('Gallery'),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      );

      if (source == null) return;

      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          if (isFaceScan) {
            _faceScanPath = image.path;
            _scanCompleted = false; // Reset scan status if a new image is chosen
            _scanProgress = 0.0;
          } else {
            _targetHairStylePath = image.path;
          }
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

  void _startFaceMeshScan() {
    if (_faceScanPath == null) return;
    setState(() {
      _isScanning = true;
      _scanProgress = 0.0;
    });
    _progressController.forward(from: 0.0);
  }

  void _submitReconstruction() {
    if (!_scanCompleted || _faceScanPath == null || _targetHairStylePath == null) return;

    context.read<StyleTryOnController>().add(
          GenerateHair3DModelEvent(
            faceScanPath: _faceScanPath!,
            targetHairStylePath: _targetHairStylePath!,
          ),
        );
  }

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
              'HairPredict needs camera access to capture your face and target hairstyle images. '
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

  @override
  Widget build(BuildContext context) {
    final brand = Theme.of(context).extension<HairTheme>() ??
        HairTheme.forBrightness(Theme.of(context).brightness);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: HairBrandAppBar(
        title: '3D Face AI Style Try-On',
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
                    'AI Reconstructing Face & Hairstyle...',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Mapping facial contours and generating hairstyle overlay via Qwen AI',
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
                // STEP 1: 3D FACE SCAN CARD
                _buildFaceScanSection(brand),
                const SizedBox(height: 24),

                // STEP 2: ATTACH TARGET HAIRSTYLE CARD
                _buildHairstyleAttachSection(brand),
                const SizedBox(height: 32),

                // GENERATE ACTION
                GradientButton(
                  label: 'Generate 3D Style Try-On',
                  isExpanded: true,
                  onPressed: (_scanCompleted && _targetHairStylePath != null) ? _submitReconstruction : null,
                  icon: Icons.auto_awesome,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildFaceScanSection(HairTheme brand) {
    final double scannerHeight = 280.0;

    return Card(
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: _scanCompleted
              ? AppColors.success.withValues(alpha: 0.5)
              : AppColors.primary.withValues(alpha: 0.15),
          width: 1.5,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.face_retouching_natural,
                    color: AppColors.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Step 1: 3D Face Scanner',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                ),
                const Spacer(),
                if (_scanCompleted)
                  const Icon(Icons.check_circle, color: AppColors.success, size: 22),
              ],
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                height: scannerHeight,
                color: Colors.black.withValues(alpha: 0.3),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    if (_faceScanPath != null)
                      Positioned.fill(
                        child: Image.file(
                          File(_faceScanPath!),
                          fit: BoxFit.cover,
                        ),
                      )
                    else
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.camera_front_outlined,
                              size: 56,
                              color: brand.colors.textSecondary.withValues(alpha: 0.5),
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'Face Scan Photo Required',
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Take a front photo of your face',
                              style: TextStyle(
                                color: brand.colors.textSecondary,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),

                    // OVAL GUIDELINE MASK (only show when not complete or during scan)
                    if (!_scanCompleted)
                      IgnorePointer(
                        child: Container(
                          decoration: ShapeDecoration(
                            shape: OvalBorder(
                              side: BorderSide(
                                color: _isScanning
                                    ? AppColors.primaryLight
                                    : AppColors.primary.withValues(alpha: 0.4),
                                width: 2,
                              ),
                            ),
                          ),
                          margin: const EdgeInsets.symmetric(horizontal: 56, vertical: 20),
                        ),
                      ),

                    // HOLOGRAPHIC MESH OVERLAY DURING SCANNING
                    if (_isScanning)
                      Positioned.fill(
                        child: AnimatedBuilder(
                          animation: Listenable.merge([_pulseController, _progressController]),
                          builder: (context, child) {
                            return CustomPaint(
                              painter: FaceMeshPainter(
                                progress: _scanProgress,
                                pulse: _pulseController.value,
                              ),
                            );
                          },
                        ),
                      ),

                    // SCANNING LASER LINE
                    if (_isScanning)
                      Positioned(
                        top: scannerHeight * _scanProgress,
                        left: 0,
                        right: 0,
                        child: Container(
                          height: 3,
                          decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primaryLight.withValues(alpha: 0.8),
                                blurRadius: 10,
                                spreadRadius: 2,
                              ),
                            ],
                            gradient: const LinearGradient(
                              colors: [
                                Colors.transparent,
                                AppColors.primaryLight,
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      ),

                    // LOADING TEXT OVERLAY DURING SCAN
                    if (_isScanning)
                      Positioned(
                        bottom: 12,
                        left: 12,
                        right: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.75),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _scanStepText,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 6),
                              LinearProgressIndicator(
                                value: _scanProgress,
                                backgroundColor: Colors.white24,
                                color: AppColors.primary,
                                minHeight: 4,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (_faceScanPath == null)
              GradientButton(
                label: 'Capture Face Photo',
                variant: GradientButtonVariant.secondary,
                icon: Icons.camera_alt_outlined,
                onPressed: () => _pickImage(true),
              )
            else if (!_isScanning && !_scanCompleted)
              Row(
                children: [
                  Expanded(
                    child: TextButton.icon(
                      icon: const Icon(Icons.refresh, color: AppColors.textSecondary),
                      label: const Text('Retake Photo', style: TextStyle(color: AppColors.textSecondary)),
                      onPressed: () => _pickImage(true),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GradientButton(
                      label: 'Run 3D Mesh Scan',
                      icon: Icons.radar,
                      onPressed: _startFaceMeshScan,
                    ),
                  ),
                ],
              )
            else if (_scanCompleted)
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      '3D mesh contours mapped',
                      style: TextStyle(
                        color: AppColors.success,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  TextButton.icon(
                    icon: const Icon(Icons.refresh, color: AppColors.primary),
                    label: const Text('Rescan', style: TextStyle(color: AppColors.primary)),
                    onPressed: () => _pickImage(true),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildHairstyleAttachSection(HairTheme brand) {
    final bool isEnabled = _scanCompleted;

    return Card(
      color: isEnabled ? AppColors.surface : AppColors.surface.withValues(alpha: 0.4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: _targetHairStylePath != null
              ? AppColors.primary.withValues(alpha: 0.5)
              : AppColors.primary.withValues(alpha: isEnabled ? 0.15 : 0.05),
          width: 1.5,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: (isEnabled ? AppColors.primary : AppColors.textSecondary)
                        .withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.attachment,
                    color: isEnabled ? AppColors.primary : AppColors.textSecondary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Step 2: Attach Target Hairstyle',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isEnabled ? AppColors.textPrimary : AppColors.textSecondary,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (!isEnabled)
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Text(
                    'Complete the face scan in Step 1 to unlock',
                    style: TextStyle(
                      color: brand.colors.textSecondary.withValues(alpha: 0.6),
                      fontSize: 14,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              )
            else if (_targetHairStylePath == null)
              Container(
                height: 140,
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.1),
                  ),
                ),
                child: InkWell(
                  onTap: () => _pickImage(false),
                  borderRadius: BorderRadius.circular(12),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add_photo_alternate_outlined,
                        size: 40,
                        color: brand.colors.textSecondary,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Upload/Attach Hairstyle Photo',
                        style: TextStyle(
                          color: brand.colors.textSecondary,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Select a photo of the cut you want',
                        style: TextStyle(
                          color: brand.colors.textSecondary.withValues(alpha: 0.6),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              Container(
                height: 160,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(11),
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: Image.file(
                          File(_targetHairStylePath!),
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: CircleAvatar(
                          backgroundColor: Colors.black54,
                          child: IconButton(
                            icon: const Icon(Icons.delete_outline, color: AppColors.error),
                            onPressed: () => setState(() => _targetHairStylePath = null),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          color: Colors.black54,
                          child: const Row(
                            children: [
                              Icon(Icons.image_search, color: AppColors.primaryLight, size: 16),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Hairstyle reference attached',
                                  style: TextStyle(color: Colors.white, fontSize: 12),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class FaceMeshPainter extends CustomPainter {
  final double progress; // 0.0 to 1.0
  final double pulse; // 0.0 to 1.0 (repeating)

  FaceMeshPainter({required this.progress, required this.pulse});

  @override
  void paint(Canvas canvas, Size size) {
    final width = size.width;
    final height = size.height;
    final centerX = width / 2;
    final centerY = height / 2;

    final paintLine = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.15 + 0.2 * pulse)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    final paintDot = Paint()
      ..color = AppColors.primaryLight.withValues(alpha: 0.5 + 0.5 * pulse)
      ..style = PaintingStyle.fill;

    // Fixed set of mesh coordinates relative to center, simulating facial features
    final rawPoints = [
      // Contour / Jawline
      const Offset(0, -0.65),
      const Offset(-0.3, -0.55), const Offset(0.3, -0.55),
      const Offset(-0.5, -0.3), const Offset(0.5, -0.3),
      const Offset(-0.55, 0.0), const Offset(0.55, 0.0),
      const Offset(-0.45, 0.3), const Offset(0.45, 0.3),
      const Offset(-0.25, 0.55), const Offset(0.25, 0.55),
      const Offset(0, 0.7),
      
      // Eyebrows
      const Offset(-0.22, -0.22), const Offset(-0.08, -0.2), const Offset(-0.16, -0.26),
      const Offset(0.22, -0.22), const Offset(0.08, -0.2), const Offset(0.16, -0.26),

      // Eyes
      const Offset(-0.2, -0.12), const Offset(-0.1, -0.12),
      const Offset(0.2, -0.12), const Offset(0.1, -0.12),
      
      // Nose
      const Offset(0, -0.1), const Offset(0, 0.15), const Offset(-0.08, 0.2), const Offset(0.08, 0.2),
      
      // Mouth
      const Offset(-0.18, 0.38), const Offset(0.18, 0.38), const Offset(0, 0.46), const Offset(0, 0.32)
    ];

    // Scale and translate points
    final points = rawPoints.map((pt) {
      // Add subtle scale animation based on pulse
      final scale = 1.0 + 0.02 * pulse;
      return Offset(
        centerX + pt.dx * (width * 0.5) * scale,
        centerY + pt.dy * (height * 0.5) * scale,
      );
    }).toList();

    // Draw mesh connection lines (wireframe)
    void drawLine(int i, int j) {
      if (i < points.length && j < points.length) {
        canvas.drawLine(points[i], points[j], paintLine);
      }
    }

    // Connect jawline
    for (int i = 0; i < 11; i++) {
      drawLine(i, i + 1);
    }
    drawLine(11, 0);

    // Triangulate contour to center / nose bridge
    for (int i = 0; i < 12; i++) {
      drawLine(i, 24); // nose bridge start
      drawLine(i, 25); // nose tip
    }

    // Connect Eyebrows / Eyes
    drawLine(12, 14); drawLine(14, 13);
    drawLine(15, 17); drawLine(17, 16);
    drawLine(18, 19);
    drawLine(20, 21);

    // Connect Nose
    drawLine(24, 25); drawLine(25, 26); drawLine(25, 27); drawLine(26, 27);

    // Connect Mouth
    drawLine(28, 30); drawLine(30, 29); drawLine(29, 31); drawLine(31, 28);
    drawLine(28, 29);

    // Draw dots at vertices depending on current progress
    final visibleCount = (points.length * progress).round();
    for (int i = 0; i < visibleCount; i++) {
      canvas.drawCircle(points[i], 2.5, paintDot);
    }
  }

  @override
  bool shouldRepaint(covariant FaceMeshPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.pulse != pulse;
  }
}
