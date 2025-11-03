import 'package:flutter/material.dart';
import 'dart:convert';

/// 提醒类型
enum ReminderType { hydration, medication, exercise, sleep }

/// 健康提醒模型
class Reminder {
  final String id;
  final String title;
  final ReminderType type;
  final TimeOfDay time;
  final List<int> daysOfWeek; // 0=周一 ... 6=周日
  final String? notes;
  final bool enabled;

  const Reminder({
    required this.id,
    required this.title,
    required this.type,
    required this.time,
    this.daysOfWeek = const [0, 1, 2, 3, 4, 5, 6],
    this.notes,
    this.enabled = true,
  });

  Reminder copyWith({
    String? id,
    String? title,
    ReminderType? type,
    TimeOfDay? time,
    List<int>? daysOfWeek,
    String? notes,
    bool? enabled,
  }) {
    return Reminder(
      id: id ?? this.id,
      title: title ?? this.title,
      type: type ?? this.type,
      time: time ?? this.time,
      daysOfWeek: daysOfWeek ?? this.daysOfWeek,
      notes: notes ?? this.notes,
      enabled: enabled ?? this.enabled,
    );
  }

  /// 便于显示的类型图标
  IconData get icon {
    switch (type) {
      case ReminderType.hydration:
        return Icons.water_drop_outlined;
      case ReminderType.medication:
        return Icons.medication_outlined;
      case ReminderType.exercise:
        return Icons.directions_run_outlined;
      case ReminderType.sleep:
        return Icons.bedtime_outlined;
    }
  }

  /// 类型颜色
  Color get color {
    switch (type) {
      case ReminderType.hydration:
        return Colors.blue;
      case ReminderType.medication:
        return Colors.green;
      case ReminderType.exercise:
        return Colors.orange;
      case ReminderType.sleep:
        return Colors.purple;
    }
  }

  // 序列化
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'type': _typeToString(type),
      'time': {'hour': time.hour, 'minute': time.minute},
      'daysOfWeek': daysOfWeek,
      'notes': notes,
      'enabled': enabled,
    };
  }

  static Reminder fromJson(Map<String, dynamic> json) {
    final t = json['time'] as Map<String, dynamic>;
    return Reminder(
      id: json['id'] as String,
      title: json['title'] as String,
      type: _stringToType(json['type'] as String),
      time: TimeOfDay(hour: t['hour'] as int, minute: t['minute'] as int),
      daysOfWeek: (json['daysOfWeek'] as List<dynamic>?)
              ?.map((e) => e as int)
              .toList() ??
          const [0, 1, 2, 3, 4, 5, 6],
      notes: json['notes'] as String?,
      enabled: json['enabled'] as bool? ?? true,
    );
  }

  static String _typeToString(ReminderType t) {
    switch (t) {
      case ReminderType.hydration:
        return 'hydration';
      case ReminderType.medication:
        return 'medication';
      case ReminderType.exercise:
        return 'exercise';
      case ReminderType.sleep:
        return 'sleep';
    }
  }

  static ReminderType _stringToType(String s) {
    switch (s) {
      case 'hydration':
        return ReminderType.hydration;
      case 'medication':
        return ReminderType.medication;
      case 'exercise':
        return ReminderType.exercise;
      case 'sleep':
        return ReminderType.sleep;
      default:
        return ReminderType.hydration;
    }
  }
}