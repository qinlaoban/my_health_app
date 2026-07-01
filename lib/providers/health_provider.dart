import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/health_models.dart';
import '../services/health_service.dart';

class HealthProvider extends ChangeNotifier {
  static const _prefsHealthKey = 'health_records';
  static const _prefsMedicalKey = 'medical_records';
  final HealthService _healthService = HealthService();
  bool _loaded = false;
  bool _healthKitAvailable = false;

  // 用户基本信息
  String _userName = '用户';
  int _age = 25;
  double _height = 170.0;
  double _weight = 65.0;

  // 健康数据
  List<HealthRecord> _healthRecords = [];
  List<MedicalRecord> _medicalRecords = [];

  // HealthKit 实时数据缓存
  int _todaySteps = 0;
  double _sleepHours = 0;
  double? _latestWeight;
  double _heartRate = 0;
  Map<String, double?> _bloodPressure = {'systolic': null, 'diastolic': null};
  bool _isSyncing = false;

  // Getters
  String get userName => _userName;
  int get age => _age;
  double get height => _height;
  double get weight => _weight;
  List<HealthRecord> get healthRecords => _healthRecords;
  List<MedicalRecord> get medicalRecords => _medicalRecords;
  int get todaySteps => _todaySteps;
  double get sleepHours => _sleepHours;
  double? get latestWeight => _latestWeight;
  double get heartRate => _heartRate;
  Map<String, double?> get bloodPressure => _bloodPressure;
  bool get isSyncing => _isSyncing;
  bool get healthKitAvailable => _healthKitAvailable;

  double get bmi => _weight / ((_height / 100) * (_height / 100));

  void updateUserInfo({String? name, int? age, double? height, double? weight}) {
    if (name != null) _userName = name;
    if (age != null) _age = age;
    if (height != null) _height = height;
    if (weight != null) _weight = weight;
    notifyListeners();
  }

  void addHealthRecord(HealthRecord record) {
    _healthRecords.add(record);
    notifyListeners();
    _persist();
  }

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

  /// 从 HealthKit 同步数据
  Future<void> syncFromHealthKit() async {
    _isSyncing = true;
    notifyListeners();

    try {
      _healthKitAvailable = await _healthService.initialize();
      if (!_healthKitAvailable) {
        _isSyncing = false;
        notifyListeners();
        return;
      }

      final results = await Future.wait([
        _healthService.getTodaySteps(),
        _healthService.getTodaySleepHours(),
        _healthService.getLatestWeight(),
        _healthService.getLatestBloodPressure(),
      ]);

      _todaySteps = results[0] as int;
      _sleepHours = results[1] as double;
      _latestWeight = results[2] as double?;
      _bloodPressure = results[3] as Map<String, double?>;

      // 创建一个新的健康记录
      final now = DateTime.now();
      addHealthRecord(HealthRecord(
        date: now,
        weight: _latestWeight,
        bloodPressureSystolic: _bloodPressure['systolic'],
        bloodPressureDiastolic: _bloodPressure['diastolic'],
        notes: 'HealthKit 同步',
      ));
    } catch (e) {
      debugPrint('HealthKit 同步失败: $e');
    }

    _isSyncing = false;
    notifyListeners();
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
