import 'package:flutter/material.dart';
import '../services/usage_service.dart';
import '../widgets/carbon_circle.dart';
import '../widgets/app_drawer.dart';

class TotalImpactPage extends StatefulWidget {
  const TotalImpactPage({Key? key}) : super(key: key);

  @override
  State<TotalImpactPage> createState() => _TotalImpactPageState();
}

class _TotalImpactPageState extends State<TotalImpactPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final UsageService _usageService = UsageService();

  // Data placeholders
  double _dailyImpact = 0.0;
  double _monthlyImpact = 0.0;
  double _yearlyImpact = 0.0;

  bool _loadingDaily = true;
  bool _loadingMonthly = true;
  bool _loadingYearly = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _fetchAllData();
  }

  /// Fetch all time ranges in sequence
  Future<void> _fetchAllData() async {
    await _fetchYearlyImpact();
    await _fetchMonthlyImpact();
    await _fetchDailyImpact();
  }

  Future<void> _fetchYearlyImpact() async {
    try {
      final now = DateTime.now();
      final startThisYear = DateTime(now.year, 1, 1);
      final startLastYear = DateTime(now.year - 1, 1, 1);
      final endLastYear = DateTime(now.year - 1, 12, 31, 23, 59, 59);

      final thisYearData = await _usageService.getRangeUsage(
          start: startThisYear, end: now);
      final lastYearData = await _usageService.getRangeUsage(
          start: startLastYear, end: endLastYear);

      final thisYearTotal =
          thisYearData.fold<double>(0, (sum, item) => sum + (item['co2'] as double));
      final lastYearTotal =
          lastYearData.fold<double>(0, (sum, item) => sum + (item['co2'] as double));

      setState(() {
        _yearlyImpact = thisYearTotal - lastYearTotal;
      });
    } catch (e) {
      debugPrint('Error fetching yearly impact: $e');
    } finally {
      setState(() {
        _loadingYearly = false;
      });
    }
  }

  Future<void> _fetchMonthlyImpact() async {
    try {
      final now = DateTime.now();
      final startThisMonth = DateTime(now.year, now.month, 1);
      final startLastMonth =
          DateTime(now.year, now.month - 1, 1); // Handles year overflow too
      final endLastMonth = DateTime(now.year, now.month, 0); // Last day of last month

      final thisMonthData = await _usageService.getRangeUsage(
          start: startThisMonth, end: now);
      final lastMonthData = await _usageService.getRangeUsage(
          start: startLastMonth, end: endLastMonth);

      final thisMonthTotal =
          thisMonthData.fold<double>(0, (sum, item) => sum + (item['co2'] as double));
      final lastMonthTotal =
          lastMonthData.fold<double>(0, (sum, item) => sum + (item['co2'] as double));

      setState(() {
        _monthlyImpact = thisMonthTotal - lastMonthTotal;
      });
    } catch (e) {
      debugPrint('Error fetching monthly impact: $e');
    } finally {
      setState(() {
        _loadingMonthly = false;
      });
    }
  }

  Future<void> _fetchDailyImpact() async {
    try {
      final now = DateTime.now();
      final startToday = DateTime(now.year, now.month, now.day);
      final startYesterday = startToday.subtract(const Duration(days: 1));
      final endYesterday = startToday.subtract(const Duration(seconds: 1));

      final todayData = await _usageService.getRangeUsage(
          start: startToday, end: now);
      final yesterdayData = await _usageService.getRangeUsage(
          start: startYesterday, end: endYesterday);

      final todayTotal =
          todayData.fold<double>(0, (sum, item) => sum + (item['co2'] as double));
      final yesterdayTotal =
          yesterdayData.fold<double>(0, (sum, item) => sum + (item['co2'] as double));

      setState(() {
        _dailyImpact = todayTotal - yesterdayTotal;
      });
    } catch (e) {
      debugPrint('Error fetching daily impact: $e');
    } finally {
      setState(() {
        _loadingDaily = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Total Impact'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Daily'),
            Tab(text: 'Monthly'),
            Tab(text: 'Yearly'),
          ],
        ),
      ),
      drawer: const AppDrawer(),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildTabContent(_dailyImpact, _loadingDaily),
          _buildTabContent(_monthlyImpact, _loadingMonthly),
          _buildTabContent(_yearlyImpact, _loadingYearly),
        ],
      ),
    );
  }

  /// Helper to build each tab's content based on data + loading flags
  Widget _buildTabContent(double impact, bool isLoading) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    return Center(
      child: CarbonCircle(co2Value: impact),
    );
  }
}
