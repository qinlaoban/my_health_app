import 'package:flutter/material.dart';
import 'dart:math' as math;

class ScatterChartWidget extends StatefulWidget {
  final String selectedMetric;

  const ScatterChartWidget({super.key, required this.selectedMetric});

  @override
  State<ScatterChartWidget> createState() => _ScatterChartWidgetState();
}

class _ScatterChartWidgetState extends State<ScatterChartWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  int? _selectedPointIndex;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(ScatterChartWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedMetric != widget.selectedMetric) {
      _animationController.reset();
      _animationController.forward();
      setState(() {
        _selectedPointIndex = null;
      });
    }
  }

  List<ScatterPoint> _generateSampleData() {
    final random = math.Random(42);
    final List<ScatterPoint> points = [];

    switch (widget.selectedMetric) {
      case 'Blood Pressure vs Heart Rate':
        for (int i = 0; i < 30; i++) {
          final systolic = 90 + random.nextDouble() * 60;
          final heartRate =
              60 + (systolic - 90) * 0.5 + random.nextDouble() * 20;
          points.add(
            ScatterPoint(
              x: systolic,
              y: heartRate,
              label: 'Day ${i + 1}',
              color: _getPointColor(systolic, 90, 150),
            ),
          );
        }
        break;
      case 'Cholesterol vs BMI':
        for (int i = 0; i < 30; i++) {
          final cholesterol = 150 + random.nextDouble() * 100;
          final bmi = 18 + (cholesterol - 150) * 0.08 + random.nextDouble() * 8;
          points.add(
            ScatterPoint(
              x: cholesterol,
              y: bmi,
              label: 'Record ${i + 1}',
              color: _getPointColor(cholesterol, 150, 250),
            ),
          );
        }
        break;
      case 'Glucose vs Weight':
        for (int i = 0; i < 30; i++) {
          final glucose = 70 + random.nextDouble() * 60;
          final weight = 50 + (glucose - 70) * 0.5 + random.nextDouble() * 30;
          points.add(
            ScatterPoint(
              x: glucose,
              y: weight,
              label: 'Test ${i + 1}',
              color: _getPointColor(glucose, 70, 130),
            ),
          );
        }
        break;
      case 'Sleep vs Stress Level':
        for (int i = 0; i < 30; i++) {
          final sleep = 4 + random.nextDouble() * 6;
          final stress = 10 - sleep + random.nextDouble() * 3;
          points.add(
            ScatterPoint(
              x: sleep,
              y: stress,
              label: 'Night ${i + 1}',
              color: _getPointColor(sleep, 4, 10),
            ),
          );
        }
        break;
    }
    return points;
  }

  Color _getPointColor(double value, double min, double max) {
    final normalized = (value - min) / (max - min);
    if (normalized < 0.33) {
      return const Color(0xFF4CAF50); // 绿色 - 良好
    } else if (normalized < 0.66) {
      return const Color(0xFFFF9800); // 橙色 - 中等
    } else {
      return const Color(0xFFF44336); // 红色 - 需关注
    }
  }

  @override
  Widget build(BuildContext context) {
    final points = _generateSampleData();

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return GestureDetector(
          onTapDown: (details) => _handleTap(details.localPosition, points),
          child: CustomPaint(
            painter: ScatterChartPainter(
              points: points,
              animation: _animation.value,
              selectedPointIndex: _selectedPointIndex,
            ),
            size: Size.infinite,
          ),
        );
      },
    );
  }

  void _handleTap(Offset position, List<ScatterPoint> points) {
    const double padding = 60;
    const double bottomPadding = 80;
    const double topPadding = 40;

    final chartWidth = MediaQuery.of(context).size.width - 2 * padding - 32;
    final chartHeight = 400 - bottomPadding - topPadding;

    final minX = points.map((p) => p.x).reduce(math.min);
    final maxX = points.map((p) => p.x).reduce(math.max);
    final minY = points.map((p) => p.y).reduce(math.min);
    final maxY = points.map((p) => p.y).reduce(math.max);

    if (position.dx < padding ||
        position.dx > padding + chartWidth ||
        position.dy < topPadding ||
        position.dy > topPadding + chartHeight) {
      return;
    }

    double minDistance = double.infinity;
    int? nearestIndex;

    for (int i = 0; i < points.length; i++) {
      final point = points[i];
      final x = padding + (point.x - minX) / (maxX - minX) * chartWidth;
      final y =
          topPadding +
          chartHeight -
          (point.y - minY) / (maxY - minY) * chartHeight;

      final distance = math.sqrt(
        math.pow(position.dx - x, 2) + math.pow(position.dy - y, 2),
      );

      if (distance < 25 && distance < minDistance) {
        minDistance = distance;
        nearestIndex = i;
      }
    }

    setState(() {
      _selectedPointIndex = nearestIndex;
    });

    if (nearestIndex != null) {
      _showPointDetails(points[nearestIndex]);
    }
  }

  void _showPointDetails(ScatterPoint point) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            point.label,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: point.color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'X: ${point.x.toStringAsFixed(1)}',
                    style: const TextStyle(fontSize: 14, color: Colors.white70),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: point.color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Y: ${point.y.toStringAsFixed(1)}',
                    style: const TextStyle(fontSize: 14, color: Colors.white70),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                '关闭',
                style: TextStyle(color: Color(0xFF4ECDC4)),
              ),
            ),
          ],
        );
      },
    );
  }
}

