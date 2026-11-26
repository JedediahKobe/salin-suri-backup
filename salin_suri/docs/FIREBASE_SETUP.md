# Connecting Salin-Suri to Firebase

The app ships with no data: every screen shows an empty state until a backend fills it. All data access goes through four repositories
(`lib/data/backend/repositories.dart`):

| Repository | Used by | Empty impl | Firestore impl |
|---|---|---|---|
| `FiltrationRepository` | Monitoring History, bins | `InMemoryFiltrationRepository` | `_FsFiltration` |
| `MaintenanceRepository` | Maintenance History / details, bins | `InMemoryMaintenanceRepository` | `_FsMaintenance` |
| `NotificationRepository` | Notifications, bins, red dots | `InMemoryNotificationRepository` | `_FsNotifications` |
| `SensorRepository` | Home live dashboard, connection status | `InMemorySensorRepository` | `_FsSensors` |

`flutter run` uses the empty in-memory repositories. `flutter run --dart-define=USE_FIREBASE=true` uses Firestore.

## One-time setup
1. Create a Firebase project; enable **Authentication → Anonymous** and **Cloud Firestore**.
2. `dart pub global activate flutterfire_cli && flutterfire configure` (adds
   `google-services.json` / `GoogleService-Info.plist`).
3. `flutter pub get`, then run with `--dart-define=USE_FIREBASE=true`.
4. Publish the rules in `firestore.rules`.

## Collections
```
users/{uid}                          { deviceId: "ESP-1234-6789" }
users/{uid}/filtrationRecords/{id}   { number, timestamp, isPre, ph, temperature, turbidity, tds,
                                       counterpart?{ph,temperature,turbidity,tds}, status }
users/{uid}/maintenanceRecords/{id}  { number, when, replaced?, recordedAt?, status }
users/{uid}/notifications/{id}       { title, body, createdAt, unread, opensPhDetails,
                                       ph?, turbidity?, filtrationNumber?, status }
devices/{deviceId}                   { connected, updatedAt, connectionType, flowRate, flowSeries[],
                                       parameters{ ph | temperature | turbidity | tds :
                                         { pre, post, preSeries[], postSeries[],
                                           historyPreSeries[], historyPostSeries[] } } }
```
* Date fields are Firestore `Timestamp`s; `status` is `active | archived | deleted`
  (archive / delete / restore only change this field).
* `counterpart` holds the other stage's readings of the same run (a pre record stores its
  post readings and vice versa); the filtration report shows "--" until it exists.
* The ESP-32 (or a Cloud Function) writes `devices/{deviceId}` and creates filtration
  records / notifications; the app writes `status`, `unread`, `replaced`, `recordedAt`.

## Still static (not database-backed)
Sensor names, reference ranges and chart axes (`lib/data/sensor_specs.dart`), the sensor
list on Device Information, filter media content, and settings (`shared_preferences`).
