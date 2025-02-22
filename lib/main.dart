// lib/main.dart
import 'package:flutter/material.dart';
import 'pages/home_page.dart';
import 'pages/stats_page.dart';
import 'pages/total_impact_page.dart';
import 'pages/about_page.dart';
import 'pages/analysis_page.dart';
import 'screens/permission_check_screen.dart';

void main() {
  runApp(const SocialMediaCarbonFootprintApp());
}

class SocialMediaCarbonFootprintApp extends StatelessWidget {
  const SocialMediaCarbonFootprintApp({Key? key}) : super(key: key);

  // Define the custom green color.
  static const Color customGreen = Color(0xFF00AB66);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Social Media Carbon Footprint',
      theme: ThemeData(
        fontFamily: 'Titillium',
        scaffoldBackgroundColor: Colors.white,
        primaryColor: customGreen,
        appBarTheme: const AppBarTheme(
          backgroundColor: customGreen,
          titleTextStyle: TextStyle(
            color: Colors.white, // Ensures title bar text is white
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          iconTheme: IconThemeData(color: Colors.white), // Also make the icons white
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: customGreen,
        ),
        textTheme: const TextTheme(
          headlineMedium: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      // Start by checking usage permission.
      initialRoute: '/',
      routes: {
        '/': (context) => const PermissionCheckScreen(),
        '/home': (context) => const HomePage(),
        '/stats': (context) => const StatsPage(),
        '/totalImpact': (context) => const TotalImpactPage(),
        '/about': (context) => const AboutPage(),
        '/analysis': (context) => const AnalysisPage(),
      },
    );
  }
}
