import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/health_provider.dart';
import '../models/health_models.dart';
import '../theme/app_theme.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  Future<void> _refreshData() async {
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(const SnackBar(content: Text('数据已刷新'), duration: Duration(seconds: 1)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('健康'),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle, size: 26),
            onPressed: () => context.push('/profile'),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(0, 0, 0, 24),
          children: [
            _buildGreeting(),
            const SizedBox(height: 4),
            _buildFavoritesSection(),
            const SizedBox(height: 10),
            _buildTrendsSection(),
            const SizedBox(height: 10),
            _buildSuggestionsSection(),
            const SizedBox(height: 10),
            _buildRecentRecordsSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildGreeting() {
    return Selector<HealthProvider, String>(
      selector: (_, p) => p.userName,
      builder: (context, userName, _) {
        final hour = DateTime.now().hour;
        final greeting = hour < 12 ? '早上好' : hour < 18 ? '下午好' : '晚上好';
        final weekDays = ['周一', '周二', '周三', '周四', '周五', '周六', '周日'];
        final now = DateTime.now();
        final dateStr = '${weekDays[now.weekday - 1]}, ${now.month}月${now.day}日';

        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(dateStr, style: AppTypography.footnote.copyWith(color: AppColors.secondaryText)),
              const SizedBox(height: 2),
              Text('$greeting，$userName', style: AppTypography.largeTitle),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFavoritesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader('收藏', () => context.push('/health_records')),
        const SizedBox(height: 8),
        Consumer<HealthProvider>(
          builder: (context, hp, _) => SizedBox(
            height: 110,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _favoriteCard('心率', hp.heartRate.toInt().toString(), 'bpm', Icons.favorite, AppColors.heartRate),
                _favoriteCard('步数', hp.todaySteps.toString(), '步', Icons.directions_walk, AppColors.steps),
                _favoriteCard('睡眠', hp.sleepHours.toStringAsFixed(1), '小时', Icons.bedtime, AppColors.sleep),
                _favoriteCard('体重', hp.latestWeight?.toStringAsFixed(1) ?? '--', 'kg', Icons.monitor_weight, AppColors.weight),
                SizedBox(
                  width: 80,
                  child: Center(
                    child: IconButton(
                      icon: const Icon(Icons.add_circle, size: 36, color: Color(0xFF007AFF)),
                      onPressed: () {},
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _favoriteCard(String label, String value, String unit, IconData icon, Color color) {
    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 10),
      child: Card(
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, size: 18, color: color),
                  const SizedBox(width: 6),
                  Text(label, style: AppTypography.footnote.copyWith(color: AppColors.secondaryText)),
                ],
              ),
              const Spacer(),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(value, style: AppTypography.metricValue.copyWith(fontSize: 28, height: 1)),
                  const SizedBox(width: 4),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(unit, style: AppTypography.footnote),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTrendsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader('健康趋势', null),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Card(
            margin: EdgeInsets.zero,
            child: Column(
              children: [
                _trendItem('步数', '↗', '比昨天多走了 1,234 步', AppColors.steps),
                const Divider(indent: 52),
                _trendItem('心率', '→', '心率保持稳定', AppColors.heartRate),
                const Divider(indent: 52),
                _trendItem('睡眠', '↘', '比昨天少睡了 0.5 小时', AppColors.sleep),
                const Divider(indent: 52),
                _trendItem('体重', '↗', '比上周增加了 0.2 kg', AppColors.weight),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _trendItem(String title, String trend, String desc, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 28, height: 28,
            decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(7)),
            child: Center(child: Text(trend, style: TextStyle(fontSize: 16, color: color, fontWeight: FontWeight.w700))),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTypography.body),
                const SizedBox(height: 1),
                Text(desc, style: AppTypography.footnote),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader('健康建议', null),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Card(
            margin: EdgeInsets.zero,
            child: Column(
              children: [
                _suggestionItem(Icons.directions_walk, '增加运动量', '今天的步数还差 1,458 步达到目标', AppColors.steps),
                const Divider(indent: 52),
                _suggestionItem(Icons.water_drop_outlined, '多喝水', '建议每天饮水 2-3 升', AppColors.water),
                const Divider(indent: 52),
                _suggestionItem(Icons.bedtime_outlined, '规律作息', '建议每晚 11 点前入睡', AppColors.sleep),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _suggestionItem(IconData icon, String title, String desc, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(9)),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTypography.headline.copyWith(fontSize: 15)),
                const SizedBox(height: 1),
                Text(desc, style: AppTypography.footnote),
              ],
            ),
          ),
          Icon(Icons.chevron_right, size: 20, color: AppColors.tertiaryText),
        ],
      ),
    );
  }

  Widget _buildRecentRecordsSection() {
    return Selector<HealthProvider, ({List<HealthRecord> healthRecords, List<MedicalRecord> medicalRecords})>(
      selector: (_, p) => (healthRecords: p.healthRecords, medicalRecords: p.medicalRecords),
      builder: (context, data, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionHeader('最近记录', null),
            if (data.healthRecords.isEmpty && data.medicalRecords.isEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
                child: Center(
                  child: Column(
                    children: [
                      Icon(Icons.inbox_outlined, size: 40, color: AppColors.tertiaryText),
                      const SizedBox(height: 8),
                      Text('暂无记录', style: AppTypography.subheadline),
                    ],
                  ),
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Card(
                  margin: EdgeInsets.zero,
                  child: Column(
                    children: [
                      ...data.healthRecords.take(3).map((r) => _recordItem('健康数据', r.notes ?? '无备注', r.date)),
                      if (data.healthRecords.isNotEmpty && data.medicalRecords.isNotEmpty)
                        const Divider(indent: 52),
                      ...data.medicalRecords.take(3).map((r) => _recordItem(r.title, r.description, r.date)),
                    ],
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _recordItem(String title, String desc, DateTime date) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(color: const Color(0xFF007AFF).withOpacity(0.1), borderRadius: BorderRadius.circular(9)),
            child: const Icon(Icons.article, size: 18, color: Color(0xFF007AFF)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTypography.body.copyWith(fontSize: 15)),
                Text(desc, style: AppTypography.footnote),
              ],
            ),
          ),
          Text('${date.month}/${date.day}', style: AppTypography.footnote),
        ],
      ),
    );
  }

  Widget _sectionHeader(String title, VoidCallback? onTap) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: AppTypography.title2),
          if (onTap != null)
            GestureDetector(
              onTap: onTap,
              child: Text('查看全部', style: AppTypography.body.copyWith(color: const Color(0xFF007AFF))),
            ),
        ],
      ),
    );
  }
}
