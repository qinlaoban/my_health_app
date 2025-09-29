import 'package:flutter/material.dart';

class BiomarkerRangeIndicator extends StatelessWidget {
  final int normalCount;
  final int moderateCount;
  final int focusCount;
  final int totalCount;

  const BiomarkerRangeIndicator({
    Key? key,
    required this.normalCount,
    required this.moderateCount,
    required this.focusCount,
    required this.totalCount,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // 彩色圆点指示器
          Row(
            children: [
              // 第一行圆点
              Expanded(
                child: Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  children: [
                    // 正常范围的圆点 (绿色)
                    ...List.generate(
                      normalCount,
                      (index) => _buildDot(const Color(0xFF4ECDC4)),
                    ),
                    // 中等范围的圆点 (黄色)
                    ...List.generate(
                      moderateCount,
                      (index) => _buildDot(const Color(0xFFFFE66D)),
                    ),
                    // 需要关注的圆点 (红色)
                    ...List.generate(
                      focusCount,
                      (index) => _buildDot(const Color(0xFFFF6B6B)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // 范围说明 - 使用Wrap避免溢出
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildRangeLabel('Ranges:', null, null),
              _buildRangeLabel('$normalCount', const Color(0xFF4ECDC4), null),
              _buildRangeLabel('$moderateCount', const Color(0xFFFFE66D), null),
              _buildRangeLabel('$focusCount', const Color(0xFFFF6B6B), null),
              Text(
                '$totalCount biomarkers',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDot(Color color) {
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _buildRangeLabel(String text, Color? color, String? label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (color != null) ...[
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 4),
        ],
        Text(
          text,
          style: TextStyle(
            fontSize: 14,
            fontWeight: color != null ? FontWeight.w600 : FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        if (label != null) ...[
          const SizedBox(width: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
        ],
      ],
    );
  }
}

// 简化版的范围指示器，只显示圆点
class SimpleBiomarkerIndicator extends StatelessWidget {
  final int normalCount;
  final int moderateCount;
  final int focusCount;

  const SimpleBiomarkerIndicator({
    Key? key,
    required this.normalCount,
    required this.moderateCount,
    required this.focusCount,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 3,
      runSpacing: 3,
      children: [
        // 正常范围的圆点 (绿色)
        ...List.generate(
          normalCount,
          (index) => _buildDot(const Color(0xFF4ECDC4)),
        ),
        // 中等范围的圆点 (黄色)
        ...List.generate(
          moderateCount,
          (index) => _buildDot(const Color(0xFFFFE66D)),
        ),
        // 需要关注的圆点 (红色)
        ...List.generate(
          focusCount,
          (index) => _buildDot(const Color(0xFFFF6B6B)),
        ),
      ],
    );
  }

  Widget _buildDot(Color color) {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}