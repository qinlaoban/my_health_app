import 'package:flutter/material.dart';
import 'dart:math' as math;

class CircularProgressChart extends StatefulWidget {
  final double percentage;
  final String label;
  final Color color;
  final double size;
  final double strokeWidth;

  const CircularProgressChart({
    Key? key,
    required this.percentage,
    required this.label,
    required this.color,
    this.size = 120,
    this.strokeWidth = 8,
  }) : super(key: key);

  @override
  State<CircularProgressChart> createState() => _CircularProgressChartState();
}

class _CircularProgressChartState extends State<CircularProgressChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: widget.percentage / 100).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 背景圆环
          SizedBox(
            width: widget.size,
            height: widget.size,
            child: CircularProgressIndicator(
              value: 1.0,
              strokeWidth: widget.strokeWidth,
              backgroundColor: Colors.transparent,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.grey.shade200),
            ),
          ),
          // 进度圆环
          AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return SizedBox(
                width: widget.size,
                height: widget.size,
                child: CircularProgressIndicator(
                  value: _animation.value,
                  strokeWidth: widget.strokeWidth,
                  backgroundColor: Colors.transparent,
                  valueColor: AlwaysStoppedAnimation<Color>(widget.color),
                  strokeCap: StrokeCap.round,
                ),
              );
            },
          ),
          // 中心文本
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedBuilder(
                animation: _animation,
                builder: (context, child) {
                  return Text(
                    '${(_animation.value * 100).toStringAsFixed(1)}%',
                    style: TextStyle(
                      fontSize: widget.size * 0.15,
                      fontWeight: FontWeight.bold,
                      color: widget.color,
                    ),
                  );
                },
              ),
              if (widget.label.isNotEmpty)
                Text(
                  widget.label,
                  style: TextStyle(
                    fontSize: widget.size * 0.08,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

// 多色圆环图表组件
class MultiColorCircularChart extends StatefulWidget {
  final List<ChartSegment> segments;
  final double size;
  final double strokeWidth;
  final String centerText;
  final TextStyle? centerTextStyle;
  final Function(int)? onSegmentTap;

  const MultiColorCircularChart({
    Key? key,
    required this.segments,
    this.size = 120,
    this.strokeWidth = 8,
    this.centerText = '',
    this.centerTextStyle,
    this.onSegmentTap,
  }) : super(key: key);

  @override
  State<MultiColorCircularChart> createState() =>
      _MultiColorCircularChartState();
}

class _MultiColorCircularChartState extends State<MultiColorCircularChart>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  int? _selectedSegment;
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.5).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );

    // 默认选中第一个区块（Normal）
    _selectedSegment = 0;
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    if (widget.onSegmentTap == null) return;

    final center = Offset(widget.size / 2, widget.size / 2);
    final tapPosition = details.localPosition;
    final distance = (tapPosition - center).distance;
    final radius = (widget.size - widget.strokeWidth) / 2;

    // 检查点击是否在圆环范围内
    if (distance >= radius - widget.strokeWidth / 2 &&
        distance <= radius + widget.strokeWidth / 2) {
      // 计算点击角度
      final angle = math.atan2(
        tapPosition.dy - center.dy,
        tapPosition.dx - center.dx,
      );

      // 转换角度到0-2π范围，并调整起始位置（顶部开始）
      double normalizedAngle = angle + math.pi / 2;
      if (normalizedAngle < 0) normalizedAngle += 2 * math.pi;

      // 找到对应的区块
      double currentAngle = 0;
      final total = widget.segments.fold<double>(
        0,
        (sum, segment) => sum + segment.value,
      );

      for (int i = 0; i < widget.segments.length; i++) {
        final segmentAngle = (widget.segments[i].value / total) * 2 * math.pi;
        if (normalizedAngle >= currentAngle &&
            normalizedAngle < currentAngle + segmentAngle) {
          setState(() {
            _selectedSegment = i;
          });
          _scaleController.forward().then((_) {
            _scaleController.reverse();
          });
          widget.onSegmentTap!(i);
          break;
        }
        currentAngle += segmentAngle;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      child: SizedBox(
        width: widget.size,
        height: widget.size,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // 背景圆环
            SizedBox(
              width: widget.size,
              height: widget.size,
              child: CircularProgressIndicator(
                value: 1.0,
                strokeWidth: widget.strokeWidth,
                backgroundColor: Colors.transparent,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.grey.shade200),
              ),
            ),
            // 多色进度圆环
            AnimatedBuilder(
              animation: Listenable.merge([_animation, _scaleAnimation]),
              builder: (context, child) {
                return CustomPaint(
                  size: Size(widget.size, widget.size),
                  painter: MultiColorCircularPainter(
                    segments: widget.segments,
                    strokeWidth: widget.strokeWidth,
                    progress: _animation.value,
                    selectedSegment: _selectedSegment,
                    scaleAnimation: _scaleAnimation.value,
                  ),
                );
              },
            ),
            // 中心文本
            AnimatedBuilder(
              animation: _scaleAnimation,
              builder: (context, child) {
                // 如果有选中的区块，显示该区块的信息
                if (_selectedSegment != null &&
                    _selectedSegment! < widget.segments.length) {
                  final selectedSegmentData =
                      widget.segments[_selectedSegment!];
                  final total = widget.segments.fold<double>(
                    0,
                    (sum, segment) => sum + segment.value,
                  );
                  final percentage = (selectedSegmentData.value / total * 100);

                  return AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: Text(
                      key: ValueKey(selectedSegmentData.value),
                      '${selectedSegmentData.value.toStringAsFixed(1)}',
                      style: TextStyle(
                        fontSize: widget.size * 0.14,
                        fontWeight: FontWeight.bold,
                        color: selectedSegmentData.color,
                        letterSpacing: 0.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  );
                }

                // 默认显示第一个区块的数字（Normal区块）
                if (_selectedSegment == null && widget.segments.isNotEmpty) {
                  final defaultSegment = widget.segments[0];
                  return AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: Text(
                      key: ValueKey(defaultSegment.value),
                      '${defaultSegment.value.toStringAsFixed(1)}',
                      style: TextStyle(
                        fontSize: widget.size * 0.14,
                        fontWeight: FontWeight.bold,
                        color: defaultSegment.color,
                        letterSpacing: 0.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  );
                }

                // 如果有自定义中心文本且没有区块数据，显示自定义文本
                if (widget.centerText.isNotEmpty) {
                  return Text(
                    widget.centerText,
                    style:
                        widget.centerTextStyle ??
                        TextStyle(
                          fontSize: widget.size * 0.12,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                          letterSpacing: 0.5,
                        ),
                    textAlign: TextAlign.center,
                  );
                }

                return const SizedBox.shrink();
              },
            ),
          ],
        ),
      ),
    );
  }
}

