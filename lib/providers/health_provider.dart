import 'package:flutter/material.dart';

class HealthProvider extends ChangeNotifier {
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
  }
  
  // 添加医疗记录
  void addMedicalRecord(MedicalRecord record) {
    _medicalRecords.add(record);
    notifyListeners();
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
}