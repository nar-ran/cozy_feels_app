import 'package:flutter/material.dart';
import 'package:cozy_feels_app/core/theme/app_colors.dart';
import 'package:cozy_feels_app/l10n/app_localizations.dart';

class StatsEmptyView extends StatelessWidget {
  const StatsEmptyView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
        child: Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: AppColors.naranjaPiel.withValues(alpha: 0.45),
            borderRadius: BorderRadius.circular(32),
            border: Border.all(
              color: AppColors.rosaFuerte.withValues(alpha: 0.3),
              width: 1.5,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppColors.fondoSoft,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.rosaFuerte.withValues(alpha: 0.35),
                    width: 2,
                  ),
                ),
                child: Icon(
                  Icons.auto_graph_rounded,
                  size: 42,
                  color: AppColors.rosaFuerte,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                l10n.stats_empty_title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Dongle',
                  fontSize: 28,
                  height: 1.0,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textoOscuro,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.stats_empty_subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  height: 1.3,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textoOscuro.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
