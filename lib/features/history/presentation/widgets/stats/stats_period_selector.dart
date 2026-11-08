import 'package:flutter/material.dart';
import 'package:cozy_feels_app/core/theme/app_colors.dart';
import 'package:cozy_feels_app/features/history/domain/services/stats_service.dart';
import 'package:cozy_feels_app/l10n/app_localizations.dart';

class StatsPeriodSelector extends StatelessWidget {
  final StatsPeriod selectedPeriod;
  final ValueChanged<StatsPeriod> onPeriodChanged;

  const StatsPeriodSelector({
    super.key,
    required this.selectedPeriod,
    required this.onPeriodChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final periods = [
      (StatsPeriod.week, l10n.stats_period_week),
      (StatsPeriod.month, l10n.stats_period_month),
      (StatsPeriod.allTime, l10n.stats_period_all),
    ];

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.naranjaPiel.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.rosaFuerte.withValues(alpha: 0.25),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: periods.map((item) {
          final isSelected = item.$1 == selectedPeriod;
          return GestureDetector(
            onTap: () => onPeriodChanged(item.$1),
            behavior: HitTestBehavior.opaque,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.rosaFuerte
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: AppColors.rosaFuerte.withValues(alpha: 0.3),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: Text(
                item.$2,
                style: TextStyle(
                  fontFamily: 'Dongle',
                  fontSize: 22,
                  height: 1.0,
                  fontWeight:
                      isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected
                      ? Colors.white
                      : AppColors.textoOscuro.withValues(alpha: 0.8),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
