import 'package:flutter/material.dart';

import '../../data/maintenance_records.dart';
import '../../theme/app_theme.dart';

/// Bottom sheet flow for adding a maintenance entry: form (Figma 689:361) →
/// date picker (689:776) / time picker (689:777), all inside one sheet.
Future<void> showAddMaintenanceSheet(BuildContext context) =>
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => const AddMaintenanceSheet(),
    );

enum _View { form, date, time }

class AddMaintenanceSheet extends StatefulWidget {
  const AddMaintenanceSheet({super.key});

  @override
  State<AddMaintenanceSheet> createState() => _AddMaintenanceSheetState();
}

class _AddMaintenanceSheetState extends State<AddMaintenanceSheet> {
  _View _view = _View.form;
  DateTime? _date; // null = "Current Date"
  TimeOfDay? _time; // null = "Current Time"

  static String _fmtTime(TimeOfDay t) {
    final h = t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod;
    return '${h.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')} '
        '${t.period == DayPeriod.am ? 'AM' : 'PM'}';
  }

  static String _fmtDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  void _submit() {
    final now = DateTime.now();
    final d = _date ?? now;
    final t = _time ?? TimeOfDay.fromDateTime(now);
    MaintenanceRecord.add(DateTime(d.year, d.month, d.day, t.hour, t.minute));
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final Widget content = switch (_view) {
      _View.form => _Form(
          key: const ValueKey('form'),
          timeText: _time == null ? 'Current Time' : _fmtTime(_time!),
          dateText: _date == null ? 'Current Date' : _fmtDate(_date!),
          timeSet: _time != null,
          dateSet: _date != null,
          onTime: () => setState(() => _view = _View.time),
          onDate: () => setState(() => _view = _View.date),
          onSubmit: _submit,
        ),
      _View.date => _DatePicker(
          key: const ValueKey('date'),
          initial: _date ?? DateTime.now(),
          onBack: () => setState(() => _view = _View.form),
          onSelect: (d) => setState(() {
            _date = d;
            _view = _View.form;
          }),
        ),
      _View.time => _TimePicker(
          key: const ValueKey('time'),
          initial: _time ?? TimeOfDay.now(),
          onBack: () => setState(() => _view = _View.form),
          onSelect: (t) => setState(() {
            _time = t;
            _view = _View.form;
          }),
        ),
    };

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
          border: Border.all(color: AppColors.barBorder),
        ),
        child: SafeArea(
          top: false,
          child: AnimatedSize(
            duration: const Duration(milliseconds: 200),
            alignment: Alignment.topCenter,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 180),
              child: content,
            ),
          ),
        ),
      ),
    );
  }
}

class _BackChip extends StatelessWidget {
  const _BackChip({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          width: 32,
          height: 32,
          decoration:
              BoxDecoration(color: AppColors.iconChip, shape: BoxShape.circle),
          child: Icon(Icons.chevron_left_rounded,
              color: AppColors.accent, size: 22),
        ),
      );
}

class _GreenButton extends StatelessWidget {
  const _GreenButton(
      {required this.label, required this.onTap, this.width = 275});

  final String label;
  final VoidCallback onTap;
  final double width;

  @override
  Widget build(BuildContext context) => SizedBox(
        width: width,
        height: 42,
        child: FilledButton(
          onPressed: onTap,
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.accent,
            padding: const EdgeInsets.all(10),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
          ),
          child: Text(label, style: AppText.sf(16, weight: FontWeight.w700)),
        ),
      );
}

// ── Form ──────────────────────────────────────────────────────────────
class _Form extends StatelessWidget {
  const _Form({
    super.key,
    required this.timeText,
    required this.dateText,
    required this.timeSet,
    required this.dateSet,
    required this.onTime,
    required this.onDate,
    required this.onSubmit,
  });

