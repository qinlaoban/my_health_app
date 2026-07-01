import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/health_provider.dart';
import 'widgets/heart_rate_tab_widget.dart';
import 'widgets/steps_tab_widget.dart';
import 'widgets/sleep_tab_widget.dart';
import 'widgets/weight_tab_widget.dart';
import 'widgets/blood_pressure_tab_widget.dart';
class HealthChartsScreen extends StatefulWidget {
  const HealthChartsScreen({super.key});

  @override
  State<HealthChartsScreen> createState() => _HealthChartsScreenState();
}

class _HealthChartsScreenState extends State<HealthChartsScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _syncData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _syncData() async {
    final hp = context.read<HealthProvider>();
    if (!hp.healthKitAvailable) {
      await hp.syncFromHealthKit();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('健康图表'),
        leading: IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: () => context.pop(),
        ),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(icon: Icon(Icons.favorite, size: 18), text: '心率'),
            Tab(icon: Icon(Icons.directions_walk, size: 18), text: '步数'),
            Tab(icon: Icon(Icons.monitor_weight, size: 18), text: '体重'),
            Tab(icon: Icon(Icons.bedtime, size: 18), text: '睡眠'),
            Tab(icon: Icon(Icons.monitor_heart, size: 18), text: '血压'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          Selector<HealthProvider, double>(
            selector: (_, hp) => hp.heartRate,
            builder: (_, hr, __) => HeartRateTabWidget(heartRate: hr.toInt()),
          ),
          Selector<HealthProvider, int>(
            selector: (_, hp) => hp.todaySteps,
            builder: (_, steps, __) => StepsTabWidget(steps: steps),
          ),
          Selector<HealthProvider, double?>(
            selector: (_, hp) => hp.latestWeight,
            builder: (_, w, __) => WeightTabWidget(weight: w),
          ),
          Selector<HealthProvider, double>(
            selector: (_, hp) => hp.sleepHours,
            builder: (_, sleep, __) => SleepTabWidget(sleepHours: sleep),
          ),
          Selector<HealthProvider, Map<String, double?>>(
            selector: (_, hp) => hp.bloodPressure,
            builder: (_, bp, __) => BloodPressureTabWidget(
              bloodPressure: {
                'systolic': bp['systolic'] ?? 0,
                'diastolic': bp['diastolic'] ?? 0,
              },
            ),
          ),
        ],
      ),
    );
  }
}
