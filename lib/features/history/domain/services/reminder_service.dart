import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../entities/reminder.dart';

class ReminderStorageService {
  static const String _remindersKey = 'user_reminders';

  // --- CARGAR RECORDATORIOS ---
  Future<List<Reminder>> loadReminders() async {
    final prefs = await SharedPreferences.getInstance();
    final remindersJson = prefs.getStringList(_remindersKey);

    if (remindersJson == null) return [];

    return remindersJson.map((jsonStr) {
      final Map<String, dynamic> map = jsonDecode(jsonStr);
      return Reminder(
        id: map['id'] as String,
        hour: map['hour'] as int,
        minute: map['minute'] as int,
        days: List<bool>.from(map['days'] as List),
        isActive: map['isActive'] as bool? ?? true,
      );
    }).toList();
  }

  // --- GUARDAR RECORDATORIOS ---
  Future<void> saveReminders(List<Reminder> reminders) async {
    final prefs = await SharedPreferences.getInstance();

    final remindersJson = reminders.map((reminder) {
      return jsonEncode({
        'id': reminder.id,
        'hour': reminder.hour,
        'minute': reminder.minute,
        'days': reminder.days,
        'isActive': reminder.isActive,
      });
    }).toList();

    await prefs.setStringList(_remindersKey, remindersJson);
  }
}
