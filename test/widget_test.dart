import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:campus_event_explorer/data/event_store.dart';
import 'package:campus_event_explorer/data/events_data.dart';
import 'package:campus_event_explorer/main.dart';
import 'package:campus_event_explorer/models/campus_event.dart';

void main() {
  group('Sample data', () {
    test('meets the assignment rules', () {
      final events = createSampleEvents();
      expect(events.length, greaterThanOrEqualTo(6));
      expect(events.map((e) => e.id).toSet().length, events.length);
      expect(events.map((e) => e.category).toSet().length,
          greaterThanOrEqualTo(3));
      expect(events.map((e) => e.imagePath).toSet().length,
          greaterThanOrEqualTo(3));
      expect(events.any((e) => e.availablePlaces == 0), isTrue);
      expect(events.any((e) => e.availablePlaces == 1), isTrue);
      final deadline = DateTime(2026, 10, 25, 23, 59);
      for (final e in events) {
        expect(e.dateTime.isAfter(deadline), isTrue, reason: e.id);
        expect(e.availablePlaces, inInclusiveRange(0, e.totalCapacity));
      }
    });
  });

  group('EventStore', () {
    late EventStore store;
    late CampusEvent lastPlace;
    late CampusEvent full;

    setUp(() {
      store = EventStore(createSampleEvents());
      lastPlace = store.events.firstWhere((e) => e.availablePlaces == 1);
      full = store.events.firstWhere((e) => e.availablePlaces == 0);
    });

    test('joining twice does not duplicate or reduce capacity twice', () {
      expect(store.join(lastPlace), ParticipationResult.success);
      expect(store.join(lastPlace), ParticipationResult.alreadyJoined);
      expect(lastPlace.availablePlaces, 0);
      expect(store.joinedCount, 1);
      expect(store.joinedEvents.length, 1);
    });

    test('student who took the last place can cancel', () {
      store.join(lastPlace);
      expect(lastPlace.isFull, isTrue);
      expect(store.cancel(lastPlace), ParticipationResult.success);
      expect(lastPlace.availablePlaces, 1);
      expect(store.joinedEvents, isEmpty);
    });

    test('a full event cannot be joined', () {
      expect(store.canJoin(full), isFalse);
      expect(store.join(full), ParticipationResult.full);
      expect(full.availablePlaces, 0);
      expect(store.joinedCount, 0);
    });

    test('favorites do not change participation or capacity', () {
      final before = lastPlace.availablePlaces;
      store.toggleFavorite(lastPlace);
      expect(store.isFavorite(lastPlace), isTrue);
      expect(store.isJoined(lastPlace), isFalse);
      expect(lastPlace.availablePlaces, before);
      store.toggleFavorite(lastPlace);
      expect(store.favoriteEvents, isEmpty);
    });

    test('search ignores case and spaces and combines with category', () {
      final all = store.events;
      expect(applyFilter(all, query: '  WATERCOLOR ', category: null).length,
          1);
      expect(
          applyFilter(all, query: 'watercolor', category: EventCategory.sports),
          isEmpty);
      expect(applyFilter(all, query: '', category: EventCategory.arts).length,
          2);
    });
  });

  group('UI', () {
    testWidgets('empty search shows message and can be cleared',
        (tester) async {
      await tester.pumpWidget(const CampusEventApp());
      await tester.enterText(find.byKey(const Key('search-field')), 'zzzz');
      await tester.pump();
      expect(find.text('No matching events'), findsOneWidget);
      expect(find.text('0 matching events'), findsOneWidget);

      await tester.tap(find.byKey(const Key('clear-search')));
      await tester.pump();
      expect(find.text('No matching events'), findsNothing);
      expect(find.text('8 matching events'), findsOneWidget);
    });

    testWidgets('No in the join dialog changes nothing; Yes joins once',
        (tester) async {
      await tester.pumpWidget(const CampusEventApp());
      await tester.enterText(
          find.byKey(const Key('search-field')), 'watercolor');
      await tester.pump();
      await tester.ensureVisible(find.text('Details')); // scroll into view
      await tester.pumpAndSettle();
      await tester.tap(find.text('Details'));
      await tester.pumpAndSettle();

      // Dialog -> No
      await tester.tap(find.byKey(const Key('join-button')));
      await tester.pumpAndSettle();
      expect(find.text('Join this event?'), findsOneWidget);
      await tester.tap(find.text('No'));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('join-button')), findsOneWidget);

      // Dialog -> Yes (takes the last place)
      await tester.tap(find.byKey(const Key('join-button')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Yes'));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('cancel-button')), findsOneWidget);

      // Back to the list: total joined is updated
      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(find.text('Joined: 1'), findsOneWidget);
      await tester.pump(const Duration(seconds: 5)); // let SnackBar expire
    });

    testWidgets('full event shows a disabled Full button', (tester) async {
      await tester.pumpWidget(const CampusEventApp());
      await tester.enterText(
          find.byKey(const Key('search-field')), 'hackathon');
      await tester.pump();
      await tester.ensureVisible(find.text('Details')); // scroll into view
      await tester.pumpAndSettle();
      await tester.tap(find.text('Details'));
      await tester.pumpAndSettle();
      final button = tester.widget<FilledButton>(
          find.byKey(const Key('full-button')));
      expect(button.onPressed, isNull);
    });
  });
}