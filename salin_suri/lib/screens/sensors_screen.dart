import 'package:flutter/material.dart';

import '../data/notification_store.dart';
import '../theme/app_theme.dart';
import '../widgets/app_icons.dart';
import '../widgets/common.dart';
import '../data/sensor_specs.dart';
import 'notification_screen.dart';
import 'sensor_page.dart';

class SensorInfo {
  const SensorInfo(this.name, this.icon, this.specId);

  final String name;
  final IconData icon;

  /// Matches a [SensorSpec.id]; null = no detail design yet (Water Flow).
  final String? specId;

  SensorSpec? get spec => specId == null ? null : SensorSpec.byId(specId!);

  static const all = <SensorInfo>[
    SensorInfo('Temperature', Icons.thermostat_rounded, 'temperature'),
    SensorInfo('pH Level', Icons.water_drop_outlined, 'ph'),
    SensorInfo('Turbidity', Icons.grain_rounded, 'turbidity'),
    SensorInfo('Total Dissolved\nSolids (TDS)', Icons.opacity_outlined, 'tds'),
    SensorInfo('Water Flow', Icons.waves_rounded, null),
  ];
}

/// Card used both in the horizontal Home list (143x133, r20) and the Sensors grid (r15).
class SensorCard extends StatelessWidget {
  const SensorCard({
    super.key,
    required this.info,
    this.width,
    this.radius = 15,
  });

  final SensorInfo info;
  final double? width;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: info.spec == null
          ? null
          : () => Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => SensorPage(spec: info.spec!))),
      child: Container(
        width: width,
        height: 133,
        padding: const EdgeInsets.fromLTRB(13, 26, 8, 12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(radius),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                      color: AppColors.iconChip, shape: BoxShape.circle),
                  child: Icon(info.icon, size: 20, color: AppColors.text),
                ),
                Icon(Icons.chevron_right_rounded,
                    color: AppColors.text, size: 24),
              ],
            ),
            const Spacer(),
            Text(info.name, style: AppText.inter(15, weight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}

class SensorsScreen extends StatelessWidget {
  const SensorsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppTopBar(
        title: 'Salin-Suri',
        showBack: true,
        trailing: ListenableBuilder(
          listenable: NotificationStore.instance,
          builder: (context, _) => CircleChip(
            appIcon: AppIconType.bell,
            dot: NotificationStore.instance.hasUnread,
          onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const NotificationScreen(standalone: true))),
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(11),
        children: [
          Text('Sensors', style: AppText.sf(22, weight: FontWeight.w700)),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 2,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 180 / 133,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 10),
            children: [for (final s in SensorInfo.all) SensorCard(info: s)],
          ),
        ],
      ),
    );
  }
}
