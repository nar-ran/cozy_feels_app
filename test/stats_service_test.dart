import 'package:flutter_test/flutter_test.dart';
import 'package:cozy_feels_app/features/history/domain/entities/history_entry.dart';
import 'package:cozy_feels_app/features/history/domain/services/stats_service.dart';

void main() {
  final now = DateTime(2026, 11, 8, 14, 0); // Sunday Nov 8, 2026

  group('StatsService - Normalization & Key extraction', () {
    test('normalizes legacy and modern emoji paths', () {
      expect(
        StatsService.normalizeMoodPath('assets/icons/svg/sentiment_calm.svg'),
        'assets/icons/svg/feelings/sentiment_calm.svg',
      );
      expect(
        StatsService.normalizeMoodPath(
            'assets/icons/svg/feelings/sentiment_calm.svg'),
        'assets/icons/svg/feelings/sentiment_calm.svg',
      );
    });

    test('extracts mood key', () {
      expect(
        StatsService.getMoodKey('assets/icons/svg/feelings/sentiment_calm.svg'),
        'Calm',
      );
      expect(
        StatsService.getMoodKey(
            'assets/icons/svg/feelings/sentiment_very_satisfied.svg'),
        'Very Satisfied',
      );
    });
  });

  group('StatsService - Period Filtering', () {
    final entries = [
      HistoryEntry(
        date: DateTime(2026, 11, 8, 10, 0), // Today (Sunday)
        message: 'Entry 1',
        emojiPath: 'assets/icons/svg/feelings/sentiment_satisfied.svg',
      ),
      HistoryEntry(
        date: DateTime(2026, 11, 3, 10, 0), // Tuesday of current week
        message: 'Entry 2',
        emojiPath: 'assets/icons/svg/feelings/sentiment_calm.svg',
      ),
      HistoryEntry(
        date: DateTime(2026, 11, 1, 10, 0), // Sunday previous week (same month)
        message: 'Entry 3',
        emojiPath: 'assets/icons/svg/feelings/sentiment_neutral.svg',
      ),
      HistoryEntry(
        date: DateTime(2026, 10, 25, 10, 0), // Previous month
        message: 'Entry 4',
        emojiPath: 'assets/icons/svg/feelings/sentiment_sad.svg',
      ),
    ];

    test('filters by week (Monday Nov 2 to Sunday Nov 8)', () {
      final filtered = StatsService.filterByPeriod(
        entries,
        StatsPeriod.week,
        now: now,
      );
      expect(filtered.length, 2);
      expect(filtered.map((e) => e.message), containsAll(['Entry 1', 'Entry 2']));
    });

    test('filters by month (Nov 1 to Nov 8)', () {
      final filtered = StatsService.filterByPeriod(
        entries,
        StatsPeriod.month,
        now: now,
      );
      expect(filtered.length, 3);
      expect(filtered.map((e) => e.message),
          containsAll(['Entry 1', 'Entry 2', 'Entry 3']));
    });

    test('filters allTime returns all entries', () {
      final filtered = StatsService.filterByPeriod(
        entries,
        StatsPeriod.allTime,
        now: now,
      );
      expect(filtered.length, 4);
    });
  });

  group('StatsService - Streak Calculation', () {
    test('returns 0 for empty list', () {
      final streaks = StatsService.calculateStreaks([], now: now);
      expect(streaks.currentStreak, 0);
      expect(streaks.bestStreak, 0);
    });

    test('returns 1 when there is an entry today', () {
      final entries = [
        HistoryEntry(
          date: DateTime(2026, 11, 8, 9, 0),
          message: 'Today',
          emojiPath: '',
        ),
      ];
      final streaks = StatsService.calculateStreaks(entries, now: now);
      expect(streaks.currentStreak, 1);
      expect(streaks.bestStreak, 1);
    });

    test('returns 1 when there is an entry yesterday but not today', () {
      final entries = [
        HistoryEntry(
          date: DateTime(2026, 11, 7, 18, 0),
          message: 'Yesterday',
          emojiPath: '',
        ),
      ];
      final streaks = StatsService.calculateStreaks(entries, now: now);
      expect(streaks.currentStreak, 1);
      expect(streaks.bestStreak, 1);
    });

    test('returns 0 current streak if last entry was 2 days ago', () {
      final entries = [
        HistoryEntry(
          date: DateTime(2026, 11, 6, 12, 0),
          message: 'Friday',
          emojiPath: '',
        ),
      ];
      final streaks = StatsService.calculateStreaks(entries, now: now);
      expect(streaks.currentStreak, 0);
      expect(streaks.bestStreak, 1);
    });

    test('calculates multi-day consecutive streak and handles multiple entries same day', () {
      final entries = [
        HistoryEntry(date: DateTime(2026, 11, 8, 9, 0), message: 'Today 1', emojiPath: ''),
        HistoryEntry(date: DateTime(2026, 11, 8, 14, 0), message: 'Today 2', emojiPath: ''),
        HistoryEntry(date: DateTime(2026, 11, 7, 10, 0), message: 'Nov 7', emojiPath: ''),
        HistoryEntry(date: DateTime(2026, 11, 6, 11, 0), message: 'Nov 6', emojiPath: ''),
        HistoryEntry(date: DateTime(2026, 11, 5, 8, 0), message: 'Nov 5', emojiPath: ''),
      ];
      final streaks = StatsService.calculateStreaks(entries, now: now);
      expect(streaks.currentStreak, 4);
      expect(streaks.bestStreak, 4);
    });

    test('tracks historical best streak when past streak was longer than current', () {
      final entries = [
        // Past streak: Oct 1, 2, 3, 4, 5 (5 days)
        HistoryEntry(date: DateTime(2026, 10, 1), message: '', emojiPath: ''),
        HistoryEntry(date: DateTime(2026, 10, 2), message: '', emojiPath: ''),
        HistoryEntry(date: DateTime(2026, 10, 3), message: '', emojiPath: ''),
        HistoryEntry(date: DateTime(2026, 10, 4), message: '', emojiPath: ''),
        HistoryEntry(date: DateTime(2026, 10, 5), message: '', emojiPath: ''),
        // Gap
        // Current streak: Nov 7, Nov 8 (2 days)
        HistoryEntry(date: DateTime(2026, 11, 7), message: '', emojiPath: ''),
        HistoryEntry(date: DateTime(2026, 11, 8), message: '', emojiPath: ''),
      ];
      final streaks = StatsService.calculateStreaks(entries, now: now);
      expect(streaks.currentStreak, 2);
      expect(streaks.bestStreak, 5);
    });
  });

  group('StatsService - Summary calculation', () {
    test('computes mood distribution, dominant mood, percentages, and top tags', () {
      final entries = [
        HistoryEntry(
          date: DateTime(2026, 11, 8, 10, 0),
          message: 'Happy at work',
          emojiPath: 'assets/icons/svg/feelings/sentiment_satisfied.svg',
          tags: ['Trabajo', 'Gym'],
        ),
        HistoryEntry(
          date: DateTime(2026, 11, 7, 10, 0),
          message: 'Also satisfied',
          emojiPath: 'assets/icons/svg/feelings/sentiment_satisfied.svg',
          tags: ['Trabajo', 'Familia'],
        ),
        HistoryEntry(
          date: DateTime(2026, 11, 6, 10, 0),
          message: 'Calm',
          emojiPath: 'assets/icons/svg/feelings/sentiment_calm.svg',
          tags: ['Descanso'],
        ),
      ];

      final summary = StatsService.calculateSummary(
        allEntries: entries,
        period: StatsPeriod.week,
        now: now,
      );

      expect(summary.totalEntries, 3);
      expect(summary.activeDays, 3);
      expect(summary.currentStreak, 3);
      expect(summary.dominantMood,
          'assets/icons/svg/feelings/sentiment_satisfied.svg');
      expect(
        summary.moodCounts['assets/icons/svg/feelings/sentiment_satisfied.svg'],
        2,
      );
      expect(
        summary.moodPercentages['assets/icons/svg/feelings/sentiment_satisfied.svg'],
        closeTo(2 / 3, 0.001),
      );
      expect(summary.topTags.first.key, 'Trabajo');
      expect(summary.topTags.first.value, 2);
    });
  });
}
