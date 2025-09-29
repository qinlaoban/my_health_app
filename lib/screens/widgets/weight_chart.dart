import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:health/health.dart';
import 'dart:math';
import '../../services/health_service.dart';

enum TimeRange { day, week, month }

class WeightChart extends StatefulWidget {
  const WeightChart({super.key});

  @override
  State<WeightChart> createState() => _WeightChartState();
}

class _WeightChartState extends State<WeightChart> {
  final HealthService _healthService = HealthService();
  List<FlSpot> _weightData = [];
  bool _isLoading = true;
  TimeRange _selectedTimeRange = TimeRange.week; // 默认选择周视图

  @override
  void initState() {
    super.initState();
    // 直接生成模拟数据，确保能看到图表
    _weightData = _generateMockWeightData();
    _isLoading = false;
    // _loadWeightData(); // 暂时注释掉真实数据加载
  }

  Future<void> _loadWeightData() async {
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

      final weightData = await _healthService.getWeightData(startTime: startTime, endTime: now);

      setState(() {
        if (weightData.isNotEmpty) {
          _weightData = weightData.asMap().entries.map((entry) {
            final value = (entry.value.value as NumericHealthValue).numericValue.toDouble();
            return FlSpot(entry.key.toDouble(), value);
          }).toList();
        } else {
          // 如果没有真实数据，生成模拟数据
          _weightData = _generateMockWeightData();
        }
        _isLoading = false;
      });
    } catch (e) {
      print('加载体重数据失败: $e');
      // 出错时也使用模拟数据
      setState(() {
        _weightData = _generateMockWeightData();
        _isLoading = false;
      });
    }
  }

  List<FlSpot> _generateMockWeightData() {
    final random = Random();
    List<FlSpot> mockData = [];
    
    // 基础体重
    double baseWeight = 70.0;
    
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
      // 生成轻微波动的体重数据 (±2kg范围内)
      double variation = (random.nextDouble() - 0.5) * 4; // -2 到 +2
      double weight = baseWeight + variation;
      
      // 添加一些趋势性变化
      if (_selectedTimeRange == TimeRange.month) {
        // 月度数据显示轻微下降趋势
        weight -= (i * 0.05);
      }
      
      // 确保体重在合理范围内 (60-85kg)
      weight = weight.clamp(60.0, 85.0);
      
      mockData.add(FlSpot(i.toDouble(), weight));
    }
    
    print('生成了 ${mockData.length} 个体重数据点'); // 添加调试信息
    return mockData;
  }

  // 计算Y轴最小值
  double _calculateMinY() {
    if (_weightData.isEmpty) return 60.0;
    
    double minValue = _weightData.map((d) => d.y).reduce((a, b) => a < b ? a : b);
    // 向下取整到最近的5的倍数，并减去5作为缓冲
    double minY = (minValue / 5).floor() * 5 - 5;
    return minY.clamp(40.0, 100.0); // 确保在合理范围内
  }

  // 计算Y轴最大值
  double _calculateMaxY() {
    if (_weightData.isEmpty) return 80.0;
    
    double maxValue = _weightData.map((d) => d.y).reduce((a, b) => a > b ? a : b);
    // 向上取整到最近的5的倍数，并加上5作为缓冲
    double maxY = (maxValue / 5).ceil() * 5 + 5;
    return maxY.clamp(60.0, 150.0); // 确保在合理范围内
  }

  // 计算Y轴标签间隔
  double _calculateYAxisInterval() {
    if (_weightData.isEmpty) return 5.0;
    
    double range = _calculateMaxY() - _calculateMinY();
    
    // 根据范围动态调整间隔
    if (range <= 10) {
      return 1.0; // 小范围使用1kg间隔
    } else if (range <= 20) {
      return 2.0; // 中等范围使用2kg间隔
    } else if (range <= 40) {
      return 5.0; // 大范围使用5kg间隔
    } else {
      return 10.0; // 很大范围使用10kg间隔
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300, // 增加高度以容纳更多内容
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
          // 添加标题栏
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '体重趋势',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              if (_weightData.isNotEmpty)
                Text(
                  '当前: ${_weightData.last.y.toStringAsFixed(1)} kg',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.green[600],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          _buildTimeRangeSelector(),
          const SizedBox(height: 20),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _weightData.isEmpty
                    ? const Center(child: Text('暂无体重数据'))
                    : LineChart(
                        LineChartData(
                          gridData: FlGridData(
                            show: true,
                            drawVerticalLine: false,
                            horizontalInterval: _calculateYAxisInterval(), // 使用动态间隔
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
                                interval: _weightData.length > 10 ? (_weightData.length / 5).ceil().toDouble() : 1,
                                getTitlesWidget: (double value, TitleMeta meta) {
                                  if (value.toInt() >= 0 && value.toInt() < _weightData.length) {
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
                                reservedSize: 60, // 增加左侧空间以容纳更长的标签
                                getTitlesWidget: (double value, TitleMeta meta) {
                                  return SideTitleWidget(
                                    axisSide: meta.axisSide,
                                    child: Text(
                                      '${value.toStringAsFixed(1)}kg',
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
                          maxX: (_weightData.length - 1).toDouble(),
                          minY: _calculateMinY(),
                          maxY: _calculateMaxY(),
                          lineBarsData: [
                            LineChartBarData(
                              spots: _weightData,
                              isCurved: true,
                              gradient: LinearGradient(
                                colors: [
                                  Colors.green.withOpacity(0.8),
                                  Colors.green,
                                ],
                              ),
                              barWidth: 3,
                              isStrokeCapRound: true,
                              dotData: FlDotData(
                                show: true,
                                getDotPainter: (spot, percent, barData, index) {
                                  return FlDotCirclePainter(
                                    radius: 4,
                                    color: Colors.green,
                                    strokeWidth: 2,
                                    strokeColor: Colors.white,
                                  );
                                },
                              ),
                              belowBarData: BarAreaData(
                                show: true,
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.green.withOpacity(0.3),
                                    Colors.green.withOpacity(0.1),
                                  ],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ),
                              ),
                            ),
                          ],
                          lineTouchData: LineTouchData(
                            touchTooltipData: LineTouchTooltipData(
                              getTooltipColor: (touchedSpot) => Colors.green.withOpacity(0.8),
                              getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
                                return touchedBarSpots.map((barSpot) {
                                  return LineTooltipItem(
                                    '${barSpot.y.toStringAsFixed(1)} kg',
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
            // 重新生成对应时间范围的模拟数据
            _weightData = _generateMockWeightData();
          });
        }
      },
      selectedColor: Colors.green,
      backgroundColor: Colors.grey[200],
      showCheckmark: false,
    );
  }
}