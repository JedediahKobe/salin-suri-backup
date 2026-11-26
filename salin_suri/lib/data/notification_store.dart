import 'package:flutter/foundation.dart';

import 'backend/repositories.dart';
import 'backend/time_format.dart';

/// One notification in the list (Figma 117:1198).
class AlertItem {
  AlertItem({
    this.id = '',
    this.createdAt,
    required this.title,
    required this.body,
    required this.time,
    this.unread = false,
    this.opensPhDetails = false,
    this.today = false,
    this.ph,
    this.turbidity,
    this.filtrationNumber,
  });

  /// Database document id ('' for the built-in sample data).
  final String id;
  final DateTime? createdAt;

  final String title;
  final String body;
  final String time;

  /// Only the pH alert has a details screen so far (Figma 423:148).
  final bool opensPhDetails;

  /// Shown under "Today" instead of "Earlier" (Figma 117:1198).
  final bool today;
  bool unread;

  /// Readings that triggered a pH / turbidity alert, and the filtration run it was raised
  /// for. Null when the alert doesn't carry them.
  final double? ph;
  final double? turbidity;
  final int? filtrationNumber;

  Map<String, dynamic> toMap() => {
        'title': title,
        'body': body,
        'createdAt': createdAt,
        'unread': unread,
        'opensPhDetails': opensPhDetails,
        'today': today,
        'ph': ph,
        'turbidity': turbidity,
        'filtrationNumber': filtrationNumber,
      };

  factory AlertItem.fromMap(String id, Map<String, dynamic> m) {
    final t = m['createdAt'] as DateTime?;
    final now = DateTime.now();
    return AlertItem(
      id: id,
      createdAt: t,
      title: m['title'] as String? ?? '',
      body: m['body'] as String? ?? '',
      time: t == null ? '' : listTime(t),
      unread: m['unread'] as bool? ?? false,
      opensPhDetails: m['opensPhDetails'] as bool? ?? false,
      ph: (m['ph'] as num?)?.toDouble(),
      turbidity: (m['turbidity'] as num?)?.toDouble(),
      filtrationNumber: (m['filtrationNumber'] as num?)?.toInt(),
      today: t != null &&
          t.year == now.year &&
          t.month == now.month &&
          t.day == now.day,
    );
  }
}

/// Notifications shared by the list screen, the nav bar and the bell chips, so the red
/// dot only shows while something is unread. Data comes from [Repos.notifications].
class NotificationStore extends ChangeNotifier {
  NotificationStore._();

  static final instance = NotificationStore._();

  final alerts = <AlertItem>[];
  final archived = <AlertItem>[];
  final deleted = <AlertItem>[];

  /// Reads all three lists from the repository (called once from [Repos.init]).
  Future<void> load() async {
    final data = await Repos.notifications.load();
    alerts..clear()..addAll(data.active);
    archived..clear()..addAll(data.archived);
    deleted..clear()..addAll(data.deleted);
    notifyListeners();
  }

  void archive(Iterable<AlertItem> items) =>
      _move(items, archived, RecordStatus.archived);
  void delete(Iterable<AlertItem> items) =>
      _move(items, deleted, RecordStatus.deleted);

  void _move(Iterable<AlertItem> items, List<AlertItem> to, RecordStatus status) {
    final moved = <AlertItem>[];
    for (final a in items.toList()) {
      if (alerts.remove(a)) {
        to.insert(0, a);
        moved.add(a);
      }
    }
    notifyListeners();
    if (moved.isNotEmpty) persist(Repos.notifications.setStatus(moved, status));
  }

  void restore(AlertItem a, List<AlertItem> from) {
    if (!from.remove(a)) return;
    alerts.add(a);
    notifyListeners();
    persist(Repos.notifications.setStatus([a], RecordStatus.active));
  }

  void markReadAll(Iterable<AlertItem> items) {
    final changed = items.where((a) => a.unread).toList();
    for (final a in changed) {
      a.unread = false;
    }
    notifyListeners();
    if (changed.isNotEmpty) persist(Repos.notifications.setRead(changed, true));
  }

  int get unreadCount => alerts.where((a) => a.unread).length;
  bool get hasUnread => unreadCount > 0;

  void markRead(AlertItem a) {
    if (!a.unread) return;
    a.unread = false;
    notifyListeners();
    persist(Repos.notifications.setRead([a], true));
  }

  void markAllRead() => markReadAll(List.of(alerts));
}
