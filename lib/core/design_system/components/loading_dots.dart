import 'package:flutter/material.dart';


enum LoadingDotsSize { sm, md, lg }

/// Three dots that pulse in sequence — replaces CircularProgressIndicator
/// for "agent thinking" feel.
class LoadingDots extends StatefulWidget {
  const LoadingDots({
    super.key,
    this.size = LoadingDotsSize.md,
    this.color,
  });

  final LoadingDotsSize size;
  final Color? color;

  @override
  State<LoadingDots> createState() => _LoadingDotsState();
}

class _LoadingDotsState extends State<LoadingDots>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  double get _diameter {
    switch (widget.size) {
      case LoadingDotsSize.sm:
        return 6;
      case LoadingDotsSize.md:
        return 10;
      case LoadingDotsSize.lg:
        return 14;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.color ?? Theme.of(context).colorScheme.primary;
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (i) {
            // Stagger: dot i is offset by i * 200ms in a 600ms cycle.
            final phase = (_controller.value - i * 0.33).clamp(0.0, 1.0);
            final scale = 1.0 + (0.3 * (1 - (phase - 0.5).abs() * 2).clamp(0.0, 1.0));
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: _diameter * 0.4),
              child: Transform.scale(
                scale: scale,
                child: Container(
                  width: _diameter,
                  height: _diameter,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}
