import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/app_settings_provider.dart';
import '../providers/health_provider.dart';
import '../providers/reminder_provider.dart';
import '../models/reminder_models.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appSettings = context.watch<AppSettingsProvider>();
    final health = context.read<HealthProvider>();
    final reminders = context.read<ReminderProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('设置'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        backgroundColor: const Color(0xFF0569F1),
      ),
      body: ListView(
        children: [
          const ListTile(title: Text('外观')),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: [
                const Text('主题模式'),
                const Spacer(),
                DropdownButton<ThemeMode>(
                  value: appSettings.themeMode,
                  items: const [
                    DropdownMenuItem(
                      value: ThemeMode.system,
                      child: Text('跟随系统'),
                    ),
                    DropdownMenuItem(
                      value: ThemeMode.light,
                      child: Text('浅色'),
                    ),
                    DropdownMenuItem(
                      value: ThemeMode.dark,
                      child: Text('深色'),
                    ),
                  ],
                  onChanged: (mode) {
                    if (mode != null) {
                      context.read<AppSettingsProvider>().setThemeMode(mode);
                    }
                  },
                ),
              ],
            ),
          ),
          const Divider(),

          const ListTile(title: Text('数据工具')),
          ListTile(
            leading: const Icon(Icons.copy_all),
            title: const Text('导出数据到剪贴板'),
            subtitle: const Text('包括提醒、健康记录、医疗记录'),
            onTap: () async {
              final data = {
                'reminders': reminders.reminders.map((e) => e.toJson()).toList(),
                'healthRecords': health.healthRecords.map((e) => e.toJson()).toList(),
                'medicalRecords': health.medicalRecords.map((e) => e.toJson()).toList(),
              };
              final raw = const JsonEncoder.withIndent('  ').convert(data);
              await Clipboard.setData(ClipboardData(text: raw));
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('已复制到剪贴板')),
                );
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.refresh),
            title: const Text('重置示例数据'),
            subtitle: const Text('清空现有数据并写入示例'),
            onTap: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('确认重置'),
                  content: const Text('此操作将清空并写入示例数据，是否继续？'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('取消')),
                    ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('确定')),
                  ],
                ),
              );
              if (confirm != true) return;

              // 示例健康记录
              final now = DateTime.now();
              health.replaceHealthRecords([
                HealthRecord(date: now.subtract(const Duration(days: 1)), heartRate: 72, bloodPressureSystolic: 118, bloodPressureDiastolic: 76),
                HealthRecord(date: now.subtract(const Duration(days: 2)), weight: 65.0, notes: '晚饭后散步'),
              ]);
              health.replaceMedicalRecords([
                MedicalRecord(date: now.subtract(const Duration(days: 30)), title: '体检报告', description: '常规体检，无异常', hospital: '市人民医院'),
              ]);

              // 示例提醒
              reminders.replaceReminders([
                Reminder(
                  id: 'ex1',
                  title: '喝水提醒',
                  type: ReminderType.hydration,
                  time: const TimeOfDay(hour: 10, minute: 0),
                  notes: '每天8杯水',
                ),
                Reminder(
                  id: 'ex2',
                  title: '运动提醒',
                  type: ReminderType.exercise,
                  time: const TimeOfDay(hour: 18, minute: 30),
                  notes: '晚饭后快走30分钟',
                ),
              ]);

              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('已重置示例数据')),
                );
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete_forever),
            title: const Text('清空所有数据'),
            subtitle: const Text('提醒、健康记录、医疗记录全部清除'),
            onTap: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('确认清空'),
                  content: const Text('此操作不可撤销，是否继续？'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('取消')),
                    ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('确定')),
                  ],
                ),
              );
              if (confirm != true) return;

              health.replaceHealthRecords([]);
              health.replaceMedicalRecords([]);
              reminders.replaceReminders([]);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('已清空所有数据')),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}