class ChartSegment {
  final double value;
  final Color color;
  final String label;

  ChartSegment({required this.value, required this.color, required this.label});
}

class MultiColorCircularPainter extends CustomPainter {
  final List<ChartSegment> segments;
  final double strokeWidth;
  final double progress;
  final int? selectedSegment;
  final double scaleAnimation;

  MultiColorCircularPainter({
    required this.segments,
    required this.strokeWidth,
    required this.progress,
    this.selectedSegment,
    this.scaleAnimation = 1.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    double startAngle = -math.pi / 2; // 从顶部开始
    final total = segments.fold<double>(
      0,
      (sum, segment) => sum + segment.value,
    );

    for (int i = 0; i < segments.length; i++) {
      final segment = segments[i];
      final sweepAngle = (segment.value / total) * 2 * math.pi * progress;

      // 如果是选中的区块，调整半径和描边宽度实现向内放大效果
      final isSelected = selectedSegment == i;
      final currentRadius = radius;
      final currentStrokeWidth = isSelected
          ? strokeWidth + (strokeWidth * 0.5 * scaleAnimation)
          : strokeWidth;
      
      final rect = Rect.fromCircle(center: center, radius: currentRadius);

      final paint = Paint()
        ..color = isSelected ? segment.color.withOpacity(0.9) : segment.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = currentStrokeWidth
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(rect, startAngle, sweepAngle, false, paint);

      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
