import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../app_icons.dart';

class ActionsMenuItem {
  const ActionsMenuItem(this.value, this.label, this.icon);

  final String value;
  final String label;
  final AppIconType icon;
}

/// Edit-pill actions menu (Figma Filtration / Maintenance History Actions Menu 873:187,
/// 892:715): a bordered card under the top bar, each row icon first and then the label,
/// with a divider after the first row. No dimming barrier.
Future<String?> showActionsMenu(
  BuildContext context, {
  required List<ActionsMenuItem> items,
}) {
  final top = MediaQuery.of(context).padding.top + 56 + 4;
  return showGeneralDialog<String>(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Dismiss',
    barrierColor: Colors.transparent,
    transitionDuration: const Duration(milliseconds: 120),
    pageBuilder: (ctx, _, __) => Align(
      alignment: Alignment.topRight,
      child: Padding(
        padding: EdgeInsets.only(top: top, right: 12),
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.barBorder),
            ),
            child: IntrinsicWidth(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (var i = 0; i < items.length; i++) ...[
                    if (i == 1)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 5),
                        child: Divider(
                            height: 1, thickness: 1, color: AppColors.divider),
                      ),
                    InkWell(
                      onTap: () => Navigator.of(ctx).pop(items[i].value),
                      child: SizedBox(
                        height: 28,
                        child: Row(
                          children: [
                            SizedBox(
                              width: 24,
                              child: AppIcon(items[i].icon,
                                  size: 20,
                                  color: AppColors.accent,
                                  strokeWidth: 1.6),
                            ),
                            const SizedBox(width: 10),
                            Text(items[i].label,
                                style: AppText.inter(15,
                                    weight: FontWeight.w500)),
                          ],
                        ),
                      ),
                    ),
                    if (i != items.length - 1 && i != 0) const SizedBox(height: 10),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
