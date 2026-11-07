import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../common.dart';
import '../segmented_tabs.dart';
import 'modal_shell.dart';

/// "About pH" modal (Figma nodes 57:340, 57:341, 57:342).
/// Three steps behind the "Next →" button; the last step swaps the button to "Close".
Future<void> showPhInfoModal(BuildContext context) =>
    showAppModal<void>(context, builder: (_) => const PhInfoModal());

class PhInfoModal extends StatefulWidget {
  const PhInfoModal({super.key});

  @override
  State<PhInfoModal> createState() => _PhInfoModalState();
}

class _PhInfoModalState extends State<PhInfoModal> {
  int _step = 0;

  static const _steps = <Widget>[
    _BulletStep(
      question: 'What is pH?',
      bullet: 'pH measures how acidic or alkaline the water is.',
    ),
    _BulletStep(
      question: 'Why does it matter?',
      bullet:
          'pH can affect treatment processes, and other water-quality measurements.',
    ),
    _RangeStep(),
  ];

  bool get _isLast => _step == _steps.length - 1;

  void _onPressed() {
    if (_isLast) {
      Navigator.of(context).pop();
    } else {
      setState(() => _step++);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ModalShell(
      height: 440,
      child: Column(
        children: [
          const SizedBox(height: 29),
          // Illustration (export the Figma "Scientist" artwork to assets/images/scientist.png)
          const AssetOrIcon(
            asset: 'assets/images/scientist.png',
            fallback: Icons.science_rounded,
            width: 201,
            height: 149,
          ),
          const SizedBox(height: 29),
          Text('About pH', style: AppText.sf(22, weight: FontWeight.w600)),
          const SizedBox(height: 21),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 11),
              // Slides/fades between steps in the direction of travel.
              child: TabContentSwitcher(index: _step, child: _steps[_step]),
            ),
          ),
          ModalButton(label: _isLast ? 'Close' : 'Next →', onPressed: _onPressed),
          const SizedBox(height: 52),
        ],
      ),
    );
  }
}

class _BulletStep extends StatelessWidget {
  const _BulletStep({required this.question, required this.bullet});

  final String question;
  final String bullet;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(question, textAlign: TextAlign.center, style: AppText.sf(14)),
        const SizedBox(height: 16),
        Text('•  $bullet', textAlign: TextAlign.center, style: AppText.sf(14)),
      ],
    );
  }
}

class _RangeStep extends StatelessWidget {
  const _RangeStep();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('Ideal level set by PNSDW', style: AppText.sf(14)),
        const SizedBox(height: 10),
        Text('6.5 – 8.5', style: AppText.sf(15, weight: FontWeight.w600)),
      ],
    );
  }
}
