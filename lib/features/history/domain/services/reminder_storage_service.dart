import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cozy_feels_app/features/history/domain/entities/reminder.dart';

class ReminderStorageService {
  static const String _remindersKey = 'user_reminders';

  // --- CARGAR RECORDATORIOS ---
  Future<List<Reminder>> loadReminders() async {
    final prefs = await SharedPreferences.getInstance();
    final remindersJson = prefs.getStringList(_remindersKey);

    if (remindersJson == null) return [];

    try {
      return remindersJson.map((jsonStr) {
        final Map<String, dynamic> map = jsonDecode(jsonStr);
        return Reminder.fromMap(map);
      }).toList();
    } catch (e) {
      return [];
    }
  }

  // --- GUARDAR RECORDATORIOS ---
  Future<void> saveReminders(List<Reminder> reminders) async {
    final prefs = await SharedPreferences.getInstance();

    final remindersJson = reminders.map((reminder) {
      return jsonEncode(reminder.toMap());
    }).toList();

    await prefs.setStringList(_remindersKey, remindersJson);
  }
}
