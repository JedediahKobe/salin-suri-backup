import 'package:flutter/foundation.dart';

import 'backend/repositories.dart';
import 'backend/time_format.dart';

/// The four readings of one stage of a run.
class RunReading {
  const RunReading(
      {required this.ph,
      required this.temperature,
      required this.turbidity,
      required this.tds});

  final double ph;
  final double temperature;
  final double turbidity;
  final double tds;

  Map<String, dynamic> toMap() => {
        'ph': ph,
        'temperature': temperature,
        'turbidity': turbidity,
        'tds': tds,
      };

  static RunReading? fromMap(Object? m) => m is Map
      ? RunReading(
          ph: (m['ph'] as num?)?.toDouble() ?? 0,
          temperature: (m['temperature'] as num?)?.toDouble() ?? 0,
          turbidity: (m['turbidity'] as num?)?.toDouble() ?? 0,
          tds: (m['tds'] as num?)?.toDouble() ?? 0,
        )
      : null;
}

/// A past filtration run shown in Monitoring History (Figma 623:831) and its report
/// (623:954). Dummy data until real history is available.
class FiltrationRecord {
  const FiltrationRecord({
    this.id = '',
    this.timestamp,
    this.counterpart,
    required this.number,
    required this.time,
    required this.isPre,
    required this.ph,
    required this.temperature,
    required this.turbidity,
    required this.tds,
  });

  /// Database document id ('' for the built-in sample data).
  final String id;

  /// When the run was recorded. [time] is its display string.
  final DateTime? timestamp;

  /// The other stage's readings for the same run (post for a pre record and vice versa),
  /// null until the device has reported it.
  final RunReading? counterpart;

  final int number;
  final String time;
  final bool isPre;
  final double ph;
  final double temperature;
  final double turbidity;
  final double tds;

  /// Age relative to [referenceDate], used by the "filter date" menu.
  int get daysAgo {
    final t = timestamp ?? DateTime(2026, 10, 26);
    final day = DateTime(t.year, t.month, t.day);
    final today = DateTime(referenceDate.year, referenceDate.month, referenceDate.day);
    return today.difference(day).inDays;
  }

  /// "Today" for the date filter. The sample data is all from 26/10/26, so it is pinned
  /// there; with a real database it becomes the current time (see [Repos.init]).
  static DateTime referenceDate = DateTime(2026, 10, 27);

  /// Firestore / JSON shape. `status` is added by the repository.
  Map<String, dynamic> toMap() => {
        'number': number,
        'timestamp': timestamp,
        'isPre': isPre,
        'ph': ph,
        'temperature': temperature,
        'turbidity': turbidity,
        'tds': tds,
        'counterpart': counterpart?.toMap(),
      };

  factory FiltrationRecord.fromMap(String id, Map<String, dynamic> m) {
    final t = m['timestamp'] as DateTime?;
    return FiltrationRecord(
      id: id,
      timestamp: t,
      counterpart: RunReading.fromMap(m['counterpart']),
      number: (m['number'] as num?)?.toInt() ?? 0,
      time: t == null ? '' : listTime(t),
      isPre: m['isPre'] as bool? ?? true,
      ph: (m['ph'] as num?)?.toDouble() ?? 0,
      temperature: (m['temperature'] as num?)?.toDouble() ?? 0,
      turbidity: (m['turbidity'] as num?)?.toDouble() ?? 0,
      tds: (m['tds'] as num?)?.toDouble() ?? 0,
    );
  }

  String get title => 'Filtration #$number';
  String get stage => isPre ? 'Pre-filtration' : 'Post-filtration';

  String get phText => ph.toStringAsFixed(1);
  String get temperatureText => '${temperature.toStringAsFixed(1)} °C';
  String get turbidityText => '${turbidity.toStringAsFixed(1)} NTU';
  String get tdsText => '${tds.round()} mg/L';

  /// pH 6.5-8.5, turbidity <= 5 NTU, TDS <= 600 mg/L (PNSDW 2017); no temperature limit.
  bool get withinThresholds =>
      ph >= 6.5 && ph <= 8.5 && turbidity <= 5 && tds <= 600;
}

/// Filtration History lists: active runs, plus the archived and recently-deleted bins
/// (Figma 873:187 actions menu). Loaded from [Repos.filtration].
class FiltrationStore extends ChangeNotifier {
  FiltrationStore._();

  static final instance = FiltrationStore._();

  final active = <FiltrationRecord>[];
  final archived = <FiltrationRecord>[];
  final deleted = <FiltrationRecord>[];

  /// Reads all three lists from the repository (called once from [Repos.init]).
  Future<void> load() async {
    final data = await Repos.filtration.load();
    active..clear()..addAll(data.active);
    archived..clear()..addAll(data.archived);
    deleted..clear()..addAll(data.deleted);
    notifyListeners();
  }

  void archive(Iterable<FiltrationRecord> records) =>
      _move(records, active, archived, RecordStatus.archived);

  void delete(Iterable<FiltrationRecord> records) =>
      _move(records, active, deleted, RecordStatus.deleted);

  /// Puts a record from [from] (archived or deleted) back into the active list.
  void restore(FiltrationRecord record, List<FiltrationRecord> from) {
    if (!from.remove(record)) return;
    active
      ..add(record)
      ..sort((a, b) => a.number.compareTo(b.number));
    notifyListeners();
    persist(Repos.filtration.setStatus([record], RecordStatus.active));
  }

  void _move(Iterable<FiltrationRecord> records, List<FiltrationRecord> from,
      List<FiltrationRecord> to, RecordStatus status) {
    final moved = <FiltrationRecord>[];
    for (final r in records.toList()) {
      if (from.remove(r)) {
        to.insert(0, r);
        moved.add(r);
      }
    }
    notifyListeners();
    if (moved.isNotEmpty) persist(Repos.filtration.setStatus(moved, status));
  }
}
