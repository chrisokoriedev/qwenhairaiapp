import 'package:flutter/material.dart';

/// Editorial app bar — taller than Material default, Fraunces title,
/// optional brand-mark slot on the left.
class HairBrandAppBar extends StatelessWidget implements PreferredSizeWidget {
  const HairBrandAppBar({
    super.key,
    required this.title,
    this.leading,
    this.actions,
    this.showBrandMark = true,
  });

  final String title;
  final Widget? leading;
  final List<Widget>? actions;
  final bool showBrandMark;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 16);

  @override
  Widget build(BuildContext context) {
    final effectiveLeading = leading ??
        (showBrandMark
            ? Padding(
                padding: const EdgeInsets.only(left: 16),
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        Theme.of(context).colorScheme.primary,
                        Theme.of(context).colorScheme.secondary,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: const Icon(Icons.face_retouching_natural,
                      size: 18, color: Colors.white),
                ),
              )
            : null);

    return AppBar(
      title: Text(title),
      leading: effectiveLeading,
      actions: actions,
    );
  }
}
