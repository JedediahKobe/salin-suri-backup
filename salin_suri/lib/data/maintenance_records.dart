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
    recordedAt = DateTime.now();
    store.value = [...store.value]; // notify listeners
  }

  String get recordedText => 'Recorded at ${_short(recordedAt!)}';

  static String _short(DateTime d) {
    final h = d.hour % 12 == 0 ? 12 : d.hour % 12;
    return '${d.day}/${d.month}/${_two(d.year % 100)}, $h:${_two(d.minute)}${d.hour < 12 ? 'am' : 'pm'}';
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

  /// Newest first.
  static final ValueNotifier<List<MaintenanceRecord>> store =
      ValueNotifier<List<MaintenanceRecord>>(<MaintenanceRecord>[
    MaintenanceRecord(number: 136, when: DateTime(2026, 11, 2, 16, 55)),
    MaintenanceRecord(
        number: 135,
        when: DateTime(2026, 11, 1, 11, 10),
        replaced: true,
        recordedAt: DateTime(2026, 11, 1, 11, 43)),
    MaintenanceRecord(number: 134, when: DateTime(2026, 10, 31, 18, 20)),
    MaintenanceRecord(number: 133, when: DateTime(2026, 10, 30, 15, 0)),
    MaintenanceRecord(number: 132, when: DateTime(2026, 10, 29, 13, 45)),
    MaintenanceRecord(number: 131, when: DateTime(2026, 10, 28, 10, 30)),
    MaintenanceRecord(number: 130, when: DateTime(2026, 10, 27, 8, 0)),
    MaintenanceRecord(number: 129, when: DateTime(2026, 10, 26, 17, 15)),
  ]);
}
