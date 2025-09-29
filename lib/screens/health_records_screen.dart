import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'widgets/heart_rate_chart.dart';
import 'widgets/health_metric_card.dart';
import '../services/health_service.dart';

class HealthRecordsScreen extends StatefulWidget {
  const HealthRecordsScreen({super.key});

  @override
  State<HealthRecordsScreen> createState() => _HealthRecordsScreenState();
}

class _HealthRecordsScreenState extends State<HealthRecordsScreen> {
  final HealthService _healthService = HealthService();
  
  int _steps = 0;
  double _sleepHours = 0;
  double? _weight;
  Map<String, double?> _bloodPressure = {'systolic': null, 'diastolic': null};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHealthData();
  }

  Future<void> _loadHealthData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // 初始化HealthKit
      await _healthService.initialize();
      
      // 并行获取所有健康数据
      final results = await Future.wait([
        _healthService.getTodaySteps(),
        _healthService.getTodaySleepHours(),
        _healthService.getLatestWeight(),
        _healthService.getLatestBloodPressure(),
      ]);

      setState(() {
        _steps = results[0] as int;
        _sleepHours = results[1] as double;
        _weight = results[2] as double?;
        _bloodPressure = results[3] as Map<String, double?>;
        _isLoading = false;
      });
    } catch (e) {
      print('加载健康数据失败: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _formatBloodPressure() {
    final systolic = _bloodPressure['systolic'];
    final diastolic = _bloodPressure['diastolic'];
    
    if (systolic != null && diastolic != null) {
      return '${systolic.toInt()}/${diastolic.toInt()}';
    }
    return '--/--';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('健康数据'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadHealthData,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadHealthData,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '心率变化',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              const HeartRateChart(),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '今日数据',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(
                    children: [
                      TextButton.icon(
                        onPressed: () {
                          context.push('/health-charts');
                        },
                        icon: const Icon(Icons.bar_chart, size: 18),
                        label: const Text('查看图表'),
                        style: TextButton.styleFrom(
                          foregroundColor: const Color(0xFF0569F1),
                        ),
                      ),
                      if (_isLoading)
                        const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  HealthMetricCard(
                    title: '步数',
                    value: _steps.toString(),
                    unit: '步',
                    icon: Icons.directions_walk,
                    color: Colors.orange,
                  ),
                  HealthMetricCard(
                    title: '睡眠',
                    value: _sleepHours.toStringAsFixed(1),
                    unit: '小时',
                    icon: Icons.bedtime,
                    color: Colors.purple,
                  ),
                  HealthMetricCard(
                    title: '血压',
                    value: _formatBloodPressure(),
                    unit: 'mmHg',
                    icon: Icons.favorite,
                    color: Colors.red,
                  ),
                  HealthMetricCard(
                    title: '体重',
                    value: _weight?.toStringAsFixed(1) ?? '--',
                    unit: 'kg',
                    icon: Icons.monitor_weight,
                    color: Colors.green,
                  ),
                ],
              ),
              const SizedBox(height: 24),
              if (!_isLoading)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'HealthKit 集成',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          '数据来源于 iOS HealthKit，包括步数、睡眠、体重和血压等健康指标。',
                          style: TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton.icon(
                          onPressed: _loadHealthData,
                          icon: const Icon(Icons.sync),
                          label: const Text('同步数据'),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}