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
  
  // -------- LANGUAGE ----------
  Future<void> saveLanguage(String languageCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language_code', languageCode);
  }

  Future<String?> loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('language_code');
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

  // --- THEME ---
  static const String _themeKey = 'selected_theme_id';

  Future<void> saveTheme(String themeId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeKey, themeId);
  }

  Future<String?> loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_themeKey);
  }

  // --- CLOUD BACKUP ---
  static const String _autoCloudBackupKey = 'auto_cloud_backup_enabled';
  static const String _lastCloudBackupTimeKey = 'last_cloud_backup_time';

  Future<bool> isAutoCloudBackupEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_autoCloudBackupKey) ?? false;
  }

  Future<void> setAutoCloudBackupEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_autoCloudBackupKey, enabled);
  }

  Future<DateTime?> getLastCloudBackupTime() async {
    final prefs = await SharedPreferences.getInstance();
    final timeStr = prefs.getString(_lastCloudBackupTimeKey);
    if (timeStr == null) return null;
    return DateTime.tryParse(timeStr);
  }

  Future<void> setLastCloudBackupTime(DateTime time) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastCloudBackupTimeKey, time.toIso8601String());
  }

  // --- GESTIÓN DE ETIQUETAS (ORDEN, ACTIVAS Y PERSONALIZADAS) ---
  static const String _userTagsKey = 'user_context_tags_order';
  static const String _customTagsKey = 'custom_context_tags';

  static const List<String> defaultTagIds = [
    'work',
    'relationship',
    'family',
    'sleep',
    'study',
    'health',
    'leisure',
    'social',
  ];

  Future<List<String>> loadUserTags() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getStringList(_userTagsKey);
    if (saved != null) {
      return saved;
    }
    // Si no existe pero existían custom tags previas, unirlas
    final legacyCustom = prefs.getStringList(_customTagsKey);
    if (legacyCustom != null && legacyCustom.isNotEmpty) {
      final merged = [...defaultTagIds, ...legacyCustom];
      await prefs.setStringList(_userTagsKey, merged);
      return merged;
    }
    return List<String>.from(defaultTagIds);
  }

  Future<void> saveUserTags(List<String> tags) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_userTagsKey, tags);
  }

  Future<void> addUserTag(String tag) async {
    final trimmed = tag.trim();
    if (trimmed.isEmpty) return;
    final current = await loadUserTags();
    if (!current.contains(trimmed)) {
      current.add(trimmed);
      await saveUserTags(current);
    }
  }

  Future<void> deleteUserTag(String tag) async {
    final current = await loadUserTags();
    if (current.remove(tag.trim())) {
      await saveUserTags(current);
    }
  }

  Future<void> reorderUserTags(int oldIndex, int newIndex) async {
    final current = await loadUserTags();
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final item = current.removeAt(oldIndex);
    current.insert(newIndex, item);
    await saveUserTags(current);
  }

  Future<void> resetDefaultTags() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_userTagsKey, List<String>.from(defaultTagIds));
  }

  Future<List<String>> loadCustomTags() => loadUserTags();
  Future<void> saveCustomTags(List<String> tags) => saveUserTags(tags);
  Future<void> addCustomTag(String tag) => addUserTag(tag);
  Future<void> deleteCustomTag(String tag) => deleteUserTag(tag);
}
