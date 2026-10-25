import 'package:flutter/material.dart';

import 'data/event_store.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const CampusEventApp());
}

class CampusEventApp extends StatelessWidget {
  const CampusEventApp({super.key, this.store});

  /// Optional: tests pass their own store. The app creates one otherwise.
  final EventStore? store;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Campus Event Explorer',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        // Custom bundled font (assets/fonts, declared in pubspec.yaml).
        fontFamily: 'Poppins',
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF3F51B5)),
      ),
      home: HomeScreen(store: store),
    );
  }
}
