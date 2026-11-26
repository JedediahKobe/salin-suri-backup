import 'package:flutter/foundation.dart';

import 'backend/repositories.dart';
import 'backend/time_format.dart';

/// A maintenance entry (Figma Maintenance History 689:169 / details 689:298).
/// Dummy data until a real source exists.
class MaintenanceRecord {
  MaintenanceRecord({
    this.id = '',
    required this.number,
    required this.when,
    this.replaced,
    this.recordedAt,
  });

  /// Database document id ('' for the built-in sample data).
  final String id;

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
    persist(Repos.maintenance.saveDocumentation(this));
  }

  Map<String, dynamic> toMap() => {
        'number': number,
        'when': when,
        'replaced': replaced,
        'recordedAt': recordedAt,
      };

  factory MaintenanceRecord.fromMap(String id, Map<String, dynamic> m) =>
      MaintenanceRecord(
        id: id,
        number: (m['number'] as num?)?.toInt() ?? 0,
        when: (m['when'] as DateTime?) ?? DateTime.now(),
        replaced: m['replaced'] as bool?,
        recordedAt: m['recordedAt'] as DateTime?,
      );

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

  /// "Today" for the date filter; pinned for the sample data, current time with a database.
  static DateTime referenceDate = DateTime(2026, 11, 3);

  static String _two(int n) => two(n);

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
  static int _baseCompleted = 86;
  static int _basePending = 7;

  static int get completedCount =>
      _baseCompleted + store.value.where((r) => r.completed).length;
  static int get pendingCount =>
      _basePending + store.value.where((r) => !r.completed).length;

  static final ValueNotifier<List<MaintenanceRecord>> archived =
      ValueNotifier<List<MaintenanceRecord>>(<MaintenanceRecord>[]);
  static final ValueNotifier<List<MaintenanceRecord>> deleted =
      ValueNotifier<List<MaintenanceRecord>>(<MaintenanceRecord>[]);

  static void _move(Iterable<MaintenanceRecord> records,
      ValueNotifier<List<MaintenanceRecord>> to, RecordStatus status) {
    final list = records.toSet();
    store.value = store.value.where((r) => !list.contains(r)).toList();
    to.value = [...list, ...to.value];
    persist(Repos.maintenance.setStatus(list, status));
  }

  static void archive(Iterable<MaintenanceRecord> r) =>
      _move(r, archived, RecordStatus.archived);
  static void delete(Iterable<MaintenanceRecord> r) =>
      _move(r, deleted, RecordStatus.deleted);

  static void restore(MaintenanceRecord r, ValueNotifier<List<MaintenanceRecord>> from) {
    from.value = from.value.where((x) => x != r).toList();
    store.value = [...store.value, r]..sort((a, b) => b.number.compareTo(a.number));
    persist(Repos.maintenance.setStatus([r], RecordStatus.active));
  }

  /// Newest first.
  static final ValueNotifier<List<MaintenanceRecord>> store =
      ValueNotifier<List<MaintenanceRecord>>(<MaintenanceRecord>[]);

  /// Reads all three lists from the repository (called once from [Repos.init]).
  static Future<void> loadAll() async {
    final snap = await Repos.maintenance.load();
    _baseCompleted = snap.olderCompleted;
    _basePending = snap.olderPending;
    store.value = snap.lists.active;
    archived.value = snap.lists.archived;
    deleted.value = snap.lists.deleted;
  }

  /// Built-in sample reports, used when no database is connected.
  static List<MaintenanceRecord> sample() => [
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
    ];
}
