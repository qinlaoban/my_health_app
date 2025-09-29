import 'package:health/health.dart';

class HealthService {
  static final HealthService _instance = HealthService._internal();
  factory HealthService() => _instance;
  HealthService._internal();

  Health? _health;
  bool _isInitialized = false;

  // 支持的健康数据类型
  static const List<HealthDataType> _healthDataTypes = [
    HealthDataType.HEART_RATE,
    HealthDataType.STEPS,
    HealthDataType.WEIGHT,
    HealthDataType.BLOOD_GLUCOSE,
    HealthDataType.BLOOD_PRESSURE_SYSTOLIC,
    HealthDataType.BLOOD_PRESSURE_DIASTOLIC,
    HealthDataType.SLEEP_IN_BED,
    HealthDataType.SLEEP_ASLEEP,
  ];

  // 初始化HealthKit
  Future<bool> initialize() async {
    if (_isInitialized) return true;

    try {
      _health = Health();
      
      // 请求权限
      bool? hasPermissions = await _health?.hasPermissions(_healthDataTypes);
      
      if (hasPermissions != true) {
        hasPermissions = await _health?.requestAuthorization(_healthDataTypes);
      }
      
      _isInitialized = hasPermissions ?? false;
      return _isInitialized;
    } catch (e) {
      print('HealthKit初始化失败: $e');
      return false;
    }
  }

  // 获取心率数据
  Future<List<HealthDataPoint>> getHeartRateData({
    DateTime? startTime,
    DateTime? endTime,
  }) async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      final now = DateTime.now();
      final start = startTime ?? now.subtract(const Duration(days: 7));
      final end = endTime ?? now;

      List<HealthDataPoint> healthData = await _health?.getHealthDataFromTypes(
        types: [HealthDataType.HEART_RATE],
        startTime: start,
        endTime: end,
      ) ?? [];

