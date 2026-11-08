import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../common.dart';
import '../segmented_tabs.dart';
import 'modal_shell.dart';

/// One page of an [InfoStepsModal]: a heading line, then the body underneath.
class InfoStep {
  const InfoStep({
    required this.heading,
    required this.body,
    this.bulleted = false,
    this.emphasizeBody = false,
  });

  final String heading;
  final String body;

  /// Prefix the body with a bullet (About pH and the filter-material modals).
  final bool bulleted;

  /// Semibold 15px body, used for limit values like "6.5 – 8.5" or "600 mg/L".
  final bool emphasizeBody;
}

/// Artwork shown at the top of the modals. Export these from Figma into assets/images/.
enum InfoIllustration {
  scientist('assets/images/scientist.png', Icons.science_rounded, 201, 149),
  question('assets/images/question.png', Icons.help_outline_rounded, 150, 149);

  const InfoIllustration(this.asset, this.fallback, this.width, this.height);

  final String asset;
  final IconData fallback;
  final double width;
  final double height;
}

/// Shows a multi-step info modal: all steps share the title and artwork; the green
/// button advances ("Next") and becomes "Close" on the last step.
///
/// Used for: About pH / TDS / Turbidity / Temperature (Figma 57:340..., 583:963...,
/// 587:1434...) and the filter material modals (134:202...).
Future<void> showInfoStepsModal(
  BuildContext context, {
  required String title,
  required List<InfoStep> steps,
  InfoIllustration illustration = InfoIllustration.scientist,
  String nextLabel = 'Next →',
}) =>
    showAppModal<void>(
      context,
      builder: (_) => InfoStepsModal(
        title: title,
        steps: steps,
        illustration: illustration,
        nextLabel: nextLabel,
      ),
    );

class InfoStepsModal extends StatefulWidget {
  const InfoStepsModal({
    super.key,
    required this.title,
    required this.steps,
    this.illustration = InfoIllustration.scientist,
    this.nextLabel = 'Next →',
  });

  final String title;
  final List<InfoStep> steps;
  final InfoIllustration illustration;
  final String nextLabel;

  @override
  State<InfoStepsModal> createState() => _InfoStepsModalState();
}

class _InfoStepsModalState extends State<InfoStepsModal> {
  int _step = 0;

  bool get _isLast => _step == widget.steps.length - 1;

  void _onPressed() {
    if (_isLast) {
      Navigator.of(context).pop();
    } else {
      setState(() => _step++);
    }
  }

  @override
  Widget build(BuildContext context) {
    final art = widget.illustration;
    return ModalShell(
      height: 440,
      child: Column(
        children: [
          const SizedBox(height: 29),
          AssetOrIcon(
            asset: art.asset,
            fallback: art.fallback,
            width: art.width,
            height: art.height,
          ),
          const SizedBox(height: 29),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              widget.title,
              textAlign: TextAlign.center,
              style: AppText.sf(22, weight: FontWeight.w600),
            ),
          ),
          const SizedBox(height: 18),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22),
              child: Align(
                alignment: Alignment.topCenter,
                // Slides/fades between steps in the direction of travel.
                child: TabContentSwitcher(
                  index: _step,
                  child: _StepView(step: widget.steps[_step]),
                ),
              ),
            ),
          ),
          ModalButton(
            label: _isLast ? 'Close' : widget.nextLabel,
            onPressed: _onPressed,
          ),
          const SizedBox(height: 46),
        ],
      ),
    );
  }
}

class _StepView extends StatelessWidget {
  const _StepView({required this.step});

  final InfoStep step;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(step.heading, textAlign: TextAlign.center, style: AppText.sf(14)),
        SizedBox(height: step.emphasizeBody ? 10 : 16),
        Text(
          step.bulleted ? '•  ${step.body}' : step.body,
          textAlign: TextAlign.center,
          style: step.emphasizeBody
              ? AppText.sf(15, weight: FontWeight.w600)
              : AppText.sf(14),
        ),
      ],
    );
  }
}
