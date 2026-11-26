import 'dart:async';

import 'package:flutter/foundation.dart';

import '../filtration_records.dart';
import '../live_readings.dart';
import '../maintenance_records.dart';
import '../notification_store.dart';
import 'backend_config.dart';
import 'firebase_repositories.dart';
import 'in_memory_repositories.dart';

/// Where a record lives. Archive / delete are soft: the document stays in the database
/// with a different status, so "Restore" is just another status change.
enum RecordStatus { active, archived, deleted }

class RecordLists<T> {
  const RecordLists({
    this.active = const [],
    this.archived = const [],
    this.deleted = const [],
  });

  final List<T> active;
  final List<T> archived;
  final List<T> deleted;
}

/// Filtration runs (Monitoring History).
abstract class FiltrationRepository {
  Future<RecordLists<FiltrationRecord>> load();
  Future<void> setStatus(Iterable<FiltrationRecord> records, RecordStatus status);
}

/// Maintenance reports.
abstract class MaintenanceRepository {
  Future<MaintenanceSnapshot> load();
  Future<void> setStatus(Iterable<MaintenanceRecord> records, RecordStatus status);

  /// Saves the Yes / No documentation answer of a report.
  Future<void> saveDocumentation(MaintenanceRecord record);
}

class MaintenanceSnapshot {
  const MaintenanceSnapshot(this.lists,
      {this.olderCompleted = 0, this.olderPending = 0});

  final RecordLists<MaintenanceRecord> lists;

  /// Totals for reports older than the loaded ones (Maintenance History summary card).
  final int olderCompleted;
  final int olderPending;
}

/// Notifications / alerts.
abstract class NotificationRepository {
  Future<RecordLists<AlertItem>> load();
  Future<void> setStatus(Iterable<AlertItem> items, RecordStatus status);
  Future<void> setRead(Iterable<AlertItem> items, bool read);
}

/// Live readings coming from the ESP-32 device (written by the device, read here).
abstract class SensorRepository {
  /// Emits whenever the device reports. Must emit at least once.
  Stream<LiveSnapshot> watchLive();
}

/// Single place that decides which backend the app talks to. Call [init] once in main()
/// before runApp.
class Repos {
  Repos._();

  static late FiltrationRepository filtration;
  static late MaintenanceRepository maintenance;
  static late NotificationRepository notifications;
  static late SensorRepository sensors;

  static Future<void> init() async {
    if (kUseFirebase) {
      final fb = await FirebaseBackend.connect();
      filtration = fb.filtration;
      maintenance = fb.maintenance;
      notifications = fb.notifications;
      sensors = fb.sensors;
    } else {
      filtration = InMemoryFiltrationRepository();
      maintenance = InMemoryMaintenanceRepository();
      notifications = InMemoryNotificationRepository();
      sensors = InMemorySensorRepository();
    }
    await Future.wait([
      FiltrationStore.instance.load(),
      MaintenanceRecord.loadAll(),
      NotificationStore.instance.load(),
    ]);
    LiveReadings.instance.start(sensors);
  }
}

/// Writes are fire-and-forget so the UI stays instant; a failure is logged and the
/// next [load] brings the screen back in line with the database.
void persist(Future<void> write) {
  unawaited(write.catchError((Object e) => debugPrint('Save failed: $e')));
}
