import 'package:flutter/material.dart';

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
}