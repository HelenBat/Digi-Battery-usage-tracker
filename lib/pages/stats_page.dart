import 'package:flutter/material.dart';
import '../services/usage_service.dart';
import '../widgets/charts.dart';
import '../widgets/app_drawer.dart';

class StatsPage extends StatefulWidget {
  const StatsPage({Key? key}) : super(key: key);

  @override
  State<StatsPage> createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> {
  final UsageService _usageService = UsageService();

  final Map<String, List<Map<String, dynamic>>> _usageDataByPeriod = {
    'weekly': [],
    'monthly': [],
    'yearly': [],
  };

  bool _loadingWeekly = true;
  bool _loadingMonthly = true;
  bool _loadingYearly = true;

  @override
  void initState() {
    super.initState();
    _fetchAllData();
  }

  Future<void> _fetchAllData() async {
    await _fetchWeeklyUsage();
    await _fetchMonthlyUsage();
    await _fetchYearlyUsage();
  }

  Future<void> _fetchWeeklyUsage() async {
    try {
      final now = DateTime.now();
      final start = now.subtract(const Duration(days: 7));
      final usageList = await _usageService.getRangeUsage(start: start, end: now);
      setState(() {
        _usageDataByPeriod['weekly'] = usageList;
      });
    } catch (e) {
      debugPrint('Error fetching weekly usage: $e');
    } finally {
      setState(() {
        _loadingWeekly = false;
      });
    }
  }

  Future<void> _fetchMonthlyUsage() async {
    try {
      final now = DateTime.now();
      final start = DateTime(now.year, now.month - 1, now.day);
      final usageList = await _usageService.getRangeUsage(start: start, end: now);
      setState(() {
        _usageDataByPeriod['monthly'] = usageList;
      });
    } catch (e) {
      debugPrint('Error fetching monthly usage: $e');
    } finally {
      setState(() {
        _loadingMonthly = false;
      });
    }
  }

  Future<void> _fetchYearlyUsage() async {
    try {
      final now = DateTime.now();
      final start = DateTime(now.year - 1, now.month, now.day);
      final usageList = await _usageService.getRangeUsage(start: start, end: now);
      setState(() {
        _usageDataByPeriod['yearly'] = usageList;
      });
    } catch (e) {
      debugPrint('Error fetching yearly usage: $e');
    } finally {
      setState(() {
        _loadingYearly = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Usage Statistics'),
      ),
      drawer: const AppDrawer(),
      body: _loadingWeekly || _loadingMonthly || _loadingYearly
          ? const Center(child: CircularProgressIndicator())
          : SocialMediaPieChart(
              usageDataByPeriod: _usageDataByPeriod,
            ),
    );
  }
}
