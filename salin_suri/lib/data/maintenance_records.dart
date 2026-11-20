import 'package:flutter/foundation.dart';

/// A maintenance entry (Figma Maintenance History 689:169 / details 689:298).
/// Dummy data until a real source exists.
class MaintenanceRecord {
  MaintenanceRecord({
    required this.number,
    required this.when,
    this.replaced,
    this.recordedAt,
  });

  final int number;
  final DateTime when;

  /// "Maintenance Documentation" answer (Figma 726:157): has the filter media been
  /// replaced? null = not answered yet.
  bool? replaced;
  DateTime? recordedAt;

  /// Saves the Yes/No answer and stamps "Recorded at ...".
  void document(bool value) {
    replaced = value;
    recordedAt = value ? DateTime.now() : null;
    store.value = [...store.value]; // notify listeners
  }

  /// "Recorded at 1/11/26 at 11:43am".
  String get recordedText {
    final d = recordedAt!;
    final h = d.hour % 12 == 0 ? 12 : d.hour % 12;
    return 'Recorded at ${d.day}/${d.month}/${_two(d.year % 100)} at $h:${_two(d.minute)}${d.hour < 12 ? 'am' : 'pm'}';
  }

  String get title => 'Maintenance #$number';

  /// "02/11/26, 4:55 pm" (list card).
  String get time => '${_two(when.day)}/${_two(when.month)}/${_two(when.year % 100)}, $_clock';

  /// "2/11/26, 4:55pm" (report header).
  String get reportTime =>
      '${when.day}/${when.month}/${_two(when.year % 100)}, ${_clock.replaceAll(' ', '')}';

  String get _clock {
    final h = when.hour % 12 == 0 ? 12 : when.hour % 12;
    return '$h:${_two(when.minute)} ${when.hour < 12 ? 'am' : 'pm'}';
  }

  /// Age relative to [referenceDate], used by the date-filter menu.
  int get daysAgo => referenceDate.difference(when).inDays;

  static final referenceDate = DateTime(2026, 11, 3);

  static String _two(int n) => n.toString().padLeft(2, '0');

  bool get completed => replaced == true;

  /// "November 1, 2026" (completed documentation card).
  String get recordedDate {
    const m = ['January', 'February', 'March', 'April', 'May', 'June', 'July',
      'August', 'September', 'October', 'November', 'December'];
    final d = recordedAt!;
    return '${m[d.month - 1]} ${d.day}, ${d.year}';
  }

  /// Totals shown on the Maintenance History summary card (Figma 689:169). The base
  /// counts stand in for older reports that aren't listed.
  static const _baseCompleted = 86;
  static const _basePending = 7;

  static int get completedCount =>
      _baseCompleted + store.value.where((r) => r.completed).length;
  static int get pendingCount =>
      _basePending + store.value.where((r) => !r.completed).length;

  /// Newest first.
  static final ValueNotifier<List<MaintenanceRecord>> store =
      ValueNotifier<List<MaintenanceRecord>>(<MaintenanceRecord>[
    MaintenanceRecord(
        number: 135,
        when: DateTime(2026, 11, 1, 16, 30),
        replaced: true,
        recordedAt: DateTime(2026, 11, 1, 11, 43)),
    MaintenanceRecord(number: 134, when: DateTime(2026, 10, 31, 14, 0)),
    MaintenanceRecord(
        number: 133,
        when: DateTime(2026, 10, 30, 10, 0),
        replaced: true,
        recordedAt: DateTime(2026, 10, 30, 12, 10)),
    MaintenanceRecord(number: 132, when: DateTime(2026, 10, 29, 11, 45)),
    MaintenanceRecord(number: 131, when: DateTime(2026, 10, 28, 15, 0)),
    MaintenanceRecord(
        number: 130,
        when: DateTime(2026, 10, 27, 13, 30),
        replaced: true,
        recordedAt: DateTime(2026, 10, 27, 15, 5)),
    MaintenanceRecord(
        number: 129,
        when: DateTime(2026, 10, 26, 17, 15),
        replaced: true,
        recordedAt: DateTime(2026, 10, 26, 18, 0)),
  ]);
}
