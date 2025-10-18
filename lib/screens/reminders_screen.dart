import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/reminder_provider.dart';
import '../models/reminder_models.dart';

class RemindersScreen extends StatelessWidget {
  const RemindersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('健康提醒'),
        centerTitle: true,
      ),
      body: Consumer<ReminderProvider>(
        builder: (context, provider, child) {
          final reminders = provider.reminders;
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemBuilder: (context, index) {
              final r = reminders[index];
              return ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                leading: CircleAvatar(
                  backgroundColor: r.color.withOpacity(0.15),
                  child: Icon(r.icon, color: r.color),
                ),
                title: Text(r.title),
                subtitle: Text(_formatTime(r.time)),
                trailing: Switch(
                  value: r.enabled,
                  onChanged: (v) => provider.toggleEnable(r.id, v),
                ),
                onTap: () async {
                  final newTime = await _pickTime(context, r.time);
                  if (newTime != null) {
                    provider.updateReminderTime(r.id, newTime);
                  }
                },
              );
            },
            separatorBuilder: (context, _) => const SizedBox(height: 8),
            itemCount: reminders.length,
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddDialog(context),
        label: const Text('添加提醒'),
        icon: const Icon(Icons.add_alert),
      ),
    );
  }

  String _formatTime(TimeOfDay t) {
    final hour = t.hour.toString().padLeft(2, '0');
    final minute = t.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  Future<TimeOfDay?> _pickTime(BuildContext context, TimeOfDay initial) async {
    return showTimePicker(context: context, initialTime: initial);
  }

  void _showAddDialog(BuildContext context) {
    ReminderType type = ReminderType.hydration;
    TimeOfDay time = const TimeOfDay(hour: 10, minute: 0);
    final titleController = TextEditingController(text: '喝水提醒');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
            left: 16,
            right: 16,
            top: 16,
          ),
          child: StatefulBuilder(builder: (context, setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    const Icon(Icons.add_alert_outlined),
                    const SizedBox(width: 8),
                    const Text(
                      '添加提醒',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: '标题',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<ReminderType>(
                        value: type,
                        items: const [
                          DropdownMenuItem(
                            value: ReminderType.hydration,
                            child: Text('喝水'),
                          ),
                          DropdownMenuItem(
                            value: ReminderType.medication,
                            child: Text('用药'),
                          ),
                          DropdownMenuItem(
                            value: ReminderType.exercise,
                            child: Text('运动'),
                          ),
                          DropdownMenuItem(
                            value: ReminderType.sleep,
                            child: Text('睡眠'),
                          ),
                        ],
                        onChanged: (v) => setState(() => type = v!),
                        decoration: const InputDecoration(
                          labelText: '类型',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          final picked = await _pickTime(context, time);
                          if (picked != null) setState(() => time = picked);
                        },
                        icon: const Icon(Icons.access_time),
                        label: Text(_formatTime(time)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      final provider =
                          Provider.of<ReminderProvider>(context, listen: false);
                      final title = titleController.text.trim().isEmpty
                          ? '提醒'
                          : titleController.text.trim();
                      final id = DateTime.now().millisecondsSinceEpoch.toString();
                      provider.addReminder(Reminder(
                        id: id,
                        title: title,
                        type: type,
                        time: time,
                      ));
                      Navigator.pop(context);
                    },
                    child: const Text('保存'),
                  ),
                ),
              ],
            );
          }),
        );
      },
    );
  }
}