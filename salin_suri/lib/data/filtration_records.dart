import 'package:flutter/foundation.dart';

/// A past filtration run shown in Monitoring History (Figma 623:831) and its report
/// (623:954). Dummy data until real history is available.
class FiltrationRecord {
  const FiltrationRecord({
    required this.number,
    required this.time,
    required this.isPre,
    required this.ph,
    required this.temperature,
    required this.turbidity,
    required this.tds,
  });

  final int number;
  final String time;
  final bool isPre;
  final double ph;
  final double temperature;
  final double turbidity;
  final double tds;

  /// Age relative to [referenceDate], used by the "filter date" menu.
  int get daysAgo => referenceDate.difference(DateTime(2026, 10, 26)).inDays;

  /// Dummy "today" for the sample data (the records are all from 26/10/26).
  static final referenceDate = DateTime(2026, 10, 27);

  String get title => 'Filtration #$number';
  String get stage => isPre ? 'Pre-filtration' : 'Post-filtration';

  String get phText => ph.toStringAsFixed(1);
  String get temperatureText => '${temperature.toStringAsFixed(1)} °C';
  String get turbidityText => '${turbidity.toStringAsFixed(1)} NTU';
  String get tdsText => '${tds.round()} mg/L';

  /// pH 6.5-8.5, turbidity <= 5 NTU, TDS <= 600 mg/L (PNSDW 2017); no temperature limit.
  bool get withinThresholds =>
      ph >= 6.5 && ph <= 8.5 && turbidity <= 5 && tds <= 600;

  static const all = <FiltrationRecord>[
    FiltrationRecord(number: 123, time: '26/10/26, 3:45 pm', isPre: true, ph: 8.5, temperature: 26.2, turbidity: 1.4, tds: 600),
    FiltrationRecord(number: 124, time: '26/10/26, 4:00 pm', isPre: false, ph: 7.2, temperature: 26.0, turbidity: 0.6, tds: 160),
    FiltrationRecord(number: 125, time: '26/10/26, 4:15 pm', isPre: false, ph: 7.0, temperature: 26.1, turbidity: 0.5, tds: 155),
    FiltrationRecord(number: 126, time: '26/10/26, 4:30 pm', isPre: true, ph: 8.1, temperature: 27.4, turbidity: 2.2, tds: 320),
    FiltrationRecord(number: 127, time: '26/10/26, 4:45 pm', isPre: true, ph: 9.1, temperature: 27.6, turbidity: 1.8, tds: 280),
    FiltrationRecord(number: 128, time: '26/10/26, 5:00 pm', isPre: false, ph: 7.4, temperature: 26.8, turbidity: 0.7, tds: 180),
    FiltrationRecord(number: 129, time: '26/10/26, 5:15 pm', isPre: true, ph: 8.3, temperature: 28.1, turbidity: 2.0, tds: 310),
    FiltrationRecord(number: 130, time: '26/10/26, 5:15 pm', isPre: false, ph: 7.3, temperature: 27.0, turbidity: 0.6, tds: 170),
    FiltrationRecord(number: 131, time: '26/10/26, 6:00 pm', isPre: true, ph: 8.0, temperature: 27.9, turbidity: 2.4, tds: 330),
    FiltrationRecord(number: 132, time: '26/10/26, 6:30 pm', isPre: false, ph: 7.1, temperature: 26.7, turbidity: 0.5, tds: 150),
    FiltrationRecord(number: 133, time: '26/10/26, 7:00 pm', isPre: true, ph: 8.4, temperature: 27.5, turbidity: 1.9, tds: 290),
    FiltrationRecord(number: 134, time: '26/10/26, 7:45 pm', isPre: false, ph: 7.2, temperature: 26.5, turbidity: 0.7, tds: 165),
    FiltrationRecord(number: 135, time: '26/10/26, 8:30 pm', isPre: true, ph: 8.2, temperature: 27.8, turbidity: 2.1, tds: 300),
  ];
}

/// Filtration History lists: active runs, plus the archived and recently-deleted bins
/// (Figma 873:187 actions menu). In-memory dummy store; swap for real persistence later.
class FiltrationStore extends ChangeNotifier {
  FiltrationStore._();

  static final instance = FiltrationStore._();

  final active = <FiltrationRecord>[...FiltrationRecord.all];
  final archived = <FiltrationRecord>[];
  final deleted = <FiltrationRecord>[];

  void archive(Iterable<FiltrationRecord> records) =>
      _move(records, active, archived);

  void delete(Iterable<FiltrationRecord> records) =>
      _move(records, active, deleted);

  /// Puts a record from [from] (archived or deleted) back into the active list.
  void restore(FiltrationRecord record, List<FiltrationRecord> from) {
    if (!from.remove(record)) return;
    active
      ..add(record)
      ..sort((a, b) => a.number.compareTo(b.number));
    notifyListeners();
  }

  void _move(Iterable<FiltrationRecord> records, List<FiltrationRecord> from,
      List<FiltrationRecord> to) {
    final list = records.toList();
    for (final r in list) {
      if (from.remove(r)) to.insert(0, r);
    }
    notifyListeners();
  }
}
