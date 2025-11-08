import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/reminder_models.dart';

class ReminderProvider extends ChangeNotifier {
  final List<Reminder> _reminders = [
    Reminder(
      id: 'r1',
      title: '喝水提醒',
      type: ReminderType.hydration,
      time: const TimeOfDay(hour: 10, minute: 0),
      notes: '每天保持饮水充足',
    ),
    Reminder(
      id: 'r2',
      title: '用药提醒',
      type: ReminderType.medication,
      time: const TimeOfDay(hour: 21, minute: 0),
      notes: '睡前服用维生素D',
    ),
  ];

  static const String _prefsKey = 'reminders';
  bool _loaded = false;

  List<Reminder> get reminders => List.unmodifiable(_reminders);

  Future<void> load() async {
    if (_loaded) return;
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefsKey);
    if (raw != null) {
      try {
        final list = (jsonDecode(raw) as List<dynamic>)
            .map((e) => Reminder.fromJson(e as Map<String, dynamic>))
            .toList();
        _reminders
          ..clear()
          ..addAll(list);
      } catch (_) {
        // ignore parse errors, keep defaults
      }
    }
    _loaded = true;
    notifyListeners();
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = jsonEncode(_reminders.map((r) => r.toJson()).toList());
    await prefs.setString(_prefsKey, raw);
  }

  void replaceReminders(List<Reminder> list) {
    _reminders
      ..clear()
      ..addAll(list);
    notifyListeners();
    _persist();
  }

  void addReminder(Reminder reminder) {
    _reminders.add(reminder);
    notifyListeners();
    _persist();
  }

  void removeReminder(String id) {
    _reminders.removeWhere((r) => r.id == id);
    notifyListeners();
    _persist();
  }

  void toggleEnable(String id, bool enabled) {
    final idx = _reminders.indexWhere((r) => r.id == id);
    if (idx != -1) {
      _reminders[idx] = _reminders[idx].copyWith(enabled: enabled);
      notifyListeners();
      _persist();
    }
  }

  void updateReminderTime(String id, TimeOfDay time) {
    final idx = _reminders.indexWhere((r) => r.id == id);
    if (idx != -1) {
      _reminders[idx] = _reminders[idx].copyWith(time: time);
      notifyListeners();
      _persist();
    }
  }

  int get enabledCount => _reminders.where((r) => r.enabled).length;

  // 计算下一次提醒（不考虑周几，仅按当天时间排序，若今天无则取明天最早）
  Reminder? nextReminder() {
    final now = TimeOfDay.fromDateTime(DateTime.now());
    int toMinutes(TimeOfDay t) => t.hour * 60 + t.minute;
    final nowMin = toMinutes(now);
    final enabled = _reminders.where((r) => r.enabled).toList();
    if (enabled.isEmpty) return null;
    enabled.sort((a, b) => toMinutes(a.time).compareTo(toMinutes(b.time)));
    // 今天还未到的第一个
    final todayUpcoming = enabled.firstWhere(
      (r) => toMinutes(r.time) >= nowMin,
      orElse: () => enabled.first,
    );
    return todayUpcoming;
  }
}