import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';

import 'package:qwenhairaiapp/core/constants/app_colors.dart';
import 'package:qwenhairaiapp/core/design_system/components/gradient_button.dart';
import 'package:qwenhairaiapp/core/design_system/components/hair_brand_app_bar.dart';
import 'package:qwenhairaiapp/core/design_system/components/loading_dots.dart';
import 'package:qwenhairaiapp/core/design_system/theme/hair_theme.dart';
import 'package:qwenhairaiapp/core/design_system/tokens/app_motion.dart';
import 'package:qwenhairaiapp/core/design_system/tokens/app_radii.dart';
import 'package:qwenhairaiapp/core/design_system/tokens/app_spacing.dart';
import 'package:qwenhairaiapp/core/entities/hair_diagnostics.dart';
import 'package:qwenhairaiapp/features/diagnostics/controller/diagnostics_cubit.dart';

/// Full diagnostics screen: capture → analyze → results → PDF.
class DiagnosticsScreen extends StatefulWidget {
  const DiagnosticsScreen({super.key});

  @override
  State<DiagnosticsScreen> createState() => _DiagnosticsScreenState();
}

class _DiagnosticsScreenState extends State<DiagnosticsScreen> {
  final ImagePicker _picker = ImagePicker();
  String? _currentImagePath;

  Future<bool> _requestCameraPermission() async {
    final status = await Permission.camera.request();
    return status.isGranted;
  }

  Future<void> _pickImage() async {
    final hasPermission = await _requestCameraPermission();
    if (!hasPermission) return;

    try {
      final source = await showModalBottomSheet<ImageSource>(
        context: context,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: const Radius.circular(20)),
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
                const Text(
                  'Select Image Source',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: _sourceOption(
                        icon: Icons.camera_alt_outlined,
                        label: 'Camera',
                        onTap: () => Navigator.pop(ctx, ImageSource.camera),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _sourceOption(
                        icon: Icons.photo_library_outlined,
                        label: 'Gallery',
                        onTap: () => Navigator.pop(ctx, ImageSource.gallery),
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

      final file = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      if (file == null) return;

      setState(() => _currentImagePath = file.path);
      if (!mounted) return;
      context.read<DiagnosticsCubit>().analyzeHairPhoto(file.path);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load image: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final brand = Theme.of(context).extension<HairTheme>() ??
        HairTheme.forBrightness(Theme.of(context).brightness);

    return Scaffold(
      appBar: HairBrandAppBar(
        title: 'Hair Diagnostics',
        actions: [
          if (_currentImagePath != null)
            IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: 'New analysis',
              onPressed: () {
                setState(() => _currentImagePath = null);
                context.read<DiagnosticsCubit>().reset();
              },
            ),
        ],
      ),
      body: BlocConsumer<DiagnosticsCubit, DiagnosticsState>(
        listener: (context, state) {
          if (state is DiagnosticsPdfReady) {
            _onPdfReady(state);
          } else if (state is DiagnosticsError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        builder: (context, state) {
          return switch (state) {
            DiagnosticsInitial() => _buildInitial(brand),
            DiagnosticsAnalyzing() => _buildAnalyzing(brand),
            DiagnosticsLoaded(:final diagnostics) => _buildResults(brand, diagnostics),
            DiagnosticsPdfGenerating() => _buildPdfGenerating(brand),
            DiagnosticsPdfReady(:final diagnostics) => _buildResults(brand, diagnostics),
            DiagnosticsError() => _buildInitial(brand),
          };
        },
      ),
    );
  }

  void _onPdfReady(DiagnosticsPdfReady state) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('PDF report generated!'),
        backgroundColor: AppColors.success,
        action: SnackBarAction(
          label: 'Share',
          onPressed: () => Share.shareXFiles(
            [XFile(state.pdfPath)],
            text: 'HairPredict Diagnostics Report',
          ),
        ),
      ),
    );
  }

  // ── Initial State ─────────────────────────────────────────────────

  Widget _buildInitial(HairTheme brand) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        children: [
          const SizedBox(height: AppSpacing.xl),
          // Hero illustration
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  brand.colors.brandAmber.withValues(alpha: 0.2),
                  brand.colors.brandCopper.withValues(alpha: 0.1),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Icon(
              Icons.health_and_safety_outlined,
              size: 56,
              color: brand.colors.brandAmber,
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),
          Text(
            'AI-Powered Hair Analysis',
            style: Theme.of(context)
                .textTheme
                .headlineSmall
                ?.copyWith(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Get a professional trichology assessment of your hair\n'
            'using Qwen Vision AI. Analysis includes hair type,\n'
            'density, texture, scalp condition, and personalized advice.',
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: brand.colors.textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xxxl),
          // Preview cards
          _previewCard(
            icon: Icons.search_outlined,
            title: 'Vision Analysis',
            subtitle: 'Qwen AI examines your hair structure',
            brand: brand,
          ),
          const SizedBox(height: AppSpacing.sm),
          _previewCard(
            icon: Icons.assignment_outlined,
            title: 'Detailed Report',
            subtitle: 'Type, density, texture, scalp & health score',
            brand: brand,
          ),
          const SizedBox(height: AppSpacing.sm),
          _previewCard(
            icon: Icons.description_outlined,
            title: 'PDF Dossier',
            subtitle: 'Save & share a professional PDF report',
            brand: brand,
          ),
          const SizedBox(height: AppSpacing.xxxl),
          GradientButton(
            label: 'Start Hair Analysis',
            isExpanded: true,
            icon: Icons.camera_alt_outlined,
            onPressed: _pickImage,
          ),
          const SizedBox(height: AppSpacing.lg),
        ],
      ),
    );
  }

