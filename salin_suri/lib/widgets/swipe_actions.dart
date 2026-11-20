import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'app_icons.dart';

/// 45px round archive / delete buttons (Figma "Archive Button" / "Delete Button").
class RoundActionButton extends StatelessWidget {
  const RoundActionButton({
    super.key,
    required this.type,
    required this.onTap,
    this.enabled = true,
  });

  final AppIconType type;
  final VoidCallback onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: enabled ? onTap : null,
        child: Opacity(
          opacity: enabled ? 1 : 0.4,
          child: Container(
            width: 45,
            height: 45,
            alignment: Alignment.center,
            decoration:
                BoxDecoration(color: AppColors.iconChip, shape: BoxShape.circle),
            child: AppIcon(type,
                size: 26, color: AppColors.accent, strokeWidth: 1.6),
          ),
        ),
      );
}

/// A list row that slides left on drag to reveal Archive and Delete buttons (Figma
/// "Card Actions", Filtration History 623:831). Only one row stays open at a time.
class SwipeActionRow extends StatefulWidget {
  const SwipeActionRow({
    super.key,
    required this.child,
    required this.onArchive,
    required this.onDelete,
    this.enabled = true,
  });

  final Widget child;
  final VoidCallback onArchive;
  final VoidCallback onDelete;

  /// Off while the list is in select mode.
  final bool enabled;

  @override
  State<SwipeActionRow> createState() => _SwipeActionRowState();
}

class _SwipeActionRowState extends State<SwipeActionRow> {
  /// Which row is currently open, so opening one closes the others.
  static final _open = ValueNotifier<Object?>(null);

  /// The card slides 117px: 45 + 17 + 45 buttons plus the 10px gap from the Figma frame.
  static const _reveal = 117.0;

  double _dx = 0;
  bool _dragging = false;

  @override
  void initState() {
    super.initState();
    _open.addListener(_onOpenChanged);
  }

  @override
  void dispose() {
    _open.removeListener(_onOpenChanged);
    super.dispose();
  }

  void _onOpenChanged() {
    if (_open.value != this && _dx != 0) setState(() => _dx = 0);
  }

  void _settle(double target) {
    setState(() {
      _dragging = false;
      _dx = target;
    });
    _open.value = target == 0 ? (_open.value == this ? null : _open.value) : this;
  }

  @override
  void didUpdateWidget(SwipeActionRow old) {
    super.didUpdateWidget(old);
    if (!widget.enabled && _dx != 0) _dx = 0;
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) return widget.child;
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onHorizontalDragStart: (_) => setState(() => _dragging = true),
      onHorizontalDragUpdate: (d) => setState(
          () => _dx = (_dx + d.delta.dx).clamp(-_reveal, 0.0)),
      onHorizontalDragEnd: (_) => _settle(_dx < -_reveal / 2 ? -_reveal : 0),
      onTap: _dx != 0 ? () => _settle(0) : null,
      child: Stack(
        children: [
          Positioned(
            right: 4,
            top: 0,
            bottom: 0,
            child: Row(
              children: [
                RoundActionButton(
                    type: AppIconType.archive,
                    onTap: () {
                      _settle(0);
                      widget.onArchive();
                    }),
                const SizedBox(width: 17),
                RoundActionButton(
                    type: AppIconType.trash,
                    onTap: () {
                      _settle(0);
                      widget.onDelete();
                    }),
              ],
            ),
          ),
          AnimatedContainer(
            duration: _dragging ? Duration.zero : const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            transform: Matrix4.translationValues(_dx, 0, 0),
            child: AbsorbPointer(absorbing: _dx != 0, child: widget.child),
          ),
        ],
      ),
    );
  }
}

/// "Edit" pill at the right of the top bar (Figma 873:172, 892:611).
class EditPill extends StatelessWidget {
  const EditPill({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          width: 53,
          height: 22,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(11),
            border: Border.all(color: AppColors.divider, width: 0.5),
          ),
          child: Text('Edit', style: AppText.sf(11)),
        ),
      );
}

/// Green check that replaces the back button in select mode (Figma "Group 125").
class SelectModeExit extends StatelessWidget {
  const SelectModeExit({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          width: 32,
          height: 32,
          decoration:
              BoxDecoration(color: AppColors.accent, shape: BoxShape.circle),
          child: const Icon(Icons.check_rounded, color: Colors.white, size: 20),
        ),
      );
}

/// Select-mode bottom bar (Figma 873:339 / 892:799): Select All pill on the left,
/// archive and delete buttons on the right.
class SelectionBar extends StatelessWidget {
  const SelectionBar({
    super.key,
    required this.allSelected,
    required this.hasSelection,
    required this.onToggleAll,
    required this.onArchive,
    required this.onDelete,
  });

  final bool allSelected;
  final bool hasSelection;
  final VoidCallback onToggleAll;
  final VoidCallback onArchive;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) => Container(
        height: 82,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        color: AppColors.background,
        child: Row(
          children: [
            GestureDetector(
              onTap: onToggleAll,
              child: Container(
                width: 110,
                height: 39,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.surfaceInner,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.barBorder, width: 0.5),
                ),
                child: Text(allSelected ? 'Deselect All' : 'Select All',
                    style: AppText.sf(13)),
              ),
            ),
            const Spacer(),
            RoundActionButton(
                type: AppIconType.archive,
                enabled: hasSelection,
                onTap: onArchive),
            const SizedBox(width: 17),
            RoundActionButton(
                type: AppIconType.trash,
                enabled: hasSelection,
                onTap: onDelete),
          ],
        ),
      );
}
