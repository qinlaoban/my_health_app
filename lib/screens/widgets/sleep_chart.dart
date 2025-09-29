import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:health/health.dart';
import '../../services/health_service.dart';
import 'dart:math';

enum TimeRange { day, week, month }

class SleepChart extends StatefulWidget {
  const SleepChart({super.key});

  @override
  State<SleepChart> createState() => _SleepChartState();
}

class _SleepChartState extends State<SleepChart> {
  final HealthService _healthService = HealthService();
  List<FlSpot> _sleepData = [];
  bool _isLoading = true;
  TimeRange _selectedTimeRange = TimeRange.week;

  @override
  void initState() {
    super.initState();
    _loadSleepData();
  }

  Future<void> _loadSleepData() async {
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

      final sleepData = await _healthService.getSleepData(
        startTime: startTime,
        endTime: now,
      );

      if (sleepData.isNotEmpty) {
        setState(() {
          _sleepData = sleepData.asMap().entries.map((entry) {
            final value = (entry.value.value as NumericHealthValue).numericValue
                .toDouble();
            return FlSpot(
              entry.key.toDouble(),
              value / 60,
            ); // Convert minutes to hours
          }).toList();
          _isLoading = false;
        });
      } else {
        // 如果没有真实数据，使用模拟数据
        _generateMockSleepData();
      }
    } catch (e) {
      print('加载睡眠数据失败: $e');
      // 出错时使用模拟数据
      _generateMockSleepData();
    }
  }

  void _generateMockSleepData() {
    final random = Random();
    List<FlSpot> mockData = [];

    int dataPoints;
    switch (_selectedTimeRange) {
      case TimeRange.day:
        dataPoints = 24; // 24小时的数据点
        for (int i = 0; i < dataPoints; i++) {
          // 模拟一天中的睡眠模式，晚上11点到早上7点为主要睡眠时间
          double sleepHours = 0;
          if (i >= 23 || i <= 7) {
            sleepHours = 0.8 + random.nextDouble() * 0.4; // 0.8-1.2小时
          } else if (i >= 13 && i <= 15) {
            // 午休时间
            sleepHours = random.nextDouble() * 0.5; // 0-0.5小时
          }
          mockData.add(FlSpot(i.toDouble(), sleepHours));
        }
        break;

      case TimeRange.week:
        dataPoints = 7; // 7天的数据
        for (int i = 0; i < dataPoints; i++) {
          // 模拟每天的总睡眠时间，6-9小时之间
          double sleepHours = 6.5 + random.nextDouble() * 2.5;
          // 周末可能睡得更多
          if (i == 5 || i == 6) {
            sleepHours += random.nextDouble() * 1.5;
          }
          mockData.add(FlSpot(i.toDouble(), sleepHours));
        }
        break;

      case TimeRange.month:
        dataPoints = 30; // 30天的数据
        for (int i = 0; i < dataPoints; i++) {
          // 模拟每天的总睡眠时间，有一定的波动
          double baseSleep = 7.5;
          double variation = (random.nextDouble() - 0.5) * 3; // -1.5到+1.5小时的变化
          double sleepHours = (baseSleep + variation).clamp(5.0, 10.0);
          mockData.add(FlSpot(i.toDouble(), sleepHours));
        }
        break;
    }

    setState(() {
      _sleepData = mockData;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300, // 增加高度以更好地显示数据
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
        children: <Widget>[
          Row(
            children: [
              Icon(Icons.bedtime, color: Colors.purple[600], size: 24),
              const SizedBox(width: 8),
              const Text(
                '睡眠趋势',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const Spacer(),
              if (!_isLoading && _sleepData.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.purple[50],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '平均: ${(_sleepData.map((e) => e.y).reduce((a, b) => a + b) / _sleepData.length).toStringAsFixed(1)}h',
                    style: TextStyle(
                      color: Colors.purple[700],
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          _buildTimeRangeSelector(),
          const SizedBox(height: 20),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _sleepData.isEmpty
                ? const Center(child: Text('暂无睡眠数据'))
                : LineChart(
                    LineChartData(
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        horizontalInterval: _selectedTimeRange == TimeRange.day
                            ? 0.5
                            : 2,
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
                            interval: _getBottomInterval(),
                            getTitlesWidget: (double value, TitleMeta meta) {
                              return SideTitleWidget(
                                axisSide: meta.axisSide,
                                space: 8,
                                child: Text(
                                  _getBottomTitle(value),
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
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            interval: _selectedTimeRange == TimeRange.day
                                ? 0.5
                                : 2,
                            reservedSize: 45,
                            getTitlesWidget: (double value, TitleMeta meta) {
                              return SideTitleWidget(
                                axisSide: meta.axisSide,
                                child: Text(
                                  '${value.toStringAsFixed(_selectedTimeRange == TimeRange.day ? 1 : 0)}h',
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
                      borderData: FlBorderData(
                        show: true,
                        border: Border.all(color: Colors.grey.withOpacity(0.3)),
                      ),
                      minX: 0,
                      maxX: _sleepData.isNotEmpty ? _sleepData.last.x : 0,
                      minY: 0,
                      maxY: _getMaxY(),
                      lineBarsData: [
                        LineChartBarData(
                          spots: _sleepData,
                          isCurved: true,
                          gradient: LinearGradient(
                            colors: [
                              Colors.purple.withOpacity(0.8),
                              Colors.purple,
                            ],
                          ),
                          barWidth: 3,
                          isStrokeCapRound: true,
                          dotData: FlDotData(
                            show: _sleepData.length <= 30,
                            getDotPainter: (spot, percent, barData, index) {
                              return FlDotCirclePainter(
                                radius: 4,
                                color: Colors.purple,
                                strokeWidth: 2,
                                strokeColor: Colors.white,
                              );
                            },
                          ),
                          belowBarData: BarAreaData(
                            show: true,
                            gradient: LinearGradient(
                              colors: [
                                Colors.purple.withOpacity(0.3),
                                Colors.purple.withOpacity(0.1),
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                          ),
                        ),
                      ],
                      lineTouchData: LineTouchData(
                        touchTooltipData: LineTouchTooltipData(
                          getTooltipColor: (touchedSpot) =>
                              Colors.purple.withOpacity(0.8),
                          getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
                            return touchedBarSpots.map((barSpot) {
                              String timeUnit =
                                  _selectedTimeRange == TimeRange.day
                                  ? '小时'
                                  : '小时';
                              return LineTooltipItem(
                                '${barSpot.y.toStringAsFixed(1)} $timeUnit',
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

  double _getBottomInterval() {
    switch (_selectedTimeRange) {
      case TimeRange.day:
        return 4; // 每4小时显示一个标签
      case TimeRange.week:
        return 1; // 每天显示一个标签
      case TimeRange.month:
        return 5; // 每5天显示一个标签
    }
  }

  String _getBottomTitle(double value) {
    switch (_selectedTimeRange) {
      case TimeRange.day:
        return '${value.toInt()}:00';
      case TimeRange.week:
        const weekdays = ['周一', '周二', '周三', '周四', '周五', '周六', '周日'];
        return weekdays[value.toInt() % 7];
      case TimeRange.month:
        return '${value.toInt() + 1}日';
    }
  }

  double _getMaxY() {
    if (_sleepData.isEmpty) return 12;

    switch (_selectedTimeRange) {
      case TimeRange.day:
        return 2; // 单小时最多2小时睡眠
      case TimeRange.week:
      case TimeRange.month:
        return 12; // 每天最多12小时睡眠
    }
  }

  Widget _buildTimeRangeSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildChoiceChip(TimeRange.week, '周'),
          const SizedBox(width: 8),
          _buildChoiceChip(TimeRange.month, '月'),
        ],
      ),
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
            _loadSleepData();
          });
        }
      },
      selectedColor: Colors.purple,
      backgroundColor: Colors.grey[200],
      showCheckmark: false,
    );
  }
}
