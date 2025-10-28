import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import '../providers/health_provider.dart';
import '../providers/reminder_provider.dart';
import '../widgets/health_radar_chart.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  Future<void> _refreshData() async {
    // 模拟刷新数据
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('数据已刷新')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('概览'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () => _showNotificationDialog(context),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          children: [
            Selector<HealthProvider, String>(
              selector: (_, p) => p.userName,
              builder: (context, userName, _) => _buildWelcomeCardName(userName),
            ),
            const SizedBox(height: 16),
            RepaintBoundary(child: _buildTodayHealthOverview()),
            const SizedBox(height: 16),
            _buildHealthTrends(),
            const SizedBox(height: 16),
            _buildRemindersSummary(context),
            const SizedBox(height: 16),
            _buildQuickActions(context),
            const SizedBox(height: 16),
            _buildHealthSuggestions(),
            const SizedBox(height: 16),
            Selector<HealthProvider, ({List<HealthRecord> healthRecords, List<MedicalRecord> medicalRecords})>(
              selector: (_, p) => (healthRecords: p.healthRecords, medicalRecords: p.medicalRecords),
              builder: (context, data, _) => _buildRecentRecordsData(data.healthRecords, data.medicalRecords),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeCard(HealthProvider provider) {
    final hour = DateTime.now().hour;
    String greeting;
    if (hour < 12) {
      greeting = '早上好';
    } else if (hour < 18) {
      greeting = '下午好';
    } else {
      greeting = '晚上好';
    }

    return Card(
      elevation: 2,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [Colors.blue.shade400, Colors.blue.shade600],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$greeting，${provider.userName}',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              '今天也要保持健康的生活方式哦！',
              style: TextStyle(fontSize: 16, color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }

  // 仅依赖userName的轻量版本，配合Selector减少重建
  Widget _buildWelcomeCardName(String userName) {
    final hour = DateTime.now().hour;
    String greeting;
    if (hour < 12) {
      greeting = '早上好';
    } else if (hour < 18) {
      greeting = '下午好';
    } else {
      greeting = '晚上好';
    }

    return Card(
      elevation: 2,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [Colors.blue.shade400, Colors.blue.shade600],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$greeting，$userName',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              '今天也要保持健康的生活方式哦！',
              style: TextStyle(fontSize: 16, color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTodayHealthOverview() {
    // 模拟健康数据，实际应用中应从HealthProvider获取
    final healthData = {
      'steps': 8542.0,
      'heartRate': 72.0,
      'sleep': 7.5,
      'water': 1.8,
      'nutrition': 85.0,
      'stress': 25.0,
    };

    return HealthRadarChart(healthData: healthData, size: 280);
  }

  // 原_buildHealthMetric方法已被雷达图替代
  Widget _buildHealthTrends() {
    return Card(
      elevation: 4,
      shadowColor: Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.white, Colors.blue.shade50.withOpacity(0.3)],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.trending_up,
                      color: Colors.blue.shade600,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    '健康趋势',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _buildTrendItem(
                '步数',
                '↗',
                '比昨天多走了 1,234 步',
                Colors.green.shade600,
              ),
              const SizedBox(height: 12),
              _buildTrendItem('心率', '→', '心率保持稳定', Colors.blue.shade600),
              const SizedBox(height: 12),
              _buildTrendItem(
                '睡眠',
                '↘',
                '比昨天少睡了 0.5 小时',
                Colors.orange.shade600,
              ),
              const SizedBox(height: 12),
              _buildTrendItem('体重', '↗', '比上周增加了 0.2 kg', Colors.red.shade600),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTrendItem(
    String title,
    String trend,
    String description,
    Color color,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      trend,
                      style: TextStyle(
                        fontSize: 16,
                        color: color,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Text(
                  description,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '快速操作',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildQuickActionButton(
                      '生物标记物',
                      Icons.biotech_outlined,
                      Colors.purple,
                      () => context.push('/biomarkers'),
                    ),
                    _buildQuickActionButton(
                      '医疗记录',
                      Icons.local_hospital_outlined,
                      Colors.red,
                      () => Navigator.pushNamed(context, '/medical_records'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildQuickActionButton(
                      '散点图分析',
                      Icons.scatter_plot_outlined,
                      const Color(0xFF4ECDC4),
                      () => context.push('/scatter-chart'),
                    ),
                    _buildQuickActionButton(
                      '个人资料',
                      Icons.person_outline,
                      Colors.blue,
                      () => Navigator.pushNamed(context, '/profile'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildQuickActionButton(
                      '健康提醒',
                      Icons.notifications_active_outlined,
                      Colors.teal,
                      () => context.push('/reminders'),
                    ),
                    _buildQuickActionButton(
                      '健康图表',
                      Icons.monitor_heart_outlined,
                      Colors.indigo,
                      () => context.push('/health-charts'),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionButton(
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        splashColor: color.withOpacity(0.2),
        highlightColor: color.withOpacity(0.05),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHealthSuggestions() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '健康建议',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildSuggestionItem(
              FontAwesomeIcons.walking,
              '增加运动量',
              '今天的步数还差 1,458 步达到目标',
              Colors.orange,
            ),
            _buildSuggestionItem(
              FontAwesomeIcons.glassWater,
              '多喝水',
              '建议每天饮水 2-3 升，保持身体水分平衡',
              Colors.blue,
            ),
            _buildSuggestionItem(
              FontAwesomeIcons.bed,
              '规律作息',
              '建议每晚 11 点前入睡，保证 7-8 小时睡眠',
              Colors.purple,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuggestionItem(
    IconData icon,
    String title,
    String description,
    Color color,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: FaIcon(icon, color: color, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  description,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentRecords(HealthProvider provider) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '最近记录',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            if (provider.healthRecords.isEmpty &&
                provider.medicalRecords.isEmpty)
              const Center(
                child: Column(
                  children: [
                    Icon(Icons.inbox_outlined, size: 48, color: Colors.grey),
                    SizedBox(height: 8),
                    Text(
                      '暂无记录',
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                  ],
                ),
              )
            else
              Column(
                children: [
                  if (provider.healthRecords.isNotEmpty) ...[
                    const Text(
                      '健康记录',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...provider.healthRecords
                        .take(3)
                        .map(
                          (record) => _buildRecordItem(
                            '健康数据',
                            record.notes ?? '无备注',
                            record.date,
                          ),
                        ),
                  ],
                  if (provider.medicalRecords.isNotEmpty) ...[
                    if (provider.healthRecords.isNotEmpty)
                      const SizedBox(height: 16),
                    const Text(
                      '医疗记录',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...provider.medicalRecords
                        .take(3)
                        .map(
                          (record) => _buildRecordItem(
                            record.title,
                            record.description,
                            record.date,
                          ),
                        ),
                  ],
                ],
              ),
          ],
        ),
      ),
    );
  }

  // 仅依赖记录列表的轻量版本，配合Selector减少重建
  Widget _buildRecentRecordsData(List<HealthRecord> healthRecords, List<MedicalRecord> medicalRecords) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '最近记录',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            if (healthRecords.isEmpty && medicalRecords.isEmpty)
              const Center(
                child: Column(
                  children: [
                    Icon(Icons.inbox_outlined, size: 48, color: Colors.grey),
                    SizedBox(height: 8),
                    Text(
                      '暂无记录',
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                  ],
                ),
              )
            else
              Column(
                children: [
                  if (healthRecords.isNotEmpty) ...[
                    const Text(
                      '健康记录',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...healthRecords
                        .take(3)
                        .map(
                          (record) => _buildRecordItem(
                            '健康数据',
                            record.notes ?? '无备注',
                            record.date,
                          ),
                        ),
                  ],
                  if (medicalRecords.isNotEmpty) ...[
                    if (healthRecords.isNotEmpty)
                      const SizedBox(height: 16),
                    const Text(
                      '医疗记录',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...medicalRecords
                        .take(3)
                        .map(
                          (record) => _buildRecordItem(
                            record.title,
                            record.description,
                            record.date,
                          ),
                        ),
                  ],
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecordItem(String title, String description, DateTime date) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  description,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
          Text(
            '${date.month}/${date.day}',
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildRemindersSummary(BuildContext context) {
    return Consumer<ReminderProvider>(
      builder: (context, reminderProvider, child) {
        final next = reminderProvider.nextReminder();
        return Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.teal.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.notifications_active_outlined,
                        color: Colors.teal.shade700,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      '提醒摘要',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const Spacer(),
                    TextButton.icon(
                      onPressed: () => context.push('/reminders'),
                      icon: const Icon(Icons.settings_outlined, size: 18),
                      label: const Text('管理'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '已开启提醒：${reminderProvider.enabledCount} 项',
                            style: const TextStyle(fontSize: 14),
                          ),
                          const SizedBox(height: 6),
                          if (next != null)
                            Row(
                              children: [
                                Icon(next.icon, color: next.color, size: 18),
                                const SizedBox(width: 6),
                                Text(
                                  '下一次：${next.title} · ${_formatTime(next.time)}',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            )
                          else
                            const Text(
                              '暂无开启的提醒',
                              style: TextStyle(fontSize: 13, color: Colors.grey),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _formatTime(TimeOfDay t) {
    final h = t.hour.toString().padLeft(2, '0');
    final m = t.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  void _showNotificationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('通知'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.medication, color: Colors.green),
              title: Text('用药提醒'),
              subtitle: Text('记得服用维生素D'),
              contentPadding: EdgeInsets.zero,
            ),
            ListTile(
              leading: Icon(Icons.directions_walk, color: Colors.orange),
              title: Text('运动提醒'),
              subtitle: Text('今天还差1458步达到目标'),
              contentPadding: EdgeInsets.zero,
            ),
            ListTile(
              leading: Icon(Icons.water_drop, color: Colors.blue),
              title: Text('喝水提醒'),
              subtitle: Text('该补充水分了'),
              contentPadding: EdgeInsets.zero,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }
}
