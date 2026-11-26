# Connecting Salin-Suri to Firebase

The app ships with sample data. All data access goes through four repositories
(`lib/data/backend/repositories.dart`):

| Repository | Used by | Sample impl | Firestore impl |
|---|---|---|---|
| `FiltrationRepository` | Monitoring History, bins | `InMemoryFiltrationRepository` | `_FsFiltration` |
| `MaintenanceRepository` | Maintenance History / details, bins | `InMemoryMaintenanceRepository` | `_FsMaintenance` |
| `NotificationRepository` | Notifications, bins, red dots | `InMemoryNotificationRepository` | `_FsNotifications` |
| `SensorRepository` | Home live dashboard, connection status | `InMemorySensorRepository` | `_FsSensors` |

`flutter run` uses the sample data. `flutter run --dart-define=USE_FIREBASE=true` uses Firestore.

## One-time setup
1. Create a Firebase project; enable **Authentication → Anonymous** and **Cloud Firestore**.
2. `dart pub global activate flutterfire_cli && flutterfire configure` (adds
   `google-services.json` / `GoogleService-Info.plist`).
3. `flutter pub get`, then run with `--dart-define=USE_FIREBASE=true`.
4. Publish the rules in `firestore.rules`.

## Collections
```
users/{uid}                          { deviceId: "ESP-1234-6789" }
users/{uid}/filtrationRecords/{id}   { number, timestamp, isPre, ph, temperature, turbidity, tds, status }
users/{uid}/maintenanceRecords/{id}  { number, when, replaced?, recordedAt?, status }
users/{uid}/notifications/{id}       { title, body, createdAt, unread, opensPhDetails, status }
devices/{deviceId}                   { connected, updatedAt, flowRate,
                                       pre:{temperature,ph,turbidity,tds}, post:{...} }
```
* Date fields are Firestore `Timestamp`s; `status` is `active | archived | deleted`
  (archive / delete / restore only change this field).
* The ESP-32 (or a Cloud Function) writes `devices/{deviceId}` and creates filtration
  records / notifications; the app writes `status`, `unread`, `replaced`, `recordedAt`.

## Not yet database-backed
* Sensor detail / insight charts, history stats and reference ranges (`lib/data/sensor_specs.dart`).
* Device Information screen text, notification pH-alert detail text, filter media content.
* Settings stay on-device (`shared_preferences`).
