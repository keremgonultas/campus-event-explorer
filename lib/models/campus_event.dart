/// Event categories used in the app. [label] is what the user sees.
enum EventCategory {
  technology('Technology'),
  arts('Arts'),
  sports('Sports'),
  career('Career');

  const EventCategory(this.label);
  final String label;
}

/// One campus event. All fields are fixed except [availablePlaces],
/// which changes when the student joins or cancels.
class CampusEvent {
  CampusEvent({
    required this.id,
    required this.title,
    required this.category,
    required this.dateTime,
    required this.venue,
    required this.description,
    required this.imagePath,
    required this.totalCapacity,
    required int initialAvailablePlaces,
  })  : assert(totalCapacity > 0),
        assert(initialAvailablePlaces >= 0 &&
            initialAvailablePlaces <= totalCapacity),
        availablePlaces = initialAvailablePlaces;

  final String id;
  final String title;
  final EventCategory category;
  final DateTime dateTime;
  final String venue;
  final String description;
  final String imagePath;
  final int totalCapacity;

  /// Always kept between 0 and [totalCapacity] by EventStore.
  int availablePlaces;

  bool get isFull => availablePlaces == 0;
}
