import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cozy_feels_app/core/theme/app_colors.dart';
import 'package:cozy_feels_app/features/history/domain/entities/app_tag.dart';
import 'package:cozy_feels_app/features/history/domain/services/history_filter_service.dart';
import 'package:cozy_feels_app/l10n/app_localizations.dart';
import 'date_filter_sheet.dart';
import 'mood_filter_dialog.dart';

class HistoryFilterChipsBar extends StatelessWidget {
  final HistoryFilterCriteria criteria;
  final List<String> availableTags;
  final ValueChanged<HistoryFilterCriteria> onCriteriaChanged;

  const HistoryFilterChipsBar({
    super.key,
    required this.criteria,
    required this.availableTags,
    required this.onCriteriaChanged,
  });

  void _showDateFilter(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => DateFilterSheet(
        currentType: criteria.dateFilterType,
        currentRange: criteria.customDateRange,
        onSelected: (type, range) {
          onCriteriaChanged(
            criteria.copyWith(
              dateFilterType: type,
              customDateRange: range,
              clearDateRange: range == null,
            ),
          );
        },
      ),
    );
  }

  void _showMoodFilter(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => MoodFilterDialog(
        currentMoodPath: criteria.selectedMoodPath,
        onMoodSelected: (newMoodPath) {
          onCriteriaChanged(
            criteria.copyWith(
              selectedMoodPath: newMoodPath,
              clearMood: newMoodPath == null,
            ),
          );
        },
      ),
    );
  }

  void _toggleTag(String tagId) {
    if (criteria.selectedTag == tagId) {
      onCriteriaChanged(criteria.copyWith(clearTag: true));
    } else {
      onCriteriaChanged(criteria.copyWith(selectedTag: tagId));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    String dateLabel = l10n.history_filter_all;
    if (criteria.dateFilterType == HistoryDateFilterType.thisWeek) {
      dateLabel = l10n.history_filter_this_week;
    } else if (criteria.dateFilterType == HistoryDateFilterType.thisMonth) {
      dateLabel = l10n.history_filter_this_month;
    } else if (criteria.dateFilterType == HistoryDateFilterType.custom &&
        criteria.customDateRange != null) {
      final r = criteria.customDateRange!;
      dateLabel = "${r.start.day}/${r.start.month} - ${r.end.day}/${r.end.month}";
    }

    final isDateActive = criteria.dateFilterType != HistoryDateFilterType.all;
    final isMoodActive = criteria.selectedMoodPath != null;

    return SizedBox(
      height: 36,
      child: ListView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: [
          // 1. Chip de Fecha
          GestureDetector(
            onTap: () => _showDateFilter(context),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: isDateActive
                    ? AppColors.rosaFuerte
                    : AppColors.fondoSoft.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: isDateActive
                      ? AppColors.rosaFuerte
                      : AppColors.rosaFuerte.withValues(alpha: 0.35),
                  width: 1.2,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.calendar_today_rounded,
                    size: 14,
                    color: isDateActive ? Colors.white : AppColors.textoOscuro,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    dateLabel,
                    style: TextStyle(
                      fontFamily: 'Dongle',
                      fontSize: 20,
                      fontWeight:
                          isDateActive ? FontWeight.bold : FontWeight.w600,
                      color: isDateActive ? Colors.white : AppColors.textoOscuro,
                      height: 1.0,
                    ),
                  ),
                  const SizedBox(width: 2),
                  Icon(
                    Icons.arrow_drop_down_rounded,
                    size: 18,
                    color: isDateActive ? Colors.white : AppColors.textoOscuro,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(width: 8),

          // 2. Chip de Emoción
          GestureDetector(
            onTap: () => _showMoodFilter(context),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: isMoodActive
                    ? AppColors.rosaFuerte
                    : AppColors.fondoSoft.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: isMoodActive
                      ? AppColors.rosaFuerte
                      : AppColors.rosaFuerte.withValues(alpha: 0.35),
                  width: 1.2,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isMoodActive) ...[
                    SvgPicture.asset(
                      criteria.selectedMoodPath!,
                      width: 15,
                      height: 15,
                      colorFilter: const ColorFilter.mode(
                        Colors.white,
                        BlendMode.srcIn,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      l10n.history_filter_select_mood,
                      style: const TextStyle(
                        fontFamily: 'Dongle',
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        height: 1.0,
                      ),
                    ),
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: () => onCriteriaChanged(
                        criteria.copyWith(clearMood: true),
                      ),
                      child: const Icon(
                        Icons.close_rounded,
                        size: 14,
                        color: Colors.white,
                      ),
                    ),
                  ] else ...[
                    Icon(
                      Icons.mood_rounded,
                      size: 15,
                      color: AppColors.textoOscuro,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      l10n.history_filter_select_mood,
                      style: TextStyle(
                        fontFamily: 'Dongle',
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textoOscuro,
                        height: 1.0,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          if (availableTags.isNotEmpty) const SizedBox(width: 8),

          // 3. Chips de Etiquetas
          ...availableTags.map((tagId) {
            final isSelected = criteria.selectedTag == tagId;
            final label = AppTag.getLabelForTag(tagId, l10n);
            final icon = AppTag.getIconForTag(tagId);

            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: GestureDetector(
                onTap: () => _toggleTag(tagId),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.rosaFuerte
                        : AppColors.fondoSoft.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.rosaFuerte
                          : AppColors.rosaFuerte.withValues(alpha: 0.35),
                      width: 1.2,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        icon,
                        size: 14,
                        color:
                            isSelected ? Colors.white : AppColors.textoOscuro,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        label,
                        style: TextStyle(
                          fontFamily: 'Dongle',
                          fontSize: 20,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.w600,
                          color:
                              isSelected ? Colors.white : AppColors.textoOscuro,
                          height: 1.0,
                        ),
                      ),
                      if (isSelected) ...[
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.close_rounded,
                          size: 14,
                          color: Colors.white,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
