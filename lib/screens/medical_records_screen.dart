import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class MedicalRecordsScreen extends StatelessWidget {
  const MedicalRecordsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('医疗记录'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddDialog(context),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 4),
        children: [
          _sectionHeader('统计'),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Card(
              margin: EdgeInsets.zero,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    _statCard('总记录数', '12', Icons.folder_open, const Color(0xFF007AFF)),
                    const SizedBox(width: 12),
                    _statCard('本月就诊', '3', Icons.calendar_today, AppColors.steps),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          _sectionHeader('最近记录'),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Card(
              margin: EdgeInsets.zero,
              child: Column(
                children: [
                  _medicalRecord('体检报告', '北京和睦家医院', '2024年1月15日', '各项指标正常', Icons.assignment, Colors.blue, hasNotification: true),
                  const Divider(),
                  _medicalRecord('感冒就诊', '社区卫生服务中心', '2024年1月8日', '开具感冒药', Icons.thermostat, AppColors.heartRate),
                  const Divider(),
                  _medicalRecord('牙科检查', '口腔医院', '2023年12月20日', '洗牙，建议半年复查', Icons.medical_services, AppColors.sleep),
                  const Divider(),
                  _medicalRecord('眼科检查', '眼科专科医院', '2023年12月5日', '视力正常', Icons.remove_red_eye, AppColors.mindfulness),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          _sectionHeader('快速操作'),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Card(
              margin: EdgeInsets.zero,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(child: _quickAction('添加就诊', Icons.local_hospital, AppColors.heartRate, () => _showAddDialog(context))),
                    Expanded(child: _quickAction('用药提醒', Icons.medication, Colors.green, () => _showSnack(context, '用药提醒功能开发中...'))),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Card(
              margin: EdgeInsets.zero,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(child: _quickAction('预约挂号', Icons.schedule, const Color(0xFF007AFF), () => _showSnack(context, '预约挂号功能开发中...'))),
                    Expanded(child: _quickAction('报告查看', Icons.description, AppColors.steps, () => _showSnack(context, '报告查看功能开发中...'))),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _statCard(String title, String value, IconData icon, Color color) {
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
              Text(value, style: AppTypography.metricValue.copyWith(fontSize: 22, height: 1, color: color)),
              Text(title, style: AppTypography.footnote),
            ],
          ),
        ],
      ),
    );
  }

  Widget _medicalRecord(String title, String hospital, String date, String desc, IconData icon, Color color, {bool hasNotification = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(10)),
            child: Stack(
              children: [
                Center(child: Icon(icon, size: 20, color: color)),
                if (hasNotification)
                  Positioned(
                    top: 6, right: 6,
                    child: Container(width: 8, height: 8, decoration: const BoxDecoration(color: AppColors.heartRate, shape: BoxShape.circle)),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTypography.headline.copyWith(fontSize: 15)),
                const SizedBox(height: 1),
                Text('$hospital · $date', style: AppTypography.footnote),
                const SizedBox(height: 2),
                Text(desc, style: AppTypography.footnote.copyWith(color: AppColors.secondaryText)),
              ],
            ),
          ),
          Icon(Icons.chevron_right, size: 20, color: AppColors.tertiaryText),
        ],
      ),
    );
  }

  Widget _quickAction(String title, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(
          children: [
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, size: 22, color: color),
            ),
            const SizedBox(height: 6),
            Text(title, style: AppTypography.footnote.copyWith(color: color, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  void _showAddDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        content: const Text('添加医疗记录功能开发中...'),
        actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('确定'))],
      ),
    );
  }

  void _showSnack(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
      child: Text(title, style: AppTypography.title2),
    );
  }
}
