import 'package:flutter/material.dart';

import '../data/event_store.dart';
import '../data/events_data.dart';
import '../models/campus_event.dart';
import '../widgets/empty_state.dart';
import '../widgets/event_card.dart';
import '../widgets/search_filter_bar.dart';
import 'event_details_screen.dart';

enum HomeTab { explore, favorites, myEvents }

/// StatefulWidget that owns the session state: the EventStore, the selected
/// tab and the shared search/category filter.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, this.store});

  /// Optional, so tests can inject their own data.
  final EventStore? store;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final EventStore _store;
  final TextEditingController _searchController = TextEditingController();
  EventCategory? _category; // null = All
  HomeTab _tab = HomeTab.explore;

  @override
  void initState() {
    super.initState();
    _store = widget.store ?? EventStore(createSampleEvents());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ---------- actions ----------
  void _toggleFavorite(CampusEvent e) {
    setState(() => _store.toggleFavorite(e));
  }

  Future<void> _openDetails(CampusEvent e) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => EventDetailsScreen(event: e, store: _store),
      ),
    );
    // Coming back: rebuild so cards/badges show the updated state.
    if (mounted) setState(() {});
  }

  void _clearSearch() {
    setState(() => _searchController.clear());
  }

  void _clearAllFilters() {
    setState(() {
      _searchController.clear();
      _category = null;
    });
  }

  // ---------- helpers ----------
  List<CampusEvent> _sourceFor(HomeTab tab) {
    switch (tab) {
      case HomeTab.explore:
        return _store.events;
      case HomeTab.favorites:
        return _store.favoriteEvents;
      case HomeTab.myEvents:
        return _store.joinedEvents;
    }
  }

  String _noMatchMessage() {
    final q = _searchController.text.trim();
    final parts = <String>[];
    if (q.isNotEmpty) parts.add('titled "$q"');
    if (_category != null) parts.add('in ${_category!.label}');
    final where = switch (_tab) {
      HomeTab.explore => '',
      HomeTab.favorites => ' among your favorites',
      HomeTab.myEvents => ' among your joined events',
    };
    return 'There are no events ${parts.join(' ')}$where.\n'
        'Try another title or category.';
  }

  bool get _hasActiveFilter =>
      _searchController.text.trim().isNotEmpty || _category != null;

  @override
  Widget build(BuildContext context) {
    final source = _sourceFor(_tab);
    final visible = applyFilter(
      source,
      query: _searchController.text,
      category: _category,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Campus Event Explorer'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Chip(
              key: const Key('joined-total'),
              avatar: const Icon(Icons.how_to_reg, size: 18),
              label: Text('Joined: ${_store.joinedCount}'),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          SearchFilterBar(
            controller: _searchController,
            selectedCategory: _category,
            onQueryChanged: (_) => setState(() {}),
            onClearSearch: _clearSearch,
            onCategorySelected: (c) => setState(() => _category = c),
          ),
          _ResultHeader(
            tab: _tab,
            matchCount: visible.length,
            joinedCount: _store.joinedCount,
          ),
          Expanded(child: _buildList(source, visible)),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab.index,
        onDestinationSelected: (i) => setState(() => _tab = HomeTab.values[i]),
        destinations: [
          const NavigationDestination(
            icon: Icon(Icons.explore_outlined),
            selectedIcon: Icon(Icons.explore),
            label: 'Explore',
          ),
          NavigationDestination(
            icon: Badge(
              isLabelVisible: _store.favoriteEvents.isNotEmpty,
              label: Text('${_store.favoriteEvents.length}'),
              child: const Icon(Icons.favorite_border),
            ),
            selectedIcon: const Icon(Icons.favorite),
            label: 'Favorites',
          ),
          NavigationDestination(
            icon: Badge(
              isLabelVisible: _store.joinedCount > 0,
              label: Text('${_store.joinedCount}'),
              child: const Icon(Icons.event_available_outlined),
            ),
            selectedIcon: const Icon(Icons.event_available),
            label: 'My Events',
          ),
        ],
      ),
    );
  }

  Widget _buildList(List<CampusEvent> source, List<CampusEvent> visible) {
    // 1) The tab itself has nothing (no favorites / nothing joined yet).
    if (source.isEmpty && _tab == HomeTab.favorites) {
      return const EmptyState(
        icon: Icons.favorite_border,
        title: 'No favorites yet',
        message: 'Tap the heart on any event to save it here.',
      );
    }
    if (source.isEmpty && _tab == HomeTab.myEvents) {
      return const EmptyState(
        icon: Icons.event_busy,
        title: 'You have not joined any events',
        message: 'Open an event and tap "Join event" to see it here.',
      );
    }
    // 2) Items exist, but the search/category filter hides all of them.
    if (visible.isEmpty) {
      return EmptyState(
        icon: Icons.search_off,
        title: 'No matching events',
        message: _noMatchMessage(),
        actionLabel: _hasActiveFilter ? 'Clear search and filters' : null,
        onAction: _hasActiveFilter ? _clearAllFilters : null,
      );
    }
    return ListView.builder(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: const EdgeInsets.only(bottom: 16),
      itemCount: visible.length,
      itemBuilder: (context, i) {
        final e = visible[i];
        return EventCard(
          key: ValueKey(e.id),
          event: e,
          store: _store,
          onFavoriteTap: () => _toggleFavorite(e),
          onOpenDetails: () => _openDetails(e),
        );
      },
    );
  }
}

class _ResultHeader extends StatelessWidget {
  const _ResultHeader({
    required this.tab,
    required this.matchCount,
    required this.joinedCount,
  });

  final HomeTab tab;
  final int matchCount;
  final int joinedCount;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.bodySmall;
    final noun = matchCount == 1 ? 'event' : 'events';
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 2, 20, 2),
      child: Row(
        children: [
          Expanded(
            child: Text(
              '$matchCount matching $noun',
              key: const Key('match-count'),
              style: style,
            ),
          ),
          if (tab == HomeTab.myEvents)
            Text('Total joined: $joinedCount', style: style),
        ],
      ),
    );
  }
}
