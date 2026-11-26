import 'dart:async';

import 'package:flutter/foundation.dart';

import 'backend/repositories.dart';

/// Everything the device reports for one parameter (pH, temperature, turbidity, TDS).
/// Empty / null until the device has sent data.
class ParameterData {
  const ParameterData({
    this.pre,
    this.post,
    this.preSeries = const [],
    this.postSeries = const [],
    this.historyPreSeries = const [],
    this.historyPostSeries = const [],
  });

  /// Latest value before / after filtration.
  final double? pre;
  final double? post;

  /// Recent readings for the Sensor page chart (oldest first).
  final List<double> preSeries;
  final List<double> postSeries;

  /// Daily values for the Insights chart (oldest first).
  final List<double> historyPreSeries;
  final List<double> historyPostSeries;

  double? get historyPre =>
      historyPreSeries.isEmpty ? null : historyPreSeries.last;
  double? get historyPost =>
      historyPostSeries.isEmpty ? null : historyPostSeries.last;

  static const empty = ParameterData();

  static List<double> _list(Object? v) =>
      (v is List) ? [for (final e in v) if (e is num) e.toDouble()] : const [];

  factory ParameterData.fromMap(Map<String, dynamic>? m) => m == null
      ? empty
      : ParameterData(
          pre: (m['pre'] as num?)?.toDouble(),
          post: (m['post'] as num?)?.toDouble(),
          preSeries: _list(m['preSeries']),
          postSeries: _list(m['postSeries']),
          historyPreSeries: _list(m['historyPreSeries']),
          historyPostSeries: _list(m['historyPostSeries']),
        );
}

/// What the device last reported.
class LiveSnapshot {
  const LiveSnapshot({
    this.parameters = const {},
    this.connected = false,
    this.updatedAt,
    this.flowRate,
    this.flowSeries = const [],
    this.deviceId,
    this.connectionType,
  });

  /// Keyed by `SensorSpec.id`: 'ph', 'temperature', 'turbidity', 'tds'.
  final Map<String, ParameterData> parameters;
  final bool connected;
  final DateTime? updatedAt;

  /// L/min, null when the flow sensor hasn't reported.
  final double? flowRate;
  final List<double> flowSeries;

  final String? deviceId;

  /// e.g. "Wi-Fi".
  final String? connectionType;

  ParameterData parameter(String id) => parameters[id] ?? ParameterData.empty;

  /// Nothing received yet (no device paired, or the database is empty).
  static const empty = LiveSnapshot();

  factory LiveSnapshot.fromMap(Map<String, dynamic> m) {
    final params = m['parameters'];
    return LiveSnapshot(
      parameters: {
        if (params is Map)
          for (final e in params.entries)
            e.key as String:
                ParameterData.fromMap((e.value as Map).cast<String, dynamic>()),
      },
      connected: m['connected'] as bool? ?? false,
      updatedAt: m['updatedAt'] as DateTime?,
      flowRate: (m['flowRate'] as num?)?.toDouble(),
      flowSeries: ParameterData._list(m['flowSeries']),
      deviceId: m['deviceId'] as String?,
      connectionType: m['connectionType'] as String?,
    );
  }
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
