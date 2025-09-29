import 'package:flutter/material.dart';
import 'dart:math' as math;

class ScatterChartScreen extends StatefulWidget {
  const ScatterChartScreen({super.key});

  @override
  State<ScatterChartScreen> createState() => _ScatterChartScreenState();
}

class _ScatterChartScreenState extends State<ScatterChartScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  double _scale = 1.0;
  double _baseScale = 1.0;
  int _selectedTabIndex = 0; // 添加选中的tab索引

  // 平移相关状态变量
  Offset _offset = Offset.zero;
  Offset _baseOffset = Offset.zero;
  Offset _startFocalPoint = Offset.zero;
  Offset? _initialFocalPoint; // 初始焦点位置，用于更精确的缩放

  final List<HealthBubble> healthData = [
    HealthBubble(
      name: 'Cholesterol',
      value: '30%',
      impact: 'Impact',
      x: 0.15,
      y: 0.6,
      size: 120,
      color: Colors.orange,
    ),
    HealthBubble(
      name: 'Fasting\nglucose',
      value: '10%',
      impact: 'Impact',
      x: 0.5,
      y: 0.25,
      size: 80,
      color: Colors.green,
    ),
    HealthBubble(
      name: 'hs-CRP',
      value: '6%',
      impact: 'Impact',
      x: 0.65,
      y: 0.45,
      size: 70,
      color: Colors.orange,
    ),
    HealthBubble(
      name: 'HDL\ncholesterol',
      value: '28%',
      impact: 'Impact',
      x: 0.7,
      y: 0.75,
      size: 100,
      color: Colors.green,
    ),
    HealthBubble(
      name: 'Vitamin\nD',
      value: '4%',
      impact: 'Impact',
      x: 0.85,
      y: 0.15,
      size: 50,
      color: Colors.green,
    ),
    HealthBubble(
      name: 'Triglycerides',
      value: '<1%',
      impact: 'Impact',
      x: 0.9,
      y: 0.35,
      size: 40,
      color: Colors.green,
    ),
    // 新增的气泡数据
    HealthBubble(
      name: 'Blood\nPressure',
      value: '15%',
      impact: 'High Risk',
      x: 0.25,
      y: 0.3,
      size: 90,
      color: Colors.red,
    ),
    HealthBubble(
      name: 'BMI',
      value: '8%',
      impact: 'Normal',
      x: 0.4,
      y: 0.65,
      size: 65,
      color: Colors.blue,
    ),
    HealthBubble(
      name: 'Heart\nRate',
      value: '12%',
      impact: 'Good',
      x: 0.8,
      y: 0.55,
      size: 75,
      color: Colors.green,
    ),
    HealthBubble(
      name: 'Insulin',
      value: '22%',
      impact: 'Elevated',
      x: 0.35,
      y: 0.85,
      size: 95,
      color: Colors.orange,
    ),
    HealthBubble(
      name: 'Calcium',
      value: '3%',
      impact: 'Low',
      x: 0.6,
      y: 0.15,
      size: 45,
      color: Colors.red,
    ),
    HealthBubble(
      name: 'Iron',
      value: '7%',
      impact: 'Normal',
      x: 0.15,
      y: 0.25,
      size: 55,
      color: Colors.green,
    ),
    HealthBubble(
      name: 'Protein',
      value: '5%',
      impact: 'Good',
      x: 0.45,
      y: 0.45,
      size: 60,
      color: Colors.blue,
    ),
    HealthBubble(
      name: 'Sodium',
      value: '18%',
      impact: 'High',
      x: 0.75,
      y: 0.25,
      size: 85,
      color: Colors.orange,
    ),
    HealthBubble(
      name: 'Fiber',
      value: '2%',
      impact: 'Low',
      x: 0.55,
      y: 0.8,
      size: 35,
      color: Colors.red,
    ),
    HealthBubble(
      name: 'Omega-3',
      value: '9%',
      impact: 'Good',
      x: 0.25,
      y: 0.45,
      size: 70,
      color: Colors.green,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
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
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0569F1),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: const BoxDecoration(
                color: Color(0xFFFFB800),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.favorite, color: Colors.white, size: 16),
            ),
            const SizedBox(width: 8),
            const Text(
              '健康散点图',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // 标签栏
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedTabIndex = 0;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: _selectedTabIndex == 0
                          ? Colors.black
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Text(
                      'Health Insights',
                      style: TextStyle(
                        color: _selectedTabIndex == 0
                            ? Colors.white
                            : Colors.grey,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedTabIndex = 1;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: _selectedTabIndex == 1
                          ? Colors.black
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Text(
                      'Recommendations',
                      style: TextStyle(
                        color: _selectedTabIndex == 1
                            ? Colors.white
                            : Colors.grey,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // 内容区域 - 根据选中的tab显示不同内容
          Expanded(
            child: _selectedTabIndex == 0
                ? _buildHealthInsightsView()
                : _buildRecommendationsView(),
          ),
        ],
      ),
    );
  }

  Widget _buildHealthBubble(HealthBubble bubble, int index) {
    final screenSize = MediaQuery.of(context).size;
    final bubbleSize = bubble.size.toDouble();
    final isSelected = false; // 暂时设为false，后续可以添加选中逻辑

    return Positioned(
      left: bubble.x * screenSize.width - bubbleSize / 2,
      top: bubble.y * screenSize.height - bubbleSize / 2,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(bubbleSize / 2),
          onTap: () {
            // 点击事件处理
          },
          child: Container(
            width: bubbleSize,
            height: bubbleSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              border: Border.all(color: bubble.color, width: 2),
            ),
            child: Padding(
              padding: EdgeInsets.all(bubbleSize * 0.06),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 根据气泡大小动态调整显示内容
                  if (bubbleSize >= 80) ...[
                    // 大气泡显示完整信息
                    Flexible(
                      child: Text(
                        bubble.name,
                        style: TextStyle(
                          fontSize: (bubbleSize * 0.12).clamp(8.0, 16.0),
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(height: bubbleSize * 0.02),
                    Flexible(
                      child: Text(
                        bubble.value,
                        style: TextStyle(
                          fontSize: (bubbleSize * 0.16).clamp(10.0, 20.0),
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (bubbleSize >= 100)
                      Flexible(
                        child: Text(
                          bubble.impact,
                          style: TextStyle(
                            fontSize: (bubbleSize * 0.08).clamp(6.0, 12.0),
                            color: Colors.grey[600],
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                  ] else if (bubbleSize >= 60) ...[
                    // 中等气泡显示名称和数值
                    Flexible(
                      child: Text(
                        bubble.name.length > 8
                            ? bubble.name.substring(0, 8) + '...'
                            : bubble.name,
                        style: TextStyle(
                          fontSize: (bubbleSize * 0.14).clamp(8.0, 12.0),
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(height: bubbleSize * 0.03),
                    Flexible(
                      child: Text(
                        bubble.value,
                        style: TextStyle(
                          fontSize: (bubbleSize * 0.18).clamp(8.0, 14.0),
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ] else ...[
                    // 小气泡只显示数值
                    Flexible(
                      child: Text(
                        bubble.value,
                        style: TextStyle(
                          fontSize: (bubbleSize * 0.25).clamp(8.0, 12.0),
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // 构建健康洞察视图（原散点图）
  Widget _buildHealthInsightsView() {
    return GestureDetector(
      onScaleStart: (details) {
        setState(() {
          _baseScale = _scale;
          _baseOffset = _offset;
          _startFocalPoint = details.focalPoint;
          // 记录初始焦点位置，用于更精确的焦点缩放
          _initialFocalPoint = details.focalPoint;
        });
      },
      onScaleUpdate: (details) {
        setState(() {
          final screenSize = MediaQuery.of(context).size;

          if (details.pointerCount > 1) {
            // 双指缩放 - 优化的iOS风格焦点缩放
            final newScale = (_baseScale * details.scale).clamp(0.3, 5.0);

            // 使用初始焦点位置进行更稳定的缩放计算
            final focalPoint = _initialFocalPoint ?? details.focalPoint;

            // 计算焦点在原始内容坐标系中的位置（基于初始状态）
            final contentFocalPoint = Offset(
              (focalPoint.dx - _baseOffset.dx) / _baseScale,
              (focalPoint.dy - _baseOffset.dy) / _baseScale,
            );

            // 更新缩放比例
            _scale = newScale;

            // 重新计算偏移，确保焦点位置在屏幕上保持不变
            _offset = Offset(
              focalPoint.dx - contentFocalPoint.dx * _scale,
              focalPoint.dy - contentFocalPoint.dy * _scale,
            );
          } else {
            // 单指拖动 - 使用相对位移
            final deltaOffset = details.focalPoint - _startFocalPoint;
            _offset = _baseOffset + deltaOffset;
          }

          // iOS风格的宽松边界限制 - 允许用户查看所有放大的内容
          // 计算内容的实际边界（考虑气泡大小和额外的浏览空间）
          double minX = double.infinity, maxX = double.negativeInfinity;
          double minY = double.infinity, maxY = double.negativeInfinity;

          for (final bubble in healthData) {
            final bubbleRadius = bubble.size / 2;
            final bubbleLeft = bubble.x * screenSize.width - bubbleRadius;
            final bubbleRight = bubble.x * screenSize.width + bubbleRadius;
            final bubbleTop = bubble.y * screenSize.height - bubbleRadius;
            final bubbleBottom = bubble.y * screenSize.height + bubbleRadius;

            minX = math.min(minX, bubbleLeft);
            maxX = math.max(maxX, bubbleRight);
            minY = math.min(minY, bubbleTop);
            maxY = math.max(maxY, bubbleBottom);
          }

          // 添加额外的浏览边距，让用户可以看到边缘内容
          final extraMargin =
              math.max(screenSize.width, screenSize.height) * 0.5;
          minX -= extraMargin;
          maxX += extraMargin;
          minY -= extraMargin;
          maxY += extraMargin;

          // 缩放后的内容边界
          final scaledMinX = minX * _scale;
          final scaledMaxX = maxX * _scale;
          final scaledMinY = minY * _scale;
          final scaledMaxY = maxY * _scale;

          // iOS风格的边界限制：允许内容超出屏幕边界，但不要过度
          final minOffsetX = screenSize.width - scaledMaxX;
          final maxOffsetX = -scaledMinX;
          final minOffsetY = screenSize.height - scaledMaxY;
          final maxOffsetY = -scaledMinY;

          // 确保边界值的正确性，避免min > max的情况
          final safeMinOffsetX = math.min(minOffsetX, maxOffsetX);
          final safeMaxOffsetX = math.max(minOffsetX, maxOffsetX);
          final safeMinOffsetY = math.min(minOffsetY, maxOffsetY);
          final safeMaxOffsetY = math.max(minOffsetY, maxOffsetY);

          _offset = Offset(
            _offset.dx.clamp(safeMinOffsetX, safeMaxOffsetX),
            _offset.dy.clamp(safeMinOffsetY, safeMaxOffsetY),
          );
        });
      },
      onScaleEnd: (details) {
        // 清除初始焦点位置，为下次缩放做准备
        _initialFocalPoint = null;
      },
      child: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.blue[50]!, Colors.purple[50]!, Colors.pink[50]!],
          ),
        ),
        child: ClipRect(child: _buildBubbleCanvas()),
      ),
    );
  }

  // 独立的气泡画布组件
  Widget _buildBubbleCanvas() {
    return Transform(
      transform: Matrix4.identity()
        ..translate(_offset.dx, _offset.dy)
        ..scale(_scale),
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          final screenSize = MediaQuery.of(context).size;
          return SizedBox(
            width: screenSize.width,
            height: screenSize.height,
            child: Stack(
              clipBehavior: Clip.none, // 允许子元素超出边界
              children: [
                // Health bubbles
                ...healthData.asMap().entries.map((entry) {
                  final index = entry.key;
                  final bubble = entry.value;
                  return _buildHealthBubble(bubble, index);
                }).toList(),
              ],
            ),
          );
        },
      ),
    );
  }

  // 构建推荐建议视图（简单列表）
  Widget _buildRecommendationsView() {
    final recommendations = [
      {
        'title': '降低胆固醇',
        'description': '建议减少饱和脂肪摄入，增加纤维食物',
        'priority': 'high',
        'icon': Icons.favorite,
      },
      {
        'title': '控制血压',
        'description': '每天进行30分钟有氧运动，减少钠摄入',
        'priority': 'high',
        'icon': Icons.monitor_heart,
      },
      {
        'title': '改善胰岛素敏感性',
        'description': '规律作息，避免高糖食物',
        'priority': 'medium',
        'icon': Icons.schedule,
      },
      {
        'title': '补充维生素D',
        'description': '增加户外活动时间，适当补充维生素D',
        'priority': 'medium',
        'icon': Icons.wb_sunny,
      },
      {
        'title': '增加纤维摄入',
        'description': '多吃蔬菜、水果和全谷物食品',
        'priority': 'low',
        'icon': Icons.eco,
      },
      {
        'title': '补充Omega-3',
        'description': '每周食用2-3次深海鱼类',
        'priority': 'low',
        'icon': Icons.set_meal,
      },
    ];

    return Container(
      color: Colors.grey[100],
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: recommendations.length,
        itemBuilder: (context, index) {
          final recommendation = recommendations[index];
          final priorityColor = recommendation['priority'] == 'high'
              ? Colors.red
              : recommendation['priority'] == 'medium'
              ? Colors.orange
              : Colors.green;

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: priorityColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    recommendation['icon'] as IconData,
                    color: priorityColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        recommendation['title'] as String,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        recommendation['description'] as String,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: priorityColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    recommendation['priority'] == 'high'
                        ? '高'
                        : recommendation['priority'] == 'medium'
                        ? '中'
                        : '低',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: priorityColor,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class HealthBubble {
  final String name;
  final String value;
  final String impact;
  final Color color;
  final double x;
  final double y;
  final double size;

  HealthBubble({
    required this.name,
    required this.value,
    required this.impact,
    required this.color,
    required this.x,
    required this.y,
    required this.size,
  });
}
