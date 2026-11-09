import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cozy_feels_app/core/theme/app_colors.dart';
import 'package:cozy_feels_app/features/history/domain/services/stats_service.dart';
import 'package:cozy_feels_app/l10n/app_localizations.dart';

class DominantMoodCard extends StatelessWidget {
  final String dominantMood;
  final int count;
  final double percentage;
  final int totalEntries;
  final int activeDays;

  const DominantMoodCard({
    super.key,
    required this.dominantMood,
    required this.count,
    required this.percentage,
    required this.totalEntries,
    required this.activeDays,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).languageCode;
    final moodKey = StatsService.getMoodKey(dominantMood);
    final moodName = StatsService.getLocalizedMoodName(moodKey, locale);
    final percentStr = (percentage * 100).toStringAsFixed(0);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.naranjaPiel.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: AppColors.rosaFuerte.withValues(alpha: 0.35),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.rosaFuerte.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.auto_awesome_rounded,
                  color: AppColors.rosaFuerte,
                  size: 24,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                l10n.stats_dominant_mood,
                style: TextStyle(
                  fontFamily: 'Dongle',
                  fontSize: 26,
                  height: 1.0,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textoOscuro,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              // Badge de SVG de emoción predominante
              Container(
                width: 72,
                height: 72,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.fondoSoft,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.rosaFuerte.withValues(alpha: 0.4),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.rosaFuerte.withValues(alpha: 0.15),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: SvgPicture.asset(
                  dominantMood,
                  colorFilter: ColorFilter.mode(
                    AppColors.emojiColor,
                    BlendMode.srcIn,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      moodName,
                      style: TextStyle(
                        fontFamily: 'Dongle',
                        fontSize: 34,
                        height: 0.95,
                        fontWeight: FontWeight.bold,
                        color: AppColors.rosaFuerte,
                      ),
                    ),
                    Text(
                      '$count de $totalEntries registros ($percentStr%)',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textoOscuro.withValues(alpha: 0.75),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.fondoSoft,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${l10n.stats_total_entries}: $totalEntries',
                            style: TextStyle(
                              fontFamily: 'Dongle',
                              fontSize: 18,
                              height: 1.0,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textoOscuro,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
