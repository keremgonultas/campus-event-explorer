import 'package:flutter/material.dart';

import '../models/campus_event.dart';

/// Search field + category chips. Stateless: the HomeScreen owns the values,
/// so the SAME search/filter applies to Explore, Favorites and My Events.
class SearchFilterBar extends StatelessWidget {
  const SearchFilterBar({
    super.key,
    required this.controller,
    required this.selectedCategory,
    required this.onQueryChanged,
    required this.onClearSearch,
    required this.onCategorySelected,
  });

  final TextEditingController controller;
  final EventCategory? selectedCategory; // null = All
  final ValueChanged<String> onQueryChanged;
  final VoidCallback onClearSearch;
  final ValueChanged<EventCategory?> onCategorySelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
          child: TextField(
            key: const Key('search-field'),
            controller: controller,
            onChanged: onQueryChanged,
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              hintText: 'Search events by title',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: controller.text.isEmpty
                  ? null
                  : IconButton(
                      key: const Key('clear-search'),
                      tooltip: 'Clear search',
                      icon: const Icon(Icons.clear),
                      onPressed: onClearSearch,
                    ),
              filled: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(28),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
            ),
          ),
        ),
        SizedBox(
          height: 48,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            children: [
              _chip(context, label: 'All', value: null),
              for (final c in EventCategory.values)
                _chip(context, label: c.label, value: c),
            ],
          ),
        ),
      ],
    );
  }

  Widget _chip(BuildContext context,
      {required String label, required EventCategory? value}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: ChoiceChip(
        key: Key('chip-$label'),
        label: Text(label),
        selected: selectedCategory == value,
        onSelected: (_) => onCategorySelected(value),
      ),
    );
  }
}