  Widget _previewCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required HairTheme brand,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: brand.colors.surface,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        border: Border.all(
          color: brand.colors.brandAmber.withValues(alpha: 0.1),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: brand.colors.brandAmber.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppRadii.md),
            ),
            child: Icon(icon, color: brand.colors.brandAmber, size: 22),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: Theme.of(context)
                        .textTheme
                        .titleSmall
                        ?.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(subtitle,
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: brand.colors.textSecondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Analyzing State ───────────────────────────────────────────────

  Widget _buildAnalyzing(HairTheme brand) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Animated pulse ring
            _AnalysisPulseRing(brand: brand),
            const SizedBox(height: AppSpacing.xxl),
            const LoadingDots(size: LoadingDotsSize.lg),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Analyzing with Qwen Vision AI',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Examining hair texture, density, scalp condition,\n'
              'and generating personalized recommendations.',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: brand.colors.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // ── PDF Generating State ─────────────────────────────────────────

  Widget _buildPdfGenerating(HairTheme brand) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const LoadingDots(size: LoadingDotsSize.lg),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Generating PDF Report',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Compiling your hair diagnostics into a professional dossier.',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: brand.colors.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // ── Results State ────────────────────────────────────────────────

  Widget _buildResults(HairTheme brand, HairDiagnostics d) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Photo preview
          if (_currentImagePath != null)
            Container(
              height: 180,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppRadii.lg),
                image: DecorationImage(
                  image: FileImage(File(_currentImagePath!)),
                  fit: BoxFit.cover,
                ),
              ),
              foregroundDecoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppRadii.lg),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.6),
                  ],
                ),
              ),
              child: Align(
                alignment: Alignment.bottomLeft,
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle,
                          color: Colors.greenAccent, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        'Analysis complete',
                        style: Theme.of(context)
                            .textTheme
                            .labelLarge
                            ?.copyWith(color: Colors.white),
                      ),
                      const Spacer(),
                      Text(
                        '${d.healthScore}/100',
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge
                            ?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          const SizedBox(height: AppSpacing.lg),

          // Health Score gauge
          _HealthScoreGauge(score: d.healthScore, brand: brand),
          const SizedBox(height: AppSpacing.lg),

          // Details grid
          Text('Hair Profile',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: AppSpacing.sm),
          _detailsGrid(brand, d),
          const SizedBox(height: AppSpacing.lg),

          // Damage concerns
          if (d.damageConcerns != null) ...[
            Text('Concerns',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: AppSpacing.sm),
            _concernCard(brand, d.damageConcerns!),
            const SizedBox(height: AppSpacing.lg),
          ],

          // Recommendations
          Text('Recommendations',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: AppSpacing.sm),
          ...d.recommendations.map(
            (r) => _recommendationTile(brand, r),
          ),
          const SizedBox(height: AppSpacing.xxl),

          // Action buttons
          GradientButton(
            label: 'Generate PDF Report',
            isExpanded: true,
            icon: Icons.picture_as_pdf_outlined,
            onPressed: () => context.read<DiagnosticsCubit>().generatePdf(d),
          ),
          const SizedBox(height: AppSpacing.sm),
          GradientButton(
            label: 'New Analysis',
            isExpanded: true,
            variant: GradientButtonVariant.secondary,
            icon: Icons.camera_alt_outlined,
            onPressed: () {
              setState(() => _currentImagePath = null);
              context.read<DiagnosticsCubit>().reset();
            },
          ),
          const SizedBox(height: AppSpacing.xxl),
        ],
      ),
    );
  }

  Widget _detailsGrid(HairTheme brand, HairDiagnostics d) {
    return Row(
      children: [
        Expanded(child: _detailChip(brand, 'Type', d.hairType, Icons.code)),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
            child: _detailChip(
                brand, 'Density', d.hairDensity, Icons.line_weight)),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
            child: _detailChip(
                brand, 'Texture', d.hairTexture, Icons.grain)),
      ],
    );
  }

  Widget _detailChip(
    HairTheme brand,
    String label,
    String value,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: brand.colors.surface,
        borderRadius: BorderRadius.circular(AppRadii.md),
        border: Border.all(
          color: brand.colors.brandAmber.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        children: [
          Icon(icon, size: 20, color: brand.colors.brandAmber),
          const SizedBox(height: 6),
          Text(value,
              style: const TextStyle(
                  fontSize: 13, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center),
          const SizedBox(height: 2),
          Text(label,
              style: TextStyle(
                  fontSize: 10, color: brand.colors.textSecondary),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _concernCard(HairTheme brand, String concerns) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: brand.colors.warning.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppRadii.md),
        border: Border.all(
          color: brand.colors.warning.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.warning_amber_rounded,
              color: brand.colors.warning, size: 20),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              concerns,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  Widget _recommendationTile(HairTheme brand, String recommendation) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Icon(Icons.check_circle_outline,
                size: 18, color: brand.colors.success),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              recommendation,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  Widget _sourceOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 24),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(icon, size: 36, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 12),
            Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}

// ── Health Score Gauge ─────────────────────────────────────────────

class _HealthScoreGauge extends StatelessWidget {
  final int score;
  final HairTheme brand;

  const _HealthScoreGauge({required this.score, required this.brand});

  @override
  Widget build(BuildContext context) {
    final fraction = score / 100.0;
    final color = score >= 80
        ? Colors.greenAccent
        : score >= 50
            ? brand.colors.brandAmber
            : brand.colors.error;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: brand.colors.surface,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          // Circular progress
          SizedBox(
            width: 72,
            height: 72,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 72,
                  height: 72,
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: fraction),
                    duration: AppMotion.durationSlow,
                    curve: AppMotion.curveEmerge,
                    builder: (context, value, _) {
                      return CircularProgressIndicator(
                        value: value,
                        strokeWidth: 6,
                        backgroundColor:
                            brand.colors.surfaceVariant.withValues(alpha: 0.3),
                        valueColor: AlwaysStoppedAnimation(color),
                      );
                    },
                  ),
                ),
                Text(
                  '$score',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hair Health Score',
                  style: Theme.of(context)
                      .textTheme
                      .titleSmall
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  score >= 80
                      ? 'Excellent condition'
                      : score >= 50
                          ? 'Moderate — room for improvement'
                          : 'Needs attention — follow recommendations',
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: brand.colors.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Analysis Pulse Ring ────────────────────────────────────────────

class _AnalysisPulseRing extends StatefulWidget {
  final HairTheme brand;
  const _AnalysisPulseRing({required this.brand});

  @override
  State<_AnalysisPulseRing> createState() => _AnalysisPulseRingState();
}

class _AnalysisPulseRingState extends State<_AnalysisPulseRing>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

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
    return SizedBox(
      width: 96,
      height: 96,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return CustomPaint(
            size: const Size(96, 96),
            painter: _PulseRingPainter(
              progress: _controller.value,
              color: widget.brand.colors.brandAmber,
            ),
          );
        },
      ),
    );
  }
}

class _PulseRingPainter extends CustomPainter {
  final double progress;
  final Color color;

  _PulseRingPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 4;

    // Outer pulse ring
    final pulsePaint = Paint()
      ..color = color.withValues(alpha: (1 - progress) * 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    canvas.drawCircle(center, radius + (progress * 12), pulsePaint);

    // Inner ring
    final ringPaint = Paint()
      ..color = color.withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(center, radius, ringPaint);

    // Center dot
    final dotPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 4, dotPaint);
  }

  @override
  bool shouldRepaint(_PulseRingPainter old) => old.progress != progress;
}
