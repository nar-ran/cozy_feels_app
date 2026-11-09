import 'package:flutter/material.dart';
import 'package:cozy_feels_app/core/theme/app_colors.dart';
import 'package:cozy_feels_app/features/history/domain/entities/app_tag.dart';
import 'package:cozy_feels_app/l10n/app_localizations.dart';

class TopTagsCard extends StatelessWidget {
  final List<MapEntry<String, int>> topTags;

  const TopTagsCard({
    super.key,
    required this.topTags,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

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
                  Icons.label_outline_rounded,
                  color: AppColors.rosaFuerte,
                  size: 24,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                l10n.stats_top_tags,
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
          if (topTags.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                l10n.stats_no_tags,
                style: TextStyle(
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                  color: AppColors.textoOscuro.withValues(alpha: 0.6),
                ),
              ),
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: topTags.map((entry) {
                final tagId = entry.key;
                final count = entry.value;
                final icon = AppTag.getIconForTag(tagId);
                final label = AppTag.getLabelForTag(tagId, l10n);

                return Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.fondoSoft,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: AppColors.rosaFuerte.withValues(alpha: 0.35),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.rosaFuerte.withValues(alpha: 0.08),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(icon, size: 16, color: AppColors.rosaFuerte),
                      const SizedBox(width: 6),
                      Text(
                        label,
                        style: TextStyle(
                          fontFamily: 'Dongle',
                          fontSize: 20,
                          height: 1.0,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textoOscuro,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.rosaFuerte.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '$count',
                          style: TextStyle(
                            fontFamily: 'Dongle',
                            fontSize: 16,
                            height: 1.0,
                            fontWeight: FontWeight.bold,
                            color: AppColors.rosaFuerte,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }
}
