import 'package:flutter/material.dart';
import 'blood_pressure_chart.dart';

class BloodPressureTabWidget extends StatelessWidget {
  final Map<String, double> bloodPressure;

  const BloodPressureTabWidget({super.key, required this.bloodPressure});

  // 获取血压状态和对应颜色
  Map<String, dynamic> _getBloodPressureStatus() {
    final systolic = bloodPressure['systolic'] ?? 120;
    final diastolic = bloodPressure['diastolic'] ?? 80;

    if (systolic >= 140 || diastolic >= 90) {
      return {
        'status': '高血压',
        'color': Colors.red,
        'bgColor': Colors.red.withOpacity(0.1),
        'icon': Icons.warning_rounded,
        'description': '建议咨询医生',
      };
    } else if (systolic >= 130 || diastolic >= 85) {
      return {
        'status': '偏高',
        'color': Colors.orange,
        'bgColor': Colors.orange.withOpacity(0.1),
        'icon': Icons.info_outline_rounded,
        'description': '需要注意',
      };
    } else if (systolic >= 120 || diastolic >= 80) {
      return {
        'status': '正常偏高',
        'color': Colors.amber,
        'bgColor': Colors.amber.withOpacity(0.1),
        'icon': Icons.check_circle_outline_rounded,
        'description': '保持良好习惯',
      };
    } else {
      return {
        'status': '理想',
        'color': Colors.green,
        'bgColor': Colors.green.withOpacity(0.1),
        'icon': Icons.favorite_rounded,
        'description': '血压很健康',
      };
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildEnhancedSummaryCard(),
          const SizedBox(height: 16),
          const BloodPressureChart(),
          const SizedBox(height: 16),
          _buildInsightCard(
            title: '血压分析',
            insights: ['血压数值在正常范围内', '收缩压和舒张压都比较稳定', '建议定期监测，保持健康生活方式'],
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedSummaryCard() {
    final statusInfo = _getBloodPressureStatus();
    final systolic = bloodPressure['systolic']?.toInt() ?? 120;
    final diastolic = bloodPressure['diastolic']?.toInt() ?? 80;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white, statusInfo['bgColor']],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: statusInfo['color'].withOpacity(0.15),
            spreadRadius: 3,
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: statusInfo['color'].withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题栏
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: statusInfo['color'].withOpacity(0.15),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: statusInfo['color'].withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Icon(
                  Icons.monitor_heart_rounded,
                  color: statusInfo['color'],
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '血压概览',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          statusInfo['icon'],
                          color: statusInfo['color'],
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          statusInfo['description'],
                          style: TextStyle(
                            fontSize: 14,
                            color: statusInfo['color'],
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // 血压状态指示器
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: statusInfo['color'].withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: statusInfo['color'].withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(statusInfo['icon'], color: statusInfo['color'], size: 20),
                const SizedBox(width: 8),
                Text(
                  '血压状态: ${statusInfo['status']}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: statusInfo['color'],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // 血压数值展示
          Row(
            children: [
              Expanded(
                child: _buildPressureCard(
                  '收缩压',
                  '$systolic',
                  'mmHg',
                  Colors.red,
                  Icons.arrow_upward_rounded,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildPressureCard(
                  '舒张压',
                  '$diastolic',
                  'mmHg',
                  Colors.blue,
                  Icons.arrow_downward_rounded,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // 平均血压和脉压差
          Row(
            children: [
              Expanded(
                child: _buildMetricItem(
                  '平均动脉压',
                  '${((systolic + 2 * diastolic) / 3).toInt()}',
                  'mmHg',
                  Colors.purple,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildMetricItem(
                  '脉压差',
                  '${systolic - diastolic}',
                  'mmHg',
                  Colors.teal,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPressureCard(
    String label,
    String value,
    String unit,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2), width: 1),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 18),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                unit,
                style: TextStyle(
                  fontSize: 14,
                  color: color.withOpacity(0.7),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricItem(
    String label,
    String value,
    String unit,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2), width: 1),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const SizedBox(width: 2),
              Text(
                unit,
                style: TextStyle(fontSize: 10, color: color.withOpacity(0.7)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInsightCard({
    required String title,
    required List<String> insights,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.lightbulb_outline, color: Colors.amber[700], size: 24),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...insights.map(
            (insight) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 6),
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: Colors.blue[400],
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      insight,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
