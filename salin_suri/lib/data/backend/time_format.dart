/// Display formats shared by the records. The database stores real timestamps; the UI
/// only ever sees these strings.
String two(int n) => n.toString().padLeft(2, '0');

String clock12(DateTime d, {bool spaced = true}) {
  final h = d.hour % 12 == 0 ? 12 : d.hour % 12;
  return '$h:${two(d.minute)}${spaced ? ' ' : ''}${d.hour < 12 ? 'am' : 'pm'}';
}

/// "26/10/26, 3:45 pm"
String listTime(DateTime d) =>
    '${two(d.day)}/${two(d.month)}/${two(d.year % 100)}, ${clock12(d)}';

/// "September 24 • 10:37 am"
String liveTime(DateTime d) {
  const m = ['January', 'February', 'March', 'April', 'May', 'June', 'July',
    'August', 'September', 'October', 'November', 'December'];
  return '${m[d.month - 1]} ${d.day} • ${clock12(d)}';
}
