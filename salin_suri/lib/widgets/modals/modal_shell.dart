import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

/// Shows [builder] as a centered modal with a dimmed barrier and a scale + fade entrance.
Future<T?> showAppModal<T>(
  BuildContext context, {
  required WidgetBuilder builder,
  bool barrierDismissible = true,
}) {
  return showGeneralDialog<T>(
    context: context,
    barrierDismissible: barrierDismissible,
    barrierLabel: 'Dismiss',
    barrierColor: Colors.black54,
    transitionDuration: const Duration(milliseconds: 220),
    pageBuilder: (ctx, _, __) => builder(ctx),
    transitionBuilder: (ctx, animation, _, child) {
      final curved =
          CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
      return FadeTransition(
        opacity: curved,
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.92, end: 1).animate(curved),
          child: child,
        ),
      );
    },
  );
}

/// Card used by every modal in the Figma file: #2D3535 fill, 0.5px #909090 border,
/// 20px radius, close button in the top-right corner.
class ModalShell extends StatelessWidget {
  const ModalShell({
    super.key,
    required this.child,
    this.width = 366,
    this.height,
    this.onClose,
  });

  final Widget child;
  final double width;
  final double? height;

  /// Defaults to popping the modal.
  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: width),
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: double.infinity,
              height: height,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFF909090), width: 0.5),
              ),
              child: Stack(
                children: [
                  child,
                  Positioned(
                    top: 14,
                    right: 24,
                    child: Semantics(
                      button: true,
                      label: 'Close',
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: onClose ?? () => Navigator.of(context).pop(),
                        child: Container(
                          width: 26,
                          height: 26,
                          decoration: const BoxDecoration(
                              color: AppColors.iconChip,
                              shape: BoxShape.circle),
                          child: const Icon(Icons.close_rounded,
                              size: 15, color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Full-width green button used at the bottom of the modals (Next →, Close).
class ModalButton extends StatelessWidget {
  const ModalButton({super.key, required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 279,
      height: 38,
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.accent,
          padding: const EdgeInsets.all(10),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 180),
          child: Text(label,
              key: ValueKey(label),
              style: AppText.sf(14, weight: FontWeight.w600)),
        ),
      ),
    );
  }
}
