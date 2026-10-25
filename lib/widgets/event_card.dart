import 'package:flutter/material.dart';

import '../data/event_store.dart';
import '../models/campus_event.dart';
import '../utils/formatters.dart';
import 'availability_chip.dart';

/// Reusable StatelessWidget: one event in a scrollable list.
/// It does not hold state itself; the parent passes callbacks.
class EventCard extends StatelessWidget {
  const EventCard({
    super.key,
    required this.event,
    required this.store,
    required this.onFavoriteTap,
    required this.onOpenDetails,
  });

  final CampusEvent event;
  final EventStore store;
  final VoidCallback onFavoriteTap;
  final VoidCallback onOpenDetails;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isFav = store.isFavorite(event);

    return Card(
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: onOpenDetails,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Stack(
              children: [
                AspectRatio(
                  aspectRatio: 16 / 7,
                  child: Image.asset(event.imagePath, fit: BoxFit.cover),
                ),
                Positioned(
                  left: 12,
                  top: 12,
                  child: CategoryBadge(category: event.category),
                ),
                Positioned(
                  right: 6,
                  top: 6,
                  child: Material(
                    color: Colors.white.withValues(alpha: 0.9),
                    shape: const CircleBorder(),
                    child: IconButton(
                      key: Key('fav-${event.id}'),
                      tooltip: isFav ? 'Remove from favorites' : 'Add to favorites',
                      icon: Icon(
                        isFav ? Icons.favorite : Icons.favorite_border,
                        color: Colors.redAccent,
                      ),
                      onPressed: onFavoriteTap,
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.title,
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 6),
                  InfoRow(
                    icon: Icons.schedule,
                    text: formatDateTime(event.dateTime),
                  ),
                  const SizedBox(height: 4),
                  InfoRow(icon: Icons.place_outlined, text: event.venue),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 8, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: AvailabilityChip(event: event, store: store),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: onOpenDetails,
                    icon: const Icon(Icons.arrow_forward),
                    label: const Text('Details'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Reusable icon + text row.
class InfoRow extends StatelessWidget {
  const InfoRow({super.key, required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.onSurfaceVariant;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 6),
        Expanded(child: Text(text, style: TextStyle(color: color))),
      ],
    );
  }
}

/// Reusable category label.
class CategoryBadge extends StatelessWidget {
  const CategoryBadge({super.key, required this.category});

  final EventCategory category;

  static IconData iconFor(EventCategory c) {
    switch (c) {
      case EventCategory.technology:
        return Icons.memory;
      case EventCategory.arts:
        return Icons.palette;
      case EventCategory.sports:
        return Icons.sports_basketball;
      case EventCategory.career:
        return Icons.work_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(iconFor(category), size: 14, color: Colors.white),
          const SizedBox(width: 4),
          Text(
            category.label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
