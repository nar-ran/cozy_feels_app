import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:cozy_feels_app/core/theme/app_colors.dart';
import 'package:cozy_feels_app/core/widgets/stroke_text.dart';
import 'package:cozy_feels_app/features/history/domain/entities/history_entry.dart';
import 'package:cozy_feels_app/l10n/app_localizations.dart';

class MonthYearPickerDialog extends StatefulWidget {
  final DateTime initialDate;
  final List<HistoryEntry> entries;
  final String selectedTimezone;
  final Function(DateTime selectedDate) onMonthSelected;

  const MonthYearPickerDialog({
    super.key,
    required this.initialDate,
    required this.entries,
    required this.selectedTimezone,
    required this.onMonthSelected,
  });

  @override
  State<MonthYearPickerDialog> createState() => _MonthYearPickerDialogState();
}

class _MonthYearPickerDialogState extends State<MonthYearPickerDialog> {
  late int _selectedYear;

  @override
  void initState() {
    super.initState();
    _selectedYear = widget.initialDate.year;
  }

  int _countEntriesForMonth(int month) {
    final location = tz.getLocation(widget.selectedTimezone);
    return widget.entries.where((entry) {
      final tzDate = tz.TZDateTime.from(entry.date, location);
      return tzDate.year == _selectedYear && tzDate.month == month;
    }).length;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).languageCode;
    final location = tz.getLocation(widget.selectedTimezone);
    final now = tz.TZDateTime.now(location);
    final width = MediaQuery.of(context).size.width;

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.fondoSoft,
          borderRadius: BorderRadius.circular(30),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Title
            StrokeText(
              text: l10n.calendar_select_month,
              fontSize: width * 0.08,
              color: AppColors.rosaFuerte,
              strokeColor: AppColors.strokeColor,
            ),
            const SizedBox(height: 12),

            // Year Selector Row
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildArrowButton(
                  icon: Icons.chevron_left_rounded,
                  onTap: () {
                    setState(() => _selectedYear--);
                  },
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18.0),
                  child: Text(
                    '$_selectedYear',
                    style: TextStyle(
                      fontFamily: 'Dongle',
                      fontSize: 34,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textoOscuro,
                      height: 1.0,
                    ),
                  ),
                ),
                _buildArrowButton(
                  icon: Icons.chevron_right_rounded,
                  onTap: () {
                    setState(() => _selectedYear++);
                  },
                ),
              ],
            ),
            const SizedBox(height: 14),

            // 12 Months Grid (3 columns x 4 rows)
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 1.4,
              ),
              itemCount: 12,
              itemBuilder: (context, index) {
                final monthNumber = index + 1;
                final monthDate = DateTime(_selectedYear, monthNumber, 1);
                var monthName = DateFormat('MMMM', locale).format(monthDate);
                if (monthName.isNotEmpty) {
                  monthName = monthName[0].toUpperCase() + monthName.substring(1);
                }

                final bool isSelected = _selectedYear == widget.initialDate.year &&
                    monthNumber == widget.initialDate.month;
                final bool isCurrentMonth =
                    _selectedYear == now.year && monthNumber == now.month;

                final entryCount = _countEntriesForMonth(monthNumber);

                final Border border = isSelected
                    ? Border.all(color: AppColors.rosaFuerte, width: 2.5)
                    : (isCurrentMonth
                        ? Border.all(
                            color: AppColors.textoOscuro.withValues(alpha: 0.3),
                            width: 1.5,
                          )
                        : Border.all(color: Colors.transparent, width: 1.5));

                return GestureDetector(
                  onTap: () {
                    widget.onMonthSelected(DateTime(_selectedYear, monthNumber, 1));
                    Navigator.pop(context);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.naranjaPiel,
                      borderRadius: BorderRadius.circular(16),
                      border: border,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6.0),
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              monthName,
                              maxLines: 1,
                              style: TextStyle(
                                fontFamily: 'Dongle',
                                fontSize: 23,
                                fontWeight: (isSelected || isCurrentMonth)
                                    ? FontWeight.bold
                                    : FontWeight.w600,
                                color: isSelected
                                    ? AppColors.rosaFuerte
                                    : AppColors.textoOscuro,
                                height: 1.0,
                              ),
                            ),
                          ),
                        ),
                        if (entryCount > 0)
                          Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 5,
                                  height: 5,
                                  decoration: BoxDecoration(
                                    color: AppColors.rosaFuerte,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '$entryCount',
                                  style: TextStyle(
                                    fontFamily: 'Dongle',
                                    fontSize: 16,
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                    color: AppColors.textoOscuro.withValues(alpha: 0.8),
                                    height: 1.0,
                                  ),
                                ),
                              ],
                            ),
                          )
                        else
                          const SizedBox(height: 14),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),

            // Bottom Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // "Ir a mes actual" pill button
                GestureDetector(
                  onTap: () {
                    widget.onMonthSelected(DateTime(now.year, now.month, 1));
                    Navigator.pop(context);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.naranjaPiel,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppColors.rosaFuerte,
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.today_rounded,
                          color: AppColors.textoOscuro,
                          size: 18,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          l10n.calendar_today_button,
                          style: TextStyle(
                            fontFamily: 'Dongle',
                            fontSize: 22,
                            color: AppColors.textoOscuro,
                            fontWeight: FontWeight.bold,
                            height: 1.0,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Close button
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    l10n.common_cancel,
                    style: TextStyle(
                      fontFamily: 'Dongle',
                      fontSize: 22,
                      color: AppColors.textoOscuro.withValues(alpha: 0.8),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildArrowButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return IconButton(
      onPressed: onTap,
      splashRadius: 22,
      icon: Container(
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: AppColors.naranjaPiel,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: AppColors.rosaFuerte,
          size: 22,
        ),
      ),
    );
  }
}
