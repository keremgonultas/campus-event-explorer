import '../data/event_store.dart';
import '../models/campus_event.dart';

const _weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
const _months = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
];

String _two(int n) => n.toString().padLeft(2, '0');

/// Example: "Wed, 4 Nov 2026 · 10:00" (no intl package needed).
String formatDateTime(DateTime d) =>
    '${_weekdays[d.weekday - 1]}, ${d.day} ${_months[d.month - 1]} '
    '${d.year} · ${_two(d.hour)}:${_two(d.minute)}';

/// Availability text shown on cards and the details screen.
String availabilityLabel(CampusEvent e, EventStore store) {
  if (store.isJoined(e)) return 'Joined · ${e.availablePlaces} left';
  if (e.isFull) return 'Full';
  if (e.availablePlaces == 1) return 'Only 1 place left';
  return '${e.availablePlaces} / ${e.totalCapacity} places left';
}
