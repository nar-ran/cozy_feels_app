import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cozy_feels_app/core/theme/app_colors.dart';
import 'package:cozy_feels_app/features/history/domain/entities/history_entry.dart';

class CalendarDayCell extends StatelessWidget {
  final int dayNumber;
  final bool isCurrentMonth;
  final bool isToday;
  final HistoryEntry? entry;
  final VoidCallback? onTap;

  const CalendarDayCell({
    super.key,
    required this.dayNumber,
    required this.isCurrentMonth,
    required this.isToday,
    this.entry,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool hasEntry = entry != null;

    Color backgroundColor;
    Border? border;

    if (hasEntry) {
      backgroundColor = AppColors.naranjaPiel;
      border = Border.all(
        color: isToday ? AppColors.rosaFuerte : AppColors.rosaFuerte.withValues(alpha: 0.4),
        width: isToday ? 2.0 : 1.2,
      );
    } else if (isToday) {
      backgroundColor = Colors.white.withValues(alpha: 0.5);
      border = Border.all(color: AppColors.rosaFuerte, width: 2.0);
    } else if (isCurrentMonth) {
      backgroundColor = Colors.white.withValues(alpha: 0.2);
      border = Border.all(color: AppColors.textoOscuro.withValues(alpha: 0.12), width: 1.0);
    } else {
      backgroundColor = Colors.transparent;
      border = null;
    }

    Color textColor;
    if (isToday) {
      textColor = AppColors.rosaFuerte;
    } else if (!isCurrentMonth) {
      textColor = AppColors.textoOscuro.withValues(alpha: 0.3);
    } else {
      textColor = AppColors.textoOscuro;
    }

    String? fixedEmojiPath;
    if (hasEntry) {
      final path = entry!.emojiPath;
      fixedEmojiPath = path.contains('/feelings/')
          ? path
          : path.replaceAll('assets/icons/svg/', 'assets/icons/svg/feelings/');
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.all(3.5),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(16),
          border: border,
          boxShadow: hasEntry
              ? [
                  BoxShadow(
                    color: AppColors.textoOscuro.withValues(alpha: 0.08),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  )
                ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '$dayNumber',
              style: TextStyle(
                fontFamily: 'Dongle',
                fontSize: 19,
                fontWeight: (isToday || hasEntry) ? FontWeight.bold : FontWeight.normal,
                color: textColor,
                height: 0.9,
              ),
            ),
            if (hasEntry && isCurrentMonth && fixedEmojiPath != null) ...[
              const SizedBox(height: 2),
              SvgPicture.asset(
                fixedEmojiPath,
                width: 24,
                height: 24,
                colorFilter: ColorFilter.mode(
                  AppColors.emojiColor,
                  BlendMode.srcIn,
                ),
              ),
            ] else if (isToday) ...[
              const SizedBox(height: 3),
              Container(
                width: 5,
                height: 5,
                decoration: BoxDecoration(
                  color: AppColors.rosaFuerte,
                  shape: BoxShape.circle,
                ),
              ),
            ] else ...[
              const SizedBox(height: 8),
            ],
          ],
        ),
      ),
    );
  }
}
