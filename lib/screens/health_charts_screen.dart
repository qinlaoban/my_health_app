import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:health/health.dart';
import 'package:go_router/go_router.dart';
import '../providers/health_provider.dart';
import '../services/health_service.dart';
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
  final HealthService _healthService = HealthService();

  // 健康数据
  int _heartRate = 0;
  int _steps = 0;
  double _sleepHours = 0;
  double? _weight;
  Map<String, double> _bloodPressure = {'systolic': 120, 'diastolic': 80};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _loadHealthData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadHealthData() async {
    try {
      await _healthService.initialize();

      final now = DateTime.now();
      final startTime = now.subtract(const Duration(days: 7));

      // 加载心率数据
      final heartRateData = await _healthService.getHeartRateData(
        startTime: startTime,
        endTime: now,
      );
      if (heartRateData.isNotEmpty) {
        setState(() {
          final heartRateValue = heartRateData.last.value;
          if (heartRateValue is NumericHealthValue) {
            _heartRate = heartRateValue.numericValue.toInt();
          }
        });
      }

      // 加载步数数据
      final stepsData = await _healthService.getTodaySteps();
      setState(() {
        _steps = stepsData;
      });

      // 加载睡眠数据
      final sleepData = await _healthService.getSleepData(
        startTime: startTime,
        endTime: now,
      );
      if (sleepData.isNotEmpty) {
        setState(() {
          final sleepValue = sleepData.last.value;
          if (sleepValue is NumericHealthValue) {
            _sleepHours = sleepValue.numericValue.toDouble();
          }
        });
      }

      // 加载体重数据
      final weightData = await _healthService.getWeightData(
        startTime: startTime,
        endTime: now,
      );
      if (weightData.isNotEmpty) {
        setState(() {
          final weightValue = weightData.last.value;
          if (weightValue is NumericHealthValue) {
            _weight = weightValue.numericValue.toDouble();
          }
        });
      }

      // 加载血压数据
      final bloodPressureData = await _healthService.getBloodPressureData(
        startTime: startTime,
        endTime: now,
      );
      if (bloodPressureData.isNotEmpty) {
        setState(() {
          final systolicData = bloodPressureData['systolic'];
          final diastolicData = bloodPressureData['diastolic'];

          double systolic = 120.0;
          double diastolic = 80.0;

          if (systolicData != null && systolicData.isNotEmpty) {
            final systolicValue = systolicData.last.value;
            if (systolicValue is NumericHealthValue) {
              systolic = systolicValue.numericValue.toDouble();
            }
          }

          if (diastolicData != null && diastolicData.isNotEmpty) {
            final diastolicValue = diastolicData.last.value;
            if (diastolicValue is NumericHealthValue) {
              diastolic = diastolicValue.numericValue.toDouble();
            }
          }

          _bloodPressure = {'systolic': systolic, 'diastolic': diastolic};
        });
      }
    } catch (e) {
      print('加载健康数据失败: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<HealthProvider>(
      builder: (context, healthProvider, child) {
        return Scaffold(
          backgroundColor: Colors.grey[50],
          appBar: AppBar(
            title: const Text(
              '健康数据',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            backgroundColor: Colors.blue[600],
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => context.pop(),
            ),
            bottom: TabBar(
              controller: _tabController,
              isScrollable: true,
              indicatorColor: Colors.white,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white70,
              tabs: const [
                Tab(icon: Icon(Icons.favorite), text: '心率'),
                Tab(icon: Icon(Icons.directions_walk), text: '步数'),
                Tab(icon: Icon(Icons.bedtime), text: '睡眠'),
                Tab(icon: Icon(Icons.monitor_weight), text: '体重'),
                Tab(icon: Icon(Icons.monitor_heart), text: '血压'),
              ],
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            children: [
              HeartRateTabWidget(heartRate: _heartRate),
              StepsTabWidget(steps: _steps),
              SleepTabWidget(sleepHours: _sleepHours),
              WeightTabWidget(weight: _weight),
              BloodPressureTabWidget(bloodPressure: _bloodPressure),
            ],
          ),
        );
      },
    );
  }
}
