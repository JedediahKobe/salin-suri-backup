import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

import '../filtration_records.dart';
import '../live_readings.dart';
import '../maintenance_records.dart';
import '../notification_store.dart';
import 'repositories.dart';

/// Cloud Firestore backend. Layout (full details in docs/FIREBASE_SETUP.md):
///
///   users/{uid}                          { deviceId }
///   users/{uid}/filtrationRecords/{id}   { number, timestamp, isPre, ph, temperature,
///                                          turbidity, tds, status }
///   users/{uid}/maintenanceRecords/{id}  { number, when, replaced, recordedAt, status }
///   users/{uid}/notifications/{id}       { title, body, createdAt, unread,
///                                          opensPhDetails, status }
///   devices/{deviceId}                   { connected, updatedAt, connectionType, flowRate,
///                                          flowSeries[],
///                                          parameters{ph|temperature|turbidity|tds:
///                                            {pre, post, preSeries[], postSeries[],
///                                             historyPreSeries[], historyPostSeries[]}} }
///                                        ← written by the ESP-32
class FirebaseBackend {
  FirebaseBackend._(this.filtration, this.maintenance, this.notifications, this.sensors);

  final FiltrationRepository filtration;
  final MaintenanceRepository maintenance;
  final NotificationRepository notifications;
  final SensorRepository sensors;

  /// Initialises Firebase (needs the platform config files, see the setup guide),
  /// signs in anonymously if nobody is signed in, and builds the repositories.
  static Future<FirebaseBackend> connect() async {
    await Firebase.initializeApp();
    final auth = FirebaseAuth.instance;
    final user = auth.currentUser ?? (await auth.signInAnonymously()).user!;
    final db = FirebaseFirestore.instance;
    final userDoc = db.collection('users').doc(user.uid);

    // "Today" for the date filters is now, not the pinned sample date.
    final now = DateTime.now();
    FiltrationRecord.referenceDate = now;
    MaintenanceRecord.referenceDate = now;

    return FirebaseBackend._(
      _FsFiltration(userDoc.collection('filtrationRecords')),
      _FsMaintenance(userDoc.collection('maintenanceRecords')),
      _FsNotifications(userDoc.collection('notifications')),
      _FsSensors(db, userDoc),
    );
  }
}

// ── helpers ─────────────────────────────────────────────────────────────

/// Firestore Timestamps → DateTime so the models never see Firebase types.
Map<String, dynamic> _plain(Map<String, dynamic> m) => {
      for (final e in m.entries)
        e.key: e.value is Timestamp ? (e.value as Timestamp).toDate() : e.value,
    };

/// DateTime → Timestamp for writing.
Map<String, dynamic> _wire(Map<String, dynamic> m) => {
      for (final e in m.entries)
        e.key: e.value is DateTime ? Timestamp.fromDate(e.value as DateTime) : e.value,
    };

RecordStatus _statusOf(Map<String, dynamic> m) => RecordStatus.values.firstWhere(
      (s) => s.name == m['status'],
      orElse: () => RecordStatus.active,
    );

Future<RecordLists<T>> _loadLists<T>(
  Query<Map<String, dynamic>> query,
  T Function(String id, Map<String, dynamic> data) build,
) async {
  final snap = await query.get();
  final active = <T>[], archived = <T>[], deleted = <T>[];
  for (final d in snap.docs) {
    final data = _plain(d.data());
    final item = build(d.id, data);
    switch (_statusOf(data)) {
      case RecordStatus.active:
        active.add(item);
      case RecordStatus.archived:
        archived.add(item);
      case RecordStatus.deleted:
        deleted.add(item);
    }
  }
  return RecordLists(active: active, archived: archived, deleted: deleted);
}

/// Applies the same field update to many documents in one batch.
Future<void> _updateMany(CollectionReference<Map<String, dynamic>> col,
    Iterable<String> ids, Map<String, dynamic> fields) {
  final batch = col.firestore.batch();
  for (final id in ids.where((i) => i.isNotEmpty)) {
    batch.update(col.doc(id), fields);
  }
  return batch.commit();
}

// ── repositories ────────────────────────────────────────────────────────

class _FsFiltration implements FiltrationRepository {
  _FsFiltration(this._col);
  final CollectionReference<Map<String, dynamic>> _col;

  @override
  Future<RecordLists<FiltrationRecord>> load() => _loadLists(
      _col.orderBy('number'), (id, m) => FiltrationRecord.fromMap(id, m));

  @override
  Future<void> setStatus(Iterable<FiltrationRecord> records, RecordStatus status) =>
      _updateMany(_col, records.map((r) => r.id), {'status': status.name});
}

class _FsMaintenance implements MaintenanceRepository {
  _FsMaintenance(this._col);
  final CollectionReference<Map<String, dynamic>> _col;

  @override
  Future<MaintenanceSnapshot> load() async {
    final lists = await _loadLists(_col.orderBy('number', descending: true),
        (id, m) => MaintenanceRecord.fromMap(id, m));
    return MaintenanceSnapshot(lists);
  }

  @override
  Future<void> setStatus(Iterable<MaintenanceRecord> records, RecordStatus status) =>
      _updateMany(_col, records.map((r) => r.id), {'status': status.name});

  @override
  Future<void> saveDocumentation(MaintenanceRecord r) {
    if (r.id.isEmpty) return Future.value();
    return _col.doc(r.id).update(_wire({
      'replaced': r.replaced,
      'recordedAt': r.recordedAt,
    }));
  }
}

class _FsNotifications implements NotificationRepository {
  _FsNotifications(this._col);
  final CollectionReference<Map<String, dynamic>> _col;

  @override
  Future<RecordLists<AlertItem>> load() => _loadLists(
      _col.orderBy('createdAt', descending: true), (id, m) => AlertItem.fromMap(id, m));

  @override
  Future<void> setStatus(Iterable<AlertItem> items, RecordStatus status) =>
      _updateMany(_col, items.map((a) => a.id), {'status': status.name});

  @override
  Future<void> setRead(Iterable<AlertItem> items, bool read) =>
      _updateMany(_col, items.map((a) => a.id), {'unread': !read});
}

class _FsSensors implements SensorRepository {
  _FsSensors(this._db, this._userDoc);
  final FirebaseFirestore _db;
  final DocumentReference<Map<String, dynamic>> _userDoc;

  /// The user's document names their device; that device document is then streamed.
  @override
  Stream<LiveSnapshot> watchLive() async* {
    final user = await _userDoc.get();
    final deviceId = user.data()?['deviceId'] as String?;
    if (deviceId == null || deviceId.isEmpty) {
      yield LiveSnapshot.empty; // no device paired yet → shows Offline
      return;
    }
    yield* _db.collection('devices').doc(deviceId).snapshots().map((doc) {
      final m = _plain(doc.data() ?? const {});
      return LiveSnapshot.fromMap({...m, 'deviceId': deviceId});
    });
  }
}
