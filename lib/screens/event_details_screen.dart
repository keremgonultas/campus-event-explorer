import 'package:flutter/material.dart';

import '../data/event_store.dart';
import '../models/campus_event.dart';
import '../utils/formatters.dart';
import '../utils/participation_dialogs.dart';
import '../widgets/availability_chip.dart';
import '../widgets/event_card.dart';
import 'image_viewer_screen.dart';

/// Separate screen with all event information, a favorite control and a
/// participation button. It changes the shared EventStore, so the previous
/// screen shows the updated state after returning.
class EventDetailsScreen extends StatefulWidget {
  const EventDetailsScreen({
    super.key,
    required this.event,
    required this.store,
  });

  final CampusEvent event;
  final EventStore store;

  @override
  State<EventDetailsScreen> createState() => _EventDetailsScreenState();
}

class _EventDetailsScreenState extends State<EventDetailsScreen> {
  CampusEvent get _e => widget.event;
  EventStore get _store => widget.store;

  void _toggleFavorite() {
    setState(() => _store.toggleFavorite(_e));
    showFeedback(
      context,
      _store.isFavorite(_e) ? 'Added to favorites' : 'Removed from favorites',
    );
  }

  Future<void> _join() async {
    final ok = await confirmParticipationDialog(
      context,
      event: _e,
      isCancel: false,
    );
    if (!ok || !mounted) return; // "No" or dismissed: nothing changes
    final result = _store.join(_e); // Set prevents duplicate joins
    setState(() {});
    switch (result) {
      case ParticipationResult.success:
        showFeedback(context, 'You joined "${_e.title}"');
      case ParticipationResult.alreadyJoined:
        showFeedback(context, 'You have already joined this event');
      case ParticipationResult.full:
        showFeedback(context, 'Sorry, this event is full');
      case ParticipationResult.notJoined:
        break;
    }
  }

  Future<void> _cancel() async {
    final ok = await confirmParticipationDialog(
      context,
      event: _e,
      isCancel: true,
    );
    if (!ok || !mounted) return;
    final result = _store.cancel(_e);
    setState(() {});
    if (result == ParticipationResult.success) {
      showFeedback(context, 'Participation cancelled. One place was released.');
    }
  }

  void _openImage() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ImageViewerScreen(
          imagePath: _e.imagePath,
          title: _e.title,
          heroTag: 'event-image-${_e.id}',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isFav = _store.isFavorite(_e);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Event details'),
        actions: [
          IconButton(
            key: const Key('details-fav'),
            tooltip: isFav ? 'Remove from favorites' : 'Add to favorites',
            icon: Icon(
              isFav ? Icons.favorite : Icons.favorite_border,
              color: Colors.redAccent,
            ),
            onPressed: _toggleFavorite,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          GestureDetector(
            key: const Key('details-image'),
            onDoubleTap: _openImage,
            child: Hero(
              tag: 'event-image-${_e.id}',
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Image.asset(_e.imagePath, fit: BoxFit.cover),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              'Double-tap the image to enlarge',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall,
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CategoryBadge(category: _e.category),
                    const SizedBox(width: 8),
                    Flexible(
                      child: AvailabilityChip(event: _e, store: _store),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  _e.title,
                  style: theme.textTheme.headlineSmall
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 16),
                _DetailTile(
                  icon: Icons.schedule,
                  label: 'Date & time',
                  value: formatDateTime(_e.dateTime),
                ),
                _DetailTile(
                  icon: Icons.place_outlined,
                  label: 'Venue',
                  value: _e.venue,
                ),
                _DetailTile(
                  icon: Icons.category_outlined,
                  label: 'Category',
                  value: _e.category.label,
                ),
                _DetailTile(
                  icon: Icons.groups_outlined,
                  label: 'Capacity',
                  value: '${_e.availablePlaces} of ${_e.totalCapacity} '
                      'places available',
                ),
                _DetailTile(
                  icon: Icons.tag,
                  label: 'Event ID',
                  value: _e.id,
                ),
                const SizedBox(height: 8),
                Text('About this event', style: theme.textTheme.titleMedium),
                const SizedBox(height: 6),
                Text(_e.description, style: theme.textTheme.bodyLarge),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
          child: SizedBox(height: 52, child: _participationButton()),
        ),
      ),
    );
  }

  Widget _participationButton() {
    if (_store.isJoined(_e)) {
      // Works even if the student took the LAST place (availablePlaces == 0).
      return OutlinedButton.icon(
        key: const Key('cancel-button'),
        style: OutlinedButton.styleFrom(
          foregroundColor: Theme.of(context).colorScheme.error,
          side: BorderSide(color: Theme.of(context).colorScheme.error),
        ),
        onPressed: _cancel,
        icon: const Icon(Icons.event_busy),
        label: const Text('Cancel participation'),
      );
    }
    if (_e.isFull) {
      return const FilledButton(
        key: Key('full-button'),
        onPressed: null, // disabled
        child: Text('Full'),
      );
    }
    return FilledButton.icon(
      key: const Key('join-button'),
      onPressed: _join,
      icon: const Icon(Icons.how_to_reg),
      label: const Text('Join event'),
    );
  }
}

class _DetailTile extends StatelessWidget {
  const _DetailTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: theme.colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: theme.textTheme.labelMedium),
                Text(value, style: theme.textTheme.bodyLarge),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