  final String timeText;
  final String dateText;
  final bool timeSet;
  final bool dateSet;
  final VoidCallback onTime;
  final VoidCallback onDate;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 16, 14, 26),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
              child: Text('Maintenance Details',
                  style: AppText.sf(24, weight: FontWeight.w700))),
          const SizedBox(height: 14),
          Padding(
            padding: const EdgeInsets.only(left: 24, bottom: 4),
            child: Text('Pick time of maintenance',
                style: AppText.sf(12, color: AppColors.muted)),
          ),
          _Field(
              icon: Icons.access_time_rounded,
              text: timeText,
              set: timeSet,
              onTap: onTime),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.only(left: 24, bottom: 4),
            child: Text('Pick date of maintenance',
                style: AppText.sf(12, color: AppColors.muted)),
          ),
          _Field(
              icon: Icons.calendar_today_outlined,
              text: dateText,
              set: dateSet,
              onTap: onDate),
          const SizedBox(height: 26),
          _GreenButton(
              label: 'Add Maintenance Details',
              onTap: onSubmit,
              width: double.infinity),
        ],
      ),
    );
  }
}

class _Field extends StatelessWidget {
  const _Field(
      {required this.icon,
      required this.text,
      required this.set,
      required this.onTap});

  final IconData icon;
  final String text;
  final bool set;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: AppColors.surfaceInner,
          borderRadius: BorderRadius.circular(40),
          border: Border.all(color: AppColors.barBorder, width: 0.5),
        ),
        child: Row(
          children: [
            Icon(icon, size: 24, color: AppColors.muted),
            const SizedBox(width: 10),
            Text(text,
                style: AppText.sf(16,
                    weight: FontWeight.w500,
                    color: set ? AppColors.text : AppColors.muted)),
          ],
        ),
      ),
    );
  }
}

// ── Date picker ───────────────────────────────────────────────────────
class _DatePicker extends StatefulWidget {
  const _DatePicker(
      {super.key,
      required this.initial,
      required this.onBack,
      required this.onSelect});

  final DateTime initial;
  final VoidCallback onBack;
  final ValueChanged<DateTime> onSelect;

  @override
  State<_DatePicker> createState() => _DatePickerState();
}

class _DatePickerState extends State<_DatePicker> {
  static const _months = [
    'January', 'February', 'March', 'April', 'May', 'June', 'July', 'August',
    'September', 'October', 'November', 'December',
  ];
  static const _days = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

  late DateTime _month = DateTime(widget.initial.year, widget.initial.month);
  late DateTime _selected = widget.initial;

  void _shift(int delta) =>
      setState(() => _month = DateTime(_month.year, _month.month + delta));

  @override
  Widget build(BuildContext context) {
    final daysInMonth = DateTime(_month.year, _month.month + 1, 0).day;
    final lead = DateTime(_month.year, _month.month).weekday % 7; // Sunday = 0
    final cells = <int?>[
      for (var i = 0; i < lead; i++) null,
      for (var d = 1; d <= daysInMonth; d++) d,
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              _BackChip(onTap: widget.onBack),
              const Spacer(),
              _Arrow(icon: Icons.chevron_left_rounded, onTap: () => _shift(-1)),
              const SizedBox(width: 6),
              Text('${_months[_month.month - 1]} ${_month.year}',
                  style: AppText.sf(24, weight: FontWeight.w700)),
              const SizedBox(width: 6),
              _Arrow(icon: Icons.chevron_right_rounded, onTap: () => _shift(1)),
              const Spacer(),
              const SizedBox(width: 32),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              for (final d in _days)
                Expanded(
                  child: Center(
                      child: Text(d,
                          style: AppText.sf(16, weight: FontWeight.w700))),
                ),
            ],
          ),
          const SizedBox(height: 6),
          for (var r = 0; r < (cells.length / 7).ceil(); r++)
            Row(
              children: [
                for (var c = 0; c < 7; c++)
                  Expanded(child: _cell(r * 7 + c < cells.length ? cells[r * 7 + c] : null)),
              ],
            ),
          const SizedBox(height: 14),
          _GreenButton(
              label: 'Select Date', onTap: () => widget.onSelect(_selected)),
        ],
      ),
    );
  }

  Widget _cell(int? day) {
    if (day == null) return const SizedBox(height: 36);
    final date = DateTime(_month.year, _month.month, day);
    final selected = date.year == _selected.year &&
        date.month == _selected.month &&
        date.day == _selected.day;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => setState(() => _selected = date),
      child: SizedBox(
        height: 36,
        child: Center(
          child: Container(
            width: 30,
            height: 30,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: selected ? AppColors.accent : Colors.transparent,
              shape: BoxShape.circle,
            ),
            child: Text('$day',
                style: AppText.sf(18,
                    weight: FontWeight.w600,
                    color: selected ? Colors.white : null)),
          ),
        ),
      ),
    );
  }
}

