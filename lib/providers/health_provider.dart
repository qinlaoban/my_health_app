import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class HealthProvider extends ChangeNotifier {
  static const _prefsHealthKey = 'health_records';
  static const _prefsMedicalKey = 'medical_records';
  bool _loaded = false;
  // 用户基本信息
  String _userName = '用户';
  int _age = 25;
  double _height = 170.0; // cm
  double _weight = 65.0; // kg
  
  // 健康数据
  List<HealthRecord> _healthRecords = [];
  List<MedicalRecord> _medicalRecords = [];
  
  // Getters
  String get userName => _userName;
  int get age => _age;
  double get height => _height;
  double get weight => _weight;
  List<HealthRecord> get healthRecords => _healthRecords;
  List<MedicalRecord> get medicalRecords => _medicalRecords;
  
  // BMI计算
  double get bmi => _weight / ((_height / 100) * (_height / 100));
  
  // 更新用户信息
  void updateUserInfo({String? name, int? age, double? height, double? weight}) {
    if (name != null) _userName = name;
    if (age != null) _age = age;
    if (height != null) _height = height;
    if (weight != null) _weight = weight;
    notifyListeners();
  }
  
  // 添加健康记录
  void addHealthRecord(HealthRecord record) {
    _healthRecords.add(record);
    notifyListeners();
    _persist();
  }
  
  // 添加医疗记录
  void addMedicalRecord(MedicalRecord record) {
    _medicalRecords.add(record);
    notifyListeners();
    _persist();
  }

  void replaceHealthRecords(List<HealthRecord> list) {
    _healthRecords = List.from(list);
    notifyListeners();
    _persist();
  }

  void replaceMedicalRecords(List<MedicalRecord> list) {
    _medicalRecords = List.from(list);
    notifyListeners();
    _persist();
  }

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final healthJson = prefs.getString(_prefsHealthKey);
    final medicalJson = prefs.getString(_prefsMedicalKey);

    if (healthJson != null) {
      final List<dynamic> list = jsonDecode(healthJson);
      _healthRecords = list
          .map((e) => HealthRecord.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    if (medicalJson != null) {
      final List<dynamic> list = jsonDecode(medicalJson);
      _medicalRecords = list
          .map((e) => MedicalRecord.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    _loaded = true;
    notifyListeners();
  }

  Future<void> _persist() async {
    if (!_loaded) return;
    final prefs = await SharedPreferences.getInstance();
    final healthJson =
        jsonEncode(_healthRecords.map((e) => e.toJson()).toList());
    final medicalJson =
        jsonEncode(_medicalRecords.map((e) => e.toJson()).toList());
    await prefs.setString(_prefsHealthKey, healthJson);
    await prefs.setString(_prefsMedicalKey, medicalJson);
  }
}

// 健康记录模型
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