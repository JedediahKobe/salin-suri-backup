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

  /// Pending selection before Submit (Yes / No); null until the user picks one.
  bool? _choice;

  void _submit() {
    final yes = _choice!;
    setState(() {
      if (yes) record.document(true);
      _choice = null;
    });
    if (!yes) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Maintenance status kept as pending.')));
    }
  }

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
                              Text(record.completed ? record.reportTime : 'Required',
                                  style: AppText.sf(13,
                                      color: record.completed
                                          ? AppColors.divider
                                          : AppColors.alert)),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Divider(
                              height: 1, thickness: 1, color: AppColors.divider),
                          const SizedBox(height: 20),
                          Text(
                            'This notification documents the need of replacement of filter materials. '
                            'Based on the post-filtration report it is recommended that the '
                            'filtration media needs to be replaced.',
                            style: AppText.sf(18, color: AppColors.muted),
                          ),
                          if (!record.completed) ...[
                            const SizedBox(height: 20),
                            Divider(
                                height: 1, thickness: 1, color: AppColors.divider),
                            const SizedBox(height: 20),
                            Text('Notified at ${record.reportTime}',
                                style: AppText.sf(13, color: AppColors.muted)),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    _DocumentationCard(
                      record: record,
                      choice: _choice,
                      onChanged: (v) => setState(() => _choice = v),
                      onSubmit: _submit,
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

/// "Maintenance Documentation" card (Figma 689:298 pending, 726:150 completed).
/// Pending: Yes / No radios and a Submit button once one is chosen. Completed: a locked
/// summary, since an answered report can't be edited.
class _DocumentationCard extends StatelessWidget {
  const _DocumentationCard({
    required this.record,
    required this.choice,
    required this.onChanged,
    required this.onSubmit,
  });

  final MaintenanceRecord record;
  final bool? choice;
  final ValueChanged<bool?> onChanged;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final divider = Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Divider(height: 1, thickness: 1, color: AppColors.divider),
    );
    return SurfaceCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Maintenance Documentation',
              style: AppText.sf(24, weight: FontWeight.w700)),
          divider,
          if (record.completed) ...[
            Text('The replacement of filtration has been already conducted',
                style: AppText.sf(18, color: AppColors.muted)),
            const SizedBox(height: 20),
            _Row('Status', 'Completed', AppColors.accent),
            const SizedBox(height: 12),
            _Row('Date', record.recordedDate, AppColors.text),
            const SizedBox(height: 12),
            _Row('Confirmation', 'Yes', AppColors.accent),
            divider,
            Text(record.recordedText,
                style: AppText.sf(13, color: AppColors.muted)),
          ] else ...[
            Text('Please confirm whether the filter replacement has been conducted.',
                style: AppText.sf(18, color: AppColors.muted)),
            const SizedBox(height: 20),
            _Option(
                label: 'Yes, replacement completed',
                sub: 'Proceed to record replacement details.',
                selected: choice == true,
                onTap: () => onChanged(choice == true ? null : true)),
            const SizedBox(height: 20),
            _Option(
                label: 'No, not yet recorded',
                sub: 'Keep the maintenance status pending.',
                selected: choice == false,
                onTap: () => onChanged(choice == false ? null : false)),
            const SizedBox(height: 20),
            Container(
              height: 80,
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
              decoration: BoxDecoration(
                color: AppColors.surfaceInner,
                borderRadius: BorderRadius.circular(15),
              ),
              child: TextField(
                maxLines: null,
                style: AppText.inter(15),
                cursorColor: AppColors.accent,
                decoration: InputDecoration(
                  isDense: true,
                  border: InputBorder.none,
                  hintText: 'Additional Notes (Optional)',
                  hintStyle: AppText.inter(15, color: AppColors.muted),
                ),
              ),
            ),
            if (choice != null) ...[
              divider,
              Center(
                child: SizedBox(
                  width: 340,
                  height: 40,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(40)),
                    ),
                    onPressed: onSubmit,
                    child: Text('Submit',
                        style: AppText.sf(18, weight: FontWeight.w600)),
                  ),
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row(this.label, this.value, this.valueColor);

  final String label;
  final String value;
  final Color valueColor;

  @override
  Widget build(BuildContext context) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppText.sf(18, color: AppColors.muted)),
          Text(value, style: AppText.sf(18, weight: FontWeight.w600, color: valueColor)),
        ],
      );
}

class _Option extends StatelessWidget {
  const _Option({
    required this.label,
    required this.sub,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final String sub;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(width: 10),
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: AppRadio(selected: selected, onTap: onTap),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: AppText.sf(18, weight: FontWeight.w600)),
                Text(sub, style: AppText.sf(14, color: AppColors.muted)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
