import 'dart:io';

import 'package:flutter/material.dart';

import '../theme/hair_theme.dart';
import '../tokens/app_motion.dart';

/// Reusable capture card for the 4-angle hair scan flow.
/// Renders 4 corner brackets + camera icon when empty; image + check mark when filled.
class CaptureFrame extends StatelessWidget {
  const CaptureFrame({
    super.key,
    required this.angleLabel,
    required this.onTap,
    this.imagePath,
  });

  final String angleLabel;
  final String? imagePath;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final brand = Theme.of(context).extension<HairTheme>()!;
    final filled = imagePath != null;
    final bracketColor = filled
        ? Theme.of(context).colorScheme.primary
        : brand.colors.brandAmber;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppMotion.durationNormal,
        curve: AppMotion.curveEmerge,
        decoration: BoxDecoration(
          color: brand.colors.surface,
          borderRadius: BorderRadius.circular(brand.radii.lg),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            Positioned.fill(
              child: filled
                  ? Image.file(File(imagePath!), fit: BoxFit.cover)
                  : Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.camera_alt_outlined,
                            size: 40,
                            color: brand.colors.textSecondary.withValues(
                              alpha: 0.6,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            angleLabel,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Tap to capture',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(color: brand.colors.textSecondary),
                          ),
                        ],
                      ),
                    ),
            ),
            if (filled)
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.transparent, Colors.black87],
                    ),
                  ),
                ),
              ),
            // Corner brackets
            ..._buildCorners(bracketColor),
            if (filled)
              Positioned(
                bottom: 8,
                right: 8,
                child: Icon(
                  Icons.check_circle,
                  color: bracketColor,
                  size: 24,
                ),
              ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildCorners(Color color) {
    const armLength = 16.0;
    const strokeWidth = 2.0;
    Widget corner(Alignment align) {
      return Align(
        alignment: align,
        child: SizedBox(
          width: armLength,
          height: armLength,
          child: CustomPaint(
            painter: _CornerPainter(color, strokeWidth, align),
          ),
        ),
      );
    }

    return [
      corner(Alignment.topLeft),
      corner(Alignment.topRight),
      corner(Alignment.bottomLeft),
      corner(Alignment.bottomRight),
    ];
  }
}

class _CornerPainter extends CustomPainter {
  _CornerPainter(this.color, this.strokeWidth, this.alignment);

  final Color color;
  final double strokeWidth;
  final Alignment alignment;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;
    final path = Path();
    final isLeft = alignment == Alignment.topLeft ||
        alignment == Alignment.bottomLeft;
    final isTop = alignment == Alignment.topLeft ||
        alignment == Alignment.topRight;
    final x = isLeft ? 0.0 : size.width;
    final y = isTop ? 0.0 : size.height;

    if (isLeft) {
      path.moveTo(x, y + size.height);
      path.lineTo(x, y);
    } else {
      path.moveTo(x, y + size.height);
      path.lineTo(x, y);
    }
    if (isTop) {
      path.moveTo(0, y);
      path.lineTo(size.width, y);
    } else {
      path.moveTo(0, y);
      path.lineTo(size.width, y);
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_CornerPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.strokeWidth != strokeWidth;
}
