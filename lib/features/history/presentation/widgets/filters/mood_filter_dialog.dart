import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cozy_feels_app/core/constants/app_assets.dart';
import 'package:cozy_feels_app/core/theme/app_colors.dart';
import 'package:cozy_feels_app/core/widgets/stroke_text.dart';
import 'package:cozy_feels_app/l10n/app_localizations.dart';

class MoodFilterDialog extends StatelessWidget {
  final String? currentMoodPath;
  final ValueChanged<String?> onMoodSelected;

  const MoodFilterDialog({
    super.key,
    required this.currentMoodPath,
    required this.onMoodSelected,
  });

  String _normalize(String path) {
    if (path.contains('/feelings/')) return path;
    return path.replaceAll('assets/icons/svg/', 'assets/icons/svg/feelings/');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final width = MediaQuery.of(context).size.width;
    final entries = AppAssets.sentimentEmojis.entries.toList();

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: AppColors.fondoSoft,
          borderRadius: BorderRadius.circular(32),
          border: Border.all(
            color: AppColors.rosaFuerte.withValues(alpha: 0.4),
            width: 1.5,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(Icons.mood_rounded, color: AppColors.rosaFuerte, size: 26),
                const SizedBox(width: 8),
                Expanded(
                  child: StrokeText(
                    text: l10n.history_filter_select_mood,
                    fontSize: width * 0.07,
                    color: AppColors.rosaFuerte,
                    strokeColor: AppColors.strokeColor,
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.close_rounded,
                    color: AppColors.textoOscuro.withValues(alpha: 0.7),
                  ),
                  onPressed: () => Navigator.pop(context),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Flexible(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  alignment: WrapAlignment.center,
                  children: entries.map((entry) {
                    final moodPath = entry.value;
                    final isSelected = currentMoodPath != null &&
                        _normalize(currentMoodPath!) == _normalize(moodPath);

                    return GestureDetector(
                      onTap: () {
                        if (isSelected) {
                          onMoodSelected(null);
                        } else {
                          onMoodSelected(moodPath);
                        }
                        Navigator.pop(context);
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        width: 54,
                        height: 54,
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.rosaFuerte.withValues(alpha: 0.25)
                              : AppColors.naranjaPiel.withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.rosaFuerte
                                : AppColors.rosaFuerte.withValues(alpha: 0.3),
                            width: isSelected ? 2.2 : 1,
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: AppColors.rosaFuerte
                                        .withValues(alpha: 0.25),
                                    blurRadius: 6,
                                  ),
                                ]
                              : null,
                        ),
                        child: SvgPicture.asset(
                          moodPath,
                          colorFilter: ColorFilter.mode(
                            AppColors.emojiColor,
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (currentMoodPath != null)
              OutlinedButton.icon(
                onPressed: () {
                  onMoodSelected(null);
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.clear_rounded, size: 18),
                label: Text(
                  l10n.history_filter_clear,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.rosaFuerte,
                  side: BorderSide(
                    color: AppColors.rosaFuerte.withValues(alpha: 0.5),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
