import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cozy_feels_app/core/theme/app_colors.dart';
import 'package:cozy_feels_app/l10n/app_localizations.dart';

class CalendarMonthHeader extends StatelessWidget {
  final DateTime currentMonth;
  final VoidCallback onPreviousMonth;
  final VoidCallback onNextMonth;
  final VoidCallback? onMonthTitleTap;

  const CalendarMonthHeader({
    super.key,
    required this.currentMonth,
    required this.onPreviousMonth,
    required this.onNextMonth,
    this.onMonthTitleTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).languageCode;
    var monthYearText = DateFormat('MMMM yyyy', locale).format(currentMonth);

    if (monthYearText.isNotEmpty) {
      monthYearText = monthYearText[0].toUpperCase() + monthYearText.substring(1);
    }

    final weekdays = [
      l10n.calendar_day_monday,
      l10n.calendar_day_tuesday,
      l10n.calendar_day_wednesday,
      l10n.calendar_day_thursday,
      l10n.calendar_day_friday,
      l10n.calendar_day_saturday,
      l10n.calendar_day_sunday,
    ];

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildArrowButton(
                icon: Icons.chevron_left_rounded,
                onTap: onPreviousMonth,
                tooltip: l10n.calendar_prev_month,
              ),
              GestureDetector(
                onTap: onMonthTitleTap,
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        monthYearText,
                        style: TextStyle(
                          fontFamily: 'Dongle',
                          fontSize: 34,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textoOscuro,
                          height: 1.0,
                        ),
                      ),
                      const SizedBox(width: 2),
                      Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: AppColors.textoOscuro,
                        size: 26,
                      ),
                    ],
                  ),
                ),
              ),
              _buildArrowButton(
                icon: Icons.chevron_right_rounded,
                onTap: onNextMonth,
                tooltip: l10n.calendar_next_month,
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: weekdays.map((day) {
              return Expanded(
                child: Center(
                  child: Text(
                    day,
                    style: TextStyle(
                      fontFamily: 'Dongle',
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textoOscuro,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 4),
      ],
    );
  }

  Widget _buildArrowButton({
    required IconData icon,
    required VoidCallback onTap,
    required String tooltip,
  }) {
    return IconButton(
      onPressed: onTap,
      tooltip: tooltip,
      icon: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: AppColors.naranjaPiel,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: AppColors.rosaFuerte,
          size: 24,
        ),
      ),
    );
  }
}
