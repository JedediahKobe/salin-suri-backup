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

  /// Built-in sample notifications, used when no database is connected.
  static List<AlertItem> sample() => [
      AlertItem(
        title: 'Pre Filtration Alert',
        body:
            'Pre-filtration pH and turbidity exceeded the reference range.',
        time: '27/10/26, 9:10 am',
        unread: true,
        opensPhDetails: true,
        today: true,
      ),
      AlertItem(
        title: 'Post Filtration Alert',
        body:
            'High Turbidity Detected Post-filtration turbidity spiked to 4.2 NTU, exceeding the 1.0 NTU thr...',
        time: '26/10/26, 3:45 pm',
      ),
      AlertItem(
        title: 'Flow Rate Notice',
        body:
            'Low Flow Rate Warning Intake flow dropped to 12 L/min, below the expected 20 L/min minimu..',
        time: '24/10/26, 8:05 am',
      ),
      AlertItem(
        title: 'Maintenance Alert',
        body:
            'Routine maintenance is due. Check and clean the filters to maintain system performance.',
        time: '24/10/26, 8:05 am',
      ),
    ];

  Map<String, dynamic> toMap() => {
        'title': title,
        'body': body,
        'createdAt': createdAt,
        'unread': unread,
        'opensPhDetails': opensPhDetails,
        'today': today,
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
