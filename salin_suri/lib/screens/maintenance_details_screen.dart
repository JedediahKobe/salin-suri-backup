import 'package:flutter/material.dart';

import '../data/maintenance_records.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';

/// Report for one maintenance entry (Figma 689:298).
class MaintenanceDetailsScreen extends StatelessWidget {
  const MaintenanceDetailsScreen({super.key, required this.record});

  final MaintenanceRecord record;

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
                            'This notification documents the replacement of filter materials. '
                            'Based on the post-filtration report it is recommended that the '
                            'filtration media needs to be replaced. ',
                            style: AppText.sf(18, color: AppColors.muted),
                          ),
                        ],
                      ),
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
