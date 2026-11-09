import 'package:flutter/material.dart';
import 'package:cozy_feels_app/core/theme/app_colors.dart';
import 'package:cozy_feels_app/features/history/domain/services/history_filter_service.dart';
import 'package:cozy_feels_app/l10n/app_localizations.dart';

class DateFilterSheet extends StatelessWidget {
  final HistoryDateFilterType currentType;
  final DateTimeRange? currentRange;
  final Function(HistoryDateFilterType type, DateTimeRange? range) onSelected;

  const DateFilterSheet({
    super.key,
    required this.currentType,
    required this.currentRange,
    required this.onSelected,
  });

  Future<void> _pickCustomRange(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(now.year + 2),
      initialDateRange: currentRange ??
          DateTimeRange(
            start: now.subtract(const Duration(days: 7)),
            end: now,
          ),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.rosaFuerte,
              onPrimary: Colors.white,
              surface: AppColors.fondoSoft,
              onSurface: AppColors.textoOscuro,
              secondary: AppColors.naranjaPiel,
            ),
            dialogTheme: DialogThemeData(
              backgroundColor: AppColors.fondoSoft,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      onSelected(HistoryDateFilterType.custom, picked);
      if (context.mounted) {
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.naranjaPiel,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Container(
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.fondoSoft,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.history_filter_custom_date,
              style: TextStyle(
                fontFamily: 'Dongle',
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppColors.textoOscuro,
                height: 1.0,
              ),
            ),
            const SizedBox(height: 12),
            _buildOption(
              context: context,
              title: l10n.history_filter_all,
              isSelected: currentType == HistoryDateFilterType.all,
              onTap: () {
                onSelected(HistoryDateFilterType.all, null);
                Navigator.pop(context);
              },
            ),
            _buildOption(
              context: context,
              title: l10n.history_filter_this_week,
              isSelected: currentType == HistoryDateFilterType.thisWeek,
              onTap: () {
                onSelected(HistoryDateFilterType.thisWeek, null);
                Navigator.pop(context);
              },
            ),
            _buildOption(
              context: context,
              title: l10n.history_filter_this_month,
              isSelected: currentType == HistoryDateFilterType.thisMonth,
              onTap: () {
                onSelected(HistoryDateFilterType.thisMonth, null);
                Navigator.pop(context);
              },
            ),
            _buildOption(
              context: context,
              title: currentType == HistoryDateFilterType.custom &&
                      currentRange != null
                  ? "${currentRange!.start.day}/${currentRange!.start.month} - ${currentRange!.end.day}/${currentRange!.end.month}"
                  : l10n.history_filter_custom_date,
              isSelected: currentType == HistoryDateFilterType.custom,
              icon: Icons.date_range_rounded,
              onTap: () => _pickCustomRange(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOption({
    required BuildContext context,
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
    IconData? icon,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      decoration: BoxDecoration(
        color: isSelected
            ? AppColors.rosaFuerte.withValues(alpha: 0.2)
            : AppColors.fondoSoft.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected
              ? AppColors.rosaFuerte
              : AppColors.rosaFuerte.withValues(alpha: 0.2),
          width: isSelected ? 1.8 : 1,
        ),
      ),
      child: ListTile(
        dense: true,
        onTap: onTap,
        title: Text(
          title,
          style: TextStyle(
            color: AppColors.textoOscuro,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
            fontSize: 16,
          ),
        ),
        trailing: icon != null
            ? Icon(icon, color: AppColors.rosaFuerte, size: 20)
            : isSelected
                ? Icon(Icons.check_rounded, color: AppColors.rosaFuerte)
                : null,
      ),
    );
  }
}
