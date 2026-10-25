import 'package:flutter/material.dart';

import '../models/campus_event.dart';
import 'formatters.dart';

/// Shows a Yes/No confirmation dialog with the event title, date/time and
/// venue. Returns true ONLY when the user taps "Yes".
/// Tapping "No", tapping outside or pressing Back returns false.
Future<bool> confirmParticipationDialog(
  BuildContext context, {
  required CampusEvent event,
  required bool isCancel,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(isCancel ? 'Cancel participation?' : 'Join this event?'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            event.title,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
          ),
          const SizedBox(height: 12),
          _DialogRow(icon: Icons.schedule, text: formatDateTime(event.dateTime)),
          const SizedBox(height: 6),
          _DialogRow(icon: Icons.place_outlined, text: event.venue),
          const SizedBox(height: 12),
          Text(
            isCancel
                ? 'Your place will be released for other students.'
                : 'One place will be reserved for you.',
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(false),
          child: const Text('No'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(dialogContext).pop(true),
          child: const Text('Yes'),
        ),
      ],
    ),
  );
  return result ?? false; // dismissed => no change
}

class _DialogRow extends StatelessWidget {
  const _DialogRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18),
        const SizedBox(width: 8),
        Expanded(child: Text(text)),
      ],
    );
  }
}

void showFeedback(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));
}
