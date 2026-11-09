import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cozy_feels_app/core/theme/app_colors.dart';
import 'package:cozy_feels_app/features/history/domain/services/stats_service.dart';
import 'package:cozy_feels_app/l10n/app_localizations.dart';

class MoodDistributionCard extends StatelessWidget {
  final Map<String, int> moodCounts;
  final Map<String, double> moodPercentages;
  final int totalEntries;

  const MoodDistributionCard({
    super.key,
    required this.moodCounts,
    required this.moodPercentages,
    required this.totalEntries,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).languageCode;

    final sortedMoods = moodCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

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
                  Icons.pie_chart_outline_rounded,
                  color: AppColors.rosaFuerte,
                  size: 24,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                l10n.stats_mood_distribution,
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
          ...sortedMoods.map((entry) {
            final moodPath = entry.key;
            final count = entry.value;
            final percentage = moodPercentages[moodPath] ?? 0.0;
            final moodKey = StatsService.getMoodKey(moodPath);
            final moodName = StatsService.getLocalizedMoodName(moodKey, locale);
            final percentStr = (percentage * 100).toStringAsFixed(0);

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      SizedBox(
                        width: 24,
                        height: 24,
                        child: SvgPicture.asset(
                          moodPath,
                          colorFilter: ColorFilter.mode(
                            AppColors.emojiColor,
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          moodName,
                          style: TextStyle(
                            fontFamily: 'Dongle',
                            fontSize: 22,
                            height: 1.0,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textoOscuro,
                          ),
                        ),
                      ),
                      Text(
                        '$count ($percentStr%)',
                        style: TextStyle(
                          fontFamily: 'Dongle',
                          fontSize: 20,
                          height: 1.0,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textoOscuro.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      height: 10,
                      color: AppColors.fondoSoft.withValues(alpha: 0.7),
                      child: TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0.0, end: percentage),
                        duration: const Duration(milliseconds: 600),
                        curve: Curves.easeOutCubic,
                        builder: (context, value, _) {
                          return FractionallySizedBox(
                            alignment: Alignment.centerLeft,
                            widthFactor: value.clamp(0.0, 1.0),
                            child: Container(
                              decoration: BoxDecoration(
                                color: AppColors.rosaFuerte,
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
