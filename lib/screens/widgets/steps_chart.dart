import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:health/health.dart';
import '../../services/health_service.dart';

enum TimeRange { week, month }

class StepsChart extends StatefulWidget {
  const StepsChart({super.key});

  @override
  State<StepsChart> createState() => _StepsChartState();
}

class _StepsChartState extends State<StepsChart> {
  final HealthService _healthService = HealthService();
  List<BarChartGroupData> _stepsData = [];
  bool _isLoading = true;
  TimeRange _selectedTimeRange = TimeRange.week;

  @override
  void initState() {
    super.initState();
    _loadStepsData();
  }

  Future<void> _loadStepsData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await _healthService.initialize();

      final now = DateTime.now();
      DateTime startTime;

      switch (_selectedTimeRange) {
        case TimeRange.week:
          startTime = now.subtract(const Duration(days: 7));
          break;
        case TimeRange.month:
          startTime = now.subtract(const Duration(days: 30));
          break;
      }

      final steps = await _healthService.getStepsData(startTime: startTime, endTime: now);

      setState(() {
        _stepsData = steps.asMap().entries.map((entry) {
          return BarChartGroupData(
            x: entry.key,
            barRods: [
              BarChartRodData(
                toY: (entry.value.value as NumericHealthValue).numericValue.toDouble(),
                gradient: LinearGradient(
                  colors: [
                    Colors.orange.withOpacity(0.8),
                    Colors.orange,
                  ],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
                width: 20,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(4),
                  topRight: Radius.circular(4),
                ),
              ),
            ],
          );
        }).toList();
        _isLoading = false;
      });
    } catch (e) {
      print('加载步数数据失败: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 250,
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
          _buildTimeRangeSelector(),
          const SizedBox(height: 20),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _stepsData.isEmpty
                    ? const Center(child: Text('暂无步数数据'))
                    : BarChart(
                        BarChartData(
                          alignment: BarChartAlignment.spaceAround,
                          maxY: _stepsData.isNotEmpty ? _stepsData.map((d) => d.barRods.first.toY).reduce((a, b) => a > b ? a : b) * 1.2 : 10000,
                          barTouchData: BarTouchData(
                            touchTooltipData: BarTouchTooltipData(
                              getTooltipColor: (group) => Colors.orange.withOpacity(0.8),
                              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                                return BarTooltipItem(
                                  '${rod.toY.round()} 步',
                                  const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                );
                              },
                            ),
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
                                getTitlesWidget: (double value, TitleMeta meta) {
                                  const style = TextStyle(
                                    color: Colors.grey,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  );
                                  return SideTitleWidget(
                                    axisSide: meta.axisSide,
                                    space: 16,
                                    child: Text(value.toInt().toString(), style: style),
                                  );
                                },
                                reservedSize: 42,
                              ),
                            ),
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 50,
                                interval: _stepsData.isNotEmpty ? _stepsData.map((d) => d.barRods.first.toY).reduce((a, b) => a > b ? a : b) / 4 : 2500,
                                getTitlesWidget: (double value, TitleMeta meta) {
                                  return Text(
                                    '${(value / 1000).toStringAsFixed(0)}k',
                                    style: const TextStyle(
                                      color: Colors.grey,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 10,
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                          borderData: FlBorderData(show: false),
                          barGroups: _stepsData,
                          gridData: FlGridData(
                            show: true,
                            drawVerticalLine: false,
                            horizontalInterval: _stepsData.isNotEmpty ? _stepsData.map((d) => d.barRods.first.toY).reduce((a, b) => a > b ? a : b) / 4 : 2500,
                            getDrawingHorizontalLine: (value) {
                              return FlLine(
                                color: Colors.grey.withOpacity(0.2),
                                strokeWidth: 1,
                              );
                            },
                          ),
                        ),
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
            _loadStepsData();
          });
        }
      },
      selectedColor: Colors.orange,
      backgroundColor: Colors.grey[200],
      showCheckmark: false,
    );
  }
}