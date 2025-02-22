// lib/pages/home_page.dart
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/usage_service.dart';
import '../widgets/app_drawer.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final UsageService _usageService = UsageService();
  String? _selectedApp;
  Map<String, dynamic>? _selectedAppData;
  bool _isLoading = false;

  // List of supported app package names.
  final List<String> _supportedApps = [
    'com.google.android.youtube',
    'tv.twitch.android.app',
    'com.twitter.android',
    'com.linkedin.android',
    'com.facebook.katana',
    'com.snapchat.android',
    'com.instagram.android',
    'com.pinterest',
    'com.reddit.frontpage',
    'com.zhiliaoapp.musically',
  ];

  // Mapping of package names to friendly names.
  final Map<String, String> _appFriendlyNames = {
    'com.google.android.youtube': 'YouTube',
    'tv.twitch.android.app': 'Twitch',
    'com.twitter.android': 'Twitter',
    'com.linkedin.android': 'LinkedIn',
    'com.facebook.katana': 'Facebook',
    'com.snapchat.android': 'Snapchat',
    'com.instagram.android': 'Instagram',
    'com.pinterest': 'Pinterest',
    'com.reddit.frontpage': 'Reddit',
    'com.zhiliaoapp.musically': 'TikTok',
  };

  @override
  void initState() {
    super.initState();
    _selectedApp = _supportedApps.first;
    _fetchUsageForSelectedApp();
  }

  // Fetch usage data and aggregate values for the selected app.
  Future<void> _fetchUsageForSelectedApp() async {
    setState(() {
      _isLoading = true;
    });
    final usageList = await _usageService.getTodayUsage();
    // Filter records for the selected app.
    final filtered =
    usageList.where((entry) => entry['package'] == _selectedApp).toList();
    double totalCO2 = 0.0;
    double totalEnergy = 0.0;
    double totalMinutes = 0.0;
    for (var entry in filtered) {
      totalCO2 += (entry['co2'] as double);
      totalEnergy += (entry['energy'] as double);
      totalMinutes += (entry['minutes'] as double);
    }
    setState(() {
      _selectedAppData = {
        'co2': totalCO2,
        'energy': totalEnergy,
        'minutes': totalMinutes,
      };
      _isLoading = false;
    });
  }

  // Build a bar chart showing the CO₂ and energy values,
  // and display the metrics below the chart.
  Widget _buildChart() {
    if (_selectedAppData == null) {
      return const Center(child: Text('No data available'));
    }

    // Determine the maximum y-value for the chart.
    double maxY = ((_selectedAppData!['co2'] as double) >
        (_selectedAppData!['energy'] as double))
        ? (_selectedAppData!['co2'] as double)
        : (_selectedAppData!['energy'] as double);
    maxY *= 1.2; // add some padding

    return Column(
      children: [
        SizedBox(
          height: 300,
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: maxY,
              barTouchData: BarTouchData(enabled: true),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (double value, TitleMeta meta) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: Text(
                          value.toInt().toString(),
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (double value, TitleMeta meta) {
                      switch (value.toInt()) {
                        case 0:
                          return const Text('CO₂');
                        case 1:
                          return const Text('Energy');
                        default:
                          return const Text('');
                      }
                    },
                  ),
                ),
              ),
              borderData: FlBorderData(show: false),
              barGroups: [
                BarChartGroupData(
                  x: 0,
                  barRods: [
                    BarChartRodData(
                      toY: _selectedAppData!['co2'] as double,
                      color: const Color(0xFF00AB66),
                      width: 30,
                    ),
                  ],
                ),
                BarChartGroupData(
                  x: 1,
                  barRods: [
                    BarChartRodData(
                      toY: _selectedAppData!['energy'] as double,
                      color: const Color(0xFFFF8609),
                      width: 30,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Display the metric values below the chart.
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text(
              'CO₂: ${(_selectedAppData!['co2'] as double).toStringAsFixed(1)} g',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Energy: ${(_selectedAppData!['energy'] as double).toStringAsFixed(1)} mAh',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar with light green background.
      appBar: AppBar(
        title: const Text('Digital Impact'),

      ),
      drawer: const AppDrawer(),
      // Body with white background.
      body: Container(
        color: Colors.white,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Centered welcome message.
                  Center(
                    child: Column(
                      children: [
                        Text(
                          "Welcome to Eco-Impact Tracker!",
                          style: Theme.of(context)
                              .textTheme
                              .headlineMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Discover how your favorite apps impact the environment. Track their eco-footprint and battery usage in real time.",
                          style: Theme.of(context).textTheme.bodyLarge,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Select the app to see its impact:",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Dropdown for app selection with friendly names.
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Select an App',
                      border: OutlineInputBorder(),
                    ),
                    value: _selectedApp,
                    items: _supportedApps.map((app) {
                      return DropdownMenuItem(
                        value: app,
                        child: Text(_appFriendlyNames[app] ?? app),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedApp = value;
                      });
                      _fetchUsageForSelectedApp();
                    },
                  ),
                  const SizedBox(height: 16),
                  // Animated chart transition.
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 500),
                    child: _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : _buildChart(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _fetchUsageForSelectedApp,
        tooltip: 'Refresh Data',
        backgroundColor: Colors.lightGreen,
        child: const Icon(Icons.refresh),
      ),
    );
  }
}
