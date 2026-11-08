import 'package:cozy_feels_app/core/constants/app_assets.dart';
import 'package:cozy_feels_app/features/history/domain/entities/history_entry.dart';
import 'package:timezone/timezone.dart' as tz;

enum StatsPeriod {
  week,
  month,
  allTime,
}

class MoodStatsSummary {
  final StatsPeriod period;
  final int totalEntries;
  final int currentStreak;
  final int bestStreak;
  final int activeDays;
  final Map<String, int> moodCounts;
  final Map<String, double> moodPercentages;
  final String? dominantMood;
  final List<MapEntry<String, int>> topTags;

  const MoodStatsSummary({
    required this.period,
    required this.totalEntries,
    required this.currentStreak,
    required this.bestStreak,
    required this.activeDays,
    required this.moodCounts,
    required this.moodPercentages,
    this.dominantMood,
    required this.topTags,
  });

  bool get isEmpty => totalEntries == 0;
}

class StatsService {
  static String normalizeMoodPath(String path) {
    if (path.contains('/feelings/')) {
      return path;
    }
    return path.replaceAll('assets/icons/svg/', 'assets/icons/svg/feelings/');
  }

  static String getMoodKey(String path) {
    final normalized = normalizeMoodPath(path);
    for (final entry in AppAssets.sentimentEmojis.entries) {
      if (normalizeMoodPath(entry.value) == normalized) {
        return entry.key;
      }
    }
    final fileName = path
        .split('/')
        .last
        .replaceAll('.svg', '')
        .replaceAll('sentiment_', '');
    if (fileName.isEmpty) return 'Neutral';
    return fileName[0].toUpperCase() + fileName.substring(1);
  }

  static String getLocalizedMoodName(String moodKey, String languageCode) {
    if (languageCode.startsWith('es')) {
      switch (moodKey) {
        case 'Calm':
          return 'Calma';
        case 'Content':
          return 'Contento';
        case 'Dissatisfied':
          return 'Disgustado';
        case 'Excited':
          return 'Emocionado';
        case 'Extremely Dissatisfied':
          return 'Muy disgustado';
        case 'Frustrated':
          return 'Frustrado';
        case 'Neutral':
          return 'Neutral';
        case 'Sad':
          return 'Triste';
        case 'Satisfied':
          return 'Satisfecho';
        case 'Stressed':
          return 'Estresado';
        case 'Very Dissatisfied':
          return 'Muy mal';
        case 'Very Satisfied':
          return 'Radiante';
        case 'Worried':
          return 'Preocupado';
        case 'Sick':
          return 'Enfermo';
      }
    }
    return moodKey;
  }

  static List<HistoryEntry> filterByPeriod(
    List<HistoryEntry> entries,
    StatsPeriod period, {
    String? selectedTimezone,
    DateTime? now,
  }) {
    if (entries.isEmpty) return [];
    if (period == StatsPeriod.allTime) return List.from(entries);

    final tz.Location? location = selectedTimezone != null
        ? tz.getLocation(selectedTimezone)
        : null;

    final DateTime currentNow = now ??
        (location != null
            ? tz.TZDateTime.now(location)
            : DateTime.now());

    final DateTime startLimit;
    if (period == StatsPeriod.week) {
      // Inicio de la semana actual (Lunes a las 00:00:00)
      startLimit = DateTime(
        currentNow.year,
        currentNow.month,
        currentNow.day,
      ).subtract(Duration(days: currentNow.weekday - 1));
    } else {
      // Inicio del mes actual (Día 1 a las 00:00:00)
      startLimit = DateTime(currentNow.year, currentNow.month, 1);
    }

    return entries.where((entry) {
      final entryDate = location != null
          ? tz.TZDateTime.from(entry.date, location)
          : entry.date;
      return !entryDate.isBefore(startLimit);
    }).toList();
  }

