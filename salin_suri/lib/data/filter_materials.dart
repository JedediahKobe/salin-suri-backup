import 'package:flutter/material.dart';

import '../widgets/modals/info_steps_modal.dart';

/// One filtration medium: the card on the Filter screen (Figma "Filter Media Card",
/// node 112:1075) plus the two-step info modal (nodes 134:202 ... 134:859).
class FilterMaterial {
  const FilterMaterial({
    required this.name,
    required this.stageLabel,
    required this.purpose,
    required this.filtrationType,
    required this.whatIsIt,
    required this.whyUsed,
    required this.asset,
    required this.fallbackIcon,
  });

  final String name;

  /// Shown under "Filtration". Figma labels two cards "Stage 2 of 3" and two "Stage 3 of 3".
  final String stageLabel;

  final String purpose;
  final String filtrationType;
  final String whatIsIt;
  final String whyUsed;
  final String asset;
  final IconData fallbackIcon;

  /// Title used by the info modal (single line).
  String get title => name.replaceAll('\n', ' ');

  List<InfoStep> get steps => [
        InfoStep(heading: 'What is it?', body: whatIsIt, bulleted: true),
        InfoStep(heading: 'Why is it used?', body: whyUsed, bulleted: true),
      ];

  Future<void> showInfo(BuildContext context) => showInfoStepsModal(
        context,
        title: title,
        steps: steps,
        illustration: InfoIllustration.question,
        nextLabel: 'Next',
      );

  static const all = <FilterMaterial>[
    FilterMaterial(
      name: 'Coconut Husk Fiber',
      stageLabel: 'Stage 1 of 3',
      purpose: 'Traps larger particles, dirt, and suspended solids',
      filtrationType: 'Mechanical Filtration',
      whatIsIt: 'A natural fibrous material derived from coconut husks.',
      whyUsed:
          'It provides an initial filtration layer before water moves to the next stage.',
      asset: 'assets/images/coconut_husk.png',
      fallbackIcon: Icons.grass_rounded,
    ),
    FilterMaterial(
      name: 'Coconut Shell Granular\nActivated Carbon',
      stageLabel: 'Stage 2 of 3',
      purpose: 'Reduces odors, color, and certain dissolved organic contaminants',
      filtrationType: 'Adsorption',
      whatIsIt:
          'Activated carbon produced from coconut shells and processed to develop a porous structure.',
      whyUsed: 'It can help reduce odors, color, and certain organic compounds.',
      asset: 'assets/images/granular_carbon.png',
      fallbackIcon: Icons.blur_on_rounded,
    ),
    FilterMaterial(
      name: 'Rice Husk Biochar',
      stageLabel: 'Stage 2 of 3',
      purpose: 'Helps adsorb dissolved contaminants and organic matter',
      filtrationType: 'Adsorption',
      whatIsIt:
          'A carbon-rich material produced by heating rice husk under limited oxygen conditions.',
      whyUsed:
          'It can contribute to the removal of certain dissolved contaminants and organic matter',
      asset: 'assets/images/rice_husk_biochar.png',
      fallbackIcon: Icons.local_fire_department_outlined,
    ),
    FilterMaterial(
      name: 'Sand',
      stageLabel: 'Stage 3 of 3',
      purpose: 'Removes suspended particles and fine sediment',
      filtrationType: 'Mechanical Filtration',
      whatIsIt: 'A granular filtration medium used to physically filter water.',
      whyUsed: 'It helps reduce suspended particles and fine sediment.',
      asset: 'assets/images/sand.png',
      fallbackIcon: Icons.terrain_rounded,
    ),
    FilterMaterial(
      name: 'Gravel',
      stageLabel: 'Stage 3 of 3',
      purpose: 'Traps larger particles and supports the filtration layer',
      filtrationType: 'Coarse Filtration',
      whatIsIt: 'A coarse granular material used as part of the filtration bed.',
      whyUsed:
          'It provides coarse filtration and helps support the other filtration layers.',
      asset: 'assets/images/gravel.png',
      fallbackIcon: Icons.landscape_rounded,
    ),
  ];
}
