import 'package:flutter/material.dart';
import 'heart_rate_chart.dart';

class HeartRateTabWidget extends StatelessWidget {
  final int heartRate;

  const HeartRateTabWidget({super.key, required this.heartRate});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildEnhancedSummaryCard(),
          const SizedBox(height: 16),
          const HeartRateChart(),
          const SizedBox(height: 16),
          _buildInsightCard(
            title: '心率分析',
            insights: ['您的心率变化正常，保持在健康范围内', '建议继续保持规律的运动习惯', '如有异常波动，请及时咨询医生'],
          ),
        ],
      ),
    );
  }

  // 获取心率状态信息
  Map<String, dynamic> _getHeartRateStatus() {
    final currentHeartRate = heartRate;

    if (currentHeartRate < 60) {
      return {
        'status': '偏低',
        'description': '静息心率',
        'color': const Color(0xFF42A5F5),
        'bgColor': const Color(0xFF42A5F5).withOpacity(0.05),
        'icon': Icons.trending_down_rounded,
        'advice': '心率偏低，如无不适症状属正常',
      };
    } else if (currentHeartRate <= 100) {
      return {
        'status': '正常',
        'description': '健康范围',
        'color': const Color(0xFF66BB6A),
        'bgColor': const Color(0xFF66BB6A).withOpacity(0.05),
        'icon': Icons.favorite_rounded,
        'advice': '心率正常，保持良好的生活习惯',
      };
    } else if (currentHeartRate <= 120) {
      return {
        'status': '偏高',
        'description': '轻度升高',
        'color': const Color(0xFFFFB74D),
        'bgColor': const Color(0xFFFFB74D).withOpacity(0.05),
        'icon': Icons.trending_up_rounded,
        'advice': '心率略高，注意休息和放松',
      };
    } else {
      return {
        'status': '过高',
        'description': '需要关注',
        'color': const Color(0xFFFF5722),
        'bgColor': const Color(0xFFFF5722).withOpacity(0.05),
        'icon': Icons.warning_rounded,
        'advice': '心率过高，建议咨询医生',
      };
    }
  }

  Widget _buildEnhancedSummaryCard() {
    final statusInfo = _getHeartRateStatus();

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
                  gradient: LinearGradient(
                    colors: [
                      statusInfo['color'].withOpacity(0.2),
                      statusInfo['color'].withOpacity(0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: statusInfo['color'].withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Icon(
                  Icons.favorite_rounded,
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
                      '心率概览',
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

          // 当前心率大显示
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: statusInfo['color'].withOpacity(0.1),
                    spreadRadius: 2,
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
                border: Border.all(
                  color: statusInfo['color'].withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        '$heartRate',
                        style: TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: statusInfo['color'],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'bpm',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: statusInfo['color'].withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: statusInfo['color'].withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          statusInfo['icon'],
                          color: statusInfo['color'],
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          statusInfo['status'],
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: statusInfo['color'],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // 心率统计信息
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  '平均心率',
                  '72',
                  'bpm',
                  const Color(0xFF66BB6A),
                  Icons.timeline_rounded,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  '最高心率',
                  '95',
                  'bpm',
                  const Color(0xFFFF7043),
                  Icons.trending_up_rounded,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  '最低心率',
                  '58',
                  'bpm',
                  const Color(0xFF42A5F5),
                  Icons.trending_down_rounded,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // 健康建议
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.8),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: statusInfo['color'].withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.lightbulb_outline_rounded,
                  color: statusInfo['color'],
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    statusInfo['advice'],
                    style: TextStyle(
                      fontSize: 14,
                      color: statusInfo['color'],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    String unit,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2), width: 1),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: color,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
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
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const SizedBox(width: 2),
              Text(
                unit,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: color.withOpacity(0.7),
                ),
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
