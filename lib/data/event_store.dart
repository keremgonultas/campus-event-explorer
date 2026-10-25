import '../models/campus_event.dart';

/// Result of a join/cancel attempt, used to choose the feedback message.
enum ParticipationResult { success, alreadyJoined, full, notJoined }

/// In-memory app data for one session (no database, no network).
///
/// This is a plain Dart class. Widgets call its methods inside setState(),
/// so the UI rebuilds with the new values. Because every screen receives the
/// SAME EventStore object, all views show consistent data.
class EventStore {
  EventStore(this.events);

  final List<CampusEvent> events;
  final Set<String> _favoriteIds = {};
  final Set<String> _joinedIds = {}; // a Set cannot contain duplicates

  // ---------- Favorites (never touch participation or capacity) ----------
  bool isFavorite(CampusEvent e) => _favoriteIds.contains(e.id);

  void toggleFavorite(CampusEvent e) {
    if (!_favoriteIds.remove(e.id)) {
      _favoriteIds.add(e.id);
    }
  }

  // ---------- Participation ----------
  bool isJoined(CampusEvent e) => _joinedIds.contains(e.id);

  int get joinedCount => _joinedIds.length;

  /// Full = not joined by this student AND no places left.
  bool canJoin(CampusEvent e) => !isJoined(e) && e.availablePlaces > 0;

  ParticipationResult join(CampusEvent e) {
    if (isJoined(e)) return ParticipationResult.alreadyJoined;
    if (e.availablePlaces <= 0) return ParticipationResult.full;
    _joinedIds.add(e.id);
    e.availablePlaces -= 1;
    return ParticipationResult.success;
  }

  ParticipationResult cancel(CampusEvent e) {
    if (!_joinedIds.remove(e.id)) return ParticipationResult.notJoined;
    if (e.availablePlaces < e.totalCapacity) {
      e.availablePlaces += 1;
    }
    return ParticipationResult.success;
  }

  // ---------- Lists for the three views ----------
  List<CampusEvent> get favoriteEvents =>
      events.where(isFavorite).toList(growable: false);

  List<CampusEvent> get joinedEvents =>
      events.where(isJoined).toList(growable: false);
}

/// Shared search + category filter. `null` category means "All".
/// Search ignores letter case and leading/trailing spaces.
List<CampusEvent> applyFilter(
  List<CampusEvent> source, {
  required String query,
  required EventCategory? category,
}) {
  final q = query.trim().toLowerCase();
  return source.where((e) {
    final matchesCategory = category == null || e.category == category;
    final matchesTitle = q.isEmpty || e.title.toLowerCase().contains(q);
    return matchesCategory && matchesTitle;
  }).toList(growable: false);
}
