import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'widgets/heart_rate_chart.dart';
import '../providers/health_provider.dart';
import '../theme/app_theme.dart';

class HealthRecordsScreen extends StatefulWidget {
  const HealthRecordsScreen({super.key});

  @override
  State<HealthRecordsScreen> createState() => _HealthRecordsScreenState();
}

class _HealthRecordsScreenState extends State<HealthRecordsScreen> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final provider = context.read<HealthProvider>();
    if (!provider.healthKitAvailable) {
      await provider.syncFromHealthKit();
    }
  }

  String _formatBP(Map<String, double?> bp) {
    final s = bp['systolic'];
    final d = bp['diastolic'];
    return s != null && d != null ? '${s.toInt()}/${d.toInt()}' : '--/--';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('健康数据'),
        actions: [
          Selector<HealthProvider, bool>(
            selector: (_, p) => p.isSyncing,
            builder: (context, isSyncing, _) => IconButton(
              icon: isSyncing
                  ? const SizedBox(
                      width: 22, height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2.5),
                    )
                  : const Icon(Icons.sync),
              onPressed: isSyncing ? null : () => context.read<HealthProvider>().syncFromHealthKit(),
            ),
          ),
        ],
      ),
      body: Consumer<HealthProvider>(
        builder: (context, hp, _) => RefreshIndicator(
          onRefresh: () => hp.syncFromHealthKit(),
          child: ListView(
            padding: const EdgeInsets.symmetric(vertical: 4),
            children: [
              _sectionHeader('心率趋势'),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Card(
                  margin: EdgeInsets.zero,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: RepaintBoundary(child: const HeartRateChart()),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              _sectionHeader('今日数据'),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Card(
                  margin: EdgeInsets.zero,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            _metricMiniCard('步数', hp.todaySteps.toString(), '步', Icons.directions_walk, AppColors.steps),
                            const SizedBox(width: 12),
                            _metricMiniCard('睡眠', '${hp.sleepHours.toStringAsFixed(1)}', '小时', Icons.bedtime, AppColors.sleep),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            _metricMiniCard('血压', _formatBP(hp.bloodPressure), 'mmHg', Icons.favorite, AppColors.bloodPressure),
                            const SizedBox(width: 12),
                            _metricMiniCard('体重', hp.latestWeight?.toStringAsFixed(1) ?? '--', 'kg', Icons.monitor_weight, AppColors.weight),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              if (hp.healthKitAvailable)
                _buildHealthKitCard(hp)
              else
                _buildHealthKitUnavailableCard(hp),
            ],
          ),
        ),
      ),
    );
  }

  Widget _metricMiniCard(String label, String value, String unit, IconData icon, Color color) {
    return Expanded(
      child: Row(
        children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, size: 20, color: color),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(value, style: AppTypography.metricValue.copyWith(fontSize: 22, height: 1)),
                  const SizedBox(width: 2),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 2),
                    child: Text(unit, style: AppTypography.caption),
                  ),
                ],
              ),
              Text(label, style: AppTypography.footnote),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHealthKitCard(HealthProvider hp) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader('HealthKit'),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Card(
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFF007AFF).withOpacity(0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.apple, size: 22, color: Color(0xFF007AFF)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('HealthKit', style: AppTypography.body),
                        const Text('数据已连接，可下拉刷新同步', style: AppTypography.footnote),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: hp.isSyncing ? null : () => hp.syncFromHealthKit(),
                    child: Text(hp.isSyncing ? '同步中' : '同步', style: const TextStyle(color: Color(0xFF007AFF))),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHealthKitUnavailableCard(HealthProvider hp) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader('HealthKit'),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Card(
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.secondaryText.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.apple, size: 22, color: AppColors.secondaryText),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('HealthKit 不可用', style: AppTypography.body),
                        const Text('请使用 iOS 真机设备以同步健康数据', style: AppTypography.footnote),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
      child: Text(title, style: AppTypography.title2),
    );
  }
}
