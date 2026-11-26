/// Switches the whole app between the built-in sample data and Firebase.
///
///   flutter run                              → in-memory sample data (no setup needed)
///   flutter run --dart-define=USE_FIREBASE=true → Cloud Firestore (see docs/FIREBASE_SETUP.md)
const bool kUseFirebase = bool.fromEnvironment('USE_FIREBASE');