class _Arrow extends StatelessWidget {
  const _Arrow({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Icon(icon, size: 22, color: AppColors.text),
        ),
      );
}

// ── Time picker ───────────────────────────────────────────────────────
class _TimePicker extends StatefulWidget {
  const _TimePicker(
      {super.key,
      required this.initial,
      required this.onBack,
      required this.onSelect});

  final TimeOfDay initial;
  final VoidCallback onBack;
  final ValueChanged<TimeOfDay> onSelect;

  @override
  State<_TimePicker> createState() => _TimePickerState();
}

class _TimePickerState extends State<_TimePicker> {
  late int _hour = widget.initial.hourOfPeriod == 0 ? 12 : widget.initial.hourOfPeriod;
  late int _minute = widget.initial.minute;
  late int _period = widget.initial.period == DayPeriod.am ? 0 : 1;

  late final _hourCtl = FixedExtentScrollController(initialItem: _hour - 1);
  late final _minCtl = FixedExtentScrollController(initialItem: _minute);
  late final _perCtl = FixedExtentScrollController(initialItem: _period);

  @override
  void dispose() {
    _hourCtl.dispose();
    _minCtl.dispose();
    _perCtl.dispose();
    super.dispose();
  }

  Widget _wheel({
    required FixedExtentScrollController ctl,
    required int count,
    required String Function(int) label,
    required ValueChanged<int> onChanged,
  }) {
    return Expanded(
      child: ListWheelScrollView.useDelegate(
        controller: ctl,
        itemExtent: 54,
        diameterRatio: 3,
        perspective: 0.002,
        physics: const FixedExtentScrollPhysics(),
        onSelectedItemChanged: onChanged,
        childDelegate: ListWheelChildBuilderDelegate(
          childCount: count,
          builder: (context, i) => AnimatedBuilder(
            animation: ctl,
            builder: (context, _) {
              final selected = ctl.hasClients
                  ? ctl.selectedItem == i
                  : ctl.initialItem == i;
              return Center(
                child: Text(label(i),
                    style: AppText.sf(28,
                        weight: FontWeight.w700,
                        color: selected ? AppColors.text : AppColors.muted)),
              );
            },
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              _BackChip(onTap: widget.onBack),
              Expanded(
                  child: Center(
                      child: Text('Time Picker',
                          style: AppText.sf(24, weight: FontWeight.w700)))),
              const SizedBox(width: 32),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 162,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Selected-time outline.
                Container(
                  height: 58,
                  margin: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.barBorder, width: 3),
                  ),
                ),
                Row(
                  children: [
                    _wheel(
                      ctl: _hourCtl,
                      count: 12,
                      label: (i) => (i + 1).toString().padLeft(2, '0'),
                      onChanged: (i) => _hour = i + 1,
                    ),
                    Text(':', style: AppText.sf(28, weight: FontWeight.w700, color: AppColors.muted)),
                    _wheel(
                      ctl: _minCtl,
                      count: 60,
                      label: (i) => i.toString().padLeft(2, '0'),
                      onChanged: (i) => _minute = i,
                    ),
                    _wheel(
                      ctl: _perCtl,
                      count: 2,
                      label: (i) => i == 0 ? 'AM' : 'PM',
                      onChanged: (i) => _period = i,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          _GreenButton(
            label: 'Select Time',
            onTap: () => widget.onSelect(TimeOfDay(
                hour: (_hour % 12) + (_period == 1 ? 12 : 0), minute: _minute)),
          ),
        ],
      ),
    );
  }
}
