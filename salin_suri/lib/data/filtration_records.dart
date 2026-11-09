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
  ];
}