  static ({int currentStreak, int bestStreak}) calculateStreaks(
    List<HistoryEntry> allEntries, {
    String? selectedTimezone,
    DateTime? now,
  }) {
    if (allEntries.isEmpty) {
      return (currentStreak: 0, bestStreak: 0);
    }

    final tz.Location? location = selectedTimezone != null
        ? tz.getLocation(selectedTimezone)
        : null;

    final DateTime currentNow = now ??
        (location != null
            ? tz.TZDateTime.now(location)
            : DateTime.now());

    final todayDate = DateTime(currentNow.year, currentNow.month, currentNow.day);
    final yesterdayDate = todayDate.subtract(const Duration(days: 1));

    // Obtener días únicos en orden ascendente
    final Set<DateTime> uniqueDaysSet = {};
    for (final entry in allEntries) {
      final entryDate = location != null
          ? tz.TZDateTime.from(entry.date, location)
          : entry.date;
      uniqueDaysSet.add(DateTime(entryDate.year, entryDate.month, entryDate.day));
    }

    final sortedDays = uniqueDaysSet.toList()..sort((a, b) => a.compareTo(b));

    // Calcular mejor racha histórica
    int bestStreak = 0;
    int runningStreak = 0;
    DateTime? prevDate;

    for (final date in sortedDays) {
      if (prevDate == null) {
        runningStreak = 1;
      } else {
        final diff = date.difference(prevDate).inDays;
        if (diff == 1) {
          runningStreak++;
        } else if (diff > 1) {
          runningStreak = 1;
        }
      }
      if (runningStreak > bestStreak) {
        bestStreak = runningStreak;
      }
      prevDate = date;
    }

    // Calcular racha actual desde el final
    final lastRecordedDay = sortedDays.last;
    int currentStreak = 0;

    // La racha se mantiene viva si el último registro fue hoy o ayer
    if (lastRecordedDay == todayDate || lastRecordedDay == yesterdayDate) {
      currentStreak = 1;
      var checkDate = lastRecordedDay;

      for (int i = sortedDays.length - 2; i >= 0; i--) {
        final day = sortedDays[i];
        if (checkDate.difference(day).inDays == 1) {
          currentStreak++;
          checkDate = day;
        } else {
          break;
        }
      }
    }

    return (currentStreak: currentStreak, bestStreak: bestStreak);
  }

  static MoodStatsSummary calculateSummary({
    required List<HistoryEntry> allEntries,
    required StatsPeriod period,
    String? selectedTimezone,
    DateTime? now,
  }) {
    final filtered = filterByPeriod(
      allEntries,
      period,
      selectedTimezone: selectedTimezone,
      now: now,
    );

    final streaks = calculateStreaks(
      allEntries,
      selectedTimezone: selectedTimezone,
      now: now,
    );

    final tz.Location? location = selectedTimezone != null
        ? tz.getLocation(selectedTimezone)
        : null;

    final Set<DateTime> activeDaysSet = {};
    final Map<String, int> moodCounts = {};
    final Map<String, int> tagCounts = {};

    for (final entry in filtered) {
      final entryDate = location != null
          ? tz.TZDateTime.from(entry.date, location)
          : entry.date;
      activeDaysSet.add(DateTime(entryDate.year, entryDate.month, entryDate.day));

      final normalizedMood = normalizeMoodPath(entry.emojiPath);
      moodCounts[normalizedMood] = (moodCounts[normalizedMood] ?? 0) + 1;

      for (final tag in entry.tags) {
        final cleanTag = tag.trim();
        if (cleanTag.isNotEmpty) {
          tagCounts[cleanTag] = (tagCounts[cleanTag] ?? 0) + 1;
        }
      }
    }

    final totalEntries = filtered.length;
    final Map<String, double> moodPercentages = {};
    String? dominantMood;
    int highestMoodCount = 0;

    moodCounts.forEach((mood, count) {
      moodPercentages[mood] = totalEntries > 0 ? (count / totalEntries) : 0.0;
      if (count > highestMoodCount) {
        highestMoodCount = count;
        dominantMood = mood;
      }
    });

    final sortedTags = tagCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return MoodStatsSummary(
      period: period,
      totalEntries: totalEntries,
      currentStreak: streaks.currentStreak,
      bestStreak: streaks.bestStreak,
      activeDays: activeDaysSet.length,
      moodCounts: moodCounts,
      moodPercentages: moodPercentages,
      dominantMood: dominantMood,
      topTags: sortedTags,
    );
  }
}
