import 'package:flutter/foundation.dart';

/// One notification in the list (Figma 117:1198).
class AlertItem {
  AlertItem({
    required this.title,
    required this.body,
    required this.time,
    this.unread = false,
    this.opensPhDetails = false,
  });

  final String title;
  final String body;
  final String time;

  /// Only the pH alert has a details screen so far (Figma 423:148).
  final bool opensPhDetails;
  bool unread;
}

/// Dummy in-memory notifications shared by the list screen, the nav bar and the bell chips,
/// so the red dot only shows while something is unread. Swap for a real source later.
class NotificationStore extends ChangeNotifier {
  NotificationStore._();

  static final instance = NotificationStore._();

  final alerts = <AlertItem>[
    AlertItem(
      title: 'pH Alert',
      body:
          'pH Level Outside Reference Range Pre-filtration pH reached 9.8, which is above the...',
      time: '27/10/26, 9:10 am',
      unread: true,
      opensPhDetails: true,
    ),
    AlertItem(
      title: 'Turbidity Alert',
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
  ];

  int get unreadCount => alerts.where((a) => a.unread).length;
  bool get hasUnread => unreadCount > 0;

  void markRead(AlertItem a) {
    if (!a.unread) return;
    a.unread = false;
    notifyListeners();
  }

  void markAllRead() {
    if (!hasUnread) return;
    for (final a in alerts) {
      a.unread = false;
    }
    notifyListeners();
  }
}
