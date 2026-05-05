import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../entities/history_entry.dart';

class MoodStorageService {
  static const String _historyKey = 'history';
  static const String _timezoneKey = 'selected_timezone';
  static const String _onboardingKey = 'seen_onboarding';

  // --- HISTORIAL ---
  Future<List<HistoryEntry>> loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final historyJson = prefs.getStringList(_historyKey);
    if (historyJson == null) return [];
    return historyJson
        .map((json) => HistoryEntry.fromJson(jsonDecode(json)))
        .toList();
  }

  Future<void> saveHistory(List<HistoryEntry> history) async {
    final prefs = await SharedPreferences.getInstance();
    final historyJson =
        history.map((entry) => jsonEncode(entry.toJson())).toList();
    await prefs.setStringList(_historyKey, historyJson);
  }

  // --- TIMEZONE ---
  Future<String?> loadTimezone() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_timezoneKey);
  }

  Future<void> saveTimezone(String timezone) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_timezoneKey, timezone);
  }

  // --- ONBOARDING ---
  Future<bool> hasSeenOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_onboardingKey) ?? false;
  }

  Future<void> setOnboardingSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_onboardingKey, true);
  }
}
