import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cozy_feels_app/features/history/domain/entities/history_entry.dart';
import 'package:cozy_feels_app/features/history/domain/services/history_filter_service.dart';

void main() {
  final now = DateTime(2026, 11, 8, 12, 0, 0); // Domingo
  // Inicio de semana (Lunes): 2026-11-02
  // Inicio de mes: 2026-11-01

  final entry1 = HistoryEntry(
    date: DateTime(2026, 11, 8, 9, 30),
    message: 'Caminata matutina con el perro',
    emojiPath: 'assets/icons/svg/feelings/sentiment_very_satisfied.svg',
    tags: ['health', 'leisure'],
  );

  final entry2 = HistoryEntry(
    date: DateTime(2026, 11, 5, 14, 00),
    message: 'Mucho trabajo en la oficina',
    emojiPath: 'assets/icons/svg/feelings/sentiment_stressed.svg',
    tags: ['work'],
  );

  final entry3 = HistoryEntry(
    date: DateTime(2026, 10, 25, 20, 00), // Mes pasado
    message: 'Cena familiar tranquila',
    emojiPath: 'assets/icons/svg/feelings/sentiment_calm.svg',
    tags: ['family'],
  );

  final sampleEntries = [entry1, entry2, entry3];

  group('HistoryFilterService', () {
    test('returns all entries when criteria is empty', () {
      final results = HistoryFilterService.filterEntries(
        entries: sampleEntries,
        criteria: HistoryFilterCriteria.empty,
        now: now,
      );
      expect(results.length, 3);
    });

    test('filters by text search case-insensitively', () {
      final results = HistoryFilterService.filterEntries(
        entries: sampleEntries,
        criteria: const HistoryFilterCriteria(searchQuery: 'perro'),
        now: now,
      );
      expect(results.length, 1);
      expect(results.first.message, contains('Caminata matutina'));

      final resultsUpper = HistoryFilterService.filterEntries(
        entries: sampleEntries,
        criteria: const HistoryFilterCriteria(searchQuery: 'OFICINA'),
        now: now,
      );
      expect(resultsUpper.length, 1);
      expect(resultsUpper.first.tags, contains('work'));
    });

    test('filters by mood with path normalization', () {
      final results = HistoryFilterService.filterEntries(
        entries: sampleEntries,
        criteria: const HistoryFilterCriteria(
          selectedMoodPath: 'assets/icons/svg/sentiment_stressed.svg',
        ),
        now: now,
      );
      expect(results.length, 1);
      expect(results.first.tags, contains('work'));
    });

    test('filters by tag', () {
      final results = HistoryFilterService.filterEntries(
        entries: sampleEntries,
        criteria: const HistoryFilterCriteria(selectedTag: 'health'),
        now: now,
      );
      expect(results.length, 1);
      expect(results.first.message, contains('Caminata matutina'));
    });

    test('filters by thisWeek date filter', () {
      final results = HistoryFilterService.filterEntries(
        entries: sampleEntries,
        criteria: const HistoryFilterCriteria(
          dateFilterType: HistoryDateFilterType.thisWeek,
        ),
        now: now,
      );
      // entry1 (Nov 8) and entry2 (Nov 5) are this week. entry3 (Oct 25) is not.
      expect(results.length, 2);
    });

    test('filters by thisMonth date filter', () {
      final results = HistoryFilterService.filterEntries(
        entries: sampleEntries,
        criteria: const HistoryFilterCriteria(
          dateFilterType: HistoryDateFilterType.thisMonth,
        ),
        now: now,
      );
      // entry1 and entry2 are in November. entry3 is October.
      expect(results.length, 2);
    });

    test('filters by custom date range', () {
      final results = HistoryFilterService.filterEntries(
        entries: sampleEntries,
        criteria: HistoryFilterCriteria(
          dateFilterType: HistoryDateFilterType.custom,
          customDateRange: DateTimeRange(
            start: DateTime(2026, 10, 20),
            end: DateTime(2026, 10, 30),
          ),
        ),
        now: now,
      );
      expect(results.length, 1);
      expect(results.first.message, contains('Cena familiar'));
    });

    test('filters by combined criteria (text + tag)', () {
      final results = HistoryFilterService.filterEntries(
        entries: sampleEntries,
        criteria: const HistoryFilterCriteria(
          searchQuery: 'caminata',
          selectedTag: 'health',
        ),
        now: now,
      );
      expect(results.length, 1);

      final noMatch = HistoryFilterService.filterEntries(
        entries: sampleEntries,
        criteria: const HistoryFilterCriteria(
          searchQuery: 'caminata',
          selectedTag: 'work',
        ),
        now: now,
      );
      expect(noMatch, isEmpty);
    });
  });
}
