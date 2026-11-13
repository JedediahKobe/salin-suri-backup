import 'package:flutter/material.dart';

import '../data/maintenance_records.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';

/// Report for one maintenance entry (Figma 689:298).
class MaintenanceDetailsScreen extends StatefulWidget {
  const MaintenanceDetailsScreen({super.key, required this.record});

  final MaintenanceRecord record;

  @override
  State<MaintenanceDetailsScreen> createState() =>
      _MaintenanceDetailsScreenState();
}

class _MaintenanceDetailsScreenState extends State<MaintenanceDetailsScreen> {
  MaintenanceRecord get record => widget.record;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppTopBar(title: record.title, showBack: true),
      body: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  children: [
                    SurfaceCard(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Maintenance Report',
                                  style: AppText.sf(24, weight: FontWeight.w700)),
                              Text(record.reportTime,
                                  style: AppText.sf(13, color: AppColors.divider)),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Divider(
                              height: 1, thickness: 1, color: AppColors.divider),
                          const SizedBox(height: 20),
                          Text(
                            'This notification documents the need of replacement of filter materials. '
                            'Based on the post-filtration report it is recommended that the '
                            'filtration media needs to be replaced. ',
                            style: AppText.sf(18, color: AppColors.muted),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    _DocumentationCard(
                      record: record,
                      onChanged: (v) => setState(() => record.document(v)),
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: 346,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(40)),
                  ),
                  // Back to the Filter page (the root of the Maintenance History flow).
                  onPressed: () =>
                      Navigator.of(context).popUntil((r) => r.isFirst),
                  child: Text('Go Back to Filter Page',
                      style: AppText.sf(15, weight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// "Maintenance Documentation" card (Figma 726:157): Yes / No radios and the time the
/// answer was recorded.
class _DocumentationCard extends StatelessWidget {
  const _DocumentationCard({required this.record, required this.onChanged});

  final MaintenanceRecord record;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Maintenance Documentation',
              style: AppText.sf(24, weight: FontWeight.w700)),
          const SizedBox(height: 20),
          Divider(height: 1, thickness: 1, color: AppColors.divider),
          const SizedBox(height: 20),
          Text('The replacement of filtration has been already conducted',
              style: AppText.sf(18, color: AppColors.muted)),
          const SizedBox(height: 20),
          _Option(
              label: 'Yes',
              selected: record.replaced == true,
              onTap: () => onChanged(true)),
          const SizedBox(height: 20),
          _Option(
              label: 'No',
              selected: record.replaced == false,
              onTap: () => onChanged(false)),
          if (record.recordedAt != null) ...[
            const SizedBox(height: 20),
            Divider(height: 1, thickness: 1, color: AppColors.divider),
            const SizedBox(height: 20),
            Text(record.recordedText,
                style: AppText.sf(13, color: AppColors.divider)),
          ],
        ],
      ),
    );
  }
}

class _Option extends StatelessWidget {
  const _Option(
      {required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Row(
        children: [
          const SizedBox(width: 10),
          AppRadio(selected: selected, onTap: onTap),
          const SizedBox(width: 10),
          Text(label, style: AppText.sf(18, weight: FontWeight.w600)),
        ],
      ),
    );
  }
}
