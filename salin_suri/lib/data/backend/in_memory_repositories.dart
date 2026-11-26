import 'dart:async';

import '../filtration_records.dart';
import '../live_readings.dart';
import '../maintenance_records.dart';
import '../notification_store.dart';
import 'repositories.dart';

/// Built-in sample data. Used whenever `USE_FIREBASE` isn't set, so the app runs
/// without any backend. Writes are ignored: the stores already hold the new state.
class InMemoryFiltrationRepository implements FiltrationRepository {
  @override
  Future<RecordLists<FiltrationRecord>> load() async =>
      RecordLists(active: [...FiltrationRecord.sample]);

  @override
  Future<void> setStatus(
      Iterable<FiltrationRecord> records, RecordStatus status) async {}
}

class InMemoryMaintenanceRepository implements MaintenanceRepository {
  @override
  Future<MaintenanceSnapshot> load() async => MaintenanceSnapshot(
        RecordLists(active: MaintenanceRecord.sample()),
        olderCompleted: 86,
        olderPending: 7,
      );

  @override
  Future<void> setStatus(
      Iterable<MaintenanceRecord> records, RecordStatus status) async {}

  @override
  Future<void> saveDocumentation(MaintenanceRecord record) async {}
}

class InMemoryNotificationRepository implements NotificationRepository {
  @override
  Future<RecordLists<AlertItem>> load() async =>
      RecordLists(active: AlertItem.sample());

  @override
  Future<void> setStatus(Iterable<AlertItem> items, RecordStatus status) async {}

  @override
  Future<void> setRead(Iterable<AlertItem> items, bool read) async {}
}

class InMemorySensorRepository implements SensorRepository {
  @override
  Stream<LiveSnapshot> watchLive() => Stream.value(LiveSnapshot(
        pre: const StageReading(temperature: 29.6, ph: 7.2, turbidity: 2.1, tds: 118),
        post: const StageReading(temperature: 28.9, ph: 7.2, turbidity: 2.1, tds: 118),
        connected: true,
        updatedAt: DateTime(2026, 9, 24, 10, 37),
        flowRate: 20,
      ));
}