      return healthData;
    } catch (e) {
      print('获取心率数据失败: $e');
      return [];
    }
  }

  // 获取步数数据
  Future<List<HealthDataPoint>> getStepsData({
    DateTime? startTime,
    DateTime? endTime,
  }) async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      final now = DateTime.now();
      final start = startTime ?? now.subtract(const Duration(days: 7));
      final end = endTime ?? now;

      List<HealthDataPoint> healthData = await _health?.getHealthDataFromTypes(
        types: [HealthDataType.STEPS],
        startTime: start,
        endTime: end,
      ) ?? [];

      return healthData;
    } catch (e) {
      print('获取步数数据失败: $e');
      return [];
    }
  }

  // 获取步数数据
  Future<int> getTodaySteps() async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);

      List<HealthDataPoint> healthData = await _health?.getHealthDataFromTypes(
        types: [HealthDataType.STEPS],
        startTime: startOfDay,
        endTime: now,
      ) ?? [];

      int totalSteps = 0;
      for (var point in healthData) {
        if (point.value is NumericHealthValue) {
          totalSteps += (point.value as NumericHealthValue).numericValue.toInt();
        }
      }

      return totalSteps;
    } catch (e) {
      print('获取步数数据失败: $e');
      return 0;
    }
  }

  // 获取体重数据
  Future<double?> getLatestWeight() async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      final now = DateTime.now();
      final start = now.subtract(const Duration(days: 30));

      List<HealthDataPoint> healthData = await _health?.getHealthDataFromTypes(
        types: [HealthDataType.WEIGHT],
        startTime: start,
        endTime: now,
      ) ?? [];

      if (healthData.isNotEmpty) {
        // 按时间排序，获取最新的体重数据
        healthData.sort((a, b) => b.dateTo.compareTo(a.dateTo));
        final latestWeight = healthData.first;
        
        if (latestWeight.value is NumericHealthValue) {
          return (latestWeight.value as NumericHealthValue).numericValue.toDouble();
        }
      }

      return null;
    } catch (e) {
      print('获取体重数据失败: $e');
      return null;
    }
  }

  // 获取血压数据
  Future<Map<String, List<HealthDataPoint>>> getBloodPressureData({
    DateTime? startTime,
    DateTime? endTime,
  }) async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      final now = DateTime.now();
      final start = startTime ?? now.subtract(const Duration(days: 7));
      final end = endTime ?? now;

      List<HealthDataPoint> systolicData = await _health?.getHealthDataFromTypes(
        types: [HealthDataType.BLOOD_PRESSURE_SYSTOLIC],
        startTime: start,
        endTime: end,
      ) ?? [];

      List<HealthDataPoint> diastolicData = await _health?.getHealthDataFromTypes(
        types: [HealthDataType.BLOOD_PRESSURE_DIASTOLIC],
        startTime: start,
        endTime: end,
      ) ?? [];

      return {
        'systolic': systolicData,
        'diastolic': diastolicData,
      };
    } catch (e) {
      print('获取血压数据失败: $e');
      return {
        'systolic': [],
        'diastolic': [],
      };
    }
  }

  // 获取血压数据
  Future<Map<String, double?>> getLatestBloodPressure() async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      final now = DateTime.now();
      final start = now.subtract(const Duration(days: 7));

      List<HealthDataPoint> systolicData = await _health?.getHealthDataFromTypes(
        types: [HealthDataType.BLOOD_PRESSURE_SYSTOLIC],
        startTime: start,
        endTime: now,
      ) ?? [];

      List<HealthDataPoint> diastolicData = await _health?.getHealthDataFromTypes(
        types: [HealthDataType.BLOOD_PRESSURE_DIASTOLIC],
        startTime: start,
        endTime: now,
      ) ?? [];

      double? systolic;
      double? diastolic;

      if (systolicData.isNotEmpty) {
        systolicData.sort((a, b) => b.dateTo.compareTo(a.dateTo));
        final latest = systolicData.first;
        if (latest.value is NumericHealthValue) {
          systolic = (latest.value as NumericHealthValue).numericValue.toDouble();
        }
      }

      if (diastolicData.isNotEmpty) {
        diastolicData.sort((a, b) => b.dateTo.compareTo(a.dateTo));
        final latest = diastolicData.first;
        if (latest.value is NumericHealthValue) {
          diastolic = (latest.value as NumericHealthValue).numericValue.toDouble();
        }
      }

      return {
        'systolic': systolic,
        'diastolic': diastolic,
      };
    } catch (e) {
      print('获取血压数据失败: $e');
      return {'systolic': null, 'diastolic': null};
    }
  }

  // 获取睡眠数据（小时）
  Future<double> getTodaySleepHours() async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      final now = DateTime.now();
      final yesterday = now.subtract(const Duration(days: 1));
      final startOfYesterday = DateTime(yesterday.year, yesterday.month, yesterday.day, 18); // 从昨天18点开始
      final endOfToday = DateTime(now.year, now.month, now.day, 12); // 到今天12点结束

      List<HealthDataPoint> sleepData = await _health?.getHealthDataFromTypes(
        types: [HealthDataType.SLEEP_ASLEEP],
        startTime: startOfYesterday,
        endTime: endOfToday,
      ) ?? [];

      double totalSleepMinutes = 0;
      for (var point in sleepData) {
        if (point.value is NumericHealthValue) {
          totalSleepMinutes += (point.value as NumericHealthValue).numericValue.toDouble();
        }
      }

      return totalSleepMinutes / 60; // 转换为小时
    } catch (e) {
      print('获取睡眠数据失败: $e');
      return 0;
    }
  }

  // 写入健康数据
  Future<bool> writeHealthData({
    required HealthDataType type,
    required double value,
    DateTime? startTime,
    DateTime? endTime,
  }) async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      final now = DateTime.now();
      final start = startTime ?? now;
      final end = endTime ?? now;

      bool success = await _health?.writeHealthData(
        value: value,
        type: type,
        startTime: start,
        endTime: end,
      ) ?? false;

      return success;
    } catch (e) {
      print('写入健康数据失败: $e');
      return false;
    }
  }

  Future<List<HealthDataPoint>> getSleepData(
      {required DateTime startTime, required DateTime endTime}) async {
    if (!_isInitialized) {
      await initialize();
    }

    final types = [
      HealthDataType.SLEEP_ASLEEP,
    ];

    final requested = await _health!.requestAuthorization(types);

    if (requested) {
      try {
        return await _health!.getHealthDataFromTypes(
            startTime: startTime, endTime: endTime, types: types) ?? [];
      } catch (e) {
        print("Caught exception in getSleepData: $e");
      }
    }
    return [];
  }

  Future<List<HealthDataPoint>> getWeightData(
      {required DateTime startTime, required DateTime endTime}) async {
    if (!_isInitialized) {
      await initialize();
    }

    final types = [
      HealthDataType.WEIGHT,
    ];

    final requested = await _health!.requestAuthorization(types);

    if (requested) {
      try {
        return await _health!.getHealthDataFromTypes(
            startTime: startTime, endTime: endTime, types: types) ?? [];
      } catch (e) {
        print("Caught exception in getWeightData: $e");
      }
    }
    return [];
  }
}