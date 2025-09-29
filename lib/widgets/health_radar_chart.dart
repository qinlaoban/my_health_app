import 'package:flutter/material.dart';
import 'dart:math' as math;

class HealthRadarChart extends StatefulWidget {
  final Map<String, double> healthData;
  final double size;
  
  const HealthRadarChart({
    super.key,
    required this.healthData,
    this.size = 280,
  });

  @override
  State<HealthRadarChart> createState() => _HealthRadarChartState();
}

class _HealthRadarChartState extends State<HealthRadarChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  bool _showDetails = false;
  String? _selectedDimension;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleDetails() {
    setState(() {
      _showDetails = !_showDetails;
    });
  }

  void _showDimensionDetails(String dimension) {
    setState(() {
      _selectedDimension = dimension;
    });
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildDetailBottomSheet(dimension),
    );
  }

  Widget _buildDetailBottomSheet(String dimension) {
    final dimensions = _getHealthDimensions();
    final dimensionInfo = dimensions[dimension];
    final value = widget.healthData[dimension] ?? 0;
    final score = _calculateDimensionScore(dimension, value);
    
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: dimensionInfo!['color'].withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getDimensionIcon(dimension),
                  color: dimensionInfo['color'],
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      dimensionInfo['label'],
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      _getDimensionDescription(dimension),
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '当前数值',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${value.toStringAsFixed(1)} ${_getDimensionUnit(dimension)}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '健康评分',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: _getScoreColor(score).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${score.toStringAsFixed(0)}分',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: _getScoreColor(score),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                LinearProgressIndicator(
                  value: score / 100,
                  backgroundColor: Colors.grey.shade200,
                  valueColor: AlwaysStoppedAnimation<Color>(dimensionInfo['color']),
                ),
                const SizedBox(height: 8),
                Text(
                  _getScoreAdvice(dimension, score),
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '健康评估',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getScoreColor(_calculateOverallScore()).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${_calculateOverallScore().toStringAsFixed(0)}分',
                        style: TextStyle(
                          fontSize: 14,
                          color: _getScoreColor(_calculateOverallScore()),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: _toggleDetails,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          _showDetails ? Icons.visibility_off : Icons.visibility,
                          size: 16,
                          color: Colors.blue.shade600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            GestureDetector(
               onTap: () {
                 showDialog(
                   context: context,
                   builder: (context) => _buildDataDialog(),
                 );
               },
               onLongPress: () {
                 ScaffoldMessenger.of(context).showSnackBar(
                   SnackBar(
                     content: Text('长按查看详细数据，点击查看完整报告'),
                     duration: const Duration(seconds: 2),
                     behavior: SnackBarBehavior.floating,
                   ),
                 );
               },
               child: Tooltip(
                 message: '点击查看详细数据\n长按显示提示信息',
                 child: AnimatedBuilder(
                   animation: _animation,
                   builder: (context, child) {
                     return CustomPaint(
                       size: Size(widget.size, widget.size),
                       painter: RadarChartPainter(
                         healthData: widget.healthData,
                         animationValue: _animation.value,
                         onDimensionTap: _showDimensionDetails,
                       ),
                     );
                   },
                 ),
               ),
             ),
            if (_showDetails) ...[
              const SizedBox(height: 16),
              _buildQuickStats(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDataDialog() {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '健康数据详情',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: () {
                    if (Navigator.of(context).canPop()) {
                      Navigator.of(context).pop();
                    }
                  },
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...widget.healthData.entries.map((entry) {
              final dimensions = _getHealthDimensions();
              final dimensionInfo = dimensions[entry.key];
              final score = _calculateDimensionScore(entry.key, entry.value);
              
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      _getDimensionIcon(entry.key),
                      color: dimensionInfo!['color'],
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            dimensionInfo['label'],
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            '${entry.value.toStringAsFixed(1)} ${_getDimensionUnit(entry.key)}',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getScoreColor(score).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '${score.toStringAsFixed(0)}分',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: _getScoreColor(score),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
           ),
         ),
       );
     }

  Widget _buildQuickStats() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('优秀', _getScoreCount(80, 100), Colors.green),
          _buildStatItem('良好', _getScoreCount(60, 79), Colors.orange),
          _buildStatItem('需改善', _getScoreCount(0, 59), Colors.red),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, int count, Color color) {
    return Column(
      children: [
        Text(
          count.toString(),
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  int _getScoreCount(double min, double max) {
    int count = 0;
    for (final entry in widget.healthData.entries) {
      final score = _calculateDimensionScore(entry.key, entry.value);
      if (score >= min && score <= max) {
        count++;
      }
    }
    return count;
  }

  IconData _getDimensionIcon(String dimension) {
    switch (dimension) {
      case 'steps':
        return Icons.directions_walk;
      case 'heartRate':
        return Icons.favorite;
      case 'sleep':
        return Icons.bedtime;
      case 'water':
        return Icons.water_drop;
      case 'nutrition':
        return Icons.restaurant;
      case 'stress':
        return Icons.psychology;
      default:
        return Icons.health_and_safety;
    }
  }

  String _getDimensionUnit(String dimension) {
    switch (dimension) {
      case 'steps':
        return '步';
      case 'heartRate':
        return 'bpm';
      case 'sleep':
        return '小时';
      case 'water':
        return '升';
      case 'nutrition':
        return '分';
      case 'stress':
        return '分';
      default:
        return '';
    }
  }

  String _getDimensionDescription(String dimension) {
    switch (dimension) {
      case 'steps':
        return '每日步数反映运动活跃度';
      case 'heartRate':
        return '静息心率健康指标';
      case 'sleep':
        return '每日睡眠时长质量';
      case 'water':
        return '每日水分摄入量';
      case 'nutrition':
        return '营养摄入均衡度';
      case 'stress':
        return '压力水平管理';
      default:
        return '健康指标';
    }
  }

  String _getScoreAdvice(String dimension, double score) {
    if (score >= 80) {
      return '表现优秀，继续保持！';
    } else if (score >= 60) {
      return '表现良好，还有提升空间';
    } else {
      switch (dimension) {
        case 'steps':
          return '建议增加日常运动量，目标每日10000步';
        case 'heartRate':
          return '建议进行有氧运动改善心率';
        case 'sleep':
          return '建议保持7-9小时优质睡眠';
        case 'water':
          return '建议每日饮水2.5升以上';
        case 'nutrition':
          return '建议均衡饮食，多吃蔬果';
        case 'stress':
          return '建议进行放松训练，减少压力';
        default:
          return '建议咨询专业医生';
      }
    }
  }

  Map<String, Map<String, dynamic>> _getHealthDimensions() {
    return {
      'steps': {
        'label': '运动',
        'color': Colors.orange.shade600,
      },
      'heartRate': {
        'label': '心率',
        'color': Colors.red.shade600,
      },
      'sleep': {
        'label': '睡眠',
        'color': Colors.purple.shade600,
      },
      'water': {
        'label': '水分',
        'color': Colors.blue.shade600,
      },
      'nutrition': {
        'label': '营养',
        'color': Colors.green.shade600,
      },
      'stress': {
        'label': '压力',
        'color': Colors.amber.shade600,
      },
    };
  }

  double _calculateOverallScore() {
    double totalScore = 0;
    int count = 0;
    
    for (final entry in widget.healthData.entries) {
      totalScore += _calculateDimensionScore(entry.key, entry.value);
      count++;
    }
    
    return count > 0 ? totalScore / count : 0;
  }

  double _calculateDimensionScore(String dimension, double value) {
    switch (dimension) {
      case 'steps':
        return math.min(100, (value / 10000) * 100);
      case 'heartRate':
        final optimal = 75;
        final deviation = (value - optimal).abs();
        return math.max(0, 100 - deviation * 2);
      case 'sleep':
        if (value >= 7 && value <= 9) {
          return 100;
        } else if (value >= 6 && value <= 10) {
          return 80;
        } else {
          return math.max(0, 60 - (value - 8).abs() * 10);
        }
      case 'water':
        return math.min(100, (value / 2.5) * 100);
      case 'nutrition':
        return math.min(100, value);
      case 'stress':
        return math.max(0, 100 - value * 2);
      default:
        return math.min(100, value);
    }
  }

  Color _getScoreColor(double score) {
    if (score >= 80) return Colors.green;
    if (score >= 60) return Colors.orange;
    return Colors.red;
  }
}

class RadarChartPainter extends CustomPainter {
  final Map<String, double> healthData;
  final double animationValue;
  final Function(String)? onDimensionTap;

  RadarChartPainter({
    required this.healthData,
    required this.animationValue,
    this.onDimensionTap,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 40;

    _drawGrid(canvas, center, radius);
    _drawAxes(canvas, center, radius);
    _drawLabels(canvas, center, radius);
    _drawDataArea(canvas, center, radius);
  }

  Map<String, Map<String, dynamic>> _getHealthDimensions() {
    return {
      'steps': {
        'label': '运动',
        'color': Colors.orange.shade600,
      },
      'heartRate': {
        'label': '心率',
        'color': Colors.red.shade600,
      },
      'sleep': {
        'label': '睡眠',
        'color': Colors.purple.shade600,
      },
      'water': {
        'label': '水分',
        'color': Colors.blue.shade600,
      },
      'nutrition': {
        'label': '营养',
        'color': Colors.green.shade600,
      },
      'stress': {
        'label': '压力',
        'color': Colors.amber.shade600,
      },
    };
  }

  void _drawGrid(Canvas canvas, Offset center, double radius) {
    final gridPaint = Paint()
      ..color = Colors.grey.shade200
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    for (int i = 1; i <= 4; i++) {
      final gridRadius = radius * i / 4;
      canvas.drawCircle(center, gridRadius, gridPaint);
    }
  }

  void _drawAxes(Canvas canvas, Offset center, double radius) {
    final axisPaint = Paint()
      ..color = Colors.grey.shade300
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final dimensions = _getHealthDimensions();
    final angleStep = 2 * math.pi / dimensions.length;

    for (int i = 0; i < dimensions.length; i++) {
      final angle = i * angleStep - math.pi / 2;
      final endPoint = Offset(
        center.dx + radius * math.cos(angle),
        center.dy + radius * math.sin(angle),
      );
      canvas.drawLine(center, endPoint, axisPaint);
    }
  }

  void _drawLabels(Canvas canvas, Offset center, double radius) {
    final dimensions = _getHealthDimensions();
    final angleStep = 2 * math.pi / dimensions.length;
    final entries = dimensions.entries.toList();

    for (int i = 0; i < entries.length; i++) {
      final angle = i * angleStep - math.pi / 2;
      final labelRadius = radius + 30;
      final labelPoint = Offset(
        center.dx + labelRadius * math.cos(angle),
        center.dy + labelRadius * math.sin(angle),
      );

      final textPainter = TextPainter(
        text: TextSpan(
          text: entries[i].value['label'],
          style: TextStyle(
            color: entries[i].value['color'],
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();

      final textOffset = Offset(
        labelPoint.dx - textPainter.width / 2,
        labelPoint.dy - textPainter.height / 2,
      );
      textPainter.paint(canvas, textOffset);
    }
  }

  void _drawDataArea(Canvas canvas, Offset center, double radius) {
    final dimensions = _getHealthDimensions();
    final angleStep = 2 * math.pi / dimensions.length;
    final entries = dimensions.entries.toList();

    final path = Path();
    final points = <Offset>[];

    for (int i = 0; i < entries.length; i++) {
      final dimension = entries[i].key;
      final value = healthData[dimension] ?? 0;
      final score = _calculateDimensionScore(dimension, value);
      final normalizedScore = (score / 100) * animationValue;
      
      final angle = i * angleStep - math.pi / 2;
      final point = Offset(
        center.dx + radius * normalizedScore * math.cos(angle),
        center.dy + radius * normalizedScore * math.sin(angle),
      );
      points.add(point);

      if (i == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }
    path.close();

    // 绘制填充区域
    final fillPaint = Paint()
      ..color = Colors.blue.withOpacity(0.2)
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, fillPaint);

    // 绘制边框
    final strokePaint = Paint()
      ..color = Colors.blue.shade600
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;
    canvas.drawPath(path, strokePaint);

    // 绘制数据点
    final pointPaint = Paint()
      ..color = Colors.blue.shade700
      ..style = PaintingStyle.fill;

    for (final point in points) {
      canvas.drawCircle(point, 3, pointPaint);
    }
  }

  double _calculateDimensionScore(String dimension, double value) {
    switch (dimension) {
      case 'steps':
        return math.min(100, (value / 10000) * 100);
      case 'heartRate':
        final optimal = 75;
        final deviation = (value - optimal).abs();
        return math.max(0, 100 - deviation * 2);
      case 'sleep':
        if (value >= 7 && value <= 9) {
          return 100;
        } else if (value >= 6 && value <= 10) {
          return 80;
        } else {
          return math.max(0, 60 - (value - 8).abs() * 10);
        }
      case 'water':
        return math.min(100, (value / 2.5) * 100);
      case 'nutrition':
        return math.min(100, value);
      case 'stress':
        return math.max(0, 100 - value * 2);
      default:
        return math.min(100, value);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}