import 'package:flutter/material.dart';
import 'package:cozy_feels_app/features/history/domain/entities/history_entry.dart';

enum HistoryDateFilterType {
  all,
  thisWeek,
  thisMonth,
  custom,
}

class HistoryFilterCriteria {
  final String searchQuery;
  final String? selectedMoodPath;
  final String? selectedTag;
  final HistoryDateFilterType dateFilterType;
  final DateTimeRange? customDateRange;

  const HistoryFilterCriteria({
    this.searchQuery = '',
    this.selectedMoodPath,
    this.selectedTag,
    this.dateFilterType = HistoryDateFilterType.all,
    this.customDateRange,
  });

  bool get isActive =>
      searchQuery.trim().isNotEmpty ||
      selectedMoodPath != null ||
      selectedTag != null ||
      dateFilterType != HistoryDateFilterType.all;

  HistoryFilterCriteria copyWith({
    String? searchQuery,
    String? selectedMoodPath,
    bool clearMood = false,
    String? selectedTag,
    bool clearTag = false,
    HistoryDateFilterType? dateFilterType,
    DateTimeRange? customDateRange,
    bool clearDateRange = false,
  }) {
    return HistoryFilterCriteria(
      searchQuery: searchQuery ?? this.searchQuery,
      selectedMoodPath:
          clearMood ? null : (selectedMoodPath ?? this.selectedMoodPath),
      selectedTag: clearTag ? null : (selectedTag ?? this.selectedTag),
      dateFilterType: dateFilterType ?? this.dateFilterType,
      customDateRange:
          clearDateRange ? null : (customDateRange ?? this.customDateRange),
    );
  }

  static const HistoryFilterCriteria empty = HistoryFilterCriteria();
}

class HistoryFilterService {
  static List<HistoryEntry> filterEntries({
    required List<HistoryEntry> entries,
    required HistoryFilterCriteria criteria,
    DateTime? now,
  }) {
    if (!criteria.isActive) {
      return entries;
    }

    final currentNow = now ?? DateTime.now();
    final query = criteria.searchQuery.trim().toLowerCase();

    return entries.where((entry) {
      // Filtro de búsqueda por texto (en notas o mensajes)
      if (query.isNotEmpty) {
        if (!entry.message.toLowerCase().contains(query)) {
          return false;
        }
      }

      // Filtro por emoción / emoji
      if (criteria.selectedMoodPath != null) {
        final criteriaNormalized =
            _normalizeEmojiPath(criteria.selectedMoodPath!);
        final entryNormalized = _normalizeEmojiPath(entry.emojiPath);
        if (criteriaNormalized != entryNormalized) {
          return false;
        }
      }

      // Filtro por etiqueta (Tag)
      if (criteria.selectedTag != null) {
        if (!entry.tags.contains(criteria.selectedTag)) {
          return false;
        }
      }

      // Filtro por período de fecha
      switch (criteria.dateFilterType) {
        case HistoryDateFilterType.all:
          break;
        case HistoryDateFilterType.thisWeek:
          final startOfWeek = DateTime(
            currentNow.year,
            currentNow.month,
            currentNow.day,
          ).subtract(Duration(days: currentNow.weekday - 1));
          if (entry.date.isBefore(startOfWeek)) {
            return false;
          }
          break;
        case HistoryDateFilterType.thisMonth:
          final startOfMonth = DateTime(currentNow.year, currentNow.month, 1);
          if (entry.date.isBefore(startOfMonth)) {
            return false;
          }
          break;
        case HistoryDateFilterType.custom:
          if (criteria.customDateRange != null) {
            final start = DateTime(
              criteria.customDateRange!.start.year,
              criteria.customDateRange!.start.month,
              criteria.customDateRange!.start.day,
            );
            final end = DateTime(
              criteria.customDateRange!.end.year,
              criteria.customDateRange!.end.month,
              criteria.customDateRange!.end.day,
              23,
              59,
              59,
              999,
            );
            if (entry.date.isBefore(start) || entry.date.isAfter(end)) {
              return false;
            }
          }
          break;
      }

      return true;
    }).toList();
  }

  static String _normalizeEmojiPath(String path) {
    if (path.contains('/feelings/')) {
      return path;
    }
    return path.replaceAll('assets/icons/svg/', 'assets/icons/svg/feelings/');
  }
}
