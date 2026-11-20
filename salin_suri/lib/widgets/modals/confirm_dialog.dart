import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import 'modal_shell.dart';

/// Small confirmation card (Figma Delete / Archive Filtration Confirmation 873:472,
/// 873:475): a message, a red action button and Cancel. Resolves to true when the
/// action is confirmed.
Future<bool> showConfirmation(
  BuildContext context, {
  required String message,
  required String actionLabel,
}) async {
  final result = await showAppModal<bool>(
    context,
    builder: (ctx) => Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: 220,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.barBorder),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(10),
                child: SizedBox(
                  width: 177,
                  child: Text(message, style: AppText.sf(18)),
                ),
              ),
              const SizedBox(height: 7),
              _Pill(label: actionLabel, onTap: () => Navigator.of(ctx).pop(true)),
              const SizedBox(height: 7),
              _Pill(label: 'Cancel', onTap: () => Navigator.of(ctx).pop(false)),
            ],
          ),
        ),
      ),
    ),
  );
  return result ?? false;
}

class _Pill extends StatelessWidget {
  const _Pill({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 177,
        padding: const EdgeInsets.all(10),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.iconChip,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(label, style: AppText.sf(18, color: AppColors.alert)),
      ),
    );
  }
}
