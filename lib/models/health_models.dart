import 'package:flutter/material.dart';

// 健康数据模型
class HealthData {
  final DateTime timestamp;
  final double value;
  final String unit;
  final HealthDataType type;

  const HealthData({
    required this.timestamp,
    required this.value,
    required this.unit,
    required this.type,
  });

  Map<String, dynamic> toJson() => {
    'timestamp': timestamp.toIso8601String(),
    'value': value,
    'unit': unit,
    'type': type.name,
  };

  factory HealthData.fromJson(Map<String, dynamic> json) => HealthData(
    timestamp: DateTime.parse(json['timestamp']),
    value: json['value'].toDouble(),
    unit: json['unit'],
    type: HealthDataType.values.byName(json['type']),
  );
}

enum HealthDataType {
  steps,
  heartRate,
  bloodPressure,
  weight,
  sleep,
  bloodGlucose,
}

// 健康气泡数据模型
class HealthBubble {
  final String name;
  final String value;
  final String impact;
  final double x;
  final double y;
  final double size;
  final Color color;

  const HealthBubble({
    required this.name,
    required this.value,
    required this.impact,
    required this.x,
    required this.y,
    this.size = 1.0,
    this.color = Colors.blue,
  });
}

// 用户健康档案
class UserHealthProfile {
  final String id;
  final String name;
  final int age;
  final double height;
  final double weight;
  final String gender;
  final List<String> medicalConditions;
  final List<String> medications;

  const UserHealthProfile({
    required this.id,
    required this.name,
    required this.age,
    required this.height,
    required this.weight,
    required this.gender,
    this.medicalConditions = const [],
    this.medications = const [],
  });

  double get bmi => weight / ((height / 100) * (height / 100));

  String get bmiCategory {
    if (bmi < 18.5) return '偏瘦';
    if (bmi < 24) return '正常';
    if (bmi < 28) return '超重';
    return '肥胖';
  }
}