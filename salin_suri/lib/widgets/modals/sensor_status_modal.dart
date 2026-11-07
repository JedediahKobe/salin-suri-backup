import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../common.dart';
import 'modal_shell.dart';

/// Values shown in the Sensor Status modal. Defaults match the Figma design (node 57:420).
class SensorStatusData {
  const SensorStatusData({
    this.status = 'Operational',
    this.statusColor = const Color(0xFFF2E64A),
    this.connection = 'Connected',
    this.dataStatus = 'Receiving',
    this.lastReading = '2 min ago',
  });

  final String status;
  final Color statusColor;
  final String connection;
  final String dataStatus;
  final String lastReading;
}

Future<void> showSensorStatusModal(
  BuildContext context, {
  SensorStatusData data = const SensorStatusData(),
}) =>
    showAppModal<void>(context, builder: (_) => SensorStatusModal(data: data));

class SensorStatusModal extends StatelessWidget {
  const SensorStatusModal({super.key, this.data = const SensorStatusData()});

  final SensorStatusData data;

  static const _labelColor = Color(0xFF959595);

  @override
  Widget build(BuildContext context) {
    return ModalShell(
      width: 362,
      height: 293,
      child: Column(
        children: [
          const SizedBox(height: 23),
          // Export the Figma "Concept of Unknown things" artwork to assets/images/sensor_unknown.png
          const AssetOrIcon(
            asset: 'assets/images/sensor_unknown.png',
            fallback: Icons.help_outline_rounded,
            height: 85,
          ),
          const SizedBox(height: 18),
          Text('Sensor Status', style: AppText.sf(22, weight: FontWeight.w600)),
          const SizedBox(height: 21),
          Padding(
            padding: const EdgeInsets.only(left: 64),
            child: Column(
              children: [
                _row(
                  'Sensor Status:',
                  Row(
                    children: [
                      Container(
                        width: 4,
                        height: 4,
                        decoration: BoxDecoration(
                            color: data.statusColor, shape: BoxShape.circle),
                      ),
                      const SizedBox(width: 5),
                      _value(data.status),
                    ],
                  ),
                ),
                _row('Connection:', _value(data.connection)),
                _row('Data Status:', _value(data.dataStatus)),
                _row('Last reading:', _value(data.lastReading)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _row(String label, Widget value) => SizedBox(
        height: 22,
        child: Row(
          children: [
            SizedBox(
              width: 141,
              child: Text(label,
                  style: AppText.sf(14, color: _labelColor)),
            ),
            value,
          ],
        ),
      );

  Widget _value(String text) =>
      Text(text, style: AppText.sf(14, weight: FontWeight.w500));
}
