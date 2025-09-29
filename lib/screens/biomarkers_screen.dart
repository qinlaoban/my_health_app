import 'package:flutter/material.dart';
import '../widgets/circular_progress_chart.dart';
import '../widgets/biomarker_range_indicator.dart';

class BiomarkersScreen extends StatefulWidget {
  const BiomarkersScreen({super.key});

  @override
  State<BiomarkersScreen> createState() => _BiomarkersScreenState();
}

class _BiomarkersScreenState extends State<BiomarkersScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: const Color(0xFF0569F1),
        title: const Text(
          "标记物",
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(Icons.share, color: Colors.black, size: 20),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: BiomarkerRangeIndicator(
                normalCount: 57,
                moderateCount: 18,
                focusCount: 6,
                totalCount: 81,
              ),
            ),
            const SizedBox(height: 24),
            _buildGenomeSection(),
            const SizedBox(height: 24),
            _buildMicrobiomeSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildGenomeSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Genome',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const Spacer(),
              Icon(Icons.arrow_forward_ios, color: Colors.grey[400], size: 16),
            ],
          ),
          const SizedBox(height: 32),
          Center(
            child: MultiColorCircularChart(
              size: 140,
              strokeWidth: 12,
              centerText: '',
              centerTextStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              onSegmentTap: (segmentIndex) {
                // 处理区块点击事件

              },
              segments: [
                ChartSegment(
                  value: 21.3,
                  color: const Color(0xFF4ECDC4),
                  label: 'Normal',
                ),
                ChartSegment(
                  value: 35.0,
                  color: const Color(0xFFFFE66D),
                  label: 'Moderate',
                ),
                ChartSegment(
                  value: 43.7,
                  color: const Color(0xFFFF6B6B),
                  label: 'Focus',
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.rectangle,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'Focus',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMicrobiomeSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(

            children: [
              Expanded(
                child: Row(
                  spacing: 8,
                  children: [
                    Text(
                      'Microbiome',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      'Genera',
                      style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),
              Icon(Icons.arrow_forward_ios, color: Colors.grey[400], size: 16),
            ],
          ),
          const SizedBox(height: 32),
          Center(
            child: CircularProgressChart(
              percentage: 16.6,
              label: '',
              color: const Color(0xFF9B59B6),
              size: 140,
              strokeWidth: 12,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: Colors.purple[300],
                  shape: BoxShape.rectangle,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'Prevotella',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 2),
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: index == 3 ? Colors.grey[600] : Colors.grey[300],
                  shape: BoxShape.circle,
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
