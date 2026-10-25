import 'package:flutter/material.dart';

import '../data/event_store.dart';
import '../models/campus_event.dart';
import '../utils/formatters.dart';

/// Small colored label: "Full", "Only 1 place left", "Joined", "12 / 30 ...".
class AvailabilityChip extends StatelessWidget {
  const AvailabilityChip({super.key, required this.event, required this.store});

  final CampusEvent event;
  final EventStore store;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    Color bg;
    Color fg;
    IconData icon;
    if (store.isJoined(event)) {
      bg = Colors.green.shade100;
      fg = Colors.green.shade900;
      icon = Icons.check_circle;
    } else if (event.isFull) {
      bg = scheme.errorContainer;
      fg = scheme.onErrorContainer;
      icon = Icons.block;
    } else if (event.availablePlaces == 1) {
      bg = Colors.orange.shade100;
      fg = Colors.orange.shade900;
      icon = Icons.local_fire_department;
    } else {
      bg = scheme.secondaryContainer;
      fg = scheme.onSecondaryContainer;
      icon = Icons.event_seat;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: fg),
          const SizedBox(width: 4),
          Text(
            availabilityLabel(event, store),
            style: TextStyle(
              color: fg,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