class ScatterPoint {
  final double x;
  final double y;
  final String label;
  final Color color;

  ScatterPoint({
    required this.x,
    required this.y,
    required this.label,
    required this.color,
  });
}

class ScatterChartPainter extends CustomPainter {
  final List<ScatterPoint> points;
  final double animation;
  final int? selectedPointIndex;

  ScatterChartPainter({
    required this.points,
    required this.animation,
    this.selectedPointIndex,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;

    const double padding = 60;
    const double bottomPadding = 80;
    const double topPadding = 40;
    
    final chartWidth = size.width - 2 * padding;
    final chartHeight = size.height - bottomPadding - topPadding;

    final minX = points.map((p) => p.x).reduce(math.min);
    final maxX = points.map((p) => p.x).reduce(math.max);
    final minY = points.map((p) => p.y).reduce(math.min);
    final maxY = points.map((p) => p.y).reduce(math.max);

    _drawGrid(canvas, size, padding, topPadding, chartWidth, chartHeight);
    _drawAxes(
      canvas,
      size,
      padding,
      topPadding,
      chartWidth,
      chartHeight,
      minX,
      maxX,
      minY,
      maxY,
    );
    _drawDataPoints(
      canvas,
      padding,
      topPadding,
      chartWidth,
      chartHeight,
      minX,
      maxX,
      minY,
      maxY,
    );
  }

  void _drawGrid(
    Canvas canvas,
    Size size,
    double padding,
    double topPadding,
    double chartWidth,
    double chartHeight,
  ) {
    final gridPaint = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..strokeWidth = 0.5;

    for (int i = 0; i <= 10; i++) {
      final x = padding + (chartWidth / 10) * i;
      canvas.drawLine(
        Offset(x, topPadding),
        Offset(x, topPadding + chartHeight),
        gridPaint,
      );
    }

    for (int i = 0; i <= 8; i++) {
      final y = topPadding + (chartHeight / 8) * i;
      canvas.drawLine(
        Offset(padding, y),
        Offset(padding + chartWidth, y),
        gridPaint,
      );
    }
  }

  void _drawAxes(
    Canvas canvas,
    Size size,
    double padding,
    double topPadding,
    double chartWidth,
    double chartHeight,
    double minX,
    double maxX,
    double minY,
    double maxY,
  ) {
    final axisPaint = Paint()
      ..color = Colors.white.withOpacity(0.2)
      ..strokeWidth = 1;

    canvas.drawLine(
      Offset(padding, topPadding + chartHeight),
      Offset(padding + chartWidth, topPadding + chartHeight),
      axisPaint,
    );

    canvas.drawLine(
      Offset(padding, topPadding),
      Offset(padding, topPadding + chartHeight),
      axisPaint,
    );
  }

  void _drawDataPoints(
    Canvas canvas,
    double padding,
    double topPadding,
    double chartWidth,
    double chartHeight,
    double minX,
    double maxX,
    double minY,
    double maxY,
  ) {
    for (int i = 0; i < points.length; i++) {
      final point = points[i];
      final x = padding + (point.x - minX) / (maxX - minX) * chartWidth;
      final y =
          topPadding +
          chartHeight -
          (point.y - minY) / (maxY - minY) * chartHeight;

      final isSelected = selectedPointIndex == i;
      final baseRadius = isSelected ? 14.0 : 10.0;
      final animatedRadius = baseRadius * animation;

      // 外圈光晕效果
      final glowPaint = Paint()
        ..color = point.color.withOpacity(0.4 * animation)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);

      canvas.drawCircle(Offset(x, y), animatedRadius + 8, glowPaint);

      // 主圆球
      final mainPaint = Paint()
        ..shader =
            RadialGradient(
              colors: [
                point.color.withOpacity(0.9),
                point.color,
                point.color.withOpacity(0.7),
              ],
              stops: const [0.0, 0.7, 1.0],
            ).createShader(
              Rect.fromCircle(center: Offset(x, y), radius: animatedRadius),
            );

      canvas.drawCircle(Offset(x, y), animatedRadius, mainPaint);

      // 高光效果
      final highlightPaint = Paint()
        ..color = Colors.white.withOpacity(0.6)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(
        Offset(x - animatedRadius * 0.25, y - animatedRadius * 0.25),
        animatedRadius * 0.25,
        highlightPaint,
      );

      // 选中状态的脉冲环
      if (isSelected) {
        final ringPaint = Paint()
          ..color = Colors.white.withOpacity(0.8)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3;

        canvas.drawCircle(Offset(x, y), animatedRadius + 6, ringPaint);

        // 内环
        final innerRingPaint = Paint()
          ..color = point.color.withOpacity(0.6)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2;

        canvas.drawCircle(Offset(x, y), animatedRadius + 3, innerRingPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant ScatterChartPainter oldDelegate) {
    return oldDelegate.animation != animation ||
        oldDelegate.selectedPointIndex != selectedPointIndex ||
        oldDelegate.points != points;
  }
}
