import 'package:flutter/material.dart';
import 'package:cozy_feels_app/core/theme/app_colors.dart';
import 'package:cozy_feels_app/core/theme/app_palettes.dart';
import 'package:cozy_feels_app/core/theme/theme_controller.dart';
import 'package:cozy_feels_app/core/widgets/stroke_text.dart';
import 'package:cozy_feels_app/l10n/app_localizations.dart';

class ThemeSelectorDialog extends StatelessWidget {
  const ThemeSelectorDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final width = MediaQuery.of(context).size.width;
    final themeController = ThemeController.instance;

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 30, vertical: 24),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 24),
        decoration: BoxDecoration(
          color: AppColors.fondoSoft,
          borderRadius: BorderRadius.circular(35),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            StrokeText(
              text: l10n.theme_dialog_title,
              fontSize: width * 0.08,
              color: AppColors.rosaFuerte,
              strokeColor: AppColors.strokeColor,
            ),
            const SizedBox(height: 18),
            Flexible(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: ListenableBuilder(
                  listenable: themeController,
                  builder: (context, _) {
                    final currentId = themeController.currentThemeId;

                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: AppPalettes.all.values.map((palette) {
                        final isSelected = palette.id == currentId;

                        return GestureDetector(
                          onTap: () {
                            themeController.setTheme(palette.id);
                          },
                          child: Container(
                            margin: const EdgeInsets.symmetric(vertical: 6),
                            padding: const EdgeInsets.symmetric(
                                vertical: 12, horizontal: 16),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.naranjaPiel
                                  : AppColors.naranjaPiel.withValues(alpha: 0.65),
                              borderRadius: BorderRadius.circular(22),
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.rosaFuerte
                                    : AppColors.rosaFuerte.withValues(alpha: 0.3),
                                width: isSelected ? 2.5 : 1.0,
                              ),
                            ),
                            child: Row(
                              children: [
                                // Theme name
                                Expanded(
                                  child: Text(
                                    palette.getLocalizedName(l10n),
                                    style: TextStyle(
                                      fontFamily: 'Dongle',
                                      fontSize: 26,
                                      fontWeight: isSelected
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                      color: isSelected
                                          ? AppColors.rosaFuerte
                                          : AppColors.textoOscuro,
                                      height: 1.0,
                                    ),
                                  ),
                                ),

                                // 4 Color Preview Circles
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: palette.previewColors.map((c) {
                                    return Container(
                                      margin: const EdgeInsets.symmetric(horizontal: 2),
                                      width: 16,
                                      height: 16,
                                      decoration: BoxDecoration(
                                        color: c,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: palette.textoOscuro.withValues(alpha: 0.25),
                                          width: 1,
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),

                                const SizedBox(width: 8),

                                // Selected checkmark or placeholder
                                Icon(
                                  isSelected
                                      ? Icons.check_circle_rounded
                                      : Icons.circle_outlined,
                                  color: isSelected
                                      ? AppColors.rosaFuerte
                                      : AppColors.textoOscuro.withValues(alpha: 0.3),
                                  size: 22,
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 14),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                l10n.common_accept,
                style: TextStyle(
                  fontFamily: 'Dongle',
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textoOscuro,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
