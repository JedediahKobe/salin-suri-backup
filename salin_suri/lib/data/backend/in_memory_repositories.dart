import 'dart:async';

import '../filtration_records.dart';
import '../live_readings.dart';
import '../maintenance_records.dart';
import '../notification_store.dart';
import 'repositories.dart';

/// Used whenever `USE_FIREBASE` isn't set. It holds no data, so every screen shows its
/// empty state; writes are ignored because the stores already hold the new state.
class InMemoryFiltrationRepository implements FiltrationRepository {
  @override
  Future<RecordLists<FiltrationRecord>> load() async => const RecordLists();

  @override
  Future<void> setStatus(
      Iterable<FiltrationRecord> records, RecordStatus status) async {}
}

class InMemoryMaintenanceRepository implements MaintenanceRepository {
  @override
  Future<MaintenanceSnapshot> load() async =>
      const MaintenanceSnapshot(RecordLists());

  @override
  Future<void> setStatus(
      Iterable<MaintenanceRecord> records, RecordStatus status) async {}

  @override
  Future<void> saveDocumentation(MaintenanceRecord record) async {}
}

class InMemoryNotificationRepository implements NotificationRepository {
  @override
  Future<RecordLists<AlertItem>> load() async => const RecordLists();

  @override
  Future<void> setStatus(Iterable<AlertItem> items, RecordStatus status) async {}

  @override
  Future<void> setRead(Iterable<AlertItem> items, bool read) async {}
}

class InMemorySensorRepository implements SensorRepository {
  @override
  Stream<LiveSnapshot> watchLive() => Stream.value(LiveSnapshot.empty);
}
