import 'package:flutter/material.dart';

import '../widgets/modals/info_steps_modal.dart';

/// Copy for the "About <parameter>" modals (Figma: pH 57:340-342, TDS 583:963-1117,
/// Turbidity 583:1197-1355, Temperature 587:1434-1592).
class ParameterInfo {
  const ParameterInfo({required this.title, required this.steps});

  final String title;
  final List<InfoStep> steps;

  static const ph = ParameterInfo(title: 'About pH', steps: [
    InfoStep(
      heading: 'What is pH?',
      body: 'pH measures how acidic or alkaline the water is.',
      bulleted: true,
    ),
    InfoStep(
      heading: 'Why does it matter?',
      body: 'pH can affect treatment processes, and other water-quality measurements.',
      bulleted: true,
    ),
    InfoStep(
      heading: 'Ideal level set by PNSDW',
      body: '6.5 – 8.5',
      emphasizeBody: true,
    ),
  ]);

  static const tds = ParameterInfo(title: 'About TDS', steps: [
    InfoStep(
      heading: 'What is TDS?',
      body: 'TDS is the amount of dissolved salts and minerals in water.',
    ),
    InfoStep(
      heading: 'Why does it matter?',
      body: 'High TDS can affect taste and cause mineral buildup.',
    ),
    InfoStep(
      heading: 'Maximum set by PNSDW 2017',
      body: '600 mg/L',
      emphasizeBody: true,
    ),
  ]);

  static const turbidity = ParameterInfo(title: 'About Turbidity', steps: [
    InfoStep(
      heading: 'What is turbidity?',
      body: 'Turbidity measures water cloudiness caused by suspended particles.',
    ),
    InfoStep(
      heading: 'Why does it matter?',
      body: 'Particles can shelter microbes and make disinfection less effective.',
    ),
    InfoStep(heading: 'Maximum set by PNSDW 2017', body: '5 NTU'),
  ]);

  static const temperature = ParameterInfo(title: 'About Temperature', steps: [
    InfoStep(
      heading: 'What is water temperature?',
      body: 'Temperature measures how warm or cool the water is, in °C.',
    ),
    InfoStep(
      heading: 'Why does it matter?',
      body: 'Warmer water can affect taste and encourage microbial growth.',
    ),
    InfoStep(
      heading: 'Temperature limit in PNSDW 2017',
      body: 'No limit specified.',
    ),
  ]);
}

Future<void> showParameterInfoModal(BuildContext context, ParameterInfo info) =>
    showInfoStepsModal(context, title: info.title, steps: info.steps);
