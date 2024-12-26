import 'package:flutter/material.dart';
import 'pages/home_page.dart';
import 'pages/stats_page.dart';

void main() {
  runApp(const SocialMediaCarbonFootprintApp());
}

class SocialMediaCarbonFootprintApp extends StatelessWidget {
  const SocialMediaCarbonFootprintApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Social Media Carbon Footprint',
      theme: ThemeData(
        fontFamily: 'Titillium', // MUST match the "family" in pubspec.yaml
        scaffoldBackgroundColor: const Color(0xFFB3D48E),
        // Optionally tweak your TextTheme further:
        textTheme: const TextTheme(
          headlineMedium: TextStyle(
            fontWeight: FontWeight.bold,
          ),
          // etc.
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const HomePage(),
        '/stats': (context) => const StatsPage(),
      },
    );
  }
}
