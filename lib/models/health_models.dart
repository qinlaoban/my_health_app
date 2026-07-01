import 'package:flutter/material.dart';

// 健康记录模型（每条记录包含多个指标）
class HealthRecord {
  final DateTime date;
  final double? bloodPressureSystolic;
  final double? bloodPressureDiastolic;
  final double? heartRate;
  final double? bloodSugar;
  final double? weight;
  final String? notes;

  HealthRecord({
    required this.date,
    this.bloodPressureSystolic,
    this.bloodPressureDiastolic,
    this.heartRate,
    this.bloodSugar,
    this.weight,
    this.notes,
  });

  Map<String, dynamic> toJson() => {
        'date': date.toIso8601String(),
        'bloodPressureSystolic': bloodPressureSystolic,
        'bloodPressureDiastolic': bloodPressureDiastolic,
        'heartRate': heartRate,
        'bloodSugar': bloodSugar,
        'weight': weight,
        'notes': notes,
      };

  factory HealthRecord.fromJson(Map<String, dynamic> json) => HealthRecord(
        date: DateTime.parse(json['date'] as String),
        bloodPressureSystolic:
            (json['bloodPressureSystolic'] as num?)?.toDouble(),
        bloodPressureDiastolic:
            (json['bloodPressureDiastolic'] as num?)?.toDouble(),
        heartRate: (json['heartRate'] as num?)?.toDouble(),
        bloodSugar: (json['bloodSugar'] as num?)?.toDouble(),
        weight: (json['weight'] as num?)?.toDouble(),
        notes: json['notes'] as String?,
      );
}

// 医疗记录模型
class MedicalRecord {
  final DateTime date;
  final String title;
  final String description;
  final String? doctor;
  final String? hospital;
  final List<String>? medications;

  MedicalRecord({
    required this.date,
    required this.title,
    required this.description,
    this.doctor,
    this.hospital,
    this.medications,
  });

  Map<String, dynamic> toJson() => {
        'date': date.toIso8601String(),
        'title': title,
        'description': description,
        'doctor': doctor,
        'hospital': hospital,
        'medications': medications,
      };

  factory MedicalRecord.fromJson(Map<String, dynamic> json) => MedicalRecord(
        date: DateTime.parse(json['date'] as String),
        title: json['title'] as String,
        description: json['description'] as String,
        doctor: json['doctor'] as String?,
        hospital: json['hospital'] as String?,
        medications: (json['medications'] as List?)
            ?.map((e) => e as String)
            .toList(),
      );
}

// 健康气泡数据模型（用于散点图）
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
