import 'package:flutter/foundation.dart';

/// A maintenance entry (Figma Maintenance History 689:169 / details 689:298).
/// Dummy data until a real source exists; new entries come from the Add Maintenance sheet.
class MaintenanceRecord {
  const MaintenanceRecord({required this.number, required this.when});

  final int number;
  final DateTime when;

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

  /// Newest first. Mutable so the Add Maintenance sheet can prepend.
  static final ValueNotifier<List<MaintenanceRecord>> store =
      ValueNotifier(<MaintenanceRecord>[
    MaintenanceRecord(number: 136, when: DateTime(2026, 11, 2, 16, 55)),
    MaintenanceRecord(number: 135, when: DateTime(2026, 11, 1, 11, 10)),
    MaintenanceRecord(number: 134, when: DateTime(2026, 10, 31, 18, 20)),
    MaintenanceRecord(number: 133, when: DateTime(2026, 10, 30, 15, 0)),
    MaintenanceRecord(number: 132, when: DateTime(2026, 10, 29, 13, 45)),
    MaintenanceRecord(number: 131, when: DateTime(2026, 10, 28, 10, 30)),
    MaintenanceRecord(number: 130, when: DateTime(2026, 10, 27, 8, 0)),
    MaintenanceRecord(number: 129, when: DateTime(2026, 10, 26, 17, 15)),
  ]);

  static void add(DateTime when) {
    final list = store.value;
    final next = list.isEmpty ? 1 : list.first.number + 1;
    final updated = [MaintenanceRecord(number: next, when: when), ...list]
      ..sort((a, b) => b.when.compareTo(a.when));
    store.value = updated;
  }
}
