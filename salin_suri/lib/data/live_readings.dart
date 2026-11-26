import 'dart:async';

import 'package:flutter/foundation.dart';

import 'backend/repositories.dart';

/// One stage's (pre- or post-filtration) latest sensor values.
class StageReading {
  const StageReading({
    required this.temperature,
    required this.ph,
    required this.turbidity,
    required this.tds,
  });

  final double temperature; // °C
  final double ph;
  final double turbidity; // NTU
  final double tds; // ppm (mg/L)

  String get temperatureText => '${temperature.toStringAsFixed(1)} °C';
  String get phText => ph.toStringAsFixed(1);
  String get turbidityText => '${turbidity.toStringAsFixed(1)} NTU';
  String get tdsText => '${tds.round()} ppm';

  factory StageReading.fromMap(Map<String, dynamic>? m) => StageReading(
        temperature: (m?['temperature'] as num?)?.toDouble() ?? 0,
        ph: (m?['ph'] as num?)?.toDouble() ?? 0,
        turbidity: (m?['turbidity'] as num?)?.toDouble() ?? 0,
        tds: (m?['tds'] as num?)?.toDouble() ?? 0,
      );

  Map<String, dynamic> toMap() => {
        'temperature': temperature,
        'ph': ph,
        'turbidity': turbidity,
        'tds': tds,
      };
}

/// What the device last reported.
class LiveSnapshot {
  const LiveSnapshot({
    required this.pre,
    required this.post,
    required this.connected,
    this.updatedAt,
    this.flowRate,
  });

  final StageReading pre;
  final StageReading post;
  final bool connected;
  final DateTime? updatedAt;

  /// L/min, null when the flow sensor hasn't reported.
  final double? flowRate;

  static const empty = LiveSnapshot(
    pre: StageReading(temperature: 0, ph: 0, turbidity: 0, tds: 0),
    post: StageReading(temperature: 0, ph: 0, turbidity: 0, tds: 0),
    connected: false,
  );
}

/// The latest [LiveSnapshot], kept up to date from [SensorRepository.watchLive].
class LiveReadings extends ChangeNotifier {
  LiveReadings._();

  static final instance = LiveReadings._();

  LiveSnapshot snapshot = LiveSnapshot.empty;
  StreamSubscription<LiveSnapshot>? _sub;

  void start(SensorRepository repo) {
    _sub?.cancel();
    _sub = repo.watchLive().listen((s) {
      snapshot = s;
      notifyListeners();
    }, onError: (Object e) {
      debugPrint('Live readings error: $e');
      snapshot = LiveSnapshot.empty;
      notifyListeners();
    });
  }
}
