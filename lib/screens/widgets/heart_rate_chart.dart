import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../services/health_service.dart';
import 'package:health/health.dart';
import 'dart:math';

enum TimeRange { day, week, month }

class HeartRateChart extends StatefulWidget {
  const HeartRateChart({super.key});

  @override
  State<HeartRateChart> createState() => _HeartRateChartState();
}

class _HeartRateChartState extends State<HeartRateChart> {
  final HealthService _healthService = HealthService();
  List<FlSpot> _heartRateSpots = [];
  bool _isLoading = true;
  TimeRange _selectedTimeRange = TimeRange.week;

  @override
  void initState() {
    super.initState();
    _loadHeartRateData();
  }

  Future<void> _loadHeartRateData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await _healthService.initialize();

      final now = DateTime.now();
      DateTime startTime;

      switch (_selectedTimeRange) {
        case TimeRange.day:
          startTime = now.subtract(const Duration(days: 1));
          break;
        case TimeRange.week:
          startTime = now.subtract(const Duration(days: 7));
          break;
        case TimeRange.month:
          startTime = now.subtract(const Duration(days: 30));
          break;
      }

      List<HealthDataPoint> heartRateData = await _healthService
          .getHeartRateData(startTime: startTime, endTime: now);

      if (heartRateData.isNotEmpty) {
        // 按时间排序
        heartRateData.sort((a, b) => a.dateTo.compareTo(b.dateTo));

        // 转换为图表数据点
        List<FlSpot> spots = [];
        for (int i = 0; i < heartRateData.length; i++) {
          final point = heartRateData[i];
          if (point.value is NumericHealthValue) {
            final value = (point.value as NumericHealthValue).numericValue
                .toDouble();
            spots.add(FlSpot(i.toDouble(), value));
          }
        }

        setState(() {
          _heartRateSpots = spots;
          _isLoading = false;
        });
      } else {
        // 如果没有真实数据，使用模拟数据
        _generateMockData();
      }
    } catch (e) {
      print('加载心率数据失败: $e');
      // 出错时使用模拟数据
      _generateMockData();
    }
  }

  void _generateMockData() {
    final random = Random();
    List<FlSpot> mockData = [];

    // 基础心率 (静息心率)
    double baseHeartRate = 72.0;

    int dataPoints;
    switch (_selectedTimeRange) {
      case TimeRange.day:
        dataPoints = 24; // 每小时一个数据点
        break;
      case TimeRange.week:
        dataPoints = 7; // 每天一个数据点
        break;
      case TimeRange.month:
        dataPoints = 30; // 每天一个数据点
        break;
    }

    for (int i = 0; i < dataPoints; i++) {
      double heartRate;

      if (_selectedTimeRange == TimeRange.day) {
        // 日视图：模拟一天的心率变化
        double timeOfDay = i / 24.0; // 0-1 表示一天的时间

        if (timeOfDay < 0.25 || timeOfDay > 0.9) {
          // 深夜和凌晨：较低心率 (50-65 bpm)
          heartRate = 50 + random.nextDouble() * 15;
        } else if (timeOfDay >= 0.25 && timeOfDay < 0.5) {
          // 上午：逐渐增加 (65-85 bpm)
          heartRate = 65 + (timeOfDay - 0.25) * 80 + random.nextDouble() * 10;
        } else if (timeOfDay >= 0.5 && timeOfDay < 0.75) {
          // 下午：活跃期 (75-110 bpm)
          heartRate = 75 + random.nextDouble() * 35;
          // 模拟运动时段
          if (i == 14 || i == 18) {
            // 下午2点和6点
            heartRate += 20 + random.nextDouble() * 30; // 运动心率
          }
        } else {
          // 晚上：逐渐降低 (60-80 bpm)
          heartRate = 80 - (timeOfDay - 0.75) * 40 + random.nextDouble() * 10;
        }
      } else {
        // 周视图和月视图：模拟日常心率变化
        heartRate = baseHeartRate + (random.nextDouble() - 0.5) * 30; // ±15 bpm

        // 添加一些趋势性变化
        if (_selectedTimeRange == TimeRange.week) {
          // 周末可能心率稍高（更多活动）
          if (i == 5 || i == 6) {
            // 周六周日
            heartRate += 5 + random.nextDouble() * 10;
          }
        } else if (_selectedTimeRange == TimeRange.month) {
          // 月度数据：添加轻微的周期性变化
          heartRate += sin(i * 0.2) * 8; // 周期性波动
        }
      }

      // 确保心率在合理范围内 (45-180 bpm)
      heartRate = heartRate.clamp(45.0, 180.0);

      mockData.add(FlSpot(i.toDouble(), heartRate));
    }

    setState(() {
      _heartRateSpots = mockData;
      _isLoading = false;
    });

    print('生成了 ${mockData.length} 个心率数据点，范围: ${_selectedTimeRange.name}');
  }

  // 计算Y轴最小值
  double _calculateMinY() {
    if (_heartRateSpots.isEmpty) return 50.0;

    double minValue = _heartRateSpots
        .map((d) => d.y)
        .reduce((a, b) => a < b ? a : b);
    // 向下取整到最近的10的倍数，并减去10作为缓冲
    double minY = (minValue / 10).floor() * 10 - 10;
    return minY.clamp(40.0, 200.0); // 确保在合理范围内
  }

  // 计算Y轴最大值
  double _calculateMaxY() {
    if (_heartRateSpots.isEmpty) return 100.0;

    double maxValue = _heartRateSpots
        .map((d) => d.y)
        .reduce((a, b) => a > b ? a : b);
    // 向上取整到最近的10的倍数，并加上10作为缓冲
    double maxY = (maxValue / 10).ceil() * 10 + 10;
    return maxY.clamp(60.0, 220.0); // 确保在合理范围内
  }

  // 计算Y轴标签间隔
  double _calculateYAxisInterval() {
    if (_heartRateSpots.isEmpty) return 20.0;

    double range = _calculateMaxY() - _calculateMinY();

    // 根据范围动态调整间隔
    if (range <= 40) {
      return 5.0; // 小范围使用5bpm间隔
    } else if (range <= 80) {
      return 10.0; // 中等范围使用10bpm间隔
    } else if (range <= 120) {
      return 20.0; // 大范围使用20bpm间隔
    } else {
      return 30.0; // 很大范围使用30bpm间隔
    }
  }

  // 获取心率区间颜色
  Color _getHeartRateZoneColor(double heartRate) {
    if (heartRate < 60) {
      return const Color(0xFF42A5F5); // 蓝色 - 静息心率
    } else if (heartRate < 100) {
      return const Color(0xFF66BB6A); // 绿色 - 正常心率
    } else if (heartRate < 140) {
      return const Color(0xFFFFCA28); // 黄色 - 中等强度
    } else {
      return const Color(0xFFFF5722); // 橙红色 - 高强度
    }
  }

  // 计算平均心率
  double _getAverageHeartRate() {
    if (_heartRateSpots.isEmpty) return 0.0;
    double sum = _heartRateSpots.map((spot) => spot.y).reduce((a, b) => a + b);
    return sum / _heartRateSpots.length;
  }

  // 获取最高心率
  double _getMaxHeartRate() {
    if (_heartRateSpots.isEmpty) return 0.0;
    return _heartRateSpots
        .map((spot) => spot.y)
        .reduce((a, b) => a > b ? a : b);
  }

  // 获取最低心率
  double _getMinHeartRate() {
    if (_heartRateSpots.isEmpty) return 0.0;
    return _heartRateSpots
        .map((spot) => spot.y)
        .reduce((a, b) => a < b ? a : b);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 350, // 增加高度以容纳更多内容
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
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
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 添加标题栏和统计信息
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '心率趋势',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              if (_heartRateSpots.isNotEmpty)
                Text(
                  '平均: ${_getAverageHeartRate().toInt()} bpm',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.red[600],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),

          // 心率统计信息
          if (_heartRateSpots.isNotEmpty)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatChip('最低', '${_getMinHeartRate().toInt()}', const Color(0xFF4FC3F7)), // 浅蓝色
                _buildStatChip('平均', '${_getAverageHeartRate().toInt()}', const Color(0xFF66BB6A)), // 绿色
                _buildStatChip('最高', '${_getMaxHeartRate().toInt()}', const Color(0xFFFF7043)), // 橙红色
              ],
            ),
          const SizedBox(height: 12),

          _buildTimeRangeSelector(),
          const SizedBox(height: 16),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _heartRateSpots.isEmpty
                ? const Center(
                    child: Text(
                      '暂无心率数据\n请在 iPhone 健康应用中添加心率数据',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                : LineChart(
                    LineChartData(
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        horizontalInterval: _calculateYAxisInterval(),
                        getDrawingHorizontalLine: (value) {
                          return FlLine(
                            color: Colors.grey.withOpacity(0.2),
                            strokeWidth: 1,
                          );
                        },
                      ),
                      titlesData: FlTitlesData(
                        show: true,
                        rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 30,
                            interval: _heartRateSpots.length > 10
                                ? (_heartRateSpots.length / 5).ceilToDouble()
                                : 2,
                            getTitlesWidget: (double value, TitleMeta meta) {
                              if (value.toInt() >= 0 &&
                                  value.toInt() < _heartRateSpots.length) {
                                String label;
                                switch (_selectedTimeRange) {
                                  case TimeRange.day:
                                    label = '${value.toInt()}h';
                                    break;
                                  case TimeRange.week:
                                    label = '${value.toInt() + 1}日';
                                    break;
                                  case TimeRange.month:
                                    label = '${value.toInt() + 1}日';
                                    break;
                                }
                                return Text(
                                  label,
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 10,
                                  ),
                                );
                              }
                              return const Text('');
                            },
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            interval: _calculateYAxisInterval(),
                            reservedSize: 65, // 增加左侧空间以容纳更长的标签
                            getTitlesWidget: (double value, TitleMeta meta) {
                              return SideTitleWidget(
                                axisSide: meta.axisSide,
                                child: Text(
                                  '${value.toInt()}',
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 10,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      minX: 0,
                      maxX: (_heartRateSpots.length - 1).toDouble(),
                      minY: _calculateMinY(),
                      maxY: _calculateMaxY(),
                      lineBarsData: [
                        LineChartBarData(
                          spots: _heartRateSpots,
                          isCurved: true,
                          gradient: LinearGradient(
                            colors: [
                              const Color(0xFFE91E63), // 粉红色
                              const Color(0xFFAD1457), // 深粉红色
                            ],
                          ),
                          barWidth: 3,
                          isStrokeCapRound: true,
                          dotData: FlDotData(
                            show: true,
                            getDotPainter: (spot, percent, barData, index) {
                              return FlDotCirclePainter(
                                radius: 4,
                                color: _getHeartRateZoneColor(spot.y),
                                strokeWidth: 2,
                                strokeColor: Colors.white,
                              );
                            },
                          ),
                          belowBarData: BarAreaData(
                            show: true,
                            gradient: LinearGradient(
                              colors: [
                                const Color(0xFFE91E63).withOpacity(0.2), // 浅粉红色
                                const Color(0xFFE91E63).withOpacity(0.05), // 极浅粉红色
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                          ),
                        ),
                      ],
                      lineTouchData: LineTouchData(
                        touchTooltipData: LineTouchTooltipData(
                          getTooltipColor: (touchedSpot) => const Color(0xFF263238).withOpacity(0.9), // 深灰色背景
                          getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
                            return touchedBarSpots.map((barSpot) {
                              String zone = '';
                              if (barSpot.y < 60) {
                                zone = ' (静息)';
                              } else if (barSpot.y < 100) {
                                zone = ' (正常)';
                              } else if (barSpot.y < 140) {
                                zone = ' (中等)';
                              } else {
                                zone = ' (高强度)';
                              }
                              return LineTooltipItem(
                                '${barSpot.y.toInt()} bpm$zone',
                                const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              );
                            }).toList();
                          },
                        ),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  // 构建统计信息芯片
  Widget _buildStatChip(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeRangeSelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildChoiceChip(TimeRange.day, '日'),
        const SizedBox(width: 8),
        _buildChoiceChip(TimeRange.week, '周'),
        const SizedBox(width: 8),
        _buildChoiceChip(TimeRange.month, '月'),
      ],
    );
  }

  Widget _buildChoiceChip(TimeRange range, String label) {
    final isSelected = _selectedTimeRange == range;
    return ChoiceChip(
      label: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : Colors.black,
          fontWeight: FontWeight.bold,
        ),
      ),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          setState(() {
            _selectedTimeRange = range;
            _loadHeartRateData();
          });
        }
      },
      selectedColor: Colors.red,
      backgroundColor: Colors.grey[200],
      showCheckmark: false,
    );
  }
}
