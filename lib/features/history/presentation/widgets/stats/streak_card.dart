import 'package:flutter/material.dart';
import 'package:cozy_feels_app/core/theme/app_colors.dart';
import 'package:cozy_feels_app/l10n/app_localizations.dart';

class StreakCard extends StatelessWidget {
  final int currentStreak;
  final int bestStreak;

  const StreakCard({
    super.key,
    required this.currentStreak,
    required this.bestStreak,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final String motivational;
    if (currentStreak == 0) {
      motivational = l10n.stats_streak_motivational_zero;
    } else if (currentStreak >= 7) {
      motivational = l10n.stats_streak_motivational_great;
    } else {
      motivational = l10n.stats_streak_motivational_active;
    }

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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                      Icons.local_fire_department_rounded,
                      color: AppColors.rosaFuerte,
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    l10n.stats_streak_title,
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
              // Pill de récord histórico
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.fondoSoft,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.rosaFuerte.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.emoji_events_outlined,
                      size: 16,
                      color: AppColors.rosaFuerte,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${l10n.stats_streak_record}: ${l10n.stats_streak_days(bestStreak)}',
                      style: TextStyle(
                        fontFamily: 'Dongle',
                        fontSize: 18,
                        height: 1.0,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textoOscuro,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '$currentStreak',
                style: TextStyle(
                  fontFamily: 'Dongle',
                  fontSize: 54,
                  height: 0.9,
                  fontWeight: FontWeight.bold,
                  color: AppColors.rosaFuerte,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                l10n.stats_streak_days(currentStreak),
                style: TextStyle(
                  fontFamily: 'Dongle',
                  fontSize: 28,
                  height: 1.0,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textoOscuro.withValues(alpha: 0.75),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            motivational,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.textoOscuro.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }
}
