import 'package:flutter/material.dart';
import '../services/usage_service.dart';
import '../widgets/carbon_circle.dart';
import '../widgets/app_drawer.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final UsageService _usageService = UsageService();

  double _totalCO2 = 0.0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchTodayUsage();
  }

  Future<void> _fetchTodayUsage() async {
    try {
      final usageList = await _usageService.getTodayUsage();
      double total = 0.0;

      for (var usage in usageList) {
        total += (usage['co2'] as double);
      }

      setState(() {
        _totalCO2 = total;
      });
    } catch (e) {
      debugPrint('Error fetching usage: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Carbon Footprint Tracker'),
      ),
      drawer: const AppDrawer(),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Today's Carbon Footprint",
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 20),
                  CarbonCircle(co2Value: _totalCO2),
                ],
              ),
            ),
    );
  }
}
