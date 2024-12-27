import 'package:flutter/material.dart';
import '../widgets/app_drawer.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About'),
      ),
      drawer: const AppDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'About This App',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'The Digital Carbon Footprint Tracker is an educational and research-focused '
              'mobile app designed to help users understand the environmental impact of their '
              'social media usage. By monitoring app usage, this app calculates carbon emissions '
              'based on real-time data and promotes awareness about digital sustainability.',
              style: TextStyle(fontSize: 16),
            ),

            const SizedBox(height: 16),
            const Text(
              'This is part of a course project of the program - Nordic Master on Sustainable '
              'ICT Solutions of Tomorrow under Software Engineering department at Lut University, Finland.',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